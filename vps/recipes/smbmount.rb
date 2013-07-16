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

directory "/mnt/line_drawings" do
  owner node[:unicorn][:user]
  group node[:unicorn][:group]
  mode "0755"
  action :create
end

#mount -t cifs -o credentials=/root/.smbcredentials,uid=unicorn,gid=unicorn //npi-bignas/YDrive/1art/line_drawings /mnt/line_drawings
mount "/mnt/line_drawings" do
  device "//#{node[:smb][:image_server] }/YDrive/1art/line_drawings"
  fstype "cifs"
  options "credentials=/root/.smbcredentials,uid=#{node[:unicorn][:user]},gid=#{node[:unicorn][:group]}"
  dump 0
  pass 0
  action [:mount, :enable]
end

directory "/mnt/labels" do
  owner node[:unicorn][:user]
  group node[:unicorn][:group]
  mode "0755"
  action :create
end

#mount -t cifs -o credentials=/root/.smbcredentials,uid=unicorn,gid=unicorn //thor/loftware$/LABELS /mnt/labels
mount "/mnt/labels" do
  device "//#{node[:smb][:label_server]}/loftware$/LABELS"
  fstype "cifs"
  options "credentials=/root/.smbcredentials,uid=#{node[:unicorn][:user]},gid=#{node[:unicorn][:group]}"
  dump 0
  pass 0
  action [:mount, :enable]
end

#mount -t cifs -o credentials=/root/.smbcredentials,uid=unicorn,gid=unicorn //zeus/Vdrive/Visual/VMFG/WDDrop /mnt/loftware
mount "/mnt/loftware" do
  device "//#{node[:smb][:print_server]}/Vdrive/Visual/VMFG/WDDrop"
  fstype "cifs"
  options "credentials=/root/.smbcredentials,uid=#{node[:unicorn][:user]},gid=#{node[:unicorn][:group]}"
  dump 0
  pass 0
  action [:mount, :enable]
end

directory "/mnt/loftware" do
  owner node[:unicorn][:user]
  group node[:unicorn][:group]
  mode "0755"
  action :create
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