include_recipe "unicorn"


gem_package "sinatra"
gem_package "gibbon"
gem_package "resque"


service "mailservice.app" do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true, :start => true, :stop => true, :reload => true
end

git "#{node[:unicorn][:apps_dir]}/mailservice.app" do
  repository "git@npi.unfuddle.com:npi/mailchimptest.git"
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