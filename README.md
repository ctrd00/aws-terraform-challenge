# AWS/Terraform Code Challenge 

## Run locally

Install: ```uv sync```

Run: ```FLASK_DEBUG=True uv run flask run```

## Configuration

Copy example env and fill in the necessary values:

```bash
cp .env.example .env
```

## Docker

Build the image:

```bash
docker build -t merapar-challenge .
```

Run in local:

```bash
docker run --env-file .env -p 5001:5000 merapar-challenge
```

## Deploy to AWS App Runner

Load config into environment and initialise Terraform:

```bash
set -a && source .env && set +a
terraform init
```

Create the ECR repository:

```bash
terraform apply -target=aws_ecr_repository.app
```

Build and push Docker image to ECR:

```bash
ECR_URL=$(aws ecr describe-repositories --repository-names merapar-challenge --query 'repositories[0].repositoryUri' --output text)
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR_URL

docker build --platform linux/amd64 -t "${ECR_URL}:latest" .
docker push "${ECR_URL}:latest"
```

Deploy the rest of the infrastructure:

```bash
terraform apply
```

The app URL is printed at the end of `terraform apply` as `app_url`.


