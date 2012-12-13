remote_file "/tmp/elasticsearch-servicewrapper.tar.gz" do
  source    "https://github.com/elasticsearch/elasticsearch-servicewrapper/archive/master.tar.gz"
  mode      "0644"
end

bash "extract elasticsearch-servicewrapper" do
  user  "root"
  cwd   "/tmp"
  code  <<-EOH
  tar -xfz /tmp/elasticsearch-servicewrapper.tar.gz
  mv /tmp/elasticsearch-servicewrapper-master/service /usr/local/share/elasticsearch/bin/
  rm -Rf elasticsearch-servicewrapper-master
  /usr/local/share/elasticsearch/bin/service/elasticsearch install
  ln -s `readlink -f /usr/local/share/elasticsearch/bin/service/elasticsearch` /usr/local/bin/rcelasticsearch
  EOH
  not_if{ File.exists? "/tmp/elasticsearch-servicewrapper.tar.gz" }
end

bash "extract elasticsearch-servicewrapper" do
  user  "root"
  cwd   "/tmp"
  code  <<-EOH
  tar -xfz /tmp/elasticsearch-servicewrapper.tar.gz
  mv /tmp/elasticsearch-servicewrapper-master/service /usr/local/share/elasticsearch/bin/
  rm -Rf elasticsearch-servicewrapper-master
  /usr/local/share/elasticsearch/bin/service/elasticsearch install
  ln -s `readlink -f /usr/local/share/elasticsearch/bin/service/elasticsearch` /usr/local/bin/rcelasticsearch
  EOH
  not_if{ File.exists? "/tmp/elasticsearch-servicewrapper.tar.gz" }
end