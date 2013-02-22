template "gitconfig" do
  path "/etc/gitconfig"
  source "gitconfig.erb"
  owner "root"
  group "root"
  mode "0644"
end
