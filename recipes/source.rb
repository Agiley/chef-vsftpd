include_recipe "build-essential"

source_url        =   "https://security.appspot.com/downloads/vsftpd-#{node[:vsftpd][:version]}.tar.gz"
src_filepath      =   "#{Chef::Config['file_cache_path'] || '/tmp'}/vsftpd-#{node[:vsftpd][:version]}.tar.gz"

remote_file source_url do
  source source_url
  path src_filepath
  backup false
end

packages      =   ['libssl-dev', 'libpam0g-dev', 'libcap2']

node.set[:vsftpd][:binary_path] = "/usr/sbin/vsftpd"

packages.each do |dev_pkg|
  package dev_pkg
end

configure_flags   =   (node[:vsfpd][:source][:configure_flags] && node[:vsfpd][:source][:configure_flags].any?) ? node[:vsfpd][:source][:configure_flags].join(" ") : ""
user              =   node[:vsfpd][:source][:user]      ?   node[:vsfpd][:source][:user]   :   "root"
group             =   node[:vsfpd][:source][:user]      ?   node[:vsfpd][:source][:group]  :   "root"

bash "compile_vsftpd_source" do
  cwd ::File.dirname(src_filepath)
  code <<-EOH
    tar zxf #{::File.basename(src_filepath)} -C #{::File.dirname(src_filepath)}
    cd vsftpd-#{node[:vsftpd][:version]}.tar.gz
    make && make install
  EOH
end

template "/etc/init.d/vsftpd" do
  source 'init.sh.erb'
  owner "root"
  group "root"
  mode 0755
end
