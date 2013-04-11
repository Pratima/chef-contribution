module KnifePlugins

  class MongoDump < Chef::Knife
    banner 'knife mongo dump'
    
    DBS = []
    
    option :db_env,
      :long => '--db-env DB_ENV',
      :description => 'Environment to take the dump from'

    deps do
      require 'chef/search/query'
   end

    def run
      @env = config[:db_env]
      @s3_bucket = ENV['S3_BUCKET']

     if !valid_env(@env)
        ui.fatal 'Please provide environment name' +
          ' e.g. knife mongo dump --db-env ft'
        exit 1
      end

      db_nodes = db_node_search(@env)
      if db_nodes.nil?
        ui.msg "No db server nodes found for environment #{@env}"
        exit 1
      end

      db_nodes.each do |db_node|
        if db_node.include?("ec2")
          node_id = db_node.ec2.local_hostname
        else
          node_id = db_node.ipaddress
        end
        
        if node_id == db_node.database.replica.mongo_primary.split(":")[0]
          @db_primary = node_id
          @db_port = db_node.database.replica.mongo_primary.split(":")[1]
        end
      end
      ui.msg '-'*80
      ui.msg "Starting mongo dump of build on #{@db_primary}"
      ui.msg '-'*80
      ui.msg cmd=dbdump_command(@db_primary, @db_port, @env) 
      %x[#{cmd}]
    end

    private

    def db_node_search env
      query = "chef_environment:#{env} AND roles:db_server"
      query_nodes = Chef::Search::Query.new
      db_servers = query_nodes.search('node', query)
      return db_servers[0] if db_servers[0].size > 0
    end

    def valid_env env
      true if !env.nil? && !env.strip.empty?
    end

     def dbdump_command db_host, db_port, env
      dump_dir = "/opt/mongo_backup/#{env}-mongodump-$timestamp"
      
      db_creds = load_databag(env)
      cmd = "set -e; timestamp=$(date +'%Y%m%d%H%M');"

      DBS.collect do |db|
        cmd += "mongodump --host #{db_host} --port #{db_port} -u #{db_creds['database']['user']} -p#{db_creds['database']['passwd']} -d #{db} --out #{dump_dir};"
      end.join(';')

      db_dump_cmd_str = "rm -f /tmp/db_dump.sh;"

      if !@s3_bucket.nil? && !@s3_bucket.strip.empty?
        cmd += "s3cmd sync --force #{dump_dir} #{@s3_bucket}"
      end
      
      db_dump_cmd_str += "echo '#{cmd}' > /tmp/db_dump.sh;"
      db_dump_cmd_str += 'sh /tmp/db_dump.sh;'
    end
    
    def load_databag env
      db_secret = Chef::EncryptedDataBagItem.load_secret('/etc/chef/encrypted_data_bag_secret')
      db_creds = Chef::EncryptedDataBagItem.load('secret_data', env, db_secret)
      db_creds
    end
  end
end
