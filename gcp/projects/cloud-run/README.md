# Deploy Python Image to Cloud Run

### Gcloud Login
```bash
gcloud auth application-default login
```

## Terraform Commands

### Enable APIs
```bash
gcloud services enable artifactregistry.googleapis.com
gcloud services enable run.googleapis.com
``` 

### Initialize Terraform
```bash
cd ..
terraform init
```

### Plan Changes
```bash
terraform plan -var-file=test.tfvars
```

### 1. Create Artifact Registry Repository
First, we need to create the repository so we can push our image to it.
```bash
terraform apply -target=google_artifact_registry_repository.repo -var-file=test.tfvars
```

### 2. Build and Push Image
Now that the repository exists, we can build and push the Docker image.

```bash
# Configure Docker to authenticate with Artifact Registry
gcloud auth configure-docker us-central1-docker.pkg.dev

# Get the repository location from Terraform output
REPO_LOCATION=$(terraform output -raw artifact_registry_location)

# Build the image
cd src
docker build -t python-app:1.0 .
cd ..

# Tag the image
docker tag python-app:1.0 ${REPO_LOCATION}/python-app:1.0

# Push the image
docker push ${REPO_LOCATION}/python-app:1.0
```

### 3. Deploy Cloud Run Service
With the image in place, we can now deploy the Cloud Run service.

```bash
terraform apply -var-file=test.tfvars
```

### Destroy Resources
```bash
terraform destroy -var-file=test.tfvars
```
