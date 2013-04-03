require 'chefspec'

describe 'postgres::centos' do
  let (:chef_run) { ChefSpec::ChefRunner.new.converge 'postgres::centos' }
  it 'should install postgreSQL repository' do
    chef_run.should execute_command "rpm -Uvh http://yum.postgresql.org/9.1/redhat/rhel-6-x86_64/pgdg-redhat91-9.1-5.noarch.rpm"
  end
  
  ["postgresql91","postgresql91-server"].each do |package|
    it "should install #{package}" do
      chef_run.should install_package package
    end
  end
  
  it 'should create file /var/lib/pgsql/9.1/data/postgresql.conf with owner postgres and mode 0600'do
    chef_run.cookbook_file('/var/lib/pgsql/9.1/data/postgresql.conf').should be_owned_by('postgres','postgres')
    chef_run.cookbook_file('/var/lib/pgsql/9.1/data/postgresql.conf').mode.should == "0600"
    chef_run.cookbook_file('/var/lib/pgsql/9.1/data/postgresql.conf').source.should == "postgresql.conf"
    chef_run.cookbook_file('/var/lib/pgsql/9.1/data/postgresql.conf').should notify("service[postgresql]",:restart)
  
  end

  it 'should create file /var/lib/pgsql/9.1/data/pg_hba.conf with owner postgres and mode 0600' do
    chef_run.template('/var/lib/pgsql/9.1/data/pg_hba.conf').should be_owned_by("postgres","postgres")
    chef_run.template('/var/lib/pgsql/9.1/data/pg_hba.conf').mode.should == "0600"
    chef_run.template('/var/lib/pgsql/9.1/data/pg_hba.conf').source.should == "pg_hba.conf.erb"
    chef_run.template('/var/lib/pgsql/9.1/data/pg_hba.conf').should notify("service[postgresql]",:restart)
  end
  
  it 'should intialize postgres db' do
    chef_run.should execute_command "service postgresql initdb"
  end 
  
  it 'should enable service postgresql' do
    chef_run.should set_service_to_start_on_boot "postgresql"
  end
  
  it 'should start service postgresql' do
    chef_run.should start_service "postgresql"
  end
end
