# CE09-Avengers Serverless URL Shortener (AWS)

A fully serverless, scalable URL shortener backend built with:

- **AWS Lambda**
- **API Gateway** with **Custom Domain** (`ce09-avengers-urlshortener.sctp-sandbox.com`)
- **DynamoDB**
- **WAF** (only allows your IP)
- **CloudWatch** + **SNS** for alerts
- **X-Ray** tracing
- **Terraform** Infrastructure as Code
- **GitHub Actions** CI/CD with OIDC

---

## Architecture

```text
Client ⇄ API Gateway ⇄ Lambda ⇄ DynamoDB
            ⇡              ⇡
           WAF           X-Ray
            ⇡              ⇡
       Route53       CloudWatch/SNS




Dependancy Setup:

1. Make sure you’ve configured OIDC trust + permission policies in AWS console already before run .github/workflows/cd.yml – CD Workflow

Update all