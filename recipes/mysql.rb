if (node['mysql'])
  include_recipe "mysql::server"
  include_recipe "mysql-optimization"
  
  execute_sql_file do
    template_cookbook "vsftpd"
    template_path     '/tmp/create_vsftpd_database.sql'
    template_source   'mysql/create_database.sql.erb'
  end
else
  Chef::Log.info("MySQL attributes haven't been set. Aborting.")
end