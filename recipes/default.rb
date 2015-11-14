#
# Cookbook Name:: tomcat-all
# Recipe:: default
#
# Copyleft (L) 2015 Sayantan Das
# 
#
# No rights reserved - Please Redistribute
#


user "myapp" do
    comment "Hello MyApp User"
    home "/home/myapp"
    shell "/bin/bash"
    supports  :manage_home => true
    password "$1$q1w2e3r4$sPQwbfin.7dmhPQ87kOfD/"
end

directory "/home/myapp/apps" do
    owner "myapp"
    group "myapp"
    mode 0755
 action :create
end

#directory "/home/myapp/apps/jdku51" do
#    owner "myapp"
#    group "myapp"
#    mode 0755
 #action :nothing
#end


# set new directory
directory "/home/myapp/www" do
    owner "myapp"
    group "myapp"
    mode 0755
 #action :nothing
end

# ark 'jdk' do
#  #url 'http://www.dropbox.com/s/j5fyjyxzhitegau/jdk-7u51-linux-x64.tar.gz'
#  url  'http://download.oracle.com/otn/java/jdk/7u51-b13/jdk-7u51-linux-x64.tar.gz'
#  accept_oracle_download_terms "true"
#  path "/home/myapp/apps/jdku51" 
#  owner 'myapp'
#  group 'myapp'
#  action :put
# end

#remote_file '/home/myapp/apps/jdku51/jdk-7u51-linux-x64.tar.gz' do
# source 'http://www.dropbox.com/s/j5fyjyxzhitegau/jdk-7u51-linux-x64.tar.gz'
#  source 'http://download.oracle.com/otn/java/jdk/7u51-b13/jdk-7u51-linux-x64.tar.gz'
#  headers({"Cookie" => "oraclelicense=accept-securebackup-cookie"})
#  owner 'myapp'
#  group 'myapp'
#  mode '0755'
# notifies :run, "bash[install_program]", :immediately
#end

remote_file "#{Chef::Config[:file_cache_path]}/jdk-8u65-linux-x64.tar.gz" do
  source "http://download.oracle.com/otn-pub/java/jdk/8u65-b17/jdk-8u65-linux-x64.tar.gz"
  headers({"Cookie" => "oraclelicense=accept-securebackup-cookie"})
  owner 'myapp'
  group 'myapp'
  mode '0755'
 notifies :run, "bash[install_program]", :immediately
end


bash "install_program" do
  user "myapp"
  cwd "/home/myapp/apps"
  code <<-EOH
    tar zxvf #{Chef::Config[:file_cache_path]}/jdk-8u65-linux-x64.tar.gz
   EOH
#  action :nothing
end

