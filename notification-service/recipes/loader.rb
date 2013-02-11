service "notification-loader" do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true, :start => true, :stop => true, :reload => true
end

template "notification-loader.conf" do
  path "/etc/init/notification-loader.conf"
  source "upstart.notification-loader.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
    :app_name => app_name
  )
  notifies :restart, resources(:service => "notification-loader")
end

service "notification-loader" do
  provider Chef::Provider::Service::Upstart
  action [:enable, :start]
end