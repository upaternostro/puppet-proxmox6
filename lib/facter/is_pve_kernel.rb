# Fact: is_pve_kernel
#
# Purpose: Returns true if the system runs a PVE kernel.
#
#
require 'facter'

Facter.add(:is_pve_kernel) do
  setcode do

    pve = if Facter.value(:kernelrelease) =~ /^*pve/
      'true'
    else
      'false'
    end

  end

end
