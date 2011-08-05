maintainer        "Opscode, Inc."
maintainer_email  "cookbooks@opscode.com"
license           "Apache 2.0"
description       "Installs and configures munin"
long_description  "Installs and configures Munin-node"
version           "0.10.1"

supports "arch"
supports "debian"
supports "ubuntu"

recipe "munin::client", "Instlls munin and configures a client by searching for the server, which should have a role named monitoring"
recipe "munin::server", "Install munion server with debian pkg"
recipe "munin::server-source", "Install munin server from sources"
