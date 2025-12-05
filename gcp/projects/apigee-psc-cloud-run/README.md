# Apigee X with Private Service Connect to Cloud Run - Terraform

This Terraform project automates the deployment of **Apigee X** with **Private Service Connect (PSC)** for both **northbound** (client to Apigee) and **southbound** (Apigee to Cloud Run) connectivity.

## Architecture

This setup creates:
- **Apigee X Organization** with PSC enabled (no VPC peering)
- **Cloud Run Service** with internal ingress
- **Internal Load Balancer** fronting Cloud Run
- **PSC Service Attachment** for Cloud Run backend
- **Apigee Endpoint Attachment** connecting to Cloud Run via PSC
- **Regional External Load Balancer** for public API access
- **PSC Network Endpoint Group** connecting LB to Apigee

## Prerequisites

- GCP Project with billing enabled
- Terraform >= 1.0
- `gcloud` CLI installed and authenticated
- Required IAM permissions:
  - Apigee Admin
  - Compute Network Admin
  - Cloud Run Admin
  - Service Usage Admin

## Project Structure

```
.
├── provider.tf           # Terraform and provider configuration
├── variables.tf          # Input variables
├── terraform.tfvars.example  # Example variables file
├── 00-network.tf         # VPC, subnets (apigee, PSC, proxy)
├── 01-apigee.tf          # Apigee org, instance, environment
├── 02-cloud-run.tf       # Cloud Run, Internal LB, PSC attachment
├── 03-load-balancer.tf   # External LB, PSC NEG
├── outputs.tf            # Output values
└── README.md             # This file
```

## Quick Start

### 1. Enable Required APIs

```bash
gcloud services enable \
  apigee.googleapis.com \
  cloudresourcemanager.googleapis.com \
  compute.googleapis.com \
  run.googleapis.com \
  servicenetworking.googleapis.com
```

### 2. Configure Variables

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:
```hcl
project_id      = "your-project-id"
region          = "us-east1"
zone            = "us-east1-a"
apigee_hostname = "api.example.com"
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Plan and Apply

```bash
# Review the plan
terraform plan

# Apply the configuration
terraform apply
```

**Note**: Apigee instance creation takes 20-30 minutes.

### 5. Get Outputs

```bash
terraform output
```

## Deployment Steps

The Terraform configuration deploys resources in this order:

1. **Network Resources** (`00-network.tf`)
   - VPC network
   - Apigee subnet
   - PSC subnet
   - Proxy-only subnet for load balancer

2. **Apigee Resources** (`01-apigee.tf`)
   - Apigee organization (with PSC enabled)
   - Apigee instance
   - Apigee environment
   - Environment group
   - Instance-environment attachment

3. **Cloud Run Resources** (`02-cloud-run.tf`)
   - Cloud Run service (internal ingress)
   - Serverless NEG
   - Internal Load Balancer (backend, URL map, proxy, forwarding rule)
   - PSC Service Attachment
   - Apigee Endpoint Attachment

4. **Load Balancer Resources** (`03-load-balancer.tf`)
   - External IP address
   - PSC Network Endpoint Group (pointing to Apigee)
   - Regional backend service
   - URL map
   - Target HTTP proxy
   - Forwarding rule
   - Internal PSC endpoint (optional)

## Post-Deployment Steps

### 1. Deploy API Proxy

After Terraform completes, you need to deploy an API proxy to Apigee:

```bash
# Get the endpoint attachment host
ENDPOINT_HOST=$(terraform output -raw endpoint_attachment_host)

# Create API proxy directory
mkdir -p apiproxy/proxies apiproxy/targets

# Create proxy endpoint
cat > apiproxy/proxies/default.xml <<EOF
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<ProxyEndpoint name="default">
    <HTTPProxyConnection>
        <BasePath>/cloudrun</BasePath>
    </HTTPProxyConnection>
    <RouteRule name="default">
        <TargetEndpoint>default</TargetEndpoint>
    </RouteRule>
</ProxyEndpoint>
EOF

# Create target endpoint
cat > apiproxy/targets/default.xml <<EOF
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<TargetEndpoint name="default">
    <HTTPTargetConnection>
        <URL>http://\${ENDPOINT_HOST}</URL>
    </HTTPTargetConnection>
</TargetEndpoint>
EOF

