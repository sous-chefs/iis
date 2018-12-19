control 'Manager Property' do
  title 'Check manager is setup and listening correctly'

  describe port(19500) do
    it { should be_listening }
  end
  describe windows_feature('Web-Mgmt-Service') do
    it { should be_installed }
  end
end
