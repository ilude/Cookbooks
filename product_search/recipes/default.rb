include_recipe "unicorn"

package "nodejs" # needed for javascript runtime
package "freetds-dev"

gem_package "rails"

app_name = "product_search"

service app_name do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => false, :start => true, :stop => true, :reload => false
end

host = "bitbucket.org"
repo = "git@#{host}:rammounts/product_search.git"
known_hosts = "/home/#{node[:unicorn][:user]}/.ssh/known_hosts"

bash "add_known_host" do
  user  node[:unicorn][:user]
  cwd   "/home/#{node[:unicorn][:user]}"
  code  <<-EOH
  ssh-keyscan -t rsa #{host} >> #{known_hosts}
  chown #{node[:unicorn][:user]}:#{node[:unicorn][:group]} #{known_hosts}
  chmod 600 #{known_hosts}
  EOH
  not_if { File.exists?(known_hosts) && File.read(known_hosts).include?(host) }
end

git "#{node[:unicorn][:apps_dir]}/#{app_name}" do
  repository repo
  reference "master"
  action :sync
  user node[:unicorn][:user]
  group node[:unicorn][:group]
end

# execute "bundler" do
#   command "bundle install --no-deployment"
#   cwd File.join(node[:unicorn][:apps_dir], app_name)
#   action :run
# end

execute "deployment bundler" do
  command "bundle install --deployment --without development test"
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
  command "bundle exec rake assets:precompile"
  user node[:unicorn][:user]
  group node[:unicorn][:group]
  cwd File.join(node[:unicorn][:apps_dir], app_name)
  action :run
end

%w{tmp/sockets tmp/pids log public/data}.each do |dir|
   directory "#{node[:unicorn][:apps_dir]}/#{app_name}/#{dir}" do
      mode "0775"
      owner node[:unicorn][:user]
      group node[:unicorn][:group]
      action :create
      recursive true
   end
end

template "unicorn.rb" do
  path "#{node[:unicorn][:apps_dir]}/#{app_name}/unicorn.rb"
  source "unicorn.rb.erb"
  owner node[:unicorn][:user]
  group node[:unicorn][:group]
  mode "0644"
  variables(
    :app_name => app_name
  )
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
  notifies :restart, resources(:service => app_name)
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

service app_name do
  provider Chef::Provider::Service::Upstart
  action [:enable, :start]
end
