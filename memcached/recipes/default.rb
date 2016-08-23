  #
# Cookbook Name:: Memcached
# Recipe:: default
#
# Copyright 2014, loremipsum Inc
#
# All rights reserved - Do Not Redistribute
#
if node[:staging_redis_memcached]
  memcached_servers = node[:staging_redis_memcached][:hostname]
elsif node[:optimize]
  memcached_servers =  "localhost"
else
  memcached_servers =  "services"
end
namespace = "helpkit"
# node[:opsworks][:layers][:utility][:instances].each do |instance_name, instance_config|
#   if instance_name == "services"
#     memcached_servers.push(instance_config[:private_ip])
#   end
# end
Chef::Log.info "private_dns of memcached servers #{memcached_servers}"

search("aws_opsworks_app").each do |app|
  Chef::Log.info "private_dns of memcached servers #{memcached_servers} , #{app}, #{app['shortname']}"
  template "/data/#{app['shortname']}/shared/config/memcached.yml" do
    source "memcached.yml.erb"
    owner 'deploy'
    group 'nginx'
    mode 0744
    variables(
      :hostnames => memcached_servers
    )
    only_if do
      File.directory?("/data/#{app['shortname']}/shared/config")
    end
  end

  Chef::Log.info "private_dns of memcached servers #{memcached_servers} , #{app}, #{app['shortname']}"
  template "/data/#{app['shortname']}/shared/config/dalli.yml" do
    source "memcached.yml.erb"
    owner 'deploy'
    group 'nginx'
    mode 0744
    variables(
      :hostnames => memcached_servers,
      :namespace => namespace
    )
    only_if do
      File.directory?("/data/#{app['shortname']}/shared/config")
    end
  end

  Chef::Log.info "API dalli servers : private_dns of memcached servers #{memcached_servers} , #{app}, #{app['shortname']}"
  template "/data/#{app['shortname']}/shared/config/dalli_api.yml" do
    source "memcached.yml.erb"
    owner 'deploy'
    group 'nginx'
    mode 0744
    variables(
      :hostnames => memcached_servers, # should be changed to API specific dalli servers
      :namespace => namespace
    )
    only_if do
      File.directory?("/data/#{app['shortname']}/shared/config")
    end
  end

end

if search("aws_opsworks_instance", "self:true").first['hostname'].include?("services") || node[:optimize]
  include_recipe "memcached::setup"
end
