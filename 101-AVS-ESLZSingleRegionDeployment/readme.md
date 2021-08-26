# 101-AVS-ESLZSingleRegionDeployment

```
az deployment sub create -n AVSDeploy -l SoutheastAsia -c -f "ESLZDeploy.deploy.json" -p "@ESLZDeploy.parameters.json"
```