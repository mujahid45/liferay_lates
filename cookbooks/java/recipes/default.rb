#
# Cookbook:: java
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.
package 'unzip' do
   package_name  'unzip'
end

user "#{node['functional_user']['name']}" do
  comment 'A functional user'
  manage_home true
  password 'redhat'
end

directory node['liferay']['install_location'] do
  owner node['functional_user']['name']
  group node['functional_user']['name']
  recursive true
  mode '0755'
end
bash "download java" do
  cwd node['liferay']['install_location']
  code <<-EOH
     wget --no-check-certificate -c --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u191-b12/2787e4a523244c269598db4e85c51e0c/jdk-8u191-linux-x64.tar.gz
     tar -zxvf jdk-*
   EOH
 not_if  { ::Dir.exists?(node['java']['java_home']) }
   end
 ruby_block 'Set JAVA_HOME in users bash profie' do
    block do
      file = Chef::Util::FileEdit.new(node['home']['bashprofile'])
      file.insert_line_if_no_match(/export JAVA_HOME=/, "export JAVA_HOME=#{node['java']['java_home']}")
      file.insert_line_if_no_match(/export JRE_HOME=/, "export JRE_HOME=#{node['java']['jre_home']}")
      file.insert_line_if_no_match(/export PATH=/, "export PATH=$PATH:$JAVA_HOME/bin/:$JRE_HOME/bin")
      file.write_file
    end
  end
bash "set the java home in bashprofile" do
  code <<-EOH
    source "#{node['home']['bashprofile']}"
   EOH
   end

