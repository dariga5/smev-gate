#!/bin/sh

runAdapter() {  
  JRE=/bin/java
  DEFAULT_USER_PORT=8778
  INIFILE=config.ini
  USER_JAVA=

  if [ -f "$INIFILE" ]; then
      # echo "Reading $INIFILE"

      USER_JAVA=$(awk -F "=" '/^java/ {gsub(/[ \t]/, "", $2); print $2}' $INIFILE)        

      if [ -n "$USER_JAVA" ]; then
        USER_JAVA="$USER_JAVA$JRE"     
      fi

      USER_PORT=$(awk -F "=" '/^port/ {gsub(/[ \t]/, "", $2); print $2}' $INIFILE)    
            LOCAL_STORAGE=$(awk -F "=" '/^local_storage/ {gsub(/[ \t]/, "", $2); print $2}' $INIFILE)
  else
    echo "$INIFILE not exists"
    if [ -n "$USER_JAVA" ]; then
      USER_JAVA="$JAVA_HOME/jre$JRE"
    else
      echo "JAVA_HOME variable not set"
    fi
  fi

  if [ -n "$USER_JAVA" ]; then
    echo 1 >> /dev/null
  else
    echo "Java path not SET. Please SET correct path to JRE in config.ini."
    exit 1
  fi  

  if [ -n "$USER_PORT" ]; then
    echo 1 >> /dev/null
  else
    USER_PORT=$DEFAULT_USER_PORT
  fi

  DEFAULT_LOCAL_STORAGE=/tmp/adapter

  if [ -n "$LOCAL_STORAGE" ]; then
    echo 1 >> /dev/null
  else
    LOCAL_STORAGE=$DEFAULT_LOCAL_STORAGE
  fi

  # echo "java: $USER_JAVA"
  # echo "port: $USER_PORT"

  export port="$USER_PORT"

  $USER_JAVA -Dfile.encoding=UTF-8 -Dlocal_storage="$LOCAL_STORAGE" -jar bpm-service.jar > /dev/null 2>&1
  # $USER_JAVA -Dfile.encoding=UTF-8 -Dlogback=logback_debug.xml -jar "$JAR_NAME" > /dev/null 2>&1 &

  echo $! > $pidFile
}



set -e

if [[ ! -x $JAVA_HOME ]]; then
    JAVA_HOME=/usr/lib/java
fi

if [[ ! -x $JRE_HOME ]]; then
    JRE_HOME=/usr/lib/java/jre
fi


cat << EOF > /opt/adapter/config.ini
[Settings]
version=$VERSION
java=$JRE_HOME
port=$SERVICE_PORT
local_storage=$ADAPTER_DIR
service_name=AdapterRoiv
storage_path=$ADAPTER_DIR
incoming_attachments_path=$ADAPTER_DIR/in
storage_type=postgresql
storage_adapter_url=jdbc:postgresql://$DBHOST:$DBPORT/$DBNAME?user=$DBUSER&password=$DBPASS
storage_configuration_url=jdbc:postgresql://$DBHOST:$DBPORT/$DBNAME?user=$DBUSER&password=$DBPASS
ws_integration_host=0.0.0.0
push_notifications_host=localhost
push_notifications_path=/push
push_notifications_port=7992
smev_http_adapter_url=http://localhost:$SERVICE_PORT
inner_integration_adapter_url=http://localhost:$SERVICE_PORT
send_original_messages=false
jwt_token_name=adaptersecretname
jwt_token_secret=adaptersecrettoken
jwt_token_expiration=4800
jwt_token_refresh=3600
EOF

"$@"
