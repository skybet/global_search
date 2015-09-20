require 'serverspec'

set :backend, :exec

describe "Role Searching" do
  describe file('/tmp/hosts') do
    it { should be_file }
    its(:content) { should contain 'host-a' }
    its(:content) { should contain 'host-b' }
    its(:content) { should contain 'node-d' }
    its(:content) { should contain 'node-e' }
    its(:content) { should contain 'node-a' }
    its(:content) { should_not contain 'node-b' }
    its(:content) { should_not contain 'node-c' }
  end
end
