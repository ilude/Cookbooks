package "build-essential" do
  action :install
end

user node[:redis][:user] do
  system true
  shell "/bin/false"
end

directory node[:redis][:data_dir] do
  owner "redis"
  mode "0755"
  action :create
  recursive true
end

directory node[:redis][:dir] do
  owner "root"
  mode "0755"
  action :create
  recursive true
end

remote_file "#{Chef::Config[:file_cache_path]}/redis-#{node[:redis][:version]}.tar.gz" do
  source "http://redis.googlecode.com/files/redis-#{node[:redis][:version]}.tar.gz"
  action :create_if_missing
end

bash "compile_redis_source" do
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
    tar zxf redis-#{node[:redis][:version]}.tar.gz
    cd redis-#{node[:redis][:version]}
    make && make install
  EOH
  creates "/usr/local/bin/redis-server"
end

service "redis" do
  provider Chef::Provider::Service::Upstart
  subscribes :restart, resources(:bash => "compile_redis_source")
  supports :restart => true, :start => true, :stop => true
end

template "redis.conf" do
  path "#{node[:redis][:dir]}/redis.conf"
  source "redis.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "redis")
end

template "upstart.redis.conf" do
  path "/etc/init/redis.conf"
  source "upstart.redis.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "redis")
end

directory node[:redis][:log_dir] do
  mode 0755
  owner node[:redis][:user]
  action :create
  recursive true
end


service "redis" do
  action [:enable, :start]
end