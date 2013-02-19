include_recipe "ssmtp"

package "curl"
package "tmux"
package "openssl-blacklist"

#execute "add_aliases" do
# command "echo alias l=\'ls -la\' >> /etc/bash.bashrc"
# not_if { File.read("/etc/bash.bashrc").include?("alias l=\'ls -la\'") }
#end
