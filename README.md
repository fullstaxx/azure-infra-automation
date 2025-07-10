# Secure Azure Infrastructure with Terraform and GitHub Actions

This project demonstrates how to deploy Azure infrastructure resources using:

- Infrastructure as Code with Terraform
- Remote state management using Azure Blob Storage
- CI/CD automation via GitHub Actions
- Secure authentication using Azure Service Principals
- Network-level security using NSGs with IP restrictions

---

## Features

- Infrastructure is deployed and managed via code
- Secure Terraform state stored in Azure Blob
- GitHub Actions pipeline for hands-free deployment and cleanup
- SSH access restricted to your IP address (Zero Trust principle)
- Full cleanup support via automated GitHub workflow or manual commands

---

## Architecture Overview

The following Azure resources are provisioned:

- Resource Group
- Virtual Network (VNet) and Subnet
- Linux Virtual Machine (Ubuntu)
- Network Interface (NIC)
- Network Security Group (NSG) with custom rule
- Azure Storage Account and Blob container for backend state

---

## GitHub Secrets Required

This project uses GitHub Actions with secure secrets. You'll need to define the following:

| Secret Name           | Description                                  |
|-----------------------|----------------------------------------------|
| `ARM_CLIENT_ID`       | Azure SPN App ID (`clientId`)                |
| `ARM_CLIENT_SECRET`   | Azure SPN Secret (`clientSecret`)            |
| `ARM_SUBSCRIPTION_ID` | Azure Subscription ID                        |
| `ARM_TENANT_ID`       | Azure Active Directory Tenant ID             |
| `ARM_ACCESS_KEY`      | Access key for Azure Storage account (Blob)  |

---

## Setup Instructions

### 1. Clone the repository

```bash
git clone https://github.com/YOUR_USERNAME/enterprise-azure-iac.git
cd enterprise-azure-iac
```

### 2. Create Azure backend for Terraform state

```bash
az group create --name terraform-backend-rg --location eastus

az storage account create \
  --name <yourstorageacctname> \
  --resource-group terraform-backend-rg \
  --sku Standard_LRS \
  --encryption-services blob

az storage container create \
  --name tfstate \
  --account-name <yourstorageacctname>
```

### 3. Create Service Principal

```bash
az ad sp create-for-rbac \
  --role="Contributor" \
  --scopes="/subscriptions/<your-subscription-id>" \
  --sdk-auth
```

Paste the output JSON into your GitHub Secrets.

### 4. Set your IP address in `main.tf`

Replace `"YOUR_IP"` in the NSG rule with your public IP:

```bash
curl ifconfig.me
```

---

## GitHub Actions Workflows

### deploy.yml (automatic)

Triggered on push to `main`:
- Runs `terraform init`, `plan`, and `apply`
- Provisions all infrastructure to Azure
- Uses remote state backend

### destroy.yml (manual)

Triggered manually from the Actions tab:
- Runs `terraform destroy -auto-approve`
- Safely removes all provisioned resources

---

## Cleanup

To avoid Azure charges, destroy resources when done:

Via GitHub:
- Go to **Actions**
- Select **Destroy all resources**
- Click **Run workflow**

Or via CLI:
```bash
terraform destroy -auto-approve
```

---

## Best Practices Followed

- Remote state stored securely in Azure Blob Storage
- No hardcoded credentials or IPs — all secrets stored via GitHub
- Service Principal access scoped to least privilege
- GitOps workflow using push-based automation
- Infrastructure built using repeatable, testable code

---

## Notes

- This infrastructure is intentionally minimal to serve as a secure foundation.
- You must bring your own credentials and not reuse placeholder values.
- All traffic to the VM is locked down to your IP for security.

---

## License

This project is open-source and provided for educational purposes only.
