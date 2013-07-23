include_recipe "notification-service::service"
include_recipe "notification-service::loader"

execute "restart notification services" do
  command "bundle exec rake services:restart"
  cwd File.join(node[:unicorn][:apps_dir], node['notification-service'][:app_name])
  action :run
end