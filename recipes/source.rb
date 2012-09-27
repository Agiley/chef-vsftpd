include_recipe "build-essential"

source_url        =   "https://security.appspot.com/downloads/vsftpd-#{node[:vsftpd][:version]}.tar.gz"
src_filepath      =   "#{Chef::Config['file_cache_path'] || '/tmp'}/vsftpd-#{node[:vsftpd][:version]}.tar.gz"

packages          =   ['libssl-dev', 'libpam0g-dev', 'libcap2']
packages.each do |dev_pkg|
  package dev_pkg
end

remote_file source_url do
  source source_url
  path src_filepath
  backup false
end

node.set[:vsftpd][:binary_path] = "/usr/sbin/vsftpd"
node.set[:vsftpd][:config_path] = "/etc/vsftpd/vsftpd.conf"

bash "compile_vsftpd_source" do
  cwd ::File.dirname(src_filepath)
  code <<-EOH
    mkdir -p /usr/local/man/man8/
    mkdir -p /usr/local/man/man5/
    tar zxf #{::File.basename(src_filepath)} -C #{::File.dirname(src_filepath)}
    cd vsftpd-#{node[:vsftpd][:version]}
    make && make install
  EOH
end

template "/etc/init.d/vsftpd" do
  source 'init.sh.erb'
  owner "root"
  group "root"
  mode 0755
end
