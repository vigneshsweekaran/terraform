resource "local_file" "dnsmasq_conf" {
  filename = "${path.module}/dnsmasq-dynamic.conf.tmpl"
  file_permission = "666"
  content  = <<-EOT
    bind-interfaces
    user=dnsmasq
    group=dnsmasq
    pid-file=/var/run/dnsmasq.pid
    cache-size=1000
    max-cache-ttl=300
    neg-ttl=60
    strict-order
    bogus-priv
    no-resolv
    expand-hosts
    %{ for ip in var.dns_servers }
    server=/bitslovers.com/${ip}
    %{ endfor }
    server=8.8.8.8
    no-dhcp-interface=
EOT
}