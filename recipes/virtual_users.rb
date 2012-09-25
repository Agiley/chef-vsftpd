package "openssl"

case node[:vsftpd][:credential_storage].to_sym
  when :file
    package "libpam-pwdfile"
  when :mysql
    include_recipe "vsftpd::mysql"
    package "libpam-mysql"
end

template "/etc/pam.d/vsftpd" do
  source "#{node[:vsftpd][:credential_storage]}/vsftpd-pam.erb"
  owner "root"
  group "root"
  mode 0644
  backup false
end

directory node[:vsftpd][:user_config_dir] do
  owner "root"
  group "root"
  mode 0755
end

(node[:vsftpd][:virtual_users] || []).each do |u|
  directory u[:root].gsub('/./','/') do
    owner u[:local_user] || node[:vsftpd][:guest_username]
    group u[:group]
    recursive true
    mode u[:mode]
  end
  
  vsftpd_user u[:name] do
    provider "vsftpd_user_#{node[:vsftpd][:credential_storage]}"
    action :add
    username u[:name]
    password u[:password]
    root u[:root] || node[:vsftpd][:local_root]
    local_user u[:local_user] if u[:local_user]
  end
end
