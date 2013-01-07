#
# Cookbook Name:: xvfb
# Recipe:: default
#
# Copyright 2011, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute

#xorg-x11-drivers
#   xorg-x11-server-Xorg
#   xorg-x11-xauth
#   xorg-x11-xinit
# Default Packages:
#   firstboot
#   glx-utils
#   hal
#   plymouth-system-theme
#   wacomexpresskeys
#   xorg-x11-server-utils
#   xorg-x11-utils
#   xvattr



["xorg-x11-server-Xvfb", "xorg-x11-server-Xorg", "xorg-x11-xauth", "xorg-x11-xinit","firstboot", "glx-utils", "hal","wacomexpresskeys","xorg-x11-server-utils","xorg-x11-utils","xvattr", "x11vnc", "dbus-x11" ].each do |pkg|

   package pkg do
	action :install
   end

end
