# == Class: proxmox6::hypervisor::service
#
# Manage Proxmox services
#
class proxmox6::hypervisor::service {

  if $proxmox6::hypervisor::pveproxy_service_enabled == true {
    $pveproxy_service_ensure = 'running'
  } else {
    $pveproxy_service_ensure = 'stopped'
  }

  if $::is_proxmox == 'true' {

    if $proxmox6::hypervisor::pveproxy_service_manage == true {
      service { $proxmox6::hypervisor::pveproxy_service_name:
        ensure     => $pveproxy_service_ensure,
        enable     => $proxmox6::hypervisor::pveproxy_service_enabled,
        hasstatus  => false,
        hasrestart => true,
      }
    }

  }

} # Private class: proxmox6::hypervisor::service
