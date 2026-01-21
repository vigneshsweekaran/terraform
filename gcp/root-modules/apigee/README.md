# Apigee X Refactored Root Module

This Terraform module deploys **Apigee X** and a **Regional External Load Balancer**, connected via Private Service Connect (PSC). It refactors the setup into reusable modules and configures mult-environment support.

## Architecture
- **VPC Network**: Managed by `modules/vpc` (supports optional PSC/Proxy subnets).
- **Apigee X**: Managed by `modules/apigee` (Org, Instance, Environments, Group, TargetServers).
- **Load Balancer**: Managed by `modules/regional-external-loadbalancer` (uses PSC NEG to talk to Apigee).

## Usage

1. **Initialize**:
   ```bash
   terraform init
   ```

2. **Configure Variables** (`terraform.tfvars`):
   ```hcl
   project_id      = "your-project-id"
   region          = "us-east1"
   apigee_hostname = "api.example.com"
   enable_load_balancer = true
   ```

3. **Apply**:
   ```bash
   terraform apply
   ```

This will automatically create two environments:
- **dev**: configured with target servers `target-server-1` (mocktarget) and `target-server-2` (mocktarget/xml).
- **qa**: configured with target servers `target-server-1` (httpbin/get) and `target-server-2` (httpbin/anything).

## Deploying an API Proxy

After infrastructure deployment, you must deploy an API proxy to test connectivity. We recommend the **Bundle Approach**.

### Prerequisites

Get the necessary outputs:
```bash
export AUTH=$(gcloud auth print-access-token)
export PROJECT_ID=$(terraform output -raw apigee_org_id)
```

### Option 1: Bundle Approach (Classic) - **Recommended for Production**

This approach is best suited for **Production** environments as it fits naturally into CI/CD pipelines (GitOps).

Run the following script to create, bundle, and deploy a proxy with **two target endpoints** (`target-server-1` and `target-server-2`).
Authentication uses the header `x-target` to route to specific targets (Default is `target-server-1`).

```bash
# 1. Setup Directories
mkdir -p apiproxy/proxies apiproxy/targets

# 2. Create Proxy Endpoint (Routes based on Header)
cat > apiproxy/proxies/default.xml <<EOF
<ProxyEndpoint name="default">
  <HTTPProxyConnection>
    <BasePath>/target-test</BasePath>
  </HTTPProxyConnection>
  <RouteRule name="route-target-1">
    <TargetEndpoint>target1</TargetEndpoint>
  </RouteRule>
  <RouteRule name="route-target-2">
    <TargetEndpoint>target2</TargetEndpoint>
  </RouteRule>
</ProxyEndpoint>
EOF

# 3. Create Target Endpoint 1 (target-server-1)
cat > apiproxy/targets/target1.xml <<EOF
<TargetEndpoint name="target1">
    <HTTPTargetConnection>
        <LoadBalancer>
            <Server name="target-server-1"/>
        </LoadBalancer>
        <Path>/</Path>
    </HTTPTargetConnection>
</TargetEndpoint>
EOF

# 4. Create Target Endpoint 2 (target-server-2)
cat > apiproxy/targets/target2.xml <<EOF
<TargetEndpoint name="target2">
    <HTTPTargetConnection>
        <LoadBalancer>
            <Server name="target-server-2"/>
        </LoadBalancer>
        <Path>/json</Path>
    </HTTPTargetConnection>
</TargetEndpoint>
EOF

# 5. Create Config
cat > apiproxy/target-test.xml <<EOF
<APIProxy name="target-test">
    <DisplayName>Target Server Test</DisplayName>
</APIProxy>
EOF

# 6. Zip and Deploy
zip -r target-test.zip apiproxy

# Import
curl -X POST "https://apigee.googleapis.com/v1/$PROJECT_ID/apis?action=import&name=target-test" \
  -H "Authorization: Bearer $AUTH" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@target-test.zip"

# Deploy to dev environment
curl -X POST "https://apigee.googleapis.com/v1/$PROJECT_ID/environments/dev/apis/target-test/revisions/1/deployments" \
  -H "Authorization: Bearer $AUTH"

# Deploy to qa environment

curl -X POST "https://apigee.googleapis.com/v1/$PROJECT_ID/environments/qa/apis/target-test/revisions/1/deployments" \
  -H "Authorization: Bearer $AUTH"
```

### 3. Test the Proxy

Once deployed, you can test it via the External Load Balancer.

```bash
# Get Load Balancer IP and Hostname
export LB_IP=$(terraform output -raw load_balancer_ip)
export HOSTNAME=$(terraform output -raw apigee_hostname)

# Test Target 1 (Default)
curl -v "http://$LB_IP/target-test" -H "Host: api.example.com"

# Test Target 2 (via Header)
curl -v "http://$LB_IP/target-test" -H "Host: api.example.com"
```

## Outputs
- `load_balancer_ip`: Public IP of the LB.
- `apigee_org_id`: Organization ID.
- `environment_names`: List of created environments.
