include_recipe "nginx"

gem_package "unicorn"

user node[:unicorn][:user] do
  system true
  shell "/bin/false"
end

directory "#{node[:unicorn][:apps_dir]}" do
  owner "#{node[:unicorn][:user]}"
  group "#{node[:unicorn][:group]}"
  mode "0755"
  action :create
end