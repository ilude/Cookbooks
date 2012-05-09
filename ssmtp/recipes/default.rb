package "ssmtp" do
  action :install
end

template "ssmtp.conf" do
  path "/etc/ssmtp/ssmtp.conf"
  source "ssmtp.conf.erb"
  owner "root"
  group "root"
  mode "0644"
end

package "mailutils" do
  action :install
end
