package "smbfs" do
  package_name value_for_platform(
    "ubuntu" => {
      "12.10" => "cifs-utils"
    },
    "default" => "smbfs"
  )
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
  device "//#{node[:smb][:print_server]}/Vdrive/Visual/VMFG/WDDrop"
  fstype "cifs"
  options "credentials=/root/.smbcredentials,uid=#{node[:unicorn][:user]},gid=#{node[:unicorn][:group]}"
  dump 0
  pass 0
  action [:mount, :enable]
end

["#{node[:unicorn][:apps_dir]}/vps/public/images/parts", "#{node[:unicorn][:apps_dir]}/vps/public/images/locations"].each do |path|
  directory path do
    owner node[:unicorn][:user]
    group node[:unicorn][:group]
    mode 0755
    recursive true
    action :create
  end
end

mount "#{node[:unicorn][:apps_dir]}/vps/public/images/parts" do
  device "//#{node[:smb][:image_server]}/YDrive/images_part"
  fstype "cifs"
  options "credentials=/root/.smbcredentials,uid=#{node[:unicorn][:user]},gid=#{node[:unicorn][:group]}"
  dump 0
  pass 0
  action [:mount, :enable]
end

mount "#{node[:unicorn][:apps_dir]}/vps/public/images/locations" do
  device "//#{node[:smb][:image_server]}/YDrive/images_location"
  fstype "cifs"
  options "credentials=/root/.smbcredentials,uid=#{node[:unicorn][:user]},gid=#{node[:unicorn][:group]}"
  dump 0
  pass 0
  action [:mount, :enable]
end