ruby_block "delete_environement" do
  block do
    editBashrc = Chef::Util::FileEdit.new("/home/myapp/.bash_profile")
  # editBashrc.search_file_delete_line(#{node['tomcat-all']['java_home']} environment settings)
   #editBashrc.search_file_delete_line(/^.*#Auto-generated from Cookbook by Sayantan - tomcat-all.*$/)
   editBashrc.search_file_delete_line(/^.*export JAVA_HOME=#{node['tomcat-all']['java_home']}.*$/)
   editBashrc.search_file_delete_line(/^.*export PATH=PATH#{node['tomcat-all']['java_path']}.*$/)
   editBashrc.write_file 
 end
 action :create
end

execute "create_environment" do
    cwd "/home/myapp"                                                           
    user "myapp"                                                                
    action :run   
    environment ({'HOME' => '/home/myapp', 'USER' => 'myapp'})  
   command "echo -e 'export JAVA_HOME=#{node['tomcat-all']['java_home']}' >> /home/myapp/.bash_profile && echo -e '\nexport PATH=$PATH:#{node['tomcat-all']['java_path']}' >> /home/myapp/.bash_profile"
end

execute "create_environment" do 
   cwd "/home/myapp"                                                           
    user "myapp"                                                                
    action :run   
    environment ({'HOME' => '/home/myapp', 'USER' => 'myapp'})  
    command "source ~/.bash_profile"
end

#execute "create_environment_root" do
#    command "echo -e '\nexport JAVA_HOME=#{node['tomcat-all']['java_home']}' >> /root/.bash_profile && echo -e '\nexport PATH=$PATH:#{node#['tomcat-all']['java_path']}' >> /root/.bash_profile && source ~/.bash_profile"
#end

#include_recipe "java"
# Build download URL
tomcat_version = node['tomcat-all']['version']
major_version = tomcat_version[0]
download_url = "#{node['tomcat-all']['download_server']}dist/tomcat/tomcat-#{major_version}/v#{tomcat_version}/bin/apache-tomcat-#{tomcat_version}.tar.gz"


# Create group
group node['tomcat-all']['group']

# Create user
user node['tomcat-all']['user'] do
  group node['tomcat-all']['group']
  system true
  shell '/bin/bash'
end

# set new directory
#directory "/home/myapp/apps/tomcat7" do
 #   owner "tomcat"
 #   group "tomcat"
 #   mode 0755
 #action :nothing
#end


# Download and unpack tomcat
ark 'tomcat' do
  url download_url
  version node['tomcat-all']['version']
  #home_dir node['tomcat-all']['tomcat_home']
 
 path "/home/myapp/apps/"
# home_dir "/home/myapp/apps/tomcat"
  owner node['tomcat-all']['user']
  group node['tomcat-all']['group']
   action :put
end

#tarball = "tomcat-#{node['tomcat-all']['version']}.tar.gz"
#download_file = "#{node['tomcat-all']['download_url']}/#{tarball}"

#remote_file "#{Chef::config['file_cache_path']}/#{tarball}" do
#  source download_file
#  action :create_if_missing
#  mode 00644
#end
  
#zk_install_dir=node['tomcat-all']['install_dir']

#execute "tar" do
#  user "tomcat"
#  group "tomcat"
#  cwd zk_install_dir
#  action :run
#  command "tar xvzf #{Chef::config[:file_Cache_path]}/#{tarball}"
#  not_if{ ::File.directory?("#{zk_install_dir}/tomcat")}
#end

# Log rotation (catalina.out)
template '/etc/logrotate.d/tomcat' do
  source 'logrotate.conf.erb'
  mode '0644'
  owner node['tomcat-all']['user']
  group node['tomcat-all']['group']
end

# Tomcat server configuration
template "#{node['tomcat-all']['tomcat_home']}/conf/server.xml" do
  source 'server.conf.erb'
  mode '0644'
  owner node['tomcat-all']['user']
  group node['tomcat-all']['group']
end

# Tomcat catalina configuration
template "#{node['tomcat-all']['tomcat_home']}/bin/setenv.sh" do
  source 'setenv.sh.erb'
  mode '0755'
  owner node['tomcat-all']['user']
  group node['tomcat-all']['group']
end

# Tomcat init script configuration
template "/etc/init.d/tomcat#{major_version}" do
  source 'init.conf.erb'
  mode '0755'
  owner node['tomcat-all']['user']
  group node['tomcat-all']['group']
end

include_recipe 'tomcat-all::set_tomcat_home'

# Create default catalina.pid file to prevent restart error for 1st run of coookbook.
file "#{node['tomcat-all']['tomcat_home']}/catalina.pid" do
  owner node['tomcat-all']['user']
  group node['tomcat-all']['group']
  mode '0755'
  action :create
  not_if { ::File.exist?("#{node['tomcat-all']['tomcat_home']}/catalina.pid") }
end

# Enabling tomcat service and restart the service if subscribed template has changed.
service "tomcat#{major_version}" do
  supports :restart => true
  action :enable
  subscribes :restart, "template[/etc/init.d/tomcat#{major_version}]", :delayed
  subscribes :restart, "template[#{node['tomcat-all']['tomcat_home']}/bin/setenv.sh]", :delayed
  subscribes :restart, "template[#{node['tomcat-all']['tomcat_home']}/conf/server.xml]", :delayed
end

#ruby_block "delete_environement" do
#  block do
#    editBashrc = Chef::Util::FileEdit.new("/root/.bash_profile")
#    editBashrc.search_file_delete_line(/^.*#{node['tomcat-all']['java_home']} environment settings.*$/)
#    editBashrc.search_file_delete_line(/^.*#Auto-generated from Cookbook by Sayantan - tomcat-all.*$/)
#    editBashrc.search_file_delete_line(/^.*export JAVA_HOME=#{node['tomcat-all']['java_home']}.*$/)
#    editBashrc.search_file_delete_line(/^.*export PATH=#{node['tomcat-all']['java_path']}.*$/)
#    editBashrc.write_file 
#  end
#  action :create
#end

