include_recipe "nginx"

gem_package "unicorn"

def add_known_host(hosts, user, group = user)
  
end

directory "/root/.ssh" do
  owner "root"
  group "root"
  mode "0700"
  action :create
end

file "/root/.ssh/id_rsa" do
  content node['deploy_key']
  owner "root"
  group "root"
  mode 0600
  action :create_if_missing
end 

home = "/home/#{node[:unicorn][:user]}"

execute "Delete User #{node[:unicorn][:user]}" do
  command "userdel -f #{node[:unicorn][:user]}"
  only_if { Dir.exists? home }
end

group node[:unicorn][:group] do
  action :create
end

user node[:unicorn][:user] do
  #system true
  shell "/bin/bash"
  comment "Unicorn User"
  home    home
  gid     node[:unicorn][:group]
  supports :manage_home => true
  action  :create
end

directory "#{home}/.ssh" do
  owner node[:unicorn][:user]
  group node[:unicorn][:group]
  mode "0700"
  action :create
end

file "#{home}/.ssh/id_rsa" do
  content node['deploy_key']
  owner node[:unicorn][:user]
  group node[:unicorn][:group]
  mode 0600
  action :create_if_missing
end 

file "#{home}/.ssh/authorized_keys" do
  content node['authorize_key']
  owner node[:unicorn][:user]
  group node[:unicorn][:group]
  mode 0600
  action :create_if_missing
  only_if node['authorize_key']
end 

directory "#{node[:unicorn][:apps_dir]}" do
  owner "#{node[:unicorn][:user]}"
  group "#{node[:unicorn][:group]}"
  mode "0755"
  action :create
end