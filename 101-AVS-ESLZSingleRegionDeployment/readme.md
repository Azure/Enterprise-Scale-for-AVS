# 101-AVS-ESLZSingleRegionDeployment
Status: Awaiting PG Signoff, possible 2nd revision (Awaiting CSET area architecture confirmation)


```
az deployment sub create -n AVSDeploy -l SoutheastAsia -c -f "ESLZDeploy.deploy.json" -p "@ESLZDeploy.parameters.json"
```