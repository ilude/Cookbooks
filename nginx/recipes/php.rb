include_recipe "nginx"

package "php5-cli"
package "php5-cgi"
package "psmisc"
package "spawn-fcgi"

service "php-cgi" do
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

service "php-cgi" do
  provider Chef::Provider::Service::Upstart
  action [:enable, :start]
end
