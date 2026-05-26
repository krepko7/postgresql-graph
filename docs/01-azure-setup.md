# Step 1: Create Azure PostgreSQL Flexible Server

## Prerequisites

- Azure CLI installed ([Install guide](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli))
- An active Azure subscription

## Login to Azure

```bash
az login
```

## Set Variables

```bash
# Customize these values
RESOURCE_GROUP="rg-graph-workshop"
LOCATION="eastus"
SERVER_NAME="pgflex-graph-workshop"    # Must be globally unique
ADMIN_USER="graphadmin"
ADMIN_PASSWORD="YourStr0ngP@ssword!"   # Change this!
DB_NAME="graphworkshop"
```

## Create Resource Group

```bash
az group create \
    --name $RESOURCE_GROUP \
    --location $LOCATION
```

## Create Azure PostgreSQL Flexible Server

```bash
az postgres flexible-server create \
    --resource-group $RESOURCE_GROUP \
    --name $SERVER_NAME \
    --location $LOCATION \
    --admin-user $ADMIN_USER \
    --admin-password $ADMIN_PASSWORD \
    --sku-name Standard_B2s \
    --tier Burstable \
    --storage-size 32 \
    --version 16 \
    --yes
```

> **Note:** The `Standard_B2s` SKU is cost-effective for workshops. For production, consider `Standard_D2s_v3` or higher.

## Configure Firewall Rules

Allow your current IP address:

```bash
az postgres flexible-server firewall-rule create \
    --resource-group $RESOURCE_GROUP \
    --name $SERVER_NAME \
    --rule-name AllowMyIP \
    --start-ip-address $(curl -s ifconfig.me) \
    --end-ip-address $(curl -s ifconfig.me)
```

For workshop environments, you may allow all Azure services:

```bash
az postgres flexible-server firewall-rule create \
    --resource-group $RESOURCE_GROUP \
    --name $SERVER_NAME \
    --rule-name AllowAllAzureServices \
    --start-ip-address 0.0.0.0 \
    --end-ip-address 0.0.0.0
```

## Create the Workshop Database

```bash
az postgres flexible-server db create \
    --resource-group $RESOURCE_GROUP \
    --server-name $SERVER_NAME \
    --database-name $DB_NAME
```

## Verify Connectivity

```bash
psql "host=${SERVER_NAME}.postgres.database.azure.com \
      port=5432 \
      dbname=${DB_NAME} \
      user=${ADMIN_USER} \
      sslmode=require"
```

## Connection String

Your connection string for later steps:

```
Host: <SERVER_NAME>.postgres.database.azure.com
Port: 5432
Database: graphworkshop
Username: graphadmin
Password: <your-password>
SSL Mode: Require
```

## Cost Considerations

| SKU | Monthly Cost (approx.) | Use Case |
|-----|----------------------|----------|
| Standard_B1ms | ~$13/month | Minimal testing |
| Standard_B2s | ~$26/month | Workshop (recommended) |
| Standard_D2s_v3 | ~$100/month | Production |

> **Tip:** Delete the resource group after the workshop to avoid ongoing charges:
> ```bash
> az group delete --name $RESOURCE_GROUP --yes --no-wait
> ```

---

**Next:** [Enable Apache AGE Extension →](02-enable-age.md)
