require 'spec_helper'
describe 'proxmox6' do

  context 'with defaults for all parameters' do
    it { should contain_class('proxmox6') }
  end
end
