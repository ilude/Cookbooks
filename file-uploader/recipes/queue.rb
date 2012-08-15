include_recipe "resque"

service "mailservice.queue" do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true, :start => true, :stop => true, :reload => true
end

template "mailservice.queue.conf" do
  path "/etc/init/mailservice.queue.conf"
  source "upstart.mailservice.queue.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "mailservice.queue")
end

service "mailservice.queue" do
  provider Chef::Provider::Service::Upstart
  action [:enable, :start]
end