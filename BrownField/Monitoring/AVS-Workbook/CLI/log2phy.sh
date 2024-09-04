#!/bin/bash

# Set the subscription ID parameter with a default value
subscriptionId=${1:-$(az account show --query id --output tsv)}

# Get the list of locations for the subscription
locations=$(az account list-locations --query "[].{Name:name, Region:metadata.physicalLocation, ZoneMappings:availabilityZoneMappings}" --output json)

# Output the availability zone mappings in a tabular format
echo "Subscription ID | Region | Location | Logical Zone | Physical Zone"
echo "----------------|--------|----------|--------------|--------------"
for location in $(echo "$locations" | jq -r '.[] | @base64'); do
    _jq() {
        echo ${location} | base64 --decode | jq -r ${1}
    }
    name=$(_jq '.Name')
    region=$(_jq '.Region')
    zoneMappings=$(_jq '.ZoneMappings')
    if [ "$zoneMappings" != "null" ]; then
        for zoneMapping in $(echo "$zoneMappings" | jq -r '.[] | @base64'); do
            _zone_jq() {
                echo ${zoneMapping} | base64 --decode | jq -r ${1}
            }
            logicalZone=$(_zone_jq '.logicalZone')
            physicalZone=$(_zone_jq '.physicalZone')
            echo "$subscriptionId | $region | $name | $logicalZone | $physicalZone"
        done
    fi
done