#!/bin/bash

# Get current subscriptionId
subscriptionId=$(az account show --query id -o tsv)

# Get Azure regions
regions=$(az account list-locations --query "[].name" -o tsv)

# Initialize CSV header
output=""

# Loop through each region
for region in $regions; do
    # Skip if region is blank or empty
    if [ -z "$region" ]; then
        continue
    fi

    # Console animation
    printf "Processing region: %s...\r" "$region"

    # Make POST call
    response=$(az rest --method post --uri "https://management.azure.com/subscriptions/$subscriptionId/providers/Microsoft.AVS/locations/$region/checkQuotaAvailability?api-version=2023-03-01" 2>/dev/null)

    # Parse response
    av64=$(echo $response | jq -r '.hostsRemaining.av64')
    gp=$(echo $response | jq -r '.hostsRemaining.gp')
    he=$(echo $response | jq -r '.hostsRemaining.he')
    he2=$(echo $response | jq -r '.hostsRemaining.he2')
    hv=$(echo $response | jq -r '.hostsRemaining.hv')
    quotaEnabled=$(echo $response | jq -r '.quotaEnabled')

    # Skip if quotaEnabled is blank or empty
    if [ -z "$quotaEnabled" ]; then
        continue
    fi

    # Calculate total
    total=$((av64 + gp + he + he2 + hv))

    # Append to output
    output+="$region,$quotaEnabled,$av64,$gp,$he,$he2,$hv,$total\n"
done

# Print CSV header
echo "Region,QuotaEnabled,AV64,AV36T,AV36,AV36P,AV52,Total"

# Sort and print output
echo -e "$output" | sort -t ',' -k2,2r -k8,8nr | sed '/^$/d'
