include_recipe "ssmtp"

package "tmux" 

execute "add_aliases" do
  command "echo alias l='ls -la' >> /etc/bash.bashrc"
  not_if { File.read("/etc/bash.bashrc").include?("alias l='ls -la'") }
end
