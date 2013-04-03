Chef::Log.info '-'*50
Chef::Log.info "Setting up user auth for mongo"
Chef::Log.info '-'*50

hcah_bag_item = Chef::EncryptedDataBagItem.load("hcah_secret_data", node.chef_environment)
raise "Can't load #{node.chef_environment} env databag" if hcah_bag_item.nil? or hcah_bag_item["database"].nil?

mongo_user=hcah_bag_item["database"]["user"]
mongo_password=hcah_bag_item["database"]["passwd"]
mongo_replica = node[:database][:replica]

if mongo_replica.nil?
  is_mongo_primary = true
  mongo_primary_host =node[:database][:host]
else
  mongo_primary_host = mongo_replica[:mongo_primary]
  if node.include?("ec2")
    is_mongo_primary = (mongo_primary_host.split(':').first == node.ec2.local_hostname) 
  else
    is_mongo_primary = (mongo_primary_host.split(':').first == node.ipaddress)
  end
end

if is_mongo_primary
  service "mongod" do
    supports :restart => true
    action [:enable, :start]
  end

  execute "creating admin user on #{mongo_primary_host}" do
    command "mongo admin --eval \"rs.slaveOk();db.addUser(\'#{mongo_user}\', \'#{mongo_password}\')\""
    only_if "echo \"db.system.users.find({'user':'#{mongo_user}'}).count() == 0\" | mongo admin | grep true"
  end

  node[:api][:names].keys.each do |database|
    execute "creating users on #{database}" do
      auth_str = "--host #{mongo_primary_host} -u #{mongo_user} -p #{mongo_password}"
      cmd = %W(mongo #{auth_str}
             admin --eval
             \"rs.slaveOk();db.getSiblingDB(\'#{database}\').addUser(\'#{mongo_user}\', \'#{mongo_password}\')\").join("\s")
     command cmd
     only_if "echo \"db.getSiblingDB('#{database}').system.users.find().count({'user':'#{mongo_user}'}) == 0\" | mongo #{auth_str} admin | grep true"
    end
  end
end
