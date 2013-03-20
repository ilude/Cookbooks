service "notification-scheduler" do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => false, :start => true, :stop => true, :reload => false
end

template "notification-scheduler-monitor.conf" do
  path "/etc/init/notification-scheduler-monitor.conf"
  source "notification-scheduler-monitor.conf.erb"
  owner "root"
  group "root"
  mode "0644"
end

template "notification-scheduler.conf" do
  path "/etc/init/notification-scheduler.conf"
  source "upstart.notification-scheduler.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "notification-scheduler")
end

service "notification-scheduler" do
  provider Chef::Provider::Service::Upstart
  action [:enable, :start]
end