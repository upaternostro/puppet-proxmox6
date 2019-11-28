# proxmox6

#### Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Setup](#setup)
    * [What Proxmox affects](#what-proxmox-affects)
    * [Beginning with Proxmox](#beginning-with-proxmox)
4. [Usage](#usage)
    * [Hypervisor](#hypervisor)
5. [Reference](#reference)
    * [Classes](#classes)
    * [Defined types](#defined-types)
    * [Parameters](#parameters)
6. [Other notes](#other-notes)
7. [Limitations](#limitations)
8. [Development](#development)
9. [License](#license)

## Overview

The proxmox module provide a simple way to manage Proxmox hypervisor configuration with Puppet.

## Module Description

The proxmox module automates installing Proxmox on Debian systems.

## Setup

### What Proxmox affects:

* Package/service/configuration files for Proxmox.
* A new `sources.list` file for Proxmox.
* Proxmox's cluster (master and nodes).
* System repository
* The static table lookup for hostnames `hosts`.
* Users and group permissions for WebGUI.
* WebGUI's service (pveproxy).
* Kernel modules loaded at the boot time.

### Beginning with Proxmox

To begin using proxmox module with default parameters, declare the hypervisor's class with `include proxmox6::hypervisor`.

## Usage

### Hypervisor

```
include proxmox6::hypervisor
```
**Note**: The module will NOT automatically reboot the system on the PVE Kernel. You will need to reboot it manually and start again the puppet agent.

#### Install a new hypervisor

To install Proxmox with the default parameters:
```
class { 'proxmox6::hypervisor':
}
```

#### Disable additionnal modules
Disable all additionnal modules load at the boot time:
```
class { 'proxmox6::hypervisor':
  pve_modules_list => [ '' ],
}
```

#### Create a cluster full (for Ceph)
```
node "pve_node" {
  # Install an hypervisor
  class { 'proxmox6::hypervisor':
    pveproxy_allow    => '127.0.0.1,192.168.0.0/24',
    cluster_master_ip => '192.168.0.201',
    cluster_name      => 'DeepThought',
  }
  # Access to PVE Webgui
  proxmox6::hypervisor::group { 'sysadmin': role => "Administrator", users => [ 'marvin@pam', 'arthur@pam' ] }

  # SSH authorized keys between all nodes without passphrase (the module generate a key if not present)
  ssh_authorized_key { 'hyper01':
    ensure  => present,
    key     => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDQxnLaBlnujnByt3V7YLZv1+PTjREJ3hphZFdCVNs9ebED55/kEAPmtJzcq2OL7qk8PajvhpB7efuZAatKeCdhILpFBKRrCo/q3MsQUSyaHbrGKs8Kkpz0EBHp1Tgpd8i1+kF1EzVPqT/euNcI6cA3fyMrvdgTI25BwFt93A6bBpf4We7A0l0Ba2nCAs5ekWyKKLh54GO7KBHlMmIzboYpxwgnFcbb9UhuyUz2J6PSC0K+P+hdMXY4dFk/lPMEXLgve/TTPYpgDxgxWMUaobCanwBWcXkZ4MdJw2Qs6TQ0v+cOxX3ogr78w69naGB3joJ4ll31WA+Uo0mcZU3ylFj3',
    type    => 'ssh-rsa',
    user    => 'root',
    options => 'from="192.168.0.201"',
  }
  ssh_authorized_key { 'hyper02':
    ensure  => present,
    key     => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQCxJeQ1R1rhPoig4jZLA8/Haru3nhVMgvDgO7nIqpwuPkDrheINVHOAd+DyQF0I2MtAjzg9gKfyix/cJ0cWMbd6/FdSVJ39dGYtNG9/YwTBcQiYwT0xS4NgJHzKrYE9PH2HEmjTmzcDeZ/u+IZjhO3Kyy9yZKcOhwV6fD+mzjQb4S2zsy67R/aoySbZjuoZYHrBrfjc66WbPbLtsFXIXuk46N376Y5sX37Bj17HhDEdP/lc9v939SswW1RZ2t1mVAjsMdsyBULDZk5av6Uj//YT1KuZBmBWkp7nPp1yt2ANPPGAnEW3oYjzXJd56Xtf3d0nbHOdHvMmIiV9fZyRUATd',
    type    => 'ssh-rsa',
    user    => 'root',
    options => 'from="192.168.0.202"',
  }

  # Verify the authenticity of each hosts (/etc/ssh/ssh_host_{rsa,ecdsa}_key.pub)
  sshkey { 'hyper01':
    ensure       => present,
    host_aliases => [ 'hyper01.domain.org', '192.168.42.201' ],
    key          => 'AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBJ3TC6B3+eVbohjk662FwM/1YUCjMwMT9lmZcNcfllF9Vm082lMXtKix20elUCK9yJDpPWvzFiqdyhgqPAeCNt4=',
    target       => '/root/.ssh/known_hosts',
    type         => 'ecdsa-sha2-nistp256',
  }
   sshkey { 'hyper02':
     ensure       => present,
     host_aliases => [ 'hyper02.domain.org', '192.168.42.202' ],
     key          => 'AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEqUpnig3DIQVZEr3LxJCVEF/fl4n1s8LNuUUaLRueCW2ygzNBOv2m7O42K/Ok7aa4kjGaXbnneYXMw3wBULJ1U='
     target       => '/root/.ssh/known_hosts',
     type         => 'ecdsa-sha2-nistp256',
   }

  # If you don't have a DNS service, i recommend to have an entry for each nodes in the hosts file
  host { 'hyper01':
    name         => "hyper01.${::domain}",
    ensure       => present,
    ip           => '192.168.42.201',
    host_aliases => 'hyper01',
  }
  host { 'hyper02':
    name         => "hyper02.${::domain}",
    ensure       => present,
    ip           => '192.168.42.202',
    host_aliases => 'hyper02',
  }
}

node /hyper0[12]/ inherits "pve_node" {

}

```
Will create a Cluster Proxmox with name "Deepthought", the master will be "hyper01". You also can manage all ssh ressources (and host) manually on each nodes.

## Reference

### Classes

* `proxmox`: Main class, do nothing right now.

* `proxmox6::hypervisor`: Install the Proxmox hypervisor on the system.

### Defined types

* `proxmox6::hypervisor::group`: Manage groups for Proxmox WebGUI and set permissions.

```
proxmox6::hypervisor::group { 'sysadmin':
  role  => "Administrator",
  users => [ 'user1@pam', 'toto@pve' ],
}
```

* `proxmox6::hypervisor::user`: Manage user for Proxmox WebGUI.

```
proxmox6::hypervisor::user { 'marvin':
  group => 'sysadmin',
}
```

  Mainly used by the `proxmox6::hypervisor::group` defined type to create the group, permissions and also create/add the users to a group. Because to add a user to a group via this defined type, the group should already exist.

### Parameters

#### proxmox6::hypervisor

* `ve_pkg_ensure`: What to set the Virtual Environnment package to. Can be 'present', 'absent' or 'version'. Defaults to 'present'.
* `ve_pkg_name`: The list of VirtualEnvironnment packages. Can be an array [ 'proxmox-ve', 'ksm-control-daemon', 'open-iscsi', 'pve-firmware' ].
* `kernel_pkg_name`: The list of packages to install the new PVE kernel. Can be an array [ 'pve-kernel-4.4.13-2-pve', '...' ].
* `rec_pkg_name`: The list of recommended and usefull packages for Proxmox. Can be an array [ 'bridge-utils', 'lvm2', 'ntp', 'postfix', 'ssh' ].
* `old_pkg_ensure`: What to set useless packages (non recommended, previous kernel, ...). Can be 'present' or 'absent'. Defaults to 'absent'.
* `old_pkg_name`: The list of useless packages. Can be an array [ 'acpid',  'linux-image-amd64', 'linux-base', 'linux-image-3.16.0-4-amd64' ].
* `pve_enterprise_repo_ensure`: Choose to keep the PVE enterprise repository. Can be 'present' or 'absent'. Defaults to 'absent'.
* `pveproxy_default_path`: Path of the configuration file read by the PveProxy service. Defaults to '/etc/default/pveproxy'.
* `pveproxy_default_content`: Template file use to generate the previous configuration file. Default to 'proxmox6/hypervisor/pveproxy_default.erb'.
* `pveproxy_allow`:   Can be ip addresses, range or network; separated by a comma (example: '192.168.0.0/24,10.10.0.1-10.10.0.5'). Defaults to '127.0.0.1'.
* `pveproxy_deny`: Unauthorized IP addresses. Can be 'all' or ip addresses, range or network; separated by a comma. Defaults to 'all'.
* `pveproxy_policy`: The policy access. Can be 'allow' or 'deny'. Defaults to 'deny'.
* `pveproxy_service_name`: WebGUI's service name (replace Apache2 since v3.0). Defaults to 'pveproxy'.
* `pveproxy_service_manage`: If set to 'true', Puppet will manage the WebGUI's service. Can be 'true' or 'false'. Defaults to 'true'.
* `pveproxy_service_enabled`: If set to 'true', Puppet will ensure the WebGUI's service is running. Can be 'true' or 'false'. Defaults to 'true'.
* `pve_modules_list`: The list of additionnal modules to load at boot time.
* `pve_modules_file_path`: The configuration file that will contain the modules list. Defaults to '/etc/modules-load.d/proxmox.conf'.
* `pve_modules_file_content`: Template file used to generate the previous configuration file. Defaults to 'proxmox6/hypervisor/proxmox_modules.conf.erb'.
* `pve_lvm_delay` : If set to 'true', it will add a initramfs-tools script toto ensure a good detection of all LVM. Can be 'true' or 'false'. Defaults to 'true'.
* `init_lvm_script_path` : Path of the initramfs-tools script to ensure a good detection of all LVM at startup. Defaults to '/etc/initramfs-tools/scripts/local-top/lvm-manual'.
* `init_lvm_script_content` : Temple file use to generate the previous configuration file. Default to 'proxmox6/hypervisor/initramfs-lvm-manual.erb'.
* `labs_firewall_rule`: If set to 'true', Puppet will set a iptable rule to allow WebGUI and VNC's port access. Can be 'true' or 'false'. Defaults to 'false'.
* `cluster_master_ip`: The ip address of the "master" node that will create the cluster. Must be an IP address. Defaults to 'undef'.
* `cluster_name`: The cluster's name. Defaults to 'undef'.

Other notes
-----------
By default `proxmox6::hypervisor` comes with several modules kernel load at boot time. Mainly iptables's modules to allow it in the CT.

The default modules list:
* `iptable_filter`
* `iptable_mangle`
* `iptable_nat`
* `ipt_length` (=xt_length)
* `ipt_limit` (=xt_limit)
* `ipt_LOG`
* `ipt_MASQUERADE`
* `ipt_multiport` (=xt_multiport)
* `ipt_owner` (=xt_owner)
* `ipt_recent` (=xt_recent)
* `ipt_REDIRECT`
* `ipt_REJECT`
* `ipt_state` (=xt_state)
* `ipt_TCPMSS` (=xt_TCPMSS)
* `ipt_tcpmss` (=xt_tcpmss)
* `ipt_TOS`
* `ipt_tos`
* `ip_conntrack` (=nf_conntrack)
* `ip_nat_ftp` (=nf_nat_ftp)
* `xt_iprange`
* `xt_comment`
* `ip6table_filter`
* `ip6table_mangle`
* `ip6t_REJECT' `

See [hypervisor usage](#hypervisor) if you want to disable it or [parameters](#parameters) if you want to edit this list.

Limitations
-----------

This module will only work on Debian 9.x versions.

Development
-----------

Free to send contributions, fork it, ...

License
-------

WTFPL (http://wtfpl.org/)

