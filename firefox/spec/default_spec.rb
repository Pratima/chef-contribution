require 'chefspec'

describe 'firefox::default' do
  let (:chef_run) { ChefSpec::ChefRunner.new do |node|
		
	node.automatic_attrs[:languages]={ :ruby =>{ :bin_dir=>"/xxx"} , :gems_dir => '/fake/'}
	node['chef_packages']= { 'chef' => {'version'=>'1.0'}}
	node['cpu']={'total'=>'2'}
	node.automatic_attrs[:platform] = 'centos'	
	node.automatic_attrs[:platform_version] = '6.0'	
	end.converge 'firefox::default' }


   %w{dbus-x11 firefox libXrandr abyssinica-fonts cjkuni-uming-fonts dejavu-sans-fonts dejavu-sans-mono-fonts dejavu-serif-fonts jomolhari-fonts khmeros-base-fonts kurdit-unikurd-web-fonts liberation-mono-fonts liberation-sans-fonts liberation-serif-fonts lklug-fonts lohit-assamese-fonts lohit-bengali-fonts lohit-devanagari-fonts lohit-gujarati-fonts lohit-kannada-fonts lohit-oriya-fonts lohit-punjabi-fonts lohit-tamil-fonts lohit-telugu-fonts madan-fonts paktype-naqsh-fonts paktype-tehreer-fonts sil-padauk-fonts smc-meera-fonts stix-fonts thai-scalable-waree-fonts tibetan-machine-uni-fonts un-core-dotum-fonts vlgothic-fonts wqy-zenhei-fonts aajohan-comfortaa-fonts bitmap-fixed-fonts bitmap-lucida-typewriter-fonts cjkuni-fonts-ghostscript freefont}.each do |pkg|
    it "should install firefox #{pkg}" do
      chef_run.should install_package pkg
    end
  end

  it 'should add dbus-launch to firefox startup' do
    chef_run.should execute_command "sed -i 's/exec $MOZ_LAUNCHER/exec dbus-launch $MOZ_LAUNCHER/g' /usr/bin/firefox"
  end
end
