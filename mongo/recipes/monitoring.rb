package "pymongo"

script "Download and install mms-agent" do
  interpreter "bash"
  user "root"
  group "root"
  cwd "/opt"
  code <<-EOH
    cd /opt
    wget https://mms.10gen.com/settings/mmsAgent/3c14add1a9b2a0f353e9746d2bbdfa8a/10gen-mms-agent-Hcah_India.tar.gz --no-check-certificate
    tar -xvf 10gen-mms-agent-Hcah_India.tar.gz
  EOH
  not_if "test -f /opt/mms-agent/agent.py"
  action :run
end

execute "start_mms_agent" do
  command "nohup python /opt/mms-agent/agent.py > /var/log/mongo/mms-agent.log 2>&1 &"
  action :run
  not_if "test -f /var/log/mongo/mms-agent.log"
end
