
execute "lock_root" do
  command "/usr/bin/passwd -l root"
  action :run
end