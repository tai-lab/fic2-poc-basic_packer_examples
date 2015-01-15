#! /bin/bash -e

set -x

D=$(pwd)

apt-get -y update
apt-get -y install openjdk-7-jre-headless curl wget tomcat7
service tomcat7 stop

CATALINA_BASE=/var/lib/tomcat7
rm -rf $CATALINA_BASE/webapps/ROOT

mv $D/feedsync.war $CATALINA_BASE/webapps/

echo "a7050730df95813182e17ec3746405f1  $CATALINA_BASE/webapps/feedsync.war" | md5sum -c -
sync


# CATALINA_HOME=/usr/local/tomcat

# cat <<EOF > /etc/environment

# CATALINA_HOME=$CATALINA_HOME
# PATH="$CATALINA_HOME/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"
# EOF

# mkdir -p "$CATALINA_HOME"
# cd $CATALINA_HOME

# TOMCAT_MAJOR=8
# TOMCAT_VERSION=8.0.15
# TOMCAT_TGZ_URL=https://www.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz

# curl -SL "$TOMCAT_TGZ_URL" -o tomcat.tar.gz
# tar -xvf tomcat.tar.gz --strip-components=1
# rm bin/*.bat
# rm tomcat.tar.gz*

# wget http://tomcat.apache.org/tomcat-7.0-doc/appdev/sample/sample.war -P $CATALINA_HOME/webapps