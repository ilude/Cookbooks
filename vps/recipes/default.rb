include_recipe "unicorn"

gem_package "rails"

app_name = "vps"

service app_name do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true, :start => true, :stop => true, :reload => true
end

host = "bitbucket.org"
repo = "git@#{host}:ilude/vps.git"
known_hosts = "/root/.ssh/known_hosts"

directory "/root/.ssh" do
  owner "root"
  group "root"
  mode "0700"
  action :create
end

execute "add_known_host" do
  command "ssh-keyscan -t rsa #{host} >> #{known_hosts}"
  not_if { File.exists?(known_hosts) && File.read(known_hosts).include?(host) }
end

git "#{node[:unicorn][:apps_dir]}/#{app_name}" do
  repository repo
  reference "master"
  action :sync
end

execute "unicorn_owns_apps" do
  command "chown -R #{node[:unicorn][:user]}:#{node[:unicorn][:group]} #{node[:unicorn][:apps_dir]}/#{app_name}"
  action :run
end

execute "bundler" do
  command "bundle install"
  cwd File.join(node[:unicorn][:apps_dir], app_name)
  user node[:unicorn][:user]
  action :run
end

%w{tmp/sockets tmp/pids log public/data}.each do |dir|
   directory "#{node[:unicorn][:apps_dir]}/#{app_name}/#{dir}" do
      mode "0775"
      owner "#{node[:unicorn][:user]}"
      group "#{node[:unicorn][:group]}"
      action :create
      recursive true
   end
end

template "server.#{app_name}.conf" do
  path "#{node[:nginx][:dir]}/sites-available/#{app_name}"
  source "nginx.server.app.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
    :app_name => app_name
  )
  #notifies :reload, resources(:service => "nginx")
end

link "#{node[:nginx][:dir]}/sites-enabled/#{app_name}"  do
  to "#{node[:nginx][:dir]}/sites-available/#{app_name}"
  notifies :reload, resources(:service => "nginx")
end

template "#{app_name}.conf" do
  path "/etc/init/#{app_name}.conf"
  source "upstart.app.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
    :app_name => app_name
  )
  notifies :restart, resources(:service => app_name)
end

service app_name do
  provider Chef::Provider::Service::Upstart
  action [:enable, :start]
end

cron "clean-files" do
  hour "3"
  minute "0"
  command "find #{node[:unicorn][:apps_dir]}/#{app_name}/public/data/* -mtime +14 -exec rm {} \;"
end
