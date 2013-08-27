include_recipe "nginx"

gem_package "bundler"
gem_package "unicorn"

# create logrotate configuration for all rails apps
template "rails" do
  path "/etc/logrotate.d/rails"
  source "rails.logrotate.erb"
  owner "root"
  group "root"
  mode "0644"
end

include_recipe "unicorn::user"
