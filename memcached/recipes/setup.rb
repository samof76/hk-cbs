package 'memcached' do
  action :upgrade
end

include_recipe 'memcached::service'

service 'monit' do
  action :nothing
end

template '/etc/sysconfig/memcached' do
  source 'memcached.sysconfig.erb'
  owner 'root'
  group 'root'
  mode 0644
  variables(
    :instance_type => search("aws_opsworks_instance", "self:true").first[:instance_type],
    :user => node[:memcached][:user],
    :port => node[:memcached][:port]
  )
  notifies :restart, "service[memcached]", :immediately
end

template "/etc/monit.d/memcached.monitrc" do
  source 'memcached.monitrc.erb'
  owner 'root'
  group 'root'
  mode 0644
  notifies :restart, "service[monit]"
end
