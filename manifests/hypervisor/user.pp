# == Define: proxmox6::hypervisor::user
#
# Manage users allowed to WebGUI
#
# === Parameters
#
# [*user*]
#   _default_: +$title+, the title/name of the ressource
#
#   Is the username.
#
# [*group*]
#   _default_: +undef+
#
#   The group list for the user.
#
# [*permission_file*]
#   _default_: +/etc/pve/user.cfg+
#
#   The file where group's informations are stored.
#
define proxmox6::hypervisor::user ( $user = $title, $group = '', $permission_file = '/etc/pve/user.cfg' ) {

  Exec {
    path      => ['/bin','/sbin','/usr/bin','/usr/sbin'],
    logoutput => 'on_failure',
  }

  # Manage user only if Proxmox is available
  if $::is_proxmox == 'true' {

    ## Work with an if/else test because the user must be create before adding
    # it to a group ...

    # If a group was set
    if empty($group) == false {
      # Create the user in Proxmox
      exec { "add_${user}_user":
        command => "pveum useradd ${user}",
        unless  => "grep '^user:${user}' ${permission_file}",
      }
      ->
      # Then add this user to a group
      exec { "add_${user}_to_${group}":
        command => "pveum usermod ${user} -group ${group}",
        # The grep command should return 2 lines (minium) that match the pattern
        unless  => "test `grep '${user}' -c ${permission_file}` -ge 2",
      }
    }
    else {
      # Create the user in Proxmox
      exec { "add_${user}_user":
        command => "pveum useradd ${user}",
        unless  => "grep '^user:${user}' ${permission_file}",
      }
    }
  }

} # Public ressource: proxmox6::hypervisor::user
