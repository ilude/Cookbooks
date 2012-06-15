if node[:network] && node[:network][:static]
  template "/etc/network/interfaces.new" do
    source "interfaces.static.erb"
    owner "root"
    group "root"
    mode "0600"
  end
else
  template "/etc/network/interfaces.new" do
    source "interfaces.dhcp.erb"
    owner "root"
    group "root"
    mode "0600"
  end
end

execute "replace_interfaces_file" do
  command "mv /etc/network/interfaces.new /etc/network/interfaces"
  action :run
end