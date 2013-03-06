include_recipe "ssmtp"

include_recipe "default::bash"
include_recipe "default::git"

package "curl"
package "tmux"
package "openssl-blacklist"

directory "/root/.ssh" do
  owner "root"
  group "root"
  mode "0700"
  action :create
end

file "/root/.ssh/id_rsa" do
  content node['deploy_key']
  owner "root"
  group "root"
  mode 0600
  action :create_if_missing
end 

execute "sudo setup" do
  command "/bin/sed -i -e 's/%admin ALL=NOPASSWD:ALL/%adm ALL=NOPASSWD:ALL/g' /etc/sudoers"
  only_if { File.read("/etc/sudoers").include?("%admin ALL=NOPASSWD:ALL")}
end

#execute "add_aliases" do
# command "echo alias l=\'ls -la\' >> /etc/bash.bashrc"
# not_if { File.read("/etc/bash.bashrc").include?("alias l=\'ls -la\'") }
#end
