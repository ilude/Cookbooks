include_recipe "unicorn"

app_name = "vps"

gem_package "rails"

#### Begin Loftware Setup #### 

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
  options "credentials=/root/.smbcredentials"
  dump 0
  pass 0
  action [:mount, :enable]
end

mount "/apps/vps/public/images/parts" do
  device "//npi-bignas/YDrive/images_parts"
  fstype "cifs"
  options "credentials=/root/.smbcredentials"
  dump 0
  pass 0
  action [:mount, :enable]
end

mount "/apps/vps/public/images/locations" do
  device "//npi-bignas/YDrive/images_locations"
  fstype "cifs"
  options "credentials=/root/.smbcredentials"
  dump 0
  pass 0
  action [:mount, :enable]
end

#### End Loftware Setup #### 

service app_name do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true, :start => true, :stop => true, :reload => true
end

host = "bitbucket.org"
repo = "git@#{host}:ilude/vps.git"
known_hosts = "/root/.ssh/known_hosts"

directory "/root/.ssh" do
  owner "root"
  group "root"
  mode "0700"
  action :create
end

execute "add_known_host" do
  command "ssh-keyscan -t rsa #{host} >> #{known_hosts}"
  not_if { File.exists?(known_hosts) && File.read(known_hosts).include?(host) }
end

git "#{node[:unicorn][:apps_dir]}/#{app_name}" do
  repository repo
  reference "master"
  action :sync
end

execute "unicorn_owns_apps" do
  command "chown -R #{node[:unicorn][:user]}:#{node[:unicorn][:group]} #{node[:unicorn][:apps_dir]}/#{app_name}"
  action :run
end

execute "bundler" do
  command "bundle install"
  cwd File.join(node[:unicorn][:apps_dir], app_name)
  action :run
end

%w{tmp/sockets tmp/pids log public/data}.each do |dir|
   directory "#{node[:unicorn][:apps_dir]}/#{app_name}/#{dir}" do
      mode "0775"
      owner "#{node[:unicorn][:user]}"
      group "#{node[:unicorn][:group]}"
      action :create
      recursive true
   end
end

template "server.#{app_name}.conf" do
  path "#{node[:nginx][:dir]}/sites-available/#{app_name}"
  source "nginx.server.app.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
    :app_name => app_name
  )
  #notifies :reload, resources(:service => "nginx")
end

link "#{node[:nginx][:dir]}/sites-enabled/#{app_name}"  do
  to "#{node[:nginx][:dir]}/sites-available/#{app_name}"
  notifies :reload, resources(:service => "nginx")
end

template "#{app_name}.conf" do
  path "/etc/init/#{app_name}.conf"
  source "upstart.app.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
    :app_name => app_name
  )
  notifies :restart, resources(:service => app_name)
end

service app_name do
  provider Chef::Provider::Service::Upstart
  action [:enable, :start]
end

cron "clean-files" do
  hour "3"
  minute "0"
  command "find #{node[:unicorn][:apps_dir]}/#{app_name}/public/data/* -mtime +14 -exec rm {} \;"
end
