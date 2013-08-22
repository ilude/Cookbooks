template "/etc/sysctl.conf" do
  source "sysctl.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
  )
end

execute "restart sysctl" do
  command "sysctl -p && service networking restart"
end