include_recipe "unicorn"


gem_package "sinatra"
gem_package "gibbon"
gem_package "resque"


service "mailservice.app" do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true, :start => true, :stop => true, :reload => true
end

host = "npi.unfuddle.com"
repo = "git@#{host}:npi/mailchimptest.git"

execute "add_known_host" do
  known_hosts = "/home/root/.ssh/known_hosts"
  command "ssh-keyscan -t rsa #{host} >> known_hosts"
  not_if { File.read(known_hosts).include?(host) }
end

git "#{node[:unicorn][:apps_dir]}/mailservice.app" do
  repository repo
  reference "master"
  action :sync
end

execute "unicorn_owns_apps" do
  command "chown -R #{node[:unicorn][:user]}:#{node[:unicorn][:group]} #{node[:unicorn][:apps_dir]}/mailservice.app"
  action :run
end

%w{tmp/sockets tmp/pids log}.each do |dir|
   directory "#{node[:unicorn][:apps_dir]}/mailservice.app/#{dir}" do
      mode "0775"
      owner "#{node[:unicorn][:user]}"
      group "#{node[:unicorn][:group]}"
      action :create
      recursive true
   end
end

template "server.mailservice.app.conf" do
  path "#{node[:nginx][:dir]}/apps/server.mailservice.app.conf"
  source "nginx.server.mailservice.app.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :reload, resources(:service => "nginx")
end

template "upstream.mailservice.app.conf" do
  path "#{node[:nginx][:dir]}/apps/upstream.mailservice.app.conf"
  source "nginx.upstream.mailservice.app.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :reload, resources(:service => "nginx")
end

template "mailservice.app.conf" do
  path "/etc/init/mailservice.app.conf"
  source "upstart.mailservice.app.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "mailservice.app")
end

service "mailservice.app" do
  provider Chef::Provider::Service::Upstart
  action [:enable, :start]
end