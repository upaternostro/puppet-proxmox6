#is_proxmox.rb

Facter.add("is_proxmox") do
  setcode do
    FileTest.exists?("/etc/pve/")
  end
end
