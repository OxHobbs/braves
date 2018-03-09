#
# Cookbook:: braves
# Recipe:: registry
#
# Copyright:: 2018, The Authors, All Rights Reserved.

dsc_resource 'Add Registry Key' do
  resource :Registry
  property :Key, 'HKEY_LOCAL_MACHINE\SOFTWARE\Braves'
  property :Ensure, 'Present'
  property :ValueName, ''
end

dsc_resource 'required_reg_items' do
  resource :Registry
  property :Key, 'HKEY_LOCAL_MACHINE\SOFTWARE\Braves'
  property :Ensure, 'Present'
  property :ValueName, 'BestTeamNL'
  property :ValueData, ['AtlantaBraves']
  property :ValueType, 'String'
end

reboot 'reboot if registry items added' do
  action :nothing
  reason 'registry changes made that require reboot'
  delay_mins 0
  subscribes :reboot_now, 'dsc_resource[required_reg_items]', :immediately
end
