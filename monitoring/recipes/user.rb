group node[:monitoring][:group] do
  action :create
end

home = "/home/#{node[:monitoring][:user]}"

user node[:monitoring][:user] do
  #system true
  shell "/bin/bash"
  comment "#{node[:monitoring][:user]} user"
  home    home
  gid     node[:monitoring][:group]
  supports :manage_home => true
  action  :create
end

# group "adm" do
#   action :modify
#   members node[:monitoring][:user]
#   append true
# end

# directory "#{home}/.ssh" do
#   owner node[:monitoring][:user]
#   group node[:monitoring][:group]
#   mode "0700"
#   action :create
# end

# file "#{home}/.ssh/id_rsa" do
#   content node['deploy_key']
#   owner node[:monitoring][:user]
#   group node[:monitoring][:group]
#   mode 0600
#   action :create_if_missing
# end 

# file "#{home}/.ssh/authorized_keys" do
#   content node['authorize_key']
#   owner node[:monitoring][:user]
#   group node[:monitoring][:group]
#   mode 0600
#   action :create_if_missing
# end 