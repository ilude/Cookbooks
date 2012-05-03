include_recipe "nginx"

gem_package "unicorn"

user "unicorn" 

directory "/apps" do
  owner "unicorn"
  group "unicorn"
  mode "0755"
  action :create
end