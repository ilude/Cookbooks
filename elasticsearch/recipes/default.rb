package "openjdk-7-jre"

version = "0.20.1"

service "elasticsearch" do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true, :start => true, :stop => true
end

user node[:elasticsearch][:user] do
  system true
  shell "/bin/false"
end

# FIX: Work around the fact that Chef creates the directory even for `manage_home: false`
bash "remove the elasticsearch user home" do
  user    'root'
  code    "rm -rf  #{node[:elasticsearch][:dir]}/elasticsearch"
  only_if "test -d #{node[:elasticsearch][:dir]}/elasticsearch"
end

remote_file "/tmp/elasticsearch-#{version}.tar.gz" do
  source    "https://github.com/downloads/elasticsearch/elasticsearch/elasticsearch-#{version}.tar.gz"
  mode      "0644"
  not_if{ File.exists? "/tmp/elasticsearch-#{version}.tar" }
end

bash "gunzip elasticsearch" do
  user  "root"
  cwd   "/tmp"
  code  %(gunzip elasticsearch-#{version}.tar.gz)
  not_if{ File.exists? "/tmp/elasticsearch-#{version}.tar" }
end

bash "extract elasticsearch" do
  user  "root"
  cwd   "/tmp"
  code  <<-EOH
  tar -xf /tmp/elasticsearch-#{version}.tar
  mv elasticsearch-#{version} elasticsearch
  mv elasticsearch #{node[:elasticsearch][:dir]}
  EOH
  not_if{ File.exists? "<%= node[:elasticsearch][:dir] %>/elasticsearch/bin/elasticsearch" }
end

template "elasticsearch.conf" do
  path "/etc/init/elasticsearch.conf"
  source "elasticsearch.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => 'elasticsearch')
end

# Create ES directories
#
%w| node[:elasticsearch][:config_dir] node[:elasticsearch][:data_dir] node[:elasticsearch][:log_dir] |.each do |path|
  directory path do
    owner node[:elasticsearch][:user] 
    group node[:elasticsearch][:user]
    mode 0755
    recursive true
    action :create
  end
end

template "elasticsearch.yml" do
  path   "#{node[:elasticsearch][:config_dir]}/elasticsearch.yml"
  source "elasticsearch.yml.erb"
  owner node[:elasticsearch][:user] 
  group node[:elasticsearch][:user] 
  mode 0755
  notifies :restart, resources(:service => 'elasticsearch')
end


# Make sure the service is started
service("elasticsearch") { action :start }

# Write config files
#template "#{node['elasticsearch']['config_dir']}/elasticsearch.yml" do
#  source  "elasticsearch.yml.erb"
#  owner   "root"
#  group   "root"
#  action  :create
#end
#template "#{node['elasticsearch']['config_dir']}/logging.yml" do
#  source  "logging.yml.erb"
#  owner   "root"
#  group   "root"
#  action  :create
#end