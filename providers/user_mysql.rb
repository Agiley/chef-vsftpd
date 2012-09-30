action :add do
  
  Chef::Log.info "Adding new user_mysql-resource: #{new_resource.inspect}"
  
  username = new_resource.username
  password = new_resource.password
  
  execute_sql_file do
    template_cookbook "vsftpd"
    template_path     '/tmp/add_vsftpd_user.sql'
    template_source   'mysql/add_user.sql.erb'
    
    variables :user       =>  username,
              :password   =>  password
  end

  if (node[:vsftpd][:create_user_configs])
    file "#{node[:vsftpd][:user_config_dir]}/#{new_resource.username}" do
      owner "root"
      group "root"
      mode 0644
      root = "local_root=#{new_resource.root.sub(%r!/\./.*!,'')}\n"
      user = "guest_username=#{new_resource.local_user}\n" unless new_resource.local_user.to_s.empty?
      content "#{root}#{user}"
      notifies :restart, resources(:service => "vsftpd"), :delayed
    end
  end
end

action :remove do
  username = new_resource.username
  password = new_resource.password
  
  execute_sql_file do
    template_cookbook "vsftpd"
    template_path     '/tmp/remove_vsftpd_user.sql'
    template_source   'mysql/remove_user.sql.erb'
    
    variables :user       =>  username,
              :password   =>  password
  end

  file "#{node[:vsftpd][:user_config_dir]}/#{new_resource.username}" do
    action :delete
    notifies :restart, resources(:service => "vsftpd"), :delayed
  end
end

def load_current_resource
  service "vsftpd" do
    supports :status => true, :stop => true, :start => true, :restart => true
  end
end