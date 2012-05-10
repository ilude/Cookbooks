include_recipe "ssh::server"
include_recipe "users"
include_recipe "ssmtp"

user node[:user][:name] do
  gid "adm"
  home "/home/#{node[:user][:name]}"
  supports manage_home: true
  shell "/bin/bash"
end

directory "/home/#{node[:user][:name]}/.ssh" do
  owner node[:user][:name]
  group node[:user][:name]
  mode "0700"
end

remote_file "/home/#{node[:user][:name]}/.ssh/authorized_keys" do
  source "https://raw.github.com/gist/2647943/vagabond.pub"
  owner node[:user][:name]
  group node[:user][:name]
  mode "0600"
end