package "openjdk-7-jre"

version = "0.20.1"

remote_file "/tmp/elasticsearch-#{version}.tar.gz" do
  #source    "http://cloud.github.com/downloads/elasticsearch/elasticsearch/elasticsearch-#{node['elasticsearch']['version']}.tar.gz"
  source    "https://github.com/downloads/elasticsearch/elasticsearch/elasticsearch-#{version}.tar.gz"
  mode      "0644"
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
  tar -xf /tmp/elasticsearch-#{version}.tar && \
  mv elasticsearch-* elasticsearch
  mv elasticsearch /usr/local/share
  EOH
  not_if{ File.exists? "/usr/local/share/elasticsearch/bin/elasticsearch" }
end

remote_file "/tmp/elasticsearch-servicewrapper.tar.gz" do
  source    "https://github.com/elasticsearch/elasticsearch-servicewrapper/archive/master.tar.gz"
  mode      "0644"
end

bash "gunzip elasticsearch-servicewrapper" do
  user  "root"
  cwd   "/tmp"
  code  %(gunzip elasticsearch-servicewrapper.tar.gz)
  not_if{ File.exists? "/tmp/elasticsearch-servicewrapper.tar" }
end

bash "extract elasticsearch-servicewrapper" do
  user  "root"
  cwd   "/tmp"
  code  <<-EOH
  mv *servicewrapper*/service /usr/local/share/elasticsearch/bin/
  rm -Rf *servicewrapper*
  /usr/local/share/elasticsearch/bin/service/elasticsearch install
  ln -s `readlink -f /usr/local/share/elasticsearch/bin/service/elasticsearch` /usr/local/bin/rcelasticsearch
  EOH
  not_if{ File.exists? "/usr/local/bin/rcelasticsearch" }
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