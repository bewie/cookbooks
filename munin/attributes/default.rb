#default[:munin][:server][:addresses] = Array.new

### SOURCE PACKAGES
default[:munin][:version]	= "1.4.5"
default[:munin][:source]	= "http://sourceforge.net/projects/munin/files/munin%20stable/#{munin[:version]}/munin-#{munin[:version]}.tar.gz"
default[:munin][:checksum]	= "4f8632713c5267e282b091cf7ef5163c5de321536e76dbaab2204aa23c957138"


### GENERAL
default[:munin][:home]         = "/usr/local/munin/"
default[:munin][:dir]         = "#{munin[:home]}/munin-#{munin[:version]}" # For install from source
default[:munin][:current]     = "#{munin[:home]}/current"

default[:munin][:logdir]      = "/usr/local/munin/log"
default[:munin][:logfile]     = "#{munin[:logdir]}/munin.log"
default[:munin][:pidfile]     = "/var/run/munin.pid"

default[:munin][:port]        = 4949

