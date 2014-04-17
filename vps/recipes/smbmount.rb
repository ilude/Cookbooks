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

def create_mount(local_path, remote_path)
  directory local_path do
    owner node[:unicorn][:user]
    group node[:unicorn][:group]
    mode "0755"
    recursive true
    action :create
  end

  mount local_path do
    device remote_path
    fstype "cifs"
    options "credentials=/root/.smbcredentials,uid=#{node[:unicorn][:user]},gid=#{node[:unicorn][:group]}"
    dump 0
    pass 0
    action [:mount, :enable]
  end
end

#mount -t cifs -o credentials=/root/.smbcredentials,uid=unicorn,gid=unicorn //npi-bignas/YDrive/1art/line_drawings /mnt/line_drawings
create_mount "/mnt/line_drawings", "//#{node[:smb][:image_server] }/YDrive/1art/line_drawings"

#mount -t cifs -o credentials=/root/.smbcredentials,uid=unicorn,gid=unicorn //thor/loftware$/LABELS /mnt/labels
create_mount "/mnt/labels", "//#{node[:smb][:label_server]}/loftware$/LABELS"

#mount -t cifs -o credentials=/root/.smbcredentials,uid=unicorn,gid=unicorn //zeus/Vdrive/Visual/VMFG/WDDrop /mnt/loftware
create_mount "/mnt/loftware", "//#{node[:smb][:print_server]}/Vdrive/Visual/VMFG/WDDrop"

#mount -t cifs -o credentials=/root/.smbcredentials,uid=unicorn,gid=unicorn //npi-bignas/YDrive/VPS/Dropbox /mnt/dropbox
create_mount "/mnt/dropbox", "//#{node[:smb][:image_server]}/YDrive/VPS/Dropbox"

create_mount "#{node[:unicorn][:apps_dir]}/vps/public/images/parts", "//#{node[:smb][:image_server]}/YDrive/images_part"

create_mount "#{node[:unicorn][:apps_dir]}/vps/public/images/locations", "//#{node[:smb][:image_server]}/YDrive/images_location"

create_mount "/mnt/part_files", "//#{node[:smb][:image_server]}/ydrive/VPS/PartFiles"