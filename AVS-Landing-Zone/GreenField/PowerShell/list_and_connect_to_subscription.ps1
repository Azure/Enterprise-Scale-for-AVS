Login-AzAccount
$subscriptions = Get-AzSubscription | Sort-Object SubscriptionName | Select-Object Name,SubscriptionId
[int]$subscriptionCount = $subscriptions.count
Write-output "Found" $subscriptionCount "Subscriptions"
$i = 0
foreach ($subscription in $subscriptions)
{
  $subValue = $i
  Write-output $subValue ":" $subscription.Name "("$subscription.SubscriptionId")"
  $i++
}
Do 
{
  [int]$subscriptionChoice = read-host -prompt "Select number & press enter"
} 
until ($subscriptionChoice -le $subscriptionCount)

Write-output "You selected" $subscriptions[$subscriptionChoice].Name
Set-AzContext -SubscriptionId $subscriptions[$subscriptionChoice].SubscriptionId