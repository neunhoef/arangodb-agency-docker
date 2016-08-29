#/bin/bash

set -e

sleep 15 

if [ -z "$MARATHON_APP_ID" ] ; then
    echo "This Docker image is supposed to be started via Marathon."
    sleep 30
    exit 1
fi
if [ -z "$AGENCY_SIZE" ] ; then
    echo "Need environment variable AGENCY_SIZE set."
    sleep 30
    exit 2
fi

export MARATHON=http://marathon.mesos:8080/v2/apps

curl -o /tmp/appinfo.json http://marathon.mesos:8080/v2/apps$MARATHON_APP_ID

echo AppInfo:
cat /tmp/appinfo.json

jq -r < /tmp/appinfo.json > /tmp/extraargs.txt 'reduce (.app.tasks[] | .host + ":" + (.ports[0] | tostring)) as $item (""; . + " --agency.endpoint=tcp://" + $item)'

echo ExtraArgs:
cat /tmp/extraargs.txt

export ARANGO_NO_AUTH=1

echo /entrypoint.sh --agency.activate true --agency.size $AGENCY_SIZE --agency.supervision false --agency.wait-for-sync true --server.endpoint tcp://0.0.0.0:$PORT0 --agency.my-address tcp://$HOST:$PORT0 --server.statistics false `cat /tmp/extraargs.txt`
exec /entrypoint.sh --agency.activate true --agency.size $AGENCY_SIZE --agency.supervision false --agency.wait-for-sync true --server.endpoint tcp://0.0.0.0:$PORT0 --agency.my-address tcp://$HOST:$PORT0 --server.statistics false `cat /tmp/extraargs.txt`


