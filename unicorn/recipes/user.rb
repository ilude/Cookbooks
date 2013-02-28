# execute "Delete User #{node[:unicorn][:user]}" do
#   command "userdel -f #{node[:unicorn][:user]}"
#   only_if { Dir.exists? home }
# end

group node[:unicorn][:group] do
  action :create
end

home = "/home/#{node[:unicorn][:user]}"

user node[:unicorn][:user] do
  #system true
  shell "/bin/bash"
  comment "Unicorn User"
  home    home
  gid     node[:unicorn][:group]
  supports :manage_home => true
  action  :create
end

group "adm" do
  action :modify
  members node[:unicorn][:user]
  append true
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
end 

directory "#{node[:unicorn][:apps_dir]}" do
  owner "#{node[:unicorn][:user]}"
  group "#{node[:unicorn][:group]}"
  mode "0755"
  action :create
end