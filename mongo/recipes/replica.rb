Chef::Log.info '-'*50
Chef::Log.info "Starting Replica set node"
Chef::Log.info '-'*50

mongo_replica = node[:database][:replica]
if node.include?("ec2")
  is_mongo_primary = (mongo_replica[:mongo_primary].split(':').first == node.ec2.hostname)
else
  is_mongo_primary = (mongo_replica[:mongo_primary].split(':').first == node.ipaddress)
end

template "/etc/mongod.conf" do
  source "mongo_replica.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  variables({:is_replica_set => true, :auth_enabled => node[:database][:auth]})
end

service "mongod" do
  supports :restart => true
  action [:enable, :start]
end

if is_mongo_primary
  replica_setup_js = '/tmp/replica_setup.js'
  template replica_setup_js do
    source "replica_setup.js.erb"
    owner "root"
    group "root"
    mode '0755'
    variables({ :mongo_primary => mongo_replica[:mongo_primary],
                :mongo_nodes => mongo_replica[:members],
                :mongo_arbiter => mongo_replica[:arbiter],
                :mongo_replica_id => mongo_replica[:id]})
  end

  [mongo_replica[:mongo_primary],mongo_replica[:members]].flatten.each do |mongo_node|
    execute "wait for mongo on #{mongo_node} to come up" do
      command "retry_count=0;until echo 'exit' | mongo --host #{mongo_node} --quiet; do sleep 3s; let retry_count+=1; if [ $retry_count -ge 3 ]; then exit 1; fi; done"
    end
  end

  execute "setup replica set for #{mongo_replica[:mongo_primary]}" do
    command "/usr/bin/mongo < #{replica_setup_js};echo 'Waiting for replica to initialize';sleep 60s;"
    only_if "echo 'rs.status()' | mongo local --quiet | grep -q 'run rs.initiate'"
    Chef::Log.info "Replica set node initialized"
  end
end

