service "ssh" do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true, :start => true, :stop => true
end

cookbook_file "/etc/ssh/sshd_config" do
  source "sshd_config"
  mode "0644"
  notifies :restart, resources(:service => "ssh")
end

service "ssh" do
  provider Chef::Provider::Service::Upstart
  action [:enable, :start]
end