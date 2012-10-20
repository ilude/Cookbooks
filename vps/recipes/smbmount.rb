package "smbfs" do
  action :install
end

template ".smbcredentials" do
  path "/root/.smbcredentials"
  source "smbcredentials.erb"
  owner "root"
  group "root"
  mode "0600"
end

directory "/mnt/loftware" do
  owner node[:unicorn][:user]
  group node[:unicorn][:group]
  mode "0755"
  action :create
end

mount "/mnt/loftware" do
  device "//zeus/Vdrive/Visual/VMFG/WDDrop"
  fstype "cifs"
  options "credentials=/root/.smbcredentials,uid=#{node[:unicorn][:user]},gid=#{node[:unicorn][:group]}"
  dump 0
  pass 0
  action [:mount, :enable]
end

mount "#{node[:unicorn][:apps_dir]}/vps/public/images/parts" do
  device "//npi-bignas/YDrive/images_part"
  fstype "cifs"
  options "credentials=/root/.smbcredentials,uid=#{node[:unicorn][:user]},gid=#{node[:unicorn][:group]}"
  dump 0
  pass 0
  action [:mount, :enable]
end

mount "#{node[:unicorn][:apps_dir]}/vps/public/images/locations" do
  device "//npi-bignas/YDrive/images_location"
  fstype "cifs"
  options "credentials=/root/.smbcredentials,uid=#{node[:unicorn][:user]},gid=#{node[:unicorn][:group]}"
  dump 0
  pass 0
  action [:mount, :enable]
end