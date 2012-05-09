include_recipe "nginx"

package "php5-cli"
package "php5-cgi"
package "psmisc"
package "spawn-fcgi"
package "fcgiwrap"

service "php-cgi" do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true, :start => true, :stop => true, :reload => true
end

service "fastcgi" do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true, :start => true, :stop => true, :reload => true
end

template "upstart.php-cgi.conf" do
  path "/etc/init/php-cgi.conf"
  source "upstart.php-cgi.conf.erb"
  owner "root"
  group "root"
  mode "0644"
end

template "upstart.fastcgi.conf" do
  path "/etc/init/fastcgi.conf"
  source "upstart.fastcgi.conf.erb"
  owner "root"
  group "root"
  mode "0644"
end

template "upstream.php.conf" do
  path "#{node[:nginx][:dir]}/apps/upstream.php.conf"
  source "nginx.upstream.php.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :reload, resources(:service => "nginx")
end

template "upstream.fcgi.conf" do
  path "#{node[:nginx][:dir]}/apps/upstream.fcgi.conf"
  source "nginx.upstream.fcgi.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :reload, resources(:service => "nginx")
end

service "php-cgi" do
  provider Chef::Provider::Service::Upstart
  action [:enable, :start]
end

service "fastcgi" do
  provider Chef::Provider::Service::Upstart
  action [:enable, :start]
end
