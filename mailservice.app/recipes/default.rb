include_recipe "unicorn"

execute "unicorn_owns_apps" do
  command "chown -R unicorn:unicron /apps/*"
  action :nothing
end

git "/apps/mailservice.app" do
  repository "git@npi.unfuddle.com:npi/mailchimptest.git"
  reference "master"
  action :sync
  notifies :run, resources(:execute => "unicorn_owns_apps")
end

%w{tmp/sockets tmp/pids log}.each do |dir|
   directory "/apps/mailservice.app/#{dir}" do
      mode "0775"
      owner "unicorn"
      group "unicorn"
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
end

template "upstream.mailservice.app.conf" do
  path "#{node[:nginx][:dir]}/apps/upstream.mailservice.app.conf"
  source "nginx.upstream.mailservice.app.conf.erb"
  owner "root"
  group "root"
  mode "0644"
end

template "mailservice.app.conf" do
  path "/etc/init/mailservice.app.conf"
  source "upstart.mailservice.app.conf.erb"
  owner "root"
  group "root"
  mode "0644"
end