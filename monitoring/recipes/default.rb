include_recipe "bluepill"
include_recipe "redis"

gem_package "fnordmetric"

app_name = node[:monitoring][:app_name]

unless(node.attribute? :apps_dir) 
  include_attribute "default"
end

node.set[:monitoring][:app_dir] = File.join(node[:apps_dir], app_name)

# Create User, Group and application directories

group node[:monitoring][:group] do
  action :create
end

user node[:monitoring][:user] do
  #system true
  shell "/bin/bash"
  comment "#{node[:monitoring][:user]} user"
  home    "/home/#{node[:monitoring][:user]}"
  gid     node[:monitoring][:group]
  supports :manage_home => true
  action  :create
end

%w{tmp/sockets tmp/pids log}.each do |dir|
   directory File.join(node[:monitoring][:app_dir], dir) do
      mode "0775"
      owner node[:monitoring][:user]
      group node[:monitoring][:group]
      action :create
      recursive true
   end
end

template "Fnordmetric configuration" do
  path File.join(node[:monitoring][:app_dir], "#{app_name}.rb")
  source "app.rb.erb"
  owner node[:monitoring][:user]
  group node[:monitoring][:group]
  mode "0644"
  variables(
    :app_name => app_name
  )
end

template "BluePill #{node[:monitoring][:environment]} configuration" do
  path File.join(node[:monitoring][:app_dir], "#{node[:monitoring][:environment]}.pill")
  source "#{node[:monitoring][:environment]}.pill.erb"
  owner node[:monitoring][:user]
  group node[:monitoring][:group]
  mode "0644"
  variables(
    :app_name => app_name
  )
end

template "#{app_name}-notifier.conf" do
  path "/etc/init/#{app_name}-notifier.conf"
  source "upstart.app-notifier.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
    :app_name => app_name
  )
end

service app_name do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true, :start => true, :stop => true
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
