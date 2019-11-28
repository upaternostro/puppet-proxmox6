proxmox6::hypervisor::group { 'sysadmin':
  role  => 'Administrator',
  users => [ 'user1@pam', 'toto@pve' ],
}
proxmox6::hypervisor::group { 'audit':
  role  => 'PVEAuditor',
  users => [ 'user2@pam' ],
}
