# To learn more about Custom Resources, see https://docs.chef.io/custom_resources.html

# resource_name :baseball
property :nl_team, String, default: 'Braves'
property :al_team, String, default: 'Diamondbacks'

action :create do
  teams = {
    BestTeamNL: nl_team,
    BestTeamAL: al_team
  }

  dsc_resource 'InstallIIS' do
    resource :WindowsFeature
    property :Name, 'web-server'
    property :Ensure, 'Present'
  end

  # dsc_resource 'CreateHomePage' do
  #   resource :File
  #   property :Ensure, 'Present'
  #   property :Contents, <<-EOH
  #   <html><h3>My IP is #{node['ipaddress']} and my hostname is #{node['hostname']}</h3>
  #   <body><p>Oh and the best NL team is the #{teams[:BestTeamNL]}</p>
  #   <p>The best AL team is #{teams[:BestTeamAL]}</p>
  #   </body>
  #   </html>
  #   EOH
  #   property :DestinationPath, 'c:/inetpub/wwwroot/default.htm' 
  # end

  template 'c:/inetpub/wwwroot/default.htm' do
    source 'default.htm.erb'
    action :create
    variables(
      nl_team: teams[:BestTeamNL],
      al_team: teams[:BestTeamAL]
    )
  end

  dsc_resource 'Add Registry Key' do
    resource :Registry
    property :Key, 'HKEY_LOCAL_MACHINE\SOFTWARE\baseball'
    property :Ensure, 'Present'
    property :ValueName, ''
  end

  teams.keys.each do |key|
    dsc_resource 'required_reg_items' do
      resource :Registry
      property :Key, 'HKEY_LOCAL_MACHINE\SOFTWARE\baseball'
      property :Ensure, 'Present'
      property :ValueName, key
      property :ValueData, [teams[key]]
      property :ValueType, 'String'
    end
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

  teams.keys.each do |key|
    dsc_resource 'required_reg_items' do
      resource :Registry
      property :Key, 'HKEY_LOCAL_MACHINE\SOFTWARE\baseball'
      property :Ensure, 'Absent'
      property :ValueName, key
      property :ValueData, [teams[key]]
      property :ValueType, 'String'
    end
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
