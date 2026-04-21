# AWS Infrastructure Tracker

A full-stack application that scans your AWS account in real time and inventories your cloud resources. Built as a cloud engineering portfolio project.

## What It Does

- Connects to AWS via boto3 and scans live infrastructure
- Pulls VPCs, subnets, and NAT Gateways from your AWS account
- Stores snapshots in PostgreSQL for historical tracking
- Exposes a REST API to trigger scans and retrieve results

## Architecture

```
Internet
    │
    ▼
Public Subnets (us-east-1a + us-east-1b)   ← ALB lives here
    │
    ▼
Private App Subnets (us-east-1a + us-east-1b)  ← FastAPI backend
    │
    ▼
Isolated DB Subnets (us-east-1a + us-east-1b)  ← PostgreSQL RDS
```

### VPC Design
- 1 VPC (`10.0.0.0/16`) across 2 availability zones
- 2 public subnets for the load balancer (`10.0.1.0/24`, `10.0.2.0/24`)
- 2 private subnets for the backend API (`10.0.3.0/24`, `10.0.4.0/24`)
- 2 isolated subnets for the database (`10.0.5.0/24`, `10.0.6.0/24`)
- 2 NAT Gateways (one per AZ) for high availability outbound traffic
- Internet Gateway attached to the VPC
- All infrastructure provisioned with Terraform as infrastructure as code

## Tech Stack

| Layer | Technology |
|---|---|
| Infrastructure | AWS VPC, Terraform |
| Backend | Python, FastAPI |
| AWS SDK | boto3 |
| Database | PostgreSQL, SQLAlchemy |
| Local Dev | Docker |

## Project Structure

```
aws-tracker/
├── backend/
│   ├── app/
│   │   ├── api/
│   │   │   ├── routes_health.py      # Health check endpoint
│   │   │   └── routes_resources.py   # Scan and list endpoints
│   │   ├── db/
│   │   │   └── session.py            # Database connection
│   │   ├── models/
│   │   │   └── resource.py           # SQLAlchemy table definition
│   │   ├── schemas/
│   │   │   └── resource.py           # Pydantic request/response shapes
│   │   ├── services/
│   │   │   └── aws_scanner.py        # boto3 AWS scanner
│   │   ├── config.py                 # Environment variable management
│   │   └── main.py                   # FastAPI app entry point
│   ├── requirements.txt
│   └── .env.example
└── infra/
    └── vpc.tf                        # Terraform VPC configuration
```

## API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| GET | `/health` | Health check — used by ALB |
| GET | `/api/resources` | List all scanned resources from database |
| POST | `/api/resources/scan` | Trigger a live AWS scan and store results |

## Running Locally

### Prerequisites
- Python 3.9+
- Docker
- AWS account with credentials configured

### 1. Clone the repo
```bash
git clone https://github.com/YOUR_USERNAME/aws-tracker.git
cd aws-tracker
```

### 2. Set up environment variables
```bash
cp backend/.env.example backend/.env
```
Edit `.env` with your AWS credentials and database URL.

### 3. Start PostgreSQL
```bash
docker run -d \
  --name aws-tracker-db \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=awstracker \
  -p 5432:5432 \
  postgres:15
```

### 4. Install dependencies
```bash
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### 5. Start the API
```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### 6. Trigger a scan
Visit `http://localhost:8000/docs` and call `POST /api/resources/scan`

You will see your real AWS infrastructure returned as JSON.

## Infrastructure Deployment

```bash
cd infra
terraform init
terraform plan
terraform apply
```

> ⚠️ NAT Gateways cost ~$0.045/hour each (~$65/month for both). Run `terraform destroy` when not in use to avoid charges.

## What I Learned

- Designing production-grade VPC architecture with high availability across multiple AZs
- Infrastructure as Code with Terraform — the entire network is version controlled and reproducible
- Building REST APIs with FastAPI and Python
- Using boto3 to interact with AWS programmatically
- Database modeling with SQLAlchemy ORM
- Containerizing services with Docker for local development
- Managing environment variables and secrets securely
