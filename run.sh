#!/bin/bash

: "${CLOUDFLARE_API:?Need to set CLOUDFLARE_API non-empty}"
: "${PROXIED:?Need to set PROXIED to true or false non-empty}"
: "${RECORD_TO_MODIFY:?Need to set RECORD_TO_MODIFY without a trailing . non-empty}"
: "${ZONE_NAME:?Need to set ZONE_NAME non-empty}"

# API Needed Permissions
# Zone - Zone Settings - Read
# Zone - Zone - Read
# Zone - DNS - Edit
# Set the zone resources to:
# Include - All zones
# Test cloudflare api key
while ls > /dev/null; do
	api_success=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/user/tokens/verify" \
	      -H "Authorization: Bearer ${CLOUDFLARE_API}" \
	      -H "Content-Type:application/json" | jq .success)

	if [ "${api_success}" == "true" ]; then
	  echo API key is working
	else
	  echo API key not working... Exiting...
	  exit 1
	fi

	all_zones=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones" \
	  -H "Authorization: Bearer ${CLOUDFLARE_API}" \
	  -H "Content-Type: application/json")

	zone_to_modify=$(echo $all_zones | jq ".result[] | select(.name == \"${ZONE_NAME}\" )")
	echo Zone to modify: ${zone_to_modify}
	zone_to_modify_id=$(echo ${zone_to_modify} | jq .id | sed 's/"//g')
	echo Zone to modify id: ${zone_to_modify_id}

	# get public ip
	# dig +short myip.opendns.com @resolver1.opendns.com
	# or
	# dig TXT +short o-o.myaddr.l.google.com @ns1.google.com

	my_wan_ip="$(dig +short myip.opendns.com @resolver1.opendns.com)"
	echo "My WAN/Public IP address: ${my_wan_ip}"

	record_to_modify=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/${zone_to_modify_id}/dns_records" \
	     -H "Authorization: Bearer ${CLOUDFLARE_API}" \
	     -H "Content-Type:application/json" \
	     | jq -c ".result[] | select(.name == \"${RECORD_TO_MODIFY}.${ZONE_NAME}\" )")
	echo Record to modify: ${record_to_modify}
	record_to_modify_id=$(echo ${record_to_modify} | jq .id | sed 's/"//g')
	record_to_modify_content=$(echo ${record_to_modify} | jq .content | sed 's/"//g')
	echo Record to modify id: ${record_to_modify_id}
	echo Record to modify content: ${record_to_modify_content}
	if [ "${my_wan_ip}" == "${record_to_modify_content}" ]; then
	  echo Record is correct.
	else
	  echo Record is ${record_to_modify_content}... setting record to ${my_wan_ip}...
	  curl --silent -X PUT "https://api.cloudflare.com/client/v4/zones/${zone_to_modify_id}/dns_records/${record_to_modify_id}" \
	       -H "Authorization: Bearer ${CLOUDFLARE_API}" \
	       -H "Content-Type: application/json" \
	       --data "{\"type\":\"A\",\"name\":\"${RECORD_TO_MODIFY}.${ZONE_NAME}\",\"content\":\"${my_wan_ip}\",\"ttl\":1,\"proxied\":${PROXIED}}"
	fi
	sleep 60s;
done