include_recipe "ssh::server"
include_recipe "users"
include_recipe "ssmtp"

# create a new user
user node[:user][:name] do
  gid "adm"
  home "/home/#{node[:user][:name]}"
  supports manage_home: true
  shell "/bin/bash"
end

# create a with some name as the new user
# and assign the new user to that group
group node[:user][:name] do
  members [node[:user][:name]]
end

# create .ssh directory in the new users home directory
directory "/home/#{node[:user][:name]}/.ssh" do
  owner node[:user][:name]
  group node[:user][:name]
  mode "0700"
end

# copy public key to the new users authorized_keys file
remote_file "/home/#{node[:user][:name]}/.ssh/authorized_keys" do
  source "https://raw.github.com/gist/2647943/vagabond.pub"
  owner node[:user][:name]
  group node[:user][:name]
  mode "0600"
end

# allow users in the adm group to sudo without a password
execute "adm_can_sudo" do
  command "/bin/sed -i -e 's/%admin ALL=(ALL) ALL/%adm ALL=NOPASSWD:ALL/g' /etc/sudoers"
  action :run
end
