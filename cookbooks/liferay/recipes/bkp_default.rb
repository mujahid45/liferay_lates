package 'Install OpenJDK' do
    package_name 'java-1.8.0-openjdk'
end
 

bash "set the java home " do
  code <<-EOH
    echo "export JRE_HOME=$(readlink -f /usr/bin/java | sed "s:/bin/java::")" >> $HOME/.bash_profile
    echo "export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:/jre/bin/java::")" >> $HOME/.bash_profile
    source $HOME/.bash_profile
  EOH
end

  
bash "unzip_and_start the service" do
  code <<-EOH
    unzip "/var/liferay.zip" -d /var/
    mv "/var/liferay-ce-portal-7.0-ga3" "/var/liferay/"
    mkdir -p /var/liferay/liferay-ce-portal-7.0-ga3/deploy/
    EOH
end

bash "set the java home in catalina.sh" do
 code <<-EOH
    echo "JRE_HOME=$(readlink -f /usr/bin/java | sed "s:/bin/java::")" >> /var/liferay/tomcat-8.0.32/bin/catalina.sh
    echo "JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:/jre/bin/java::")" >> /var/liferay/tomcat-8.0.32/bin/catalina.sh
  EOH
end


bash "unzip_ehcache and configure it " do
  code <<-EOH
    tar -xvzf "/var/ehcache-2.10.5-distribution.tar.gz" -C /var/
    cp /var/ehcache-2.10.5/lib/*.jar   /var/liferay/tomcat-8.0.32/lib/ 
    printf '\n\n\nCLASSPATH="/var/ehcache-2.10.5/lib/slf4j-jdk14-1.7.25.jar:/var/ehcache-2.10.5/lib/slf4j-api-1.7.25.jar:/var/ehcache-2.10.5/lib/ehcache-2.10.5.jar"' >> /var/liferay/tomcat-8.0.32/bin/setenv.sh
    EOH
end

cookbook_file '/etc/systemd/system/liferay.service' do
  source 'liferay.service'
  action :create
end

cookbook_file '/var/liferay/liferay-ce-portal-7.0-ga3/deploy/licence.xml' do
  source 'licence.xml'
  action :create
end

service 'liferay' do
  action [:enable, :start]
end

