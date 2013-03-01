include_recipe "unicorn::user"
include_recipe "resque"
include_recipe "wkhtmltopdf"
include_recipe "printing"

package "freetds-dev"

app_name = node['notification-service'][:app_name] 
node.set['notification-service'][:app_dir] = File.join(node[:apps_dir], app_name)

service app_name do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => false, :start => true, :stop => true, :reload => true
end

host = "bitbucket.org"
repo = "git@#{host}:rammounts/notification-service.git"
known_hosts = "/etc/ssh/ssh_known_hosts"

execute "add_known_host" do
  command "ssh-keyscan -t rsa #{host} >> #{known_hosts}"
  not_if { File.exists?(known_hosts) && File.read(known_hosts).include?(host) }
end

git node.set['notification-service'][:app_dir] do
  repository repo
  reference "master"
  action :sync
  user node[:unicorn][:user]
  group node[:unicorn][:group]
end

%w{tmp/sockets tmp/pids log public/data}.each do |dir|
   directory "#{node['notification-service'][:app_dir]}/#{dir}" do
      mode "0775"
      owner node[:unicorn][:user]
      group node[:unicorn][:group]
      action :create
      recursive true
   end
end

file "#{node['notification-service'][:app_dir]}/script/daemon" do
  owner node[:unicorn][:user]
  group node[:unicorn][:group]
  mode "0775"
end

execute "system bundler" do
  command "bundle install --no-deployment"
  cwd node['notification-service'][:app_dir]
  action :run
end

execute "deployment bundler" do
  command "bundle install --deployment"
  user node[:unicorn][:user]
  group node[:unicorn][:group]
  cwd node['notification-service'][:app_dir]
  action :run
end

execute "unicorn_owns_apps" do
  command "chown -R #{node[:unicorn][:user]}:#{node[:unicorn][:group]} #{node['notification-service'][:app_dir]}"
  action :run
end

# execute "assets precompile" do
#   command "sudo -u #{node[:unicorn][:user]} bundle exec rake assets:precompile"
#   cwd node['notification-service'][:app_dir]
#   action :run
# end

# template "sudoers notification-service_conf" do
#   path "/etc/sudoers.d/notification-service_conf"
#   source "sudoers.d.erb"
#   owner "root"
#   group "root"
#   mode "0440"
#   variables(
#     :app_name => app_name
#   )
# end

template "notification-service-monitor.conf" do
  path "/etc/init/notification-service-monitor.conf"
  source "notification-service-monitor.conf.erb"
  owner "root"
  group "root"
  mode "0644"
end

template "#{app_name}.conf" do
  path "/etc/init/#{app_name}.conf"
  source "upstart.#{app_name}.conf.erb"
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

execute "restart #{app_name}" do
  command "service #{app_name} restart"
  cwd node['notification-service'][:app_dir]
  action :run
  only_if "ps cax | grep `cat tmp/pids/resque.pid"
end
