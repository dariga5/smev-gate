#!/bin/sh

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

exec "$@"
