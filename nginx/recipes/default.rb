package "add-apt-repository" do
  package_name value_for_platform(
    "ubuntu" => {
      "12.10" => "software-properties-common"
    },
    "default" => "python-software-properties"
  )
end

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
  supports :status => true, :restart => true, :start => true, :stop => true, :reload => true
end

template "/etc/init/nginx.conf" do
  source "upstart.nginx.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "nginx")
end

template "nginx.conf" do
  path "#{node[:nginx][:dir]}/nginx.conf"
  source "nginx.conf.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :restart, resources(:service => "nginx")
end

# template "default-site" do
#   path "#{node[:nginx][:dir]}/sites-available/default-site"
#   source "default-site.erb"
#   owner "root"
#   group "root"
#   mode 0644
#   notifies :restart, resources(:service => "nginx")
# end

directory "#{node[:nginx][:dir]}/apps" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

file "#{node[:nginx][:dir]}/sites-enabled/default" do
  action :delete
  only_if { File.exist?("#{node[:nginx][:dir]}/sites-enabled/default") }
  notifies :restart, resources(:service => "nginx")
end

link "#{node[:nginx][:dir]}/sites-enabled/default-site" do
  to "#{node[:nginx][:dir]}/sites-available/default-site"
  notifies :restart, resources(:service => "nginx")
end

service "nginx" do
  provider Chef::Provider::Service::Upstart
  action [:enable, :start]
end

