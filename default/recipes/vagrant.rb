template "install chef-update script" do
  path "/usr/local/bin/chef-update"
  source "chef-update.erb"
  owner "root"
  group "root"
  mode "0755"
end