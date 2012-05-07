include_recipe "unicorn"

gem_package "resque"

app_name = node[:resque_web][:app_name]

service app_name do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true, :start => true, :stop => true, :reload => true
end

%w{tmp/sockets tmp/pids log}.each do |dir|
   directory "#{node[:unicorn][:apps_dir]}/#{app_name}/#{dir}" do
      mode "0775"
      owner node[:unicorn][:user]
      group node[:unicorn][:group]
      action :create
      recursive true
   end
end

template "server.#{app_name}.conf" do
  path "#{node[:nginx][:dir]}/apps/server.#{app_name}.conf"
  source "nginx.server.#{app_name}.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :reload, resources(:service => "nginx")
end

template "config.ru" do
  path "#{node[:unicorn][:apps_dir]}/#{app_name}/config.ru"
  source "config.ru.erb"
  owner node[:unicorn][:user]
  group node[:unicorn][:group]
  mode "0644"
end

template "unicorn.rb" do
  path "#{node[:unicorn][:apps_dir]}/#{app_name}/unicorn.rb"
  source "unicorn.rb.erb"
  owner node[:unicorn][:user]
  group node[:unicorn][:group]
  mode "0644"
end

template "upstream.#{app_name}.conf" do
  path "#{node[:nginx][:dir]}/apps/upstream.#{app_name}.conf"
  source "nginx.upstream.#{app_name}.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :reload, resources(:service => "nginx")
end

template "#{app_name}.conf" do
  path "/etc/init/#{app_name}.conf"
  source "upstart.#{app_name}.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => app_name)
end

service app_name do
  provider Chef::Provider::Service::Upstart
  action [:enable, :start]
end