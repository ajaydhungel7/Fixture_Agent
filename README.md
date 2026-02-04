# Rubyrana Football Orchestrator

This project uses Rubyrana with a multi‑agent router and three league‑specific agents:
- LaLiga
- Premier League
- Serie A

Each league agent uses a shared `fixtures_lookup` tool that calls the football-data.org API.
The router selects the best agent for single‑league requests; a small structured‑output classifier extracts leagues and dates for multi‑league requests.

## Local Dev

```bash
bundle install
export ANTHROPIC_API_KEY=your_key
export FOOTBALL_DATA_API_KEY=your_football_data_key
export FIXTURES_CACHE_TTL=300
ruby main.rb "Show me Premier League fixtures"
```

## Local Server

```bash
ruby server.rb
curl -s http://localhost:8080/invoke \
  -H 'Content-Type: application/json' \
  -d '{"prompt":"Show me LaLiga fixtures"}'
```

## Remote AgentCore (Client Mode)

```bash
export AGENTCORE_RUNTIME_ARN=arn:aws:bedrock-agentcore:us-east-1:123456789012:agent-runtime/your-runtime
ruby main.rb --remote "Show me Serie A fixtures"
```

## Configuration Management

- Dev: `.env` + dotenv
- Prod: AWS Secrets Manager via `SECRETS_MANAGER_SECRET_ID`

## Docker (Local)

```bash
docker compose up --build
```

## Terraform (ECS + AgentCore)

Terraform lives in `terraform/` and provisions:
- ECR repository
- ECS Fargate service + ALB
- Secrets Manager secret
- Bedrock AgentCore runtime (via CloudFormation stack)

Example usage:

```bash
cd terraform
terraform init
terraform apply \
  -var="image_uri=<your_ecr_image_uri>" \
  -var='secrets_json={"ANTHROPIC_API_KEY":"...","FOOTBALL_DATA_API_KEY":"..."}'
```

Outputs:
- `alb_dns_name`
- `agentcore_runtime_arn`

## CI/CD

GitHub Actions workflows:
- `ci.yml`: bundle install + Ruby syntax checks
- `deploy.yml`: build/push image to ECR and run Terraform (requires AWS OIDC role)

## Notes

The tool queries football-data.org for fixtures between today and the next 7 days by default.
Responses are cached in‑memory for `FIXTURES_CACHE_TTL` seconds.
