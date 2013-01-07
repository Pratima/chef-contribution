cron "run_chef_client" do
	command "chef-client -L /var/log/chef-client"
  	minute "30"
end
