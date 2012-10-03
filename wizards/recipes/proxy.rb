#"recipe[wizards::proxy]"

include_recipe "nginx"

app_name = "wizard"

template "nginx.proxy.server.conf" do
  path "#{node[:nginx][:dir]}/sites-available/#{app_name}"
  source "nginx.proxy.server.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
    :app_name => app_name
  )
end

link "#{node[:nginx][:dir]}/sites-enabled/#{app_name}"  do
  to "#{node[:nginx][:dir]}/sites-available/#{app_name}"
  notifies :reload, resources(:service => "nginx")
end