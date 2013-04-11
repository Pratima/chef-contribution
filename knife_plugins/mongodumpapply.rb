module KnifePlugins

  class MongoDumpApply < Chef::Knife
    banner 'knife mongo dump apply'
    
    option :db_env,
      :long => '--db-env DB_ENV',
      :description => 'Environment to apply the dump to'

     option :dump_dir,
      :long => '--dump-dir DUMP_DIR',
      :description => 'Full path to dump location'

   deps do
      require 'chef/search/query'
   end

    def run
      @dump_dir = config[:dump_dir]
      @env = config[:db_env]

     if !valid_option(@env) && !valid_option(@dump_dir)
        ui.fatal 'Please provide environment name and dump location' +
          ' e.g. knife mongo dump apply --db-env ft --dump-dir "/opt/mongo_backup/mongodump_201304131122"'
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
      ui.msg "Applying mongo dump of build on #{@db_primary}"
      ui.msg '-'*80
      ui.msg cmd=dbdumpapply_command(@db_primary, @db_port, @env, @dump_dir) 
      %x[#{cmd}]
    end

    private

    def db_node_search env
      query = "chef_environment:#{env} AND roles:hcah_db_server"
      query_nodes = Chef::Search::Query.new
      db_servers = query_nodes.search('node', query)
      return db_servers[0] if db_servers[0].size > 0
    end

    def valid_option option
      true if !option.nil? && !option.strip.empty?
    end

     def dbdump_command db_host, db_port, env, dump_dir
      
      db_creds = load_databag(env)

      cmd = "set -e; mongorestore --host #{db_host} --port #{db_port} --username #{db_creds['database']['user']} -p#{db_creds['database']['passwd']} #{@dump_dir};"

      db_dump_cmd_str = "rm -f /tmp/db_dump_apply.sh;"

      db_dump_cmd_str += "echo '#{cmd}' > /tmp/db_dump_apply.sh;"
      db_dump_cmd_str += 'sh /tmp/db_dump_apply.sh;'
    end
    
    def load_databag env
      db_secret = Chef::EncryptedDataBagItem.load_secret('/etc/chef/encrypted_data_bag_secret')
      db_creds = Chef::EncryptedDataBagItem.load('secret_data', env, db_secret)
      db_creds
    end
  end
end
