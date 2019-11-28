# == Class: proxmox6::hypervisor::config
#
# Some tiny configurations for Proxmox
#
class proxmox6::hypervisor::config {

  File {
    owner => root,
    group => root,
    mode  => 644,
  }

  Exec {
    path      => [ '/bin', '/sbin', '/usr/bin', '/usr/sbin' ],
    logoutput => 'on_failure',
  }

  ## Quoted boolean value because can't return "true" boolean with personal fact
  if $::is_proxmox == 'true' {

    # Pveproxy access control list
    file { $proxmox6::hypervisor::pveproxy_default_path:
      ensure  => present,
      content => template($proxmox6::hypervisor::pveproxy_default_content),
      notify  => Service[$proxmox6::hypervisor::pveproxy_service_name],
    }
    ->

    # Remove the Subscription message
    exec { 'remove_subscription_message':
      command => 'rm -f /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js.bak; sed -i".bak" -r -e "s/if \(data.status !== \'Active\'\) \{/if (false) {/" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js',
      onlyif  => 'grep "if (data.status !== \'Active\') {" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js',
    }

  }

  if $proxmox6::hypervisor::labs_firewall_rule == true {

    firewall { '100 accept proxmox':
      proto  => 'tcp',
      action => 'accept',
      port   =>  ['8006', '5900']
    }

  }

} # Private class: proxmox6::hypervisor::config
