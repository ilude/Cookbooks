default[:elasticsearch][:dir]         = "/opt"
default[:elasticsearch][:install_dir] = "#{default[:elasticsearch][:dir]}/elasticsearch"
default[:elasticsearch][:data_dir]    = "#{default[:elasticsearch][:dir]}/elasticsearch/data"
default[:elasticsearch][:config_dir]  = "#{default[:elasticsearch][:dir]}/elasticsearch/config"
default[:elasticsearch][:log_dir]     = "/var/log/elasticsearch"

default[:elasticsearch][:user]            = "elasticsearch"
default[:elasticsearch][:http][:enabled]  = true
default[:elasticsearch][:http][:port]     = 9200
default[:elasticsearch][:http][:max_content_length] = "100mb"

allocated_memory = "#{(node.memory.total.to_i * 0.6 ).floor / 1024}m"
default.elasticsearch[:allocated_memory] = allocated_memory
default[:elasticsearch][:bootstrap][:mlockall] = true

default[:elasticsearch][:index][:number_of_shards] = 1   # Development values
default[:elasticsearch][:index][:number_of_replicas] = 0

default[:elasticsearch][:cluster_name]= "default"
default[:elasticsearch][:log_level]   = "DEBUG"

default[:elasticsearch][:master]   = true
default[:elasticsearch][:data]   = true

# Network
default[:elasticsearch][:network][:bind_host] = "_local_"
default[:elasticsearch][:network][:publish_host] = "_local_"
# specify 'host' to set both 'bind_host' and 'publish_host' as the same value
default[:elasticsearch][:network][:host] = "localhost"

# Discovery
default[:elasticsearch][:discovery][:zen][:minimum_master_nodes] = 1
default[:elasticsearch][:discovery][:zen][:ping][:timeout] = "3s"
default[:elasticsearch][:discovery][:zen][:ping][:multicast][:enabled] = false
default[:elasticsearch][:discovery][:zen][:ping][:multicast][:group] = "224.2.2.4"
default[:elasticsearch][:discovery][:zen][:ping][:multicast][:port] = "54328"
default[:elasticsearch][:discovery][:zen][:ping][:multicast][:ttl] = "3"
default[:elasticsearch][:discovery][:zen][:ping][:multicast][:address] = nil

# To do unicast, disable multicast and include hosts in an array in the
# following format: ["host1", "host2:port", "host3[portX-portY]"]
default[:elasticsearch][:discovery][:zen][:ping][:unicast][:hosts] = nil