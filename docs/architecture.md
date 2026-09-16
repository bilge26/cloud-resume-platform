# Architecture

This document describes the architecture of the Cloud Resume Platform and separates the **current Terraform-defined architecture** from the **target deployment architecture**.

## 1. Current serverless architecture

```mermaid
flowchart LR
    Browser[User Browser]
    Frontend[Static Resume Frontend]

    subgraph AWS[AWS - Terraform Defined]
        S3[(Amazon S3<br/>Private + Encrypted + Versioned)]

        subgraph Backend[Visitor Counter Backend]
            APIGW[Amazon API Gateway<br/>HTTP API<br/>GET /visitors]
            Lambda[AWS Lambda<br/>Python 3.12]
            DDB[(Amazon DynamoDB<br/>PAY_PER_REQUEST)]
            Logs[Amazon CloudWatch Logs]
        end
    end

    Browser --> Frontend
    Frontend -. planned GET /visitors .-> APIGW
    APIGW -->|lambda:InvokeFunction| Lambda
    Lambda -->|dynamodb:UpdateItem| DDB
    Lambda -. execution logs .-> Logs

    Terraform[Terraform] -. defines .-> S3
    Terraform -. defines .-> APIGW
    Terraform -. defines .-> Lambda
    Terraform -. defines .-> DDB
```

### Intended runtime request flow

Once the frontend is wired to the live API:

1. The user opens the resume frontend.
2. The frontend calls `GET /visitors`.
3. API Gateway proxies the request to the Lambda function.
4. Lambda performs an atomic `UpdateItem` operation in DynamoDB.
5. DynamoDB returns the updated visitor count.
6. Lambda returns the count as JSON.
7. API Gateway returns the response to the browser.

### IAM model

```mermaid
flowchart TD
    APIGW[API Gateway] -->|Allowed to invoke| Lambda[AWS Lambda]
    Lambda -->|Assumes| Role[IAM Lambda Execution Role]
    Role -->|dynamodb:UpdateItem<br/>only on visitor table| DDB[(DynamoDB)]
    Role -->|AWSLambdaBasicExecutionRole| CW[CloudWatch Logs]
```

The Lambda function does not receive broad DynamoDB access. Its inline policy is scoped to `dynamodb:UpdateItem` on the visitor-counter table.

## 2. Continuous integration

```mermaid
flowchart LR
    Dev[Developer] -->|git push / pull request| GitHub[GitHub Repository]
    GitHub --> Actions[GitHub Actions CI]

    Actions --> Py[Python 3.12]
    Py --> Tests[Backend Unit Tests]

    Actions --> TF[Terraform]
    TF --> Fmt[terraform fmt -check]
    TF --> Init[terraform init -backend=false]
    TF --> Validate[terraform validate]

    Tests --> Result[CI Result]
    Fmt --> Result
    Init --> Result
    Validate --> Result
```

The current CI pipeline intentionally does not contain AWS credentials and does not deploy infrastructure.

## 3. Target deployment architecture

```mermaid
flowchart TB
    User[User Browser]

    subgraph Delivery[Frontend Delivery]
        CF[Amazon CloudFront]
        S3[(Amazon S3<br/>Private Frontend Bucket)]
    end

    subgraph API[Serverless API]
        GW[Amazon API Gateway<br/>HTTP API]
        L[AWS Lambda<br/>Python]
        DB[(Amazon DynamoDB)]
        CW[Amazon CloudWatch]
    end

    subgraph CICD[CI/CD]
        Repo[GitHub Repository]
        GHA[GitHub Actions]
        OIDC[GitHub OIDC]
        DeployRole[AWS IAM Deployment Role]
        Terraform[Terraform]
    end

    User --> CF
    CF --> S3
    User -->|GET /visitors| GW
    GW --> L
    L --> DB
    L -. logs/metrics .-> CW

    Repo --> GHA
    GHA --> OIDC
    OIDC --> DeployRole
    DeployRole --> Terraform

    Terraform -. provision/update .-> CF
    Terraform -. provision/update .-> S3
    Terraform -. provision/update .-> GW
    Terraform -. provision/update .-> L
    Terraform -. provision/update .-> DB
```

### Why CloudFront?

The S3 bucket remains private. CloudFront becomes the public delivery layer, providing HTTPS and preventing the frontend bucket from being directly exposed.

### Why GitHub OIDC?

The deployment workflow will use short-lived AWS credentials obtained through GitHub OIDC instead of storing long-lived AWS access keys in repository secrets.

## 4. Planned operational improvements

- CloudFront configuration
- GitHub OIDC trust policy and deployment role
- Deployment workflow
- CloudWatch alarms and monitoring configuration
- Frontend integration with the live API URL
- Optional custom domain and DNS

This separation keeps the repository accurate: CI and infrastructure definitions are implemented, while cloud deployment remains a clearly tracked next step.
