#!/bin/bash

# Simple script to create a json file of all user accounts on the Docker UCP and then perform a bulk delete operation using the account information from the users.json file.
# Created by Richard Kiles

# Set UCP FQDN and login credentials
UCP_FQDN="your.ucp.fqdn:port"
USERNAME="admin"
PASSWORD="yourpassword"

# Collect user list based on account name
USER_LIST="$(curl -sk -X GET -u ${USERNAME}:${PASSWORD} https://${UCP_FQDN}/enzi/v0/accounts | jq -r '.accounts | .[] | select(.isOrg==false) | .name')"

# Create the users.json file and define the operations section
cat <<EOT > ./users.json
{
  "operations": [
EOT

# Create an entry in the users.json file for each account except the "admin" user.
for i in ${USER_LIST}
do
  if [ "${i}" != "admin" ]
  then
    echo '    {"op": "delete", "ref": "'${i}'"},' >> ./users.json
  fi
done

# Remove the trailing "," from the last user account listed in the user.json file
sed -i -e '$ s/.$//' users.json

# Append the trailing brackets to the users.json file
cat <<EOT >> ./users.json
  ]
}
EOT

# Example curl command to parse the users.json file and delete any listed accounts using the enzi api. Remove the comment to fully automate the script.
#curl -k --request PATCH -H "Content-Type: application/json" -u ${USERNAME}:${PASSWORD} -d "@users.json" "https://${UCP_FQDN}/enzi/v0/accounts/"
