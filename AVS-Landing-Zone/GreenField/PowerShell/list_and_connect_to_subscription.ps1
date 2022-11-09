Login-AzAccount
$subscriptions = Get-AzSubscription | Sort-Object SubscriptionName | Select-Object Name,SubscriptionId
[int]$subscriptionCount = $subscriptions.count
Write-output "Found" $subscriptionCount "Subscriptions"
$i = 0
foreach ($subscription in $subscriptions)
{
  $subValue = $i
  $subText = [string]$subValue + " : " + $subscription.Name + " ( " + $subscription.SubscriptionId + " ) "
  Write-output $subText
  $i++
}
Do 
{
  [int]$subscriptionChoice = read-host -prompt "Select number & press enter"
} 
until ($subscriptionChoice -le $subscriptionCount)

$selectedSub = "You selected " + $subscriptions[$subscriptionChoice].Name
Write-output $selectedSub
Set-AzContext -SubscriptionId $subscriptions[$subscriptionChoice].SubscriptionId