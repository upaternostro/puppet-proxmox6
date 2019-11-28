# == Class: proxmox6::hypervisor::preconfig
#
# Before installing Proxmox some modifications have to be applied on the system
#
class proxmox6::hypervisor::preconfig {

  File {
    owner => root,
    group => root,
    mode  => '0644',
  }

  Exec {
    path      => [ '/bin', '/sbin', '/usr/bin', '/usr/sbin' ],
    logoutput => 'on_failure',
  }

  # Hostname should be resolvable via /etc/hosts
  #/files/etc/hosts/2
  #/files/etc/hosts/2/ipaddr = '214.938.839.123'
  #/files/etc/hosts/2/canonical = 'hypervisor.domain.tld'
  #/files/etc/hosts/2/alias[1] = 'hypervisor'
  #/files/etc/hosts/1/ipaddr = '127.0.0.1'
  #/files/etc/hosts/1/canonical = 'localhost'
  augeas { $::fqdn:
    context => '/files/etc/hosts',
    changes => [
      #"ins ipaddr ${::ipaddress}",
      "set 02/ipaddr ${::ipaddress}",
      "set *[ipaddr = '${::ipaddress}']/canonical ${::fqdn}",
      "set *[ipaddr = '${::ipaddress}']/alias[1] ${::hostname}",
      "set *[ipaddr = '127.0.0.1']/canonical localhost",
      "rm *[ipaddr = '127.0.1.1']",
    ],
    onlyif  => "match *[ipaddr = '${::ipaddress}'] size == 0",
  }
  ->
  # Remove Enterprise repository (need a subscription)
  file { '/etc/apt/sources.list.d/pve-enterprise.list':
    ensure => $proxmox6::hypervisor::pve_enterprise_repo_ensure,
    notify => Exec[apt_update],
  }
  ->
  # Add the standard repository (~community)
  apt::source {'proxmox6':
    ensure      => present,
    location    => 'http://download.proxmox.com/debian/pve',
    release     => $::lsbdistcodename,
    repos       => 'pve-no-subscription',
    include     => { 'src' => false, },
    key         => { 'id'      => '359E95965E2C3D643159CD300D9A1950E2EF0603',
                     'server'  => 'http://keyserver.ubuntu.com',
                     'options' => "$proxmox6::hypervisor::key_options",
                   },
  }

  if ! defined(File['/etc/modules-load.d']) {
    file { '/etc/modules-load.d':
      ensure => directory,
    }
  }

  file { $proxmox6::hypervisor::pve_modules_file_path:
    ensure  => present,
    content => template($proxmox6::hypervisor::pve_modules_file_content),
    require => File['/etc/modules-load.d'],
  }

  # Add a delay at boot to allow a good LVM detection
  if $proxmox6::hypervisor::pve_lvm_delay == true {
    file { $proxmox6::params::init_lvm_script_path:
      ensure  => present,
      mode    => '0755',
      content => template($proxmox6::hypervisor::init_lvm_script_content),
      notify  => Exec['rebuild_initrd'],
    }

    exec { 'rebuild_initrd':
      command     => 'update-initramfs -k all -u',
      refreshonly => true,
    }
  }


} # Private class: proxmox6::hypervisor::preconfig
