tmp_path = Chef::Config[:file_cache_path]
include_recipe 'java'
remote_file "#{tmp_path}/liferay.zip" do
  source node['liferay']['download_url']
  mode '0777'
  action :create
end

##################unzip the software in liferay home directory ################


bash 'Extract Liferay and tomcat archive' do
  cwd node['liferay']['install_location']
  user 'weloadm'
  code <<-EOH
    cp  #{tmp_path}/liferay.zip  #{node['liferay']['install_location']}
    unzip  #{node['liferay']['install_location']}/liferay.zip
  EOH
  not_if { ::Dir.exists?(node['liferay']['path']) }
end

ruby_block 'Set JAVA_HOME in catalina' do
    block do
      file = Chef::Util::FileEdit.new("#{node['tomcat']['path']}/bin/catalina.sh")
      file.insert_line_if_no_match(/JAVA_HOME=/, "JAVA_HOME=#{node['java']['java_home']}")
      file.insert_line_if_no_match(/JRE_HOME=/, "JRE_HOME=#{node['java']['jre_home']}")
      file.write_file
    end
  end
ruby_block 'Set JAVA_HOME in startup' do
    block do
      file = Chef::Util::FileEdit.new("#{node['tomcat']['path']}/bin/startup.sh")
      file.insert_line_if_no_match(/export JAVA_HOME=/, "export JAVA_HOME=#{node['java']['java_home']}")
      file.insert_line_if_no_match(/export JRE_HOME=/, "export JRE_HOME=#{node['java']['jre_home']}")
      file.write_file
    end
  end

remote_file "#{tmp_path}/ehcache.tar.gz" do
  source node['ehcache']['download_url']
  mode '0777'
  action :create
end

bash "unzip_ehcache and configure it " do
  user 'weloadm'
  code <<-EOH
    tar -xvzf "#{tmp_path}/ehcache.tar.gz" -C #{node['liferay']['install_location']}
    cp #{node['ehcache']['path']}/lib/*.jar   #{node['tomcat']['path']}/lib/
    printf '\n\nCLASSPATH="#{node['ehcache']['path']}/lib/slf4j-jdk14-1.7.25.jar:#{node['ehcache']['path']}/lib/slf4j-api-1.7.25.jar:#{node['ehcache']['path']}/lib/ehcache-2.10.5.jar"' >> #{node['tomcat']['path']}/bin/setenv.sh
    EOH
 not_if { ::Dir.exists?(node['ehcache']['path']) }
end
template "#{node['ehcache']['path']}/ehcache.xml" do
  source 'ehcache.erb'
end


directory "#{node['liferay']['path']}/deploy" do
  owner 'weloadm'
  group 'weloadm'
  mode '0755'
end
cookbook_file "#{node['liferay']['path']}/deploy/licence.xml" do
  source 'licence.xml'
  action :create
end

execute 'start the service' do
  user 'weloadm'
  command '/opt/SP/weloadm/software/liferay-ce-portal-7.0-ga3/tomcat-8.0.32/bin/startup.sh'
end
