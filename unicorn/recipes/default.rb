include_recipe "nginx"

gem_package "unicorn"

user "unicorn" do
  home "/home/unicorn"
  supports manage_home: true
end

directory "/apps" do
  owner "unicorn"
  group "unicorn"
  mode "0755"
  action :create
end