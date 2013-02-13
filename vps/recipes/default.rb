include_recipe "unicorn"

package "nodejs" # needed for javascript runtime
package "freetds-dev"

gem_package "rails"

app_name = "vps"

service app_name do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true, :start => true, :stop => true, :reload => true
end

host = "bitbucket.org"
repo = "git@#{host}:rammounts/vps.git"
known_hosts = "/home/#{node[:unicorn][:user]}/.ssh/known_hosts"

execute "add_known_host" do
  command "ssh-keyscan -t rsa #{host} >> #{known_hosts}"
  user node[:unicorn][:user]
  group node[:unicorn][:group]
  not_if { File.exists?(known_hosts) && File.read(known_hosts).include?(host) }
end

git "#{node[:unicorn][:apps_dir]}/#{app_name}" do
  repository repo
  reference "master"
  action :sync
  user node[:unicorn][:user]
  group node[:unicorn][:group]
end

execute "bundler" do
  command "bundle install --no-deployment"
  cwd File.join(node[:unicorn][:apps_dir], app_name)
  action :run
end

execute "deployment bundler" do
  command "bundle install --deployment"
  user node[:unicorn][:user]
  group node[:unicorn][:group]
  cwd File.join(node[:unicorn][:apps_dir], app_name)
  action :run
end

# execute "assets clean" do
#   command "sudo -u #{node[:unicorn][:user]} bundle exec rake assets:clean"
#   cwd File.join(node[:unicorn][:apps_dir], app_name)
#   action :run
# end

execute "assets precompile" do
  command "sudo -u #{node[:unicorn][:user]} bundle exec rake assets:precompile"
  cwd File.join(node[:unicorn][:apps_dir], app_name)
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
  notifies :restart, resources(:service => "nginx")
end

link "#{node[:nginx][:dir]}/sites-enabled/default-site" do
  action :delete
  only_if { node[:vps][:server_name].eql? "_" }
  notifies :restart, resources(:service => "nginx")
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

include_recipe "vps::smbmount"

service app_name do
  provider Chef::Provider::Service::Upstart
  action [:enable, :start]
end

cron "update requirement index" do
  hour "3"
  minute "0"
  command "cd #{node[:unicorn][:apps_dir]}/#{app_name}; /usr/local/bin/bundle exec /usr/local/bin/ruby script/load.rb"
end

execute "queue requirement load" do
  command 'echo "ruby script/load.rb 1>/apps/vps/log/requirement_load.log 2>&1" | at now + 2 minute'
  cwd File.join(node[:unicorn][:apps_dir], app_name)
  action :run
end