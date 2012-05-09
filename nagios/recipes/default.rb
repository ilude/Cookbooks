include_recipe "nginx::php"

package "nagios3"

template "server.nagios.conf" do
  path "#{node[:nginx][:dir]}/apps/server.nagios.conf"
  source "nginx.server.nagios.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :reload, resources(:service => "nginx")
end

cookbook_file "/etc/nagios3/htpasswd.users" do
  source "htpasswd.users" # this is the value that would be inferred from the path parameter
  owner "root"
  group "www-data"
  mode "0640"
end

