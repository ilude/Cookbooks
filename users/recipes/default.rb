
template "gitconfig" do
  path "/etc/gitconfig"
  source "gitconfig.erb"
  owner "root"
  group "root"
  mode "0644"
end

template "default.bashrc" do
  path "/etc/skel/.bashrc"
  source "bashrc.erb"
  owner "root"
  group "root"
  mode "0644"
end

template "default.bashrc" do
  path "/root/.bashrc"
  source "bashrc.erb"
  owner "root"
  group "root"
  mode "0644"
end