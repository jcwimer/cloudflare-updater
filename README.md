# cloudflare-updater
This updates a Cloudflare record with your current public ipv4 address.

```
: "${CLOUDFLARE_API:?Need to set CLOUDFLARE_API non-empty}"
: "${PROXIED:?Need to set PROXIED to true or false non-empty}"
: "${RECORD_TO_MODIFY:?Need to set RECORD_TO_MODIFY without a trailing . non-empty}"
: "${ZONE_NAME:?Need to set ZONE_NAME non-empty}"
```
* CLOUDFLARE_API - your api key 
* PROXIED - will the record be proxied through Cloudflare? true or false
* ZONE_NAME - the root zone of the record
* RECORD_TO_MODIFY - the record you want to modify

# Example

This will update test.codywimer.com:
`docker run -d -e CLOUDFLARE_API="XXXXXXXXXXXXXXXXXXXXXX" -e ZONE_NAME="codywimer.com" -e RECORD_TO_MODIFY="test" -e PROXIED=false jcwimer/cloudflare-updater`