# == Class: proxmox6::hypervisor::cluster
#
# Manage the Proxmox cluster.
#
class proxmox6::hypervisor::cluster
{

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
  if $::is_proxmox == 'true' and $proxmox6::hypervisor::cluster_master_ip != undef and $proxmox6::hypervisor::cluster_name != undef {
    # Ensure the root user got an ssh-key
    exec { 'create ssh-key for root':
      command => 'ssh-keygen -t rsa -f /root/.ssh/id_rsa -b 2048 -N "" -q',
      creates => '/root/.ssh/id_rsa.pub',
    }

    # Test if this node should be the master or a node
    ## has_interface_with needs double quoted string for the argument !
    if has_interface_with('ipaddress', "${proxmox6::hypervisor::cluster_master_ip}") {

      # Create the cluster on this node
      exec { "Create ${proxmox6::hypervisor::cluster_name} cluster on ${proxmox6::hypervisor::cluster_master_ip}":
        command => "pvecm create ${proxmox6::hypervisor::cluster_name}",
        onlyif  => 'uname -r | grep -- "-pve"',
        creates => '/etc/pve/corosync.conf',
      }
    }
    else {

      # Connect this node to the cluster
      exec { "Connect to ${proxmox6::hypervisor::cluster_name} cluster":
        command => "pvecm add ${proxmox6::hypervisor::cluster_master_ip}",
        onlyif  => 'uname -r | grep -- "-pve"',
        creates => '/etc/pve/corosync.conf',
      }
    }
  }


  #notify { "Master IP: ${proxmox6::hypervisor::cluster_master_ip} and Cluster name: ${proxmox6::hypervisor::cluster_name}": }

} # Private class: proxmox6::hypervisor::cluster
