# == Class: proxmox6::hypervisor
#
# Manage the Proxmox hypervisor.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if it
#   has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should not be used in preference to class parameters  as of
#   Puppet 2.6.)
#
# === Examples
#
#  class { '::proxmox6::hypervisor':
#  }
#
# === Authors
#
# Gardouille <gardouille@gmail.com>
#
# === Copyright
#
# WTFPL <http://wtfpl.org/>
#
class proxmox6::hypervisor (
  $ve_pkg_ensure              = $proxmox6::params::ve_pkg_ensure,
  $ve_pkg_name                = $proxmox6::params::ve_pkg_name,
  $kernel_pkg_name            = $proxmox6::params::kernel_pkg_name,
  $rec_pkg_name               = $proxmox6::params::rec_pkg_name,
  $old_pkg_ensure             = $proxmox6::params::old_pkg_ensure,
  $old_pkg_name               = $proxmox6::params::old_pkg_name,
  $pve_enterprise_repo_ensure = $proxmox6::params::pve_enterprise_repo_ensure,
  $pveproxy_default_path      = $proxmox6::params::pveproxy_default_path,
  $pveproxy_default_content   = $proxmox6::params::pveproxy_default_content,
  $pveproxy_allow             = $proxmox6::params::pveproxy_allow,
  $pveproxy_deny              = $proxmox6::params::pveproxy_deny,
  $pveproxy_policy            = $proxmox6::params::pveproxy_policy,
  $pveproxy_service_name      = $proxmox6::params::pveproxy_service_name,
  $pveproxy_service_manage    = $proxmox6::params::pveproxy_service_manage,
  $pveproxy_service_enabled   = $proxmox6::params::pveproxy_service_enabled,
  $pve_modules_list           = $proxmox6::params::pve_modules_list,
  $pve_modules_file_path      = $proxmox6::params::pve_modules_file_path,
  $pve_modules_file_content   = $proxmox6::params::pve_modules_file_content,
  $pve_lvm_delay              = $proxmox6::params::pve_lvm_delay,
  $init_lvm_script_path       = $proxmox6::params::init_lvm_script_path,
  $init_lvm_script_content    = $proxmox6::params::init_lvm_script_content,
  $labs_firewall_rule         = $proxmox6::params::labs_firewall_rule,
  $cluster_master_ip          = undef,
  $cluster_name               = undef,
  $key_options                = undef,
) inherits proxmox6::params {

  include '::proxmox6::hypervisor::preconfig'
  include '::proxmox6::hypervisor::install'
  include '::proxmox6::hypervisor::config'
  include '::proxmox6::hypervisor::service'
  include '::proxmox6::hypervisor::cluster'

  Class['proxmox6::hypervisor::preconfig'] ->
  Class['proxmox6::hypervisor::install'] ->
  Class['proxmox6::hypervisor::config'] ->
  Class['proxmox6::hypervisor::service'] ->
  Class['proxmox6::hypervisor::cluster']

} # Public class: proxmox6::hypervisor
