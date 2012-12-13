include_recipe "nginx"

gem_package "unicorn"

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
  #shell "/bin/false"

  comment "Unicorn User"
  home    home
  shell   "/bin/false"
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

directory "#{node[:unicorn][:apps_dir]}" do
  owner "#{node[:unicorn][:user]}"
  group "#{node[:unicorn][:group]}"
  mode "0755"
  action :create
end