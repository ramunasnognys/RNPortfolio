---
title: "Building a Production-Ready Serverless URL Shortener on AWS: A Step-by-Step Guide"
date: 2025-01-25
tags: ["AWS", "Serverless", "Python", "Terraform", "DevOps", "Infrastructure as Code"]
categories: ["Cloud Computing", "Development"]
description: "A comprehensive guide to building a serverless URL shortener using AWS Lambda, API Gateway, and DynamoDB, with automated deployments through GitHub Actions."
difficulty: "Beginner"
timeToComplete: "2-3 hours"
prerequisites: ["AWS Account", "Basic Python", "Command Line familiarity"]
---

![Pasted image 20250125094350.png](/images/Pasted%20image%2020250125094350.png)

>[!info In the modern web landscape, serverless architectures have emerged as a powerful paradigm for building scalable applications without managing traditional infrastructure. Today, we'll explore this concept by building a practical, production-ready URL shortener using AWS serverless services.] 
>



# Building a Production-Ready Serverless Application: AWS URL Shortener  

**Level**: Beginner | **Tools**: AWS, Terraform, Python, GitHub Actions  

---

## 1. Project Overview  
**Purpose**: Deploy a serverless URL shortener using AWS. Users can submit long URLs and receive shortened links via an API.  

**Architecture**:  
1. **AWS Lambda** (Python): Handles URL shortening and redirection logic.  
2. **API Gateway**: Routes HTTP requests to Lambda functions.  
3. **DynamoDB**: Stores mappings between short codes and original URLs.  
4. **GitHub Actions**: Automates deployment of infrastructure and code.  
5. **CloudWatch**: Monitors logs and performance.  

![Architecture Diagram](https://via.placeholder.com/600x300?text=Serverless+URL+Shortener+Architecture)  
*(Replace with actual diagram showing components and data flow)*  

---

## 2. Technical Requirements  
- **AWS Account** (free tier eligible).  
- **Tools Installed**:  
  - Terraform (`v1.5+`).  
  - AWS CLI (`v2.13+`).  
  - Python (`3.9+`) or Node.js (`18+`).  
  - Git.  

---

## 3. Step-by-Step Implementation  

### 3.1 Infrastructure Setup with Terraform  
**Step 1**: Configure AWS CLI.  
```bash  
aws configure  
# Enter AWS Access Key, Secret Key, and default region (e.g., us-east-1)  
```  

**Step 2**: Create Terraform files.  
```hcl  
# main.tf  
provider "aws" {  
  region = "us-east-1"  
}  

resource "aws_dynamodb_table" "url_shortener" {  
  name         = "url-mappings"  
  billing_mode = "PAY_PER_REQUEST"  
  hash_key     = "short_code"  

  attribute {  
    name = "short_code"  
    type = "S"  
  }  
}  

resource "aws_iam_role" "lambda_role" {  
  name = "lambda_execution_role"  

  assume_role_policy = jsonencode({  
    Version = "2012-10-17",  
    Statement = [{  
      Action = "sts:AssumeRole",  
      Effect = "Allow",  
      Principal = { Service = "lambda.amazonaws.com" }  
    }]  
  })  
}  

# Attach DynamoDB access policy to the role  
resource "aws_iam_role_policy_attachment" "lambda_dynamo" {  
  role       = aws_iam_role.lambda_role.name  
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"  
}  
```  

**Step 3**: Deploy infrastructure.  
```bash  
terraform init  
terraform apply -auto-approve  
```  

---

### 3.2 Write and Deploy Lambda Functions  
**Step 4**: Create a Python Lambda function (`lambda_handler.py`).  
```python  
import os  
import json  
import boto3  
from urllib.parse import urlparse  

dynamodb = boto3.resource('dynamodb')  
table = dynamodb.Table('url-mappings')  

def create_short_url(event, context):  
    import shortuuid  # Add to requirements.txt  
    body = json.loads(event['body'])  
    long_url = body['url']  
    short_code = shortuuid.ShortUUID().random(length=6)  

    table.put_item(Item={'short_code': short_code, 'long_url': long_url})  
    return {'statusCode': 200, 'body': json.dumps({'short_url': f'https://api.example.com/{short_code}'})}  

def redirect_short_url(event, context):  
    short_code = event['pathParameters']['short_code']  
    item = table.get_item(Key={'short_code': short_code}).get('Item')  
    if not item:  
        return {'statusCode': 404}  
    return {'statusCode': 301, 'headers': {'Location': item['long_url']}}  
```  

**Step 5**: Package and deploy using Terraform.  
```hcl  
# lambda.tf  
resource "aws_lambda_function" "shorten_url" {  
  filename      = "lambda.zip"  
  function_name = "shorten-url"  
  role          = aws_iam_role.lambda_role.arn  
  handler       = "lambda_handler.create_short_url"  
  runtime       = "python3.9"  
}  

resource "aws_lambda_function" "redirect_url" {  
  filename      = "lambda.zip"  
  function_name = "redirect-url"  
  role          = aws_iam_role.lambda_role.arn  
  handler       = "lambda_handler.redirect_short_url"  
  runtime       = "python3.9"  
}  
```  

---

### 3.3 Configure API Gateway  
**Step 6**: Link Lambda to API Gateway.  
```hcl  
# api_gateway.tf  
resource "aws_apigatewayv2_api" "main" {  
  name          = "url-shortener-api"  
  protocol_type = "HTTP"  
}  

resource "aws_apigatewayv2_integration" "shorten" {  
  api_id           = aws_apigatewayv2_api.main.id  
  integration_type = "AWS_PROXY"  
  integration_uri  = aws_lambda_function.shorten_url.invoke_arn  
}  

resource "aws_apigatewayv2_route" "post_route" {  
  api_id    = aws_apigatewayv2_api.main.id  
  route_key = "POST /shorten"  
  target    = "integrations/${aws_apigatewayv2_integration.shorten.id}"  
}  

resource "aws_apigatewayv2_route" "get_route" {  
  api_id    = aws_apigatewayv2_api.main.id  
  route_key = "GET /{short_code}"  
  target    = "integrations/${aws_apigatewayv2_integration.redirect.id}"  # Define redirect integration similarly  
}  
```  

---

### 3.4 Automate Deployments with GitHub Actions  
**Step 7**: Create `.github/workflows/deploy.yml`.  
```yaml  
name: Deploy  
on:  
  push:  
    branches: [main]  

jobs:  
  deploy:  
    runs-on: ubuntu-latest  
    steps:  
      - uses: actions/checkout@v4  
      - uses: hashicorp/setup-terraform@v2  

      - name: Terraform Apply  
        env:  
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}  
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}  
        run: |  
          terraform init  
          terraform apply -auto-approve  
```  

---

## 4. Testing & Validation  

### 4.1 Load Testing with k6  
```javascript  
// load-test.js  
import http from 'k6/http';  
import { check } from 'k6';  

export default function () {  
  const res = http.post('https://api.example.com/shorten', JSON.stringify({ url: 'https://example.com' }), {  
    headers: { 'Content-Type': 'application/json' },  
  });  
  check(res, { 'status was 200': (r) => r.status == 200 });  
}  
```  
Run with:  
```bash  
k6 run --vus 10 --duration 30s load-test.js  
```  

### 4.2 Cost Optimization Tips  
- Set Lambda memory to 128MB if possible.  
- Use DynamoDB auto-scaling.  
- Enable API Gateway caching.  

---

## 5. Appendix  

### Sample Terraform Output  
```hcl  
output "api_url" {  
  value = aws_apigatewayv2_api.main.api_endpoint  
}  
```  

### Troubleshooting  
**Cold Starts**:  
- Use provisioned concurrency for critical Lambdas.  

**Permission Errors**:  
- Ensure IAM roles have `dynamodb:PutItem` and `dynamodb:GetItem` policies.  

---

**Next Steps**: Add custom domains, authentication, or a frontend!  

*(Replace placeholder URLs and test all code snippets before production use.)*