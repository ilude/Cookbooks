package "python-software-properties"

execute "add-apt-repository" do
  command "add-apt-repository ppa:nginx/stable && apt-get update"
  action :run
  not_if "test -f /etc/apt/sources.list.d/nginx-stable-*.list"
end

package "nginx"

execute "rm-init.d" do
  command "update-rc.d -f nginx remove && rm /etc/init.d/nginx"
  action :run
  only_if "test -f /etc/init.d/nginx"
end

service "nginx" do
  provider Chef::Provider::Service::Upstart
#  subscribes :restart
  supports :status => true, :restart => true, :start => true, :stop => true
end

template "/etc/init/nginx.conf" do
  source "upstart.nginx.conf"
  owner "root"
  group "root"
  mode "0644"
#  notifies :restart, resources(:service => "nginx")
end

#service "nginx" do
#  action [:enable, :start]
#end

