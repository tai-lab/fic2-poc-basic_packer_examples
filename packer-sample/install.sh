#! /bin/bash -e

set -x

apt-get -y update
apt-get -y install openjdk-7-jre-headless curl wget tomcat7
service tomcat7 stop

CATALINA_BASE=/var/lib/tomcat7
rm -rf $CATALINA_BASE/webapps/ROOT

wget http://tomcat.apache.org/tomcat-7.0-doc/appdev/sample/sample.war -P $CATALINA_BASE/webapps

echo "570f196c4a1025a717269d16d11d6f37  $CATALINA_BASE/webapps/sample.war" | md5sum -c -
sync