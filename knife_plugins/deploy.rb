module KnifePlugins

  class DeployAggregate < Chef::Knife
    banner 'knife hcah deploy aggregate'

    APPS = []
    APIS = []
    ALL_APPS = APPS | APIS

    option :build_no,
      :long => '--build-no BUILD_NO',
      :description => 'Aggregate app build number'

    option :deploy_environment,
      :long => '--env  ENVIRONMENT',
      :description => 'Environment to deploy build on'

    deps do
      require 'chef/search/query'
      require 'chef/knife/ssh'
      Chef::Knife::Ssh.load_deps
    end

    def run
      if !valid_options or !valid_env
        ui.fatal 'Please provide build number and env name to deploy' +
          'e.g. APP_HOME=/path/to/app/home [JENKINS_HOST=http://jenkin_url/job/job_name] [S3_BUCKET=s3://s3_bucket/] knife deploy aggregate --build-no 59 --env qa'
        exit 1
      end

      @build_number = config[:build_no]
      @env = config[:deploy_environment]
      @app_name = "aggregate"
      @jenkins_host = ENV['JENKINS_HOST']
      @s3_bucket = ENV['S3_BUCKET']
      @app_home = ENV['APP_HOME']

      app_nodes = deploy_on_env(@env)
      if app_nodes.nil?
        ui.msg "No app server nodes found for environment #{@env}"
        exit 1
      end

      app_nodes.each do |app_node|
        if app_node.include?("ec2")
          node_id = app_node.ec2.public_hostname
        else
          node_id = app_node.ipaddress
        end
        ui.msg '-'*80
        ui.msg "Starting deploy of build #{@build_number} on #{node_id}"
        ui.msg '-'*80
        ui.msg cmd=deploy_command(app_node) 
        knife_ssh(node_id, cmd).run
      end
    end

    private

    def deploy_on_env env
      query = "chef_environment:#{env} AND roles:app_server"
      query_nodes = Chef::Search::Query.new
      app_servers = query_nodes.search('node', query)
      return app_servers[0] if app_servers[0].size > 0
    end

    def valid_options
      true if option_present(:build_no) && option_present(:deploy_environment)
    end

    def option_present option
      !config[option].nil? && !config[option].strip.empty?
    end

    def valid_env
      true if (env_present('JENKINS_HOST') && env_present('APP_HOME') || env_present('S3_BUCKET') && env_present('APP_HOME'))
    end

    def env_present variable
      !ENV[variable].nil? && !ENV[variable].strip.empty?
    end

    def deploy_command app_node
      command_string = "rm -f /tmp/deploy.sh;"
      cmd = ["set -e",cd_to_app_home,load_env, manifest_backup, pre_deploy_cleanup, copy_artifact(@env), extract_artifact,
        post_deploy_cleanup, post_deploy_env_config, post_deploy_mongoid_config, post_deploy_newrelic(app_node), post_deploy_db_seed,
        cd_to_app_home, restart_passenger].compact.join(';')
      command_string += "echo '#{cmd}' >> /tmp/deploy.sh;"
      command_string += "sh /tmp/deploy.sh"
    end

    def cd_to_app_home
      "cd #{@app_home}"
    end

    def load_env
      "export RAILS_ENV=production; export RACK_ENV=production"
    end

    def manifest_backup
      'if [ -f manifest.txt ]; then mv -f manifest.txt manifest.old; fi'
    end

    def pre_deploy_cleanup
      ALL_APPS.collect do |app|
        "rm -rf #{app}"
      end.join(';')
    end

    def copy_artifact env
      if env.include?("aws") 
        "s3cmd get #{@s3_bucket}/#{@build_number}/aggregate.tar.gz" 
      else
        "wget #{@jenkins_host}/#{@build_number}/artifact/#{@app_name}.tar.gz -O #{@app_name}.tar.gz"
      end
    end

    def extract_artifact
      "echo 'extracting aggregate archive to #{@app_home}'; tar -zxf #{@app_name}.tar.gz"
    end

    def post_deploy_env_config
      (APPS+APIS).collect do |app|
        "ln -s #{@app_home}/config/#{app}.env_config.yml #{@app_home}/#{app}/config/env_config.yml"
      end.join(';')
    end

    def post_deploy_newrelic app_node
      return unless app_node.newrelic
      (APPS+APIS).collect do |app|
        "ln -s #{@app_home}/config/#{app}.newrelic.yml #{@app_home}/#{app}/config/newrelic.yml"
      end.join(';')
    end

    def post_deploy_mongoid_config
      APIS.collect do |api|
        "ln -s #{@app_home}/config/#{api}.mongoid.yml #{@app_home}/#{api}/config/mongoid.yml"
      end.join(';')
    end

    def post_deploy_db_seed
      APIS.collect do |api|
        "cd  #{@app_home}/#{api}; RACK_ENV=production bundle exec rake db:seed"
      end.join(';')
    end

    def post_deploy_cleanup
      "rm -f #{@app_name}.tar.gz"
    end

    def restart_passenger
      cmd = 'echo restarting passenger worker processes for apps;'
      cmd += ALL_APPS.collect do |app|
        "touch #{app}/tmp/restart.txt"
      end.join(';')
    end

    def knife_ssh server_name, ssh_command
      ssh = Chef::Knife::Ssh.new
      ssh.ui = ui
      ssh.name_args = [ server_name, ssh_command]
      ssh.config[:manual] =  true
      ssh.config[:ssh_user] =  'user'
      ssh.config[:identity_file] = Chef::Config[:identity_file]
      ssh.config[:on_error] = :raise
      ssh
    end
  end
end