# Create API proxy config
cat > apiproxy/cloudrun-proxy.xml <<EOF
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<APIProxy name="cloudrun-proxy">
    <DisplayName>Cloud Run Proxy</DisplayName>
    <Description>API Proxy to Cloud Run via PSC</Description>
</APIProxy>
EOF

# Create bundle
zip -r cloudrun-proxy.zip apiproxy

# Get variables
PROJECT_ID=$(terraform output -raw apigee_org_id | cut -d'/' -f2)
APIGEE_ENV=$(terraform output -raw apigee_environment)
AUTH=$(gcloud auth print-access-token)

# Import API proxy
curl -X POST \
  "https://apigee.googleapis.com/v1/organizations/\$PROJECT_ID/apis?action=import&name=cloudrun-proxy" \
  -H "Authorization: Bearer \$AUTH" \
  -F "file=@cloudrun-proxy.zip"

# Deploy API proxy
curl -X POST \
  "https://apigee.googleapis.com/v1/organizations/\$PROJECT_ID/environments/\$APIGEE_ENV/apis/cloudrun-proxy/revisions/1/deployments" \
  -H "Authorization: Bearer \$AUTH" \
  -H "Content-Type: application/json"
```

### 2. Test the Setup

```bash
# Get the load balancer IP
LB_IP=$(terraform output -raw load_balancer_ip)

# Test external access
curl -v http://\$LB_IP/cloudrun

# For internal access (from a VM in the VPC)
PSC_IP=$(terraform output -raw psc_endpoint_ip)
curl -v http://\$PSC_IP/cloudrun
```

## Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| project_id | GCP Project ID | string | required |
| region | GCP Region | string | us-east1 |
| zone | GCP Zone | string | us-east1-a |
| apigee_env | Apigee Environment Name | string | eval |
| apigee_envgroup | Apigee Environment Group Name | string | eval-group |
| apigee_hostname | Apigee Hostname | string | api.example.com |
| vpc_network_name | VPC Network Name | string | apigee-network |
| subnet_name | Subnet Name | string | apigee-subnet |
| subnet_range | Subnet CIDR Range | string | 10.0.0.0/24 |
| psc_subnet_name | PSC Subnet Name | string | psc-subnet |
| psc_subnet_range | PSC Subnet CIDR Range | string | 10.1.0.0/24 |
| proxy_subnet_name | Proxy Subnet Name | string | proxy-subnet |
| proxy_subnet_range | Proxy Subnet CIDR Range | string | 10.2.0.0/24 |
| cloud_run_service | Cloud Run Service Name | string | backend-service |
| cloud_run_image | Cloud Run Container Image | string | us-docker.pkg.dev/cloudrun/container/hello |
| lb_name | Load Balancer Name | string | apigee-external-lb |

## Outputs

| Name | Description |
|------|-------------|
| apigee_org_id | Apigee Organization ID |
| apigee_instance_id | Apigee Instance ID |
| apigee_service_attachment | Apigee Service Attachment for PSC |
| endpoint_attachment_host | Apigee Endpoint Attachment Host |
| load_balancer_ip | External Load Balancer IP Address |
| psc_endpoint_ip | Internal PSC Endpoint IP Address |
| test_external_url | Test URL for external access |
| test_internal_url | Test URL for internal access |

## Cleanup

```bash
terraform destroy
```

**Note**: Apigee organization deletion may not be supported for evaluation organizations.

## Troubleshooting

### Apigee Instance Creation Timeout

Apigee instance creation takes 20-30 minutes. If Terraform times out, the instance may still be creating. Check status:

```bash
gcloud alpha apigee organizations describe --organization=PROJECT_ID
```

### Load Balancer Proxy Subnet Error

Ensure the proxy-only subnet exists and has the correct purpose:

```bash
gcloud compute networks subnets describe proxy-subnet --region=us-east1
```

### Cloud Run Access Denied

Grant Apigee service account access to Cloud Run:

```bash
gcloud run services add-iam-policy-binding backend-service \
  --region=us-east1 \
  --member="serviceAccount:APIGEE_SA@PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/run.invoker"
```

## Architecture Benefits

- **No VPC Peering**: Simplified network architecture using PSC
- **Private Backend**: Cloud Run remains internal-only
- **Public API Access**: External load balancer provides internet access
- **Enterprise Security**: Multiple layers of security with PSC and IAM

## References

- [Apigee X Documentation](https://cloud.google.com/apigee/docs)
- [Private Service Connect](https://cloud.google.com/vpc/docs/private-service-connect)
- [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
