include_recipe "build-essential"

source_url        =   "https://security.appspot.com/downloads/vsftpd-#{node[:vsftpd][:version]}.tar.gz"
src_filepath      =   "#{Chef::Config['file_cache_path'] || '/tmp'}/vsftpd-#{node[:vsftpd][:version]}.tar.gz"

packages          =   ['lib32gcc1', 'libssl-dev', 'libpam0g-dev', 'libcap2', 'libpam-ldap']
packages.each do |dev_pkg|
  package dev_pkg
end

remote_file source_url do
  source source_url
  path src_filepath
  backup false
end

node.set[:vsftpd][:binary_path] = "/usr/local/sbin/vsftpd"
node.set[:vsftpd][:config_path] = "/etc/vsftpd.conf"
node.set[:vsftpd][:background]  = true

bash "compile_vsftpd_source" do
  cwd ::File.dirname(src_filepath)
  code <<-EOH
    mkdir -p /usr/local/man/man8/
    mkdir -p /usr/local/man/man5/
    tar zxf #{::File.basename(src_filepath)} -C #{::File.dirname(src_filepath)}
    export LD_LIBRARY_PATH=/lib/x86_64-linux-gnu/:/usr/lib32
    cd vsftpd-#{node[:vsftpd][:version]} && ./configure
    make && make install
  EOH
end

template "/etc/init.d/vsftpd" do
  source 'init.sh.erb'
  owner "root"
  group "root"
  mode 0755
end
