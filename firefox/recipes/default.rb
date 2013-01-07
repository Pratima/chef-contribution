#
# Cookbook Name:: firefox
# Recipe:: default
#
# Copyright 2011, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute

ff_pkg = case when node['platform_version'].to_f >= 6.0
   %w{dbus-x11 firefox libXrandr abyssinica-fonts cjkuni-uming-fonts dejavu-sans-fonts dejavu-sans-mono-fonts dejavu-serif-fonts jomolhari-fonts khmeros-base-fonts kurdit-unikurd-web-fonts liberation-mono-fonts liberation-sans-fonts liberation-serif-fonts lklug-fonts lohit-assamese-fonts lohit-bengali-fonts lohit-devanagari-fonts lohit-gujarati-fonts lohit-kannada-fonts lohit-oriya-fonts lohit-punjabi-fonts lohit-tamil-fonts lohit-telugu-fonts madan-fonts paktype-naqsh-fonts paktype-tehreer-fonts sil-padauk-fonts smc-meera-fonts stix-fonts thai-scalable-waree-fonts tibetan-machine-uni-fonts un-core-dotum-fonts vlgothic-fonts wqy-zenhei-fonts aajohan-comfortaa-fonts bitmap-fixed-fonts bitmap-lucida-typewriter-fonts cjkuni-fonts-ghostscript freefont}
else 
  %w{dbus-x11 firefox libXrandr}
end

ff_pkg.each do |pkg|
  package pkg do
    action :install
    ignore_failure true
  end
end

execute "Add dbus-launch to Firefox startup" do
  command "sed -i 's/exec $MOZ_LAUNCHER/exec dbus-launch $MOZ_LAUNCHER/g' /usr/bin/firefox"
  action :run
  not_if "grep 'exec dbus-launch $MOZ_LAUNCHER' /usr/bin/firefox"
end
