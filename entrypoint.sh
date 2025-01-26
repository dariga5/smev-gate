#!/bin/sh

if [[ ! -x $JAVA_HOME ]]; then
    $JAVA_HOME=/usr/lib/java
fi

if [[ ! -x $JRE_HOME ]]; then
    $JRE_HOME=/usr/lib/java/jre
fi


cat << EOF > /opt/adapter/config.ini

EOF

exec "$@"