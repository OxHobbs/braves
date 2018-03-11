# To learn more about Custom Resources, see https://docs.chef.io/custom_resources.html

# resource_name :baseball
property :team, String, default: 'Braves'

action :create do
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
    <body>Oh and my favorite team is the #{team}</body>
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
    property :ValueData, [team]
    property :ValueType, 'String'
  end

  reboot 'reboot if registry items added' do
    action :nothing
    reason 'registry changes made that require reboot'
    delay_mins 0
    subscribes :reboot_now, 'dsc_resource[required_reg_items]', :immediately
  end
end

action :delete do
  dsc_resource 'removeIIS' do
    resource :WindowsFeature
    property :Name, 'web-server'
    property :Ensure, 'Absent'
  end

  dsc_resource 'required_reg_items' do
    resource :Registry
    property :Key, 'HKEY_LOCAL_MACHINE\SOFTWARE\baseball'
    property :Ensure, 'Absent'
    property :ValueName, 'BestTeamNL'
    property :ValueData, [team]
    property :ValueType, 'String'
  end

  dsc_resource 'Remove Registry Key' do
    resource :Registry
    property :Key, 'HKEY_LOCAL_MACHINE\SOFTWARE\baseball'
    property :Ensure, 'Absent'
    property :ValueName, ''
  end

  reboot 'reboot if registry items removed' do
    action :nothing
    reason 'registry changes made that require reboot'
    delay_mins 0
    subscribes :reboot_now, 'dsc_resource[required_reg_items]', :immediately
  end
end
