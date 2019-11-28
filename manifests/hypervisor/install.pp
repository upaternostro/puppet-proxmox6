# == Class: proxmox6::hypervisor::install
#
# Install Proxmox and inform the user he needs to reboot the system on the PVE kernel
#
class proxmox6::hypervisor::install {

  Exec {
    path      => [ '/bin', '/sbin', '/usr/bin', '/usr/sbin' ],
    logoutput => 'on_failure',
  }

  # If the system already run a PVE kernel
  ## Quoted boolean value because can't return "true" boolean with personal fact
  if $::is_pve_kernel == 'true' {

    # Installation of Virtual Environnment
    package { $proxmox6::hypervisor::ve_pkg_name:
      ensure => $proxmox6::hypervisor::ve_pkg_ensure,
    } ->

    # Remove useless packages (such as the standard kernel, acpid, ...)
    package { $proxmox6::hypervisor::old_pkg_name:
      ensure => $proxmox6::hypervisor::old_pkg_ensure,
      notify => Exec['update_grub'],
    }

    # Ensure that some recommended packages are present on the system
    ensure_packages( $proxmox6::hypervisor::rec_pkg_name )

  }
  else { # If the system run on a standard Debian Kernel

    # Ensure to upgrade all packages to latest version from Proxmox repository
    exec { 'Upgrade package from PVE repo':
      command => 'aptitude -y full-upgrade',
    } ->

    # To avoid unwanted reboot (kernel update for example), the PVE kernel is
    #  installed only if the system run on a standard Debian.
    # You will need to update your PVE kernel manually.

    # Installation of the PVE Kernel
    notify { 'Please REBOOT':
      message  => "Need to REBOOT the system on the new PVE kernel (${proxmox6::hypervisor::kernel_pkg_name}) ...",
      loglevel => warning,
    } ->

    package { $proxmox6::hypervisor::kernel_pkg_name:
      ensure => $proxmox6::hypervisor::ve_pkg_ensure,
      notify => Exec['update_grub'],
    }

  }

  # Ensure the grub is update
  exec { 'update_grub':
    command     => 'update-grub',
    refreshonly => true,
  }

} # Private class: proxmox6::hypervisor::install
