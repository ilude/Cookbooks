include_recipe "nginx"

gem_package "unicorn"

include_recipe "unicorn::user"