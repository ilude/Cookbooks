package "apache2"
package "libapache2-mod-wsgi" 
package "fontconfig"

package "git-core"

package "python-cairo-dev"
package "python-django"
package "python-django-tagging"
#package "python-memcache"
package "python-rrdtool"
package "python-pysqlite2"
package "python-zope.interface" 

basedir = node['graphite']['base_dir']
source_path = "/tmp/graphite-web"
git source_path do
  repository "https://github.com/graphite-project/graphite-web.git"
  reference "0.9.10"
  action :sync
end

execute "install graphite-web" do
  command "python setup.py install"
  cwd source_path
  action :run
end

template "graphite" do
  path "/etc/apache2/sites-available/graphite"
  source "graphite-site.conf.erb"
  owner "root"
  group "root"
  mode "0644"
end

template "graphite.wsgi" do
  path "/opt/graphite/conf/graphite.wsgi"
  source "graphite.wsgi.erb"
  owner "root"
  group "root"
  mode "0644"
end

link "/etc/apache2/sites-enabled/graphite"  do
  to "/etc/apache2/sites-available/graphite"
  notifies :restart, "service[apache2]"
end

link "/etc/apache2/mods-enabled/ssl.conf" do
  to "../mods-available/ssl.conf"
  notifies :restart, "service[apache2]"
end

link "/etc/apache2/mods-enabled/ssl.load" do
  to "../mods-available/ssl.load"
  notifies :restart, "service[apache2]"
end

link "/etc/apache2/mods-enabled/wsgi.conf" do
  to "../mods-available/wsgi.conf"
  notifies :restart, "service[apache2]"
end

link "/etc/apache2/mods-enabled/wsgi.load" do
  to "../mods-available/wsgi.load"
  notifies :restart, "service[apache2]"
end

directory "#{basedir}/storage" do
  owner 'www-data'
  group 'www-data'
end

directory "#{basedir}/storage/log" do
  owner 'www-data'
  group 'www-data'
end

%w{ webapp whisper }.each do |dir|
  directory "#{basedir}/storage/log/#{dir}" do
    owner 'www-data'
    group 'www-data'
  end
end

template "#{basedir}/bin/set_admin_passwd.py" do
  source "set_admin_passwd.py.erb"
  mode 00755
end

cookbook_file "#{basedir}/storage/graphite.db" do
  action :create_if_missing
  notifies :run, "execute[set admin password]"
end

execute "set admin password" do
  command "#{basedir}/bin/set_admin_passwd.py #{node['graphite']['username']} #{node['graphite']['password']}"
  action :nothing
end

file "#{basedir}/storage/graphite.db" do
  owner 'www-data'
  group 'www-data'
  mode 00644
end

service "apache2" do
  case node[:platform]
  when "redhat","centos","scientific","fedora","suse"
    service_name "httpd"
    # If restarted/reloaded too quickly httpd has a habit of failing.
    # This may happen with multiple recipes notifying apache to restart - like
    # during the initial bootstrap.
    restart_command "/sbin/service httpd restart && sleep 1"
    reload_command "/sbin/service httpd reload && sleep 1"
  when "debian","ubuntu"
    service_name "apache2"
    restart_command "/usr/sbin/invoke-rc.d apache2 restart && sleep 1"
    reload_command "/usr/sbin/invoke-rc.d apache2 reload && sleep 1"
  when "arch"
    service_name "httpd"
  when "freebsd"
    service_name "apache22"
  end
  supports value_for_platform(
    "debian" => { "4.0" => [ :restart, :reload ], "default" => [ :restart, :reload, :status ] },
    "ubuntu" => { "default" => [ :restart, :reload, :status ] },
    "redhat" => { "default" => [ :restart, :reload, :status ] },
    "centos" => { "default" => [ :restart, :reload, :status ] },
    "scientific" => { "default" => [ :restart, :reload, :status ] },
    "fedora" => { "default" => [ :restart, :reload, :status ] },
    "arch" => { "default" => [ :restart, :reload, :status ] },
    "suse" => { "default" => [ :restart, :reload, :status ] },
    "freebsd" => { "default" => [ :restart, :reload, :status ] },
    "default" => { "default" => [:restart, :reload ] }
  )
  action :enable
end