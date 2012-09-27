include_recipe "vsftpd::#{node['vsftpd']['install_method']}"

service "vsftpd" do
  supports :status => true, :stop => true, :start => true, :restart => true
  action :enable
end

directory "/etc/vsftpd" do
  owner "root"
  group "root"
  mode 0755
end

template node[:vsftpd][:config_path] do
  owner "root"
  group "root"
  mode 0644
  notifies :restart, resources(:service => "vsftpd"), :delayed
end

if node['vsftpd']['chroot_local_user'] or node['vsftpd']['chroot_list_enable']
  include_recipe "vsftpd::chroot_users"
end

if node['vsftpd']['virtual_users_enable']
  include_recipe "vsftpd::virtual_users"
end
