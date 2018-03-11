# # encoding: utf-8

# Inspec test for recipe braves::custom_registry

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

describe windows_feature('web-server') do
  it { should be_installed }
end

describe file('c:/inetpub/wwwroot/default.htm') do
  it { should exist }
  its('content') { should match /team is/ }
end

key = 'HKEY_LOCAL_MACHINE\SOFTWARE\baseball'
describe registry_key key do
  it { should exist }
  it { should have_property 'BestTeamNL' }
  its('BestTeamNL') { should eq 'Diamondbacks' }
  # its('WorstTeamNL') { should eq 'StLouisCardinals'}
end
