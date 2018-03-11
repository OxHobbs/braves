#
# Cookbook:: braves
# Recipe:: registry
#
# Copyright:: 2018, The Authors, All Rights Reserved.

dsc_resource 'InstallIIS' do
  resource :WindowsFeature
  property :Name, 'web-server'
  property :Ensure, 'Present'
end

dsc_resource 'CreateHomePage' do
  resource :File
  property :Ensure, 'Present'
  property :Contents, <<-EOH
  <html><h3>My IP is #{node['ipaddress']} and my hostname is #{node['hostname']}</h3>
  <body>Oh and my favorite team is the Atlanta Braves</body>
  </html>
  EOH
  property :DestinationPath, 'c:/inetpub/wwwroot/default.htm' 
end

dsc_resource 'Add Registry Key' do
  resource :Registry
  property :Key, 'HKEY_LOCAL_MACHINE\SOFTWARE\baseball'
  property :Ensure, 'Present'
  property :ValueName, ''
end

dsc_resource 'required_reg_items' do
  resource :Registry
  property :Key, 'HKEY_LOCAL_MACHINE\SOFTWARE\baseball'
  property :Ensure, 'Present'
  property :ValueName, 'BestTeamNL'
  property :ValueData, ['Braves']
  property :ValueType, 'String'
end

dsc_resource 'al_team' do
  resource :Registry
  property :Key, 'HKEY_LOCAL_MACHINE\SOFTWARE\baseball'
  property :Ensure, 'Present'
  property :ValueName, 'BestTeamAL'
  property :ValueData, ['Diamondbacks']
  property :ValueType, 'String'
end

reboot 'reboot if registry items added' do
  action :nothing
  reason 'registry changes made that require reboot'
  delay_mins 0
  subscribes :reboot_now, 'dsc_resource[required_reg_items]', :immediately
end
