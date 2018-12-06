#!/bin/bash

if [[ "${TEAMCITY_USER}" == "_" ]]
then
    echo "No Teamcity user set, exiting..."
    exit
fi

if [[ "${TEAMCITY_PWD}" == "_" ]]
then
    echo "No Teamcity password set, exiting..."
    exit
fi

ESC_TEAMCITY_HOST="$(echo $TEAMCITY_HOST | sed 's^\\^\\\\^g')"
ESC_TEAMCITY_PWD="$(echo $TEAMCITY_PWD | sed 's^\\^\\\\^g')"
ESC_TEAMCITY_USER="$(echo $TEAMCITY_USER | sed 's^\\^\\\\\\\\^g')"
sed -i "s^http://your-teamcity-server^$ESC_TEAMCITY_HOST^g" appsettings.json
sed -i "s^your-teamcity-user-password^$ESC_TEAMCITY_PWD^g" appsettings.json
sed -i "s^your-teamcity-user^$ESC_TEAMCITY_USER^g" appsettings.json

dotnet TeamCityTheatre.Web.dll