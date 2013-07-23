include_recipe "unicorn"
include_recipe "elasticsearch"

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
#   command "bundle install --no-deployment --without development test"
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

template "elasticsearch.override" do
  path "/etc/init/elasticsearch.override"
  source "elasticsearch.override.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
    :app_name => app_name
  )
end

include_recipe "vps::smbmount"

service app_name do
  provider Chef::Provider::Service::Upstart
  action [:enable, :start]
end

missing_image_command = "cd #{node[:unicorn][:apps_dir]}/#{app_name}; RAILS_ENV=production /usr/local/bin/bundle exec /usr/local/bin/ruby script/missing_images.rb"

cron "setup missing image report cron job" do
  hour "6"
  minute "0"
  command missing_image_command
end

# execute "queue missing image report" do
#   command "echo \"#{missing_image_command}\" | at now + 10 minute"
#   cwd File.join(node[:unicorn][:apps_dir], app_name)
#   action :run
# end

cron "update requirement index" do
  hour "3"
  minute "0"
  command "cd #{node[:unicorn][:apps_dir]}/#{app_name}; RAILS_ENV=production /usr/local/bin/bundle exec /usr/local/bin/ruby script/load.rb"
end

# upstart elasticsearch.override takes care of this now
#execute "queue requirement load" do
#  command 'echo "ruby script/load.rb 1>/apps/vps/log/requirement_load.log 2>&1" | at now + 2 minute'
#  cwd File.join(node[:unicorn][:apps_dir], app_name)
#  action :run
#end