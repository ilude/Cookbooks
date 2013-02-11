

execute "apt-get update" do
  command "apt-get update"
  action :run
end

execute "apt-get upgrade" do
  command "apt-get -y -f upgrade"
  action :run
end