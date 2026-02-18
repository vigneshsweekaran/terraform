# GKE Autopilot Private Cluster — Terraform

This Terraform project creates a **Private GKE Autopilot Cluster** on Google Cloud Platform, along with all required infrastructure:

- **VPC** with dedicated subnets for GKE nodes and the Bastion Host
- **Private GKE Autopilot Cluster** with PSC control plane
- **Artifact Registry** (Remote Repository — Docker Hub pull-through cache)
- **Bastion Host** for private cluster access via IAP

## Architecture

```
VPC (gke-network)
├── gke-subnet (10.0.0.0/25)
│   ├── Secondary: pods     (10.1.0.0/21)
│   └── Secondary: services (10.0.0.128/25)
└── bastion-subnet (10.0.1.0/25)
    └── Bastion Host (e2-micro)

GKE Autopilot Cluster (Private)
└── Control Plane → PSC endpoint (IP from gke-subnet primary range)

Artifact Registry
└── docker-hub-remote (Remote → Docker Hub)
```

## Prerequisites

- Terraform >= 1.3
- `gcloud` CLI authenticated
- GCP Project with billing enabled
- Required permissions: `roles/container.admin`, `roles/compute.networkAdmin`, `roles/artifactregistry.admin`

## Usage

### 1. Clone and Configure

```bash
cd terraform/gcp/projects/gke-autopilot-cluster
```

Edit `terraform.tfvars`:
```hcl
project_id   = "your-project-id"
region       = "us-central1"
cluster_name = "autopilot-cluster-1"
network_name = "gke-network"
```

### 2. Enable Required APIs

```bash
gcloud services enable \
  container.googleapis.com \
  compute.googleapis.com \
  artifactregistry.googleapis.com \
  iap.googleapis.com
```

### 3. Deploy

```bash
terraform init
terraform plan -var -file=test.tfvars
terraform apply -var-file=test.tfvars
terraform destroy -var-file=test.tfvars
```

---

## Post-Creation Steps

### Step 1: SSH into Bastion Host

```bash
export PROJECT_ID=your-project-id
export REGION=us-central1

gcloud compute ssh bastion-host \
  --zone=${REGION}-a \
  --tunnel-through-iap \
  --project=$PROJECT_ID
```

### Step 2: Install kubectl (Inside the Bastion)

```bash
sudo apt-get update
sudo apt-get install -y kubectl google-cloud-sdk-gke-gcloud-auth-plugin
```

### Step 3: Get Cluster Credentials

```bash
export CLUSTER_NAME=autopilot-cluster-1
export REGION=us-central1

gcloud container clusters get-credentials $CLUSTER_NAME \
  --region $REGION \
  --internal-ip
```

> `--internal-ip` tells `kubectl` to communicate with the cluster's private IP address via PSC.

### Step 4: Verify Nodes

```bash
kubectl get nodes -o wide
```

You should see nodes with `INTERNAL-IP` but no `EXTERNAL-IP`.

### Step 5: Deploy a Test App (via Artifact Registry)

```bash
export PROJECT_ID="folkloric-grid-484511-e7"
export REGION=us-central1

# Pull nginx via the remote Artifact Registry (Docker Hub cache)
IMAGE_PATH=${REGION}-docker.pkg.dev/${PROJECT_ID}/docker-hub-remote/nginx

kubectl create deployment nginx --image=$IMAGE_PATH --port=80
```

> **Note:** Autopilot provisions nodes dynamically. The first deployment may take a few minutes.

### Step 6: Check Pods

```bash
kubectl get pods -w
```

Wait for the pod status to become `Running`.

### Step 7: Expose via Regional External Load Balancer

The **GKE Ingress Controller** (`ingress-gce`) is installed by default — no additional installation needed.

```bash
# Create the Service
kubectl expose deployment nginx --type=NodePort --target-port=80 --port=80

# Create the Ingress
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
  annotations:
    kubernetes.io/ingress.class: "gce-regional-external"
spec:
  defaultBackend:
    service:
      name: nginx
      port:
        number: 80
EOF
```

Check the Ingress for the assigned IP:
```bash
kubectl get ingress nginx-ingress --watch
```

---

## Cleanup

```bash
terraform destroy
```

---

## File Structure

| File | Description |
|---|---|
| `vpc.tf` | VPC, subnets, secondary ranges |
| `gke.tf` | Private Autopilot Cluster |
| `artifact-registry.tf` | Remote Docker Hub repository |
| `instances.tf` | Bastion Host + IAP firewall rule |
| `variables.tf` | Input variables |
| `outputs.tf` | Useful outputs |
| `versions.tf` | Provider versions |

## Outputs

After `terraform apply`, the following outputs are available:

| Output | Description |
|---|---|
| `cluster_name` | GKE cluster name |
| `cluster_region` | Cluster region |
| `bastion_name` | Bastion host name |
| `get_credentials_command` | Ready-to-run `gcloud` command |
| `artifact_registry_repo` | Artifact Registry repo name |
