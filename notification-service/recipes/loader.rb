service "notification-loader" do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true, :start => true, :stop => true, :reload => true
end

file "#{node['notification-service'][:app_dir]}/script/daemon" do
  owner node[:unicorn][:user]
  group node[:unicorn][:group]
  mode "0775"
end

template "notification-loader-monitor.conf" do
  path "/etc/init/notification-loader-monitor.conf"
  source "notification-loader-monitor.conf.erb"
  owner "root"
  group "root"
  mode "0644"
end

template "notification-loader.conf" do
  path "/etc/init/notification-loader.conf"
  source "upstart.notification-loader.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
    :app_name => node['notification-service'][:app_name] 
  )
  notifies :restart, resources(:service => "notification-loader")
end

service "notification-loader" do
  provider Chef::Provider::Service::Upstart
  action [:enable, :start]
end

execute "restart notification-loader" do
  command "service notification-loader restart"
  cwd File.join(node[:unicorn][:apps_dir], node['notification-service'][:app_name] )
  action :run
  only_if "ps cax | grep `cat tmp/pids/notification-loader.pids"
end