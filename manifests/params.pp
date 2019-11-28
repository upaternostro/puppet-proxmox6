# == Class: proxmox6::params
#
class proxmox6::params {
  case $::osfamily {
    'Debian': {
      if $::operatingsystem == 'Debian' and versioncmp($::operatingsystemrelease, '10.0') >= 0 {
        # Virtual Environment packages
        $ve_pkg_ensure              = 'present'
        $ve_pkg_name                = [ 'proxmox-ve', 'ksm-control-daemon', 'open-iscsi', 'pve-firmware' ]

        # PVE Kernel
#        $kernel_pkg_name            = [ 'pve-kernel-4.13.13-6-pve' ]
        $kernel_pkg_name            = [ 'pve-kernel-5.0' ]

        # Recommended packages
        $rec_pkg_name               = [ 'bridge-utils', 'lvm2', 'ntp', 'postfix', 'ssh' ]

        # Old useless packages
        $old_pkg_ensure             = 'absent'
        $old_pkg_name               = [ 'acpid',  'linux-image-amd64', 'linux-image-3.16.0-4-amd64' ]

        # Manage PVE Enterprise repository (need a subscription)
        $pve_enterprise_repo_ensure = 'absent'

        # Pveproxy access restriction
        $pveproxy_default_path      = '/etc/default/pveproxy'
        $pveproxy_default_content   = 'proxmox6/hypervisor/pveproxy_default.erb'
        $pveproxy_allow             = '127.0.0.1'
        $pveproxy_deny              = 'all'
        $pveproxy_policy            = 'allow'
        $pveproxy_service_name      = 'pveproxy'
        $pveproxy_service_manage    = true
        $pveproxy_service_enabled   = true

        # Manage additionnals modules
        $pve_modules_list           = [ 'iptable_filter', 'iptable_mangle', 'iptable_nat', 'ipt_length', 'ipt_limit', 'ipt_LOG', 'ipt_MASQUERADE', 'ipt_multiport', 'ipt_owner', 'ipt_recent', 'ipt_REDIRECT', 'ipt_REJECT', 'ipt_state', 'ipt_TCPMSS', 'ipt_tcpmss', 'ipt_TOS', 'ipt_tos', 'ip_conntrack', 'ip_nat_ftp', 'xt_iprange', 'xt_comment', 'ip6table_filter', 'ip6table_mangle', 'ip6t_REJECT' ]
        $pve_modules_file_path      = '/etc/modules-load.d/proxmox.conf'
        $pve_modules_file_content   = 'proxmox6/hypervisor/proxmox_modules.conf.erb'

        # Boot
        $pve_lvm_delay              = true
        $init_lvm_script_path       = '/etc/initramfs-tools/scripts/local-top/lvm-manual'
        $init_lvm_script_content    = 'proxmox6/hypervisor/initramfs-lvm-manual.erb'

        # Firewall
        $labs_firewall_rule         = false

      }

    }
    default: {
          fail("Proxmox Virtual Environment only works with Debian system; And the OpenVZ configuration has been tested only with Debian family; So osfamily (${::osfamily}) or lsbdistid (${::lsbdistid}) is unsupported")

    }

  }

} # Private class: proxmox6::params
