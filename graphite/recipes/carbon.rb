package "python-twisted"
package "python-simplejson"

git "/tmp/carbon" do
  repository "https://github.com/graphite-project/carbon.git"
  reference "0.9.10"
  action :sync
end

execute "install carbon" do
  command "python setup.py install"
  cwd "/tmp/carbon"
  action :run
end

template "#{node['graphite']['base_dir']}/conf/carbon.conf" do
  owner 'www-data'
  group 'www-data'
  variables( :line_receiver_interface => '127.0.0.1',
             :pickle_receiver_interface => '127.0.0.1',
             :cache_query_interface => '127.0.0.1' )
  #notifies :restart, "service[carbon-cache]"
end

template "#{node['graphite']['base_dir']}/conf/storage-schemas.conf" do
  owner 'www-data'
  group 'www-data'
end

execute "carbon: change graphite storage permissions to apache user" do
  command "chown -R www-data:www-data #{node['graphite']['base_dir']}/storage"
  only_if do
    f = File.stat("#{node['graphite']['base_dir']}/storage")
    f.uid == 0 and f.gid == 0
  end
end

directory "#{node['graphite']['base_dir']}/lib/twisted/plugins/" do
  owner 'www-data'
  group 'www-data'
end