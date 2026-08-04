# School Management SaaS - Complete Production Deployment Guide

## 📋 Overview

This guide provides step-by-step instructions for deploying the School Management SaaS to production. It covers all environments from local development to full production deployment, including database setup, configuration, authentication, monitoring, and post-deployment procedures.

## 🎯 Prerequisites

### Required Tools and Software
- [Docker](https://docs.docker.com/get-docker/) (version 24+)
- [Docker Compose](https://docs.docker.com/compose/install/) (version 2+)
- PostgreSQL client (for local database management)
- .NET 8 SDK (for local development)
- Node.js 18+ (for frontend development)
- Git
- SSH access to production servers (if deploying directly)

### Hardware Requirements
- Minimum: 4 CPU cores, 8GB RAM
- Recommended: 8+ CPU cores, 16GB+ RAM
- Storage: 50GB+ for database and application data

### Network Requirements
- Outbound internet access for package downloads
- Inbound access to production servers (ports 80, 443, 5000, 5432)
- TLS certificates for HTTPS

## 🚀 Phase 1: Local Development Setup

### Step 1.1: Clone Repository
```bash
# Clone the repository
git clone https://github.com/brunoferreira94/school-management.git
cd school-management

# Checkout development branch
# (or create your branch from main)
```

### Step 1.2: Setup Backend
```bash
# Navigate to backend directory
cd school-management-api

# Restore dependencies
dotnet restore

# Configure database (local PostgreSQL)
# Edit appsettings.Development.json as needed

# Run migrations (if using local database)
# dotnet ef database update --project src/SchoolManagement

# Run the application
# dotnet run --project src/SchoolManagement
```

### Step 1.3: Setup Frontend
```bash
# Navigate to frontend directory
cd ../school-management-ui

# Install dependencies
npm ci

# Run the application
npm start
```

### Step 1.4: Database Setup (Local)

#### Option A: Using Docker Compose
```bash
# Start local database using docker-compose
cd school-management
sudo docker compose up -d postgres

# Wait for database to be ready
# Check status
sudo docker ps
```

#### Option B: Native PostgreSQL
```bash
# Initialize PostgreSQL database
dropdb -U postgres schoolmanagement || true
createdb -U postgres schoolmanagement

# Set appropriate permissions
# Grant privileges to application user
```

## 🏗️ Phase 2: Production Environment Preparation

### Step 2.1: Provision Production Infrastructure

#### AWS ECS/EKS Setup
```bash
# Create ECS cluster
aws ecs create-cluster --cluster-name school-management-prod

# Create Application Load Balancer
aws elbv2 create-load-balancer --name school-management-alb --subnets subnet-xxxxx,subnet-yyyyy

# Create Target Group for API
tg_arn=$(aws elbv2 create-target-group --name school-management-api-tg --protocol HTTP --port 5000 --vpc-id vpc-xxxxx --target-type ip --health-check-path /api/support/health --health-check-protocol HTTP --matcher "{"okcodes":"200"}"" | jq -r '.TargetGroups[0].TargetGroupArn')

# Create Target Group for Frontend
tg_frontend_arn=$(aws elbv2 create-target-group --name school-management-ui-tg --protocol HTTP --port 80 --vpc-id vpc-xxxxx --target-type ip --health-check-path / --health-check-protocol HTTP --matcher "{"okcodes":"200"}"" | jq -r '.TargetGroups[0].TargetGroupArn')

# Create RDS PostgreSQL Instance
rds_instance_arn=$(aws rds create-db-instance --db-instance-identifier school-management-prod \
  --db-instance-class db.m6g.large \
  --engine postgres \
  --allocated-storage 200 \
  --master-username ${DB_USER} \
  --master-user-password ${DB_PASSWORD} \
  --vpc-security-group-ids sg-xxxxx \
  --db-subnet-group-name school-management-subnet-group \
  --publicly-accessible \
  | jq -r '.DBInstance.DBInstanceArn')

# Wait for RDS to be available
aws rds wait db-instance-available --db-instance-identifier school-management-prod
```

#### DigitalOcean Droplets Setup
```bash
# Create production droplets
doctl compute droplet create school-management-api --image ubuntu-22-04 --size s-4vcpu-8gb --region nyc3 --ssh-keys your-ssh-key-id

doctl compute droplet create school-management-db --image ubuntu-22-04 --size s-4vcpu-8gb --region nyc3 --ssh-keys your-ssh-key-id

doctl compute domain create yourdomain.com
```

### Step 2.2: SSL/TLS Certificate Setup

#### Using Let's Encrypt (with Traefik)
```bash
# Install Docker Swarm with Traefik
sudo docker swarm init
sudo docker network create traefik

# Deploy Traefik with Let's Encrypt
# (Create docker-compose with Traefik configuration)
```

#### Using AWS Certificate Manager
```bash
# Request certificate for your domain
acm_arn=$(aws acm request-certificate --domain-name yourdomain.com --validation-method DNS | jq -r '.CertificateArn')

# Create DNS record for validation
# Wait for certificate to be issued
aws acm wait certificate-valid --certificate-arn $acm_arn
```

### Step 2.3: Environment Configuration

#### Create Production Environment File
```bash
# Create .env file in production environment
cat > .env << EOF
# Database
DB_USER=${DB_USER}
DB_PASSWORD=${DB_PASSWORD}

# JWT
JWT_SECRET=${JWT_SECRET}
JWT_ISSUER=https://auth.yourdomain.com
JWT_AUDIENCE=https://api.yourdomain.com

# Auth0
AUTH0_DOMAIN=${AUTH0_DOMAIN}
AUTH0_CLIENT_ID=${AUTH0_CLIENT_ID}
AUTH0_CLIENT_SECRET=${AUTH0_CLIENT_SECRET}
AUTH0_AUDIENCE=https://api.yourdomain.com

# Stripe
STRIPE_SECRET_KEY=${STRIPE_SECRET_KEY}
STRIPE_PUBLISHABLE_KEY=${STRIPE_PUBLISHABLE_KEY}
STRIPE_WEBHOOK_SECRET=${STRIPE_WEBHOOK_SECRET}

# Asaas
ASAAS_API_KEY=${ASAAS_API_KEY}
ASAAS_WEBHOOK_TOKEN=${ASAAS_WEBHOOK_TOKEN}
EOF
```

#### Set .NET User Secrets in Production
```bash
# On production server/container
dotnet user-secrets set DB_PASSWORD "${DB_PASSWORD}"
dotnet user-secrets set JWT_SECRET "${JWT_SECRET}"
dotnet user-secrets set JWT_ISSUER "https://auth.yourdomain.com"
dotnet user-secrets set JWT_AUDIENCE "https://api.yourdomain.com"
dotnet user-secrets set AUTH0_DOMAIN "${AUTH0_DOMAIN}"
dotnet user-secrets set AUTH0_CLIENT_ID "${AUTH0_CLIENT_ID}"
dotnet user-secrets set AUTH0_CLIENT_SECRET "${AUTH0_CLIENT_SECRET}"
dotnet user-secrets set AUTH0_AUDIENCE "https://api.yourdomain.com"
dotnet user-secrets set STRIPE_SECRET_KEY "${STRIPE_SECRET_KEY}"
dotnet user-secrets set STRIPE_PUBLISHABLE_KEY "${STRIPE_PUBLISHABLE_KEY}"
dotnet user-secrets set STRIPE_WEBHOOK_SECRET "${STRIPE_WEBHOOK_SECRET}"
dotnet user-secrets set ASAAS_API_KEY "${ASAAS_API_KEY}"
dotnet user-secrets set ASAAS_WEBHOOK_TOKEN "${ASAAS_WEBHOOK_TOKEN}"
```

## 🚀 Phase 3: Docker Deployment

### Step 3.1: Build Docker Images
```bash
# Build API image
cd school-management-api
docker build -t schoolmanagement-api:latest .

# Build UI image
cd ../school-management-ui
docker build -t schoolmanagement-ui:latest .
```

### Step 3.2: Deploy with Docker Compose
```bash
# Create production docker-compose file
cat > docker-compose.prod.yaml << EOF
version: '3.8'

services:
  api:
    image: schoolmanagement-api:latest
    restart: always
    ports:
      - "5000:5000"
    environment:
      - ASPNETCORE_ENVIRONMENT=Production
      - ASPNETCORE_URLS=http://+:5000
      - ConnectionStrings__DefaultConnection=Host=postgres;Port=5432;Database=schoolmanagement;Username=${DB_USER};Password=${DB_PASSWORD}
      - JWT_SECRET=${JWT_SECRET}
      - JWT_ISSUER=${JWT_ISSUER}
      - JWT_AUDIENCE=${JWT_AUDIENCE}
      - AUTH0_DOMAIN=${AUTH0_DOMAIN}
      - AUTH0_CLIENT_ID=${AUTH0_CLIENT_ID}
      - AUTH0_CLIENT_SECRET=${AUTH0_CLIENT_SECRET}
      - AUTH0_AUDIENCE=${AUTH0_AUDIENCE}
      - ASAAS_API_KEY = production Asaas API key (use .NET user-secrets)
      - ASAAS_WEBHOOK_TOKEN = production Asaas webhook token (use .NET user-secrets)
    depends_on:
      postgres:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5000/api/support/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  ui:
    image: schoolmanagement-ui:latest
    restart: always
    ports:
      - "80:80"
    depends_on:
      - api

  postgres:
    image: postgres:16-alpine
    restart: always
    environment:
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
      POSTGRES_DB: schoolmanagement
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./backups:/backups
    ports:
      - "5432:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER}"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  postgres_data:
EOF
```

### Step 3.3: Deploy Services
```bash
# Navigate to project directory
cd /home/user/school-management

# Start services in background
sudo docker compose -f docker-compose.prod.yaml up -d

# Check service status
sudo docker compose -f docker-compose.prod.yaml ps

# View logs if needed
sudo docker compose -f docker-compose.prod.yaml logs -f api
```

## 🔐 Phase 4: Authentication and Authorization Setup

### Step 4.1: Configure Auth0

#### Create Auth0 Tenant
1. Go to [auth0.com](https://auth0.com) and create a new tenant
2. Set up your domain (e.g., myapp.auth0.com)
3. Configure application:
   - Application type: Regular Web Applications
   - Redirect URLs: https://app.yourdomain.com/callback, https://app.yourdomain.com/logout
   - Allowed Origins: https://app.yourdomain.com

#### Configure Auth0 Settings in Application
```csharp
// In Startup.cs or Program.cs
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.Authority = $"https://{Auth0Domain}";
        options.Audience = "https://api.yourdomain.com";
        options.IncludeErrorDetails = true;
    });
```

### Step 4.2: Role-Based Access Control
```csharp
// Add authorization policies
builder.Services.AddAuthorizationBuilder()
    .AddPolicy("Admin", policy => policy.RequireRole("admin"))
    .AddPolicy("Teacher", policy => policy.RequireRole("teacher"))
    .AddPolicy("Student", policy => policy.RequireRole("student"))
    .AddPolicy("Parent", policy => policy.RequireRole("parent"));
```

### Step 4.3: JWT Token Configuration
```csharp
// Add JWT configuration
builder.Services.Configure<JwtOptions>(config.GetSection("Jwt"));

// Add JWT bearer token options
builder.Services.AddOptions<JwtBearerOptions>()
    .Configure<JwtOptions>((options, jwtOptions) =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidIssuer = jwtOptions.Issuer,
            ValidateAudience = true,
            ValidAudience = jwtOptions.Audience,
            ValidateLifetime = true,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtOptions.Secret)),
            ClockSkew = TimeSpan.Zero
        };
    });
```

## 📊 Phase 5: Monitoring and Observability

### Step 5.1: Prometheus and Grafana Setup

#### Install Prometheus
```bash
# Download and extract Prometheus
sudo wget https://github.com/prometheus/prometheus/releases/download/v2.45.0/prometheus-2.45.0.linux-amd64.tar.gz
sudo tar -xzf prometheus-2.45.0.linux-amd64.tar.gz -C /opt/

# Create systemd service
cat > /etc/systemd/system/prometheus.service << EOF
[Unit]
Description=Prometheus
After=network.target

[Service]
Type=simple
User=prometheus
WorkingDirectory=/opt/prometheus-2.45.0.linux-amd64
ExecStart=/opt/prometheus-2.45.0.linux-amd64/prometheus --config.file=/opt/prometheus-2.45.0.linux-amd64/prometheus.yml --storage.tsdb.path=/opt/prometheus-2.45.0.linux-amd64/data
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl start prometheus
```

#### Install Grafana
```bash
# Add Grafana repository
sudo apt install -y apt-transport-https
sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:grafana/stable
sudo apt update
sudo apt install -y grafana

# Start Grafana
sudo systemctl enable grafana
sudo systemctl start grafana

# Configure Grafana data source
cat > /etc/grafana/provisioning/datasources/prometheus.yaml << EOF
datasources:
  - name: Prometheus
    type: prometheus
    url: http://localhost:9090
    access: proxy
    isDefault: true
EOF
```

### Step 5.2: Application Metrics
```csharp
// Add Prometheus metrics
builder.Services.AddPrometheusExporter(options =>
{
    Options = new PrometheusExporterOptions
    {
        // Configure metrics namespace
        PrometheusExporterOptions.DefaultMetricsNamespace = "school_management";
    }
});

// Add custom metrics
var counter = Metrics.CreateCounter("active_tenants_total", "Total number of active tenants");
var gauge = Metrics.CreateGauge("memory_usage_bytes", "Current memory usage");
var histogram = Metrics.CreateHistogram("request_duration_seconds", "Request duration histogram");
```

### Step 5.3: Health Checks
```csharp
// Add health check endpoints
app.MapHealthChecks();
app.MapHealthChecks("/health", new HealthCheckOptions
{
    Predicate = _ => true,
    ResponseWriter = HealthCheckResponseWriter.WriteHealthCheckResponse
});
```

## 💾 Phase 6: Backup and Disaster Recovery

### Step 6.1: Database Backup Strategy
```bash
# Create backup directory
mkdir -p /backups/postgres
chmod 700 /backups/postgres

# Schedule regular backups
cat > /etc/cron.d/postgres-backup << EOF
# Backup daily at 2 AM
0 2 * * * root /usr/bin/pg_dump -U ${DB_USER} -d schoolmanagement > /backups/postgres/schoolmanagement-$(date +\%Y\%m\%d).sql

# Compress old backups
0 3 * * * root find /backups/postgres -name "*.sql" -mtime +7 -exec gzip {} \;
EOF

# Set up log rotation
cat > /etc/logrotate.d/postgres << EOF
/backups/postgres/*.sql {
    daily
    rotate 30
    compress
    missingok
    notifempty
    create 600 postgres postgres
}
EOF
```

### Step 6.2: Application Backup
```bash
# Create application data directory
mkdir -p /var/lib/school-management

# Schedule application backups
# (Additional backup strategy depends on specific requirements)
```

### Step 6.3: Disaster Recovery Procedure
1. **Immediate Actions**
   - Isolate affected systems
   - Notify stakeholders
   - Assess impact and scope

2. **Recovery Steps**
   ```bash
   # Restore from latest backup
   sudo docker compose -f docker-compose.prod.yaml down
   sudo docker compose -f docker-compose.prod.yaml up -d

   # If necessary, restore database
   pg_restore -U ${DB_USER} -d schoolmanagement /path/to/backup.sql
   ```

3. **Validation**
   - Run health checks
   - Test critical user workflows
   - Monitor system performance

## 🧪 Phase 7: Testing and Validation

### Step 7.1: Smoke Tests
```bash
# Health check endpoint
curl -f http://localhost:5000/api/support/health

# Readiness endpoint
curl -f http://localhost:5000/api/support/ready

# Liveness endpoint
curl -f http://localhost:5000/api/support/live
```

### Step 7.2: Performance Tests
```bash
# Use Apache Bench for load testing
ab -n 1000 -c 10 http://localhost:5000/api/students

# Use k6 for API testing
k6 run load-test.js
```

### Step 7.3: Security Tests
```bash
# Run security scanner
snyk test

# OWASP ZAP scan
zap-baseline.py -t http://localhost:5000
```

## 🔧 Phase 8: Post-Deployment Procedures

### Step 8.1: User Acceptance Testing
- [ ] Verify all core functionalities
- [ ] Test user permissions and roles
- [ ] Validate API integrations
- [ ] Confirm frontend functionality

### Step 8.2: Performance Optimization
- [ ] Monitor system metrics for 24 hours
- [ ] Optimize database queries if needed
- [ ] Scale resources as required
- [ ] Implement caching where appropriate

### Step 8.3: Documentation Update
- [ ] Update system documentation
- [ ] Create runbooks for common operations
- [ ] Document troubleshooting procedures
- [ ] Update contact information

## 📋 Phase 9: Ongoing Operations

### Step 9.1: Monitoring Setup
- Configure alerts for critical services
- Set up log aggregation
- Implement disaster recovery drills
- Schedule regular backup verification

### Step 9.2: Maintenance Schedule
- **Daily**: Backup verification, log rotation
- **Weekly**: Security updates, performance review
- **Monthly**: Backup restoration test, log analysis
- **Quarterly**: System maintenance, version updates

### Step 9.3: Continuous Improvement
- Collect user feedback
- Monitor system performance
- Identify optimization opportunities
- Plan for feature enhancements

## 🚨 Emergency Procedures

### System Outage
1. **Immediate Actions**
   - Check service status
   - Review recent changes
   - Isolate affected components

2. **Recovery Steps**
   - Restore from latest backup
   - Restart affected services
   - Verify system health

### Security Breach
1. **Containment**
   - Isolate affected systems
   - Change all exposed passwords
   - Revoke access tokens

2. **Investigation**
   - Analyze logs for breach source
   - Update security policies
   - Implement additional safeguards

### Data Corruption
1. **Assessment**
   - Determine scope of damage
   - Identify root cause

2. **Recovery**
   - Restore from clean backup
   - Verify data integrity
   - Implement additional validation

## 📚 Reference Materials

### Configuration Files
- `.env.example` - Example environment variables
- `appsettings.Production.json` - Production application settings
- `docker-compose.prod.yaml` - Production Docker configuration

### Documentation
- [Auth0 Documentation](https://auth0.com/docs)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Docker Documentation](https://docs.docker.com/)
- [Prometheus Documentation](https://prometheus.io/docs/introduction/overview/)
- [Grafana Documentation](https://grafana.com/docs/)

### Support
- **Email**: support@yourdomain.com
- **Slack**: #school-management-support
- **Phone**: +1-XXX-XXX-XXXX (24/7)

---

**Last Updated**: $(date)
**Version**: 1.0
**Environment**: Production

*This deployment guide is continuously updated. Refer to the latest version before each deployment.*