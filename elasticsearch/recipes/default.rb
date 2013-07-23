package "openjdk-7-jre"

version = "0.20.1"

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
  source    "http://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-#{version}.tar.gz"
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
end

# Create ES directories
#
%W[ #{node[:elasticsearch][:config_dir]} #{node[:elasticsearch][:data_dir]} #{node[:elasticsearch][:log_dir]} #{node[:elasticsearch][:pid_path]} ].each do |path|
  directory path do
    owner node[:elasticsearch][:user] 
    group node[:elasticsearch][:user]
    mode 0755
    recursive true
    action :create
    not_if{ Dir.exists? path }
  end
end

template "elasticsearch.yml" do
  path   "#{node[:elasticsearch][:config_dir]}/elasticsearch.yml"
  source "elasticsearch.yml.erb"
  owner node[:elasticsearch][:user] 
  group node[:elasticsearch][:user] 
  mode 0755
end

include_recipe "bluepill"
template "/etc/bluepill/elasticsearch.pill" do
  source "elasticsearch.pill.erb"
end

bluepill_service "elasticsearch" do
    action [:load, :start]
end

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