#
# Cookbook:: braves
# Recipe:: custom_registry
#
# Copyright:: 2018, The Authors, All Rights Reserved.

braves_baseball 'my_team' do
  action :create
  team 'Diamondbacks' # I know they're in the AL
end
