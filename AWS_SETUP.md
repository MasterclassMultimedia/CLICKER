# AWS Setup Guide for Color Clicker App

## Prerequisites
- AWS Account
- AWS CLI installed (optional but recommended)
- Flutter development environment

## Step 1: AWS Account Setup

1. **Create AWS Account** (if you don't have one)
   - Go to [aws.amazon.com](https://aws.amazon.com)
   - Sign up for a free account
   - Complete verification process

2. **Create IAM User**
   - Go to AWS Console → IAM → Users
   - Click "Create user"
   - Username: `color-clicker-app`
   - Attach policies: `AmazonDynamoDBFullAccess`, `AmazonAPIGatewayFullAccess`
   - Create access keys (save them securely!)

## Step 2: DynamoDB Setup

1. **Create DynamoDB Table**
   ```bash
   aws dynamodb create-table \
     --table-name ColorClickerData \
     --attribute-definitions \
       AttributeName=id,AttributeType=S \
     --key-schema \
       AttributeName=id,KeyType=HASH \
     --billing-mode PAY_PER_REQUEST
   ```

2. **Or use AWS Console**
   - Go to DynamoDB → Tables → Create table
   - Table name: `ColorClickerData`
   - Partition key: `id` (String)
   - Use default settings

## Step 3: API Gateway Setup (Recommended)

1. **Create API Gateway**
   - Go to API Gateway → Create API
   - Choose "REST API"
   - Name: `color-clicker-api`

2. **Create Resources and Methods**
   - Create resource: `/save` (POST)
   - Create resource: `/load/{deviceId}` (GET)
   - Create resource: `/health` (GET)

3. **Deploy API**
   - Deploy to stage: `prod`
   - Note the API Gateway URL

## Step 4: Configure Your App

1. **Update AWS Configuration**
   Edit `lib/aws_config.dart`:
   ```dart
   static const String accessKeyId = 'YOUR_ACTUAL_ACCESS_KEY';
   static const String secretAccessKey = 'YOUR_ACTUAL_SECRET_KEY';
   static const String apiGatewayUrl = 'https://your-api-id.execute-api.region.amazonaws.com/prod';
   ```

2. **Environment Variables (Recommended for Production)**
   ```bash
   export AWS_ACCESS_KEY_ID="your-access-key"
   export AWS_SECRET_ACCESS_KEY="your-secret-key"
   export AWS_REGION="us-east-1"
   ```

## Step 5: Test the Integration

1. **Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **Run the App**
   ```bash
   flutter run -d chrome
   ```

3. **Test Features**
   - Tap to increment counter
   - Check AWS connection status
   - Test sync functionality
   - Verify data persistence

## Security Best Practices

1. **Never commit AWS credentials to Git**
2. **Use IAM roles instead of access keys when possible**
3. **Implement proper error handling**
4. **Use environment variables for production**
5. **Enable CloudTrail for audit logging**

## Troubleshooting

### Common Issues:
- **403 Forbidden**: Check IAM permissions
- **Connection timeout**: Verify API Gateway URL
- **Data not syncing**: Check DynamoDB table permissions
- **App crashes**: Verify all dependencies are installed

### Debug Steps:
1. Check AWS CloudWatch logs
2. Verify API Gateway logs
3. Test with AWS CLI
4. Check network connectivity

## Cost Optimization

- **DynamoDB**: Pay-per-request pricing (very low cost for small apps)
- **API Gateway**: $3.50 per million API calls
- **Free Tier**: 1M free DynamoDB requests/month
- **Monitoring**: Use AWS Cost Explorer to track usage

## Next Steps

1. Set up AWS CloudWatch for monitoring
2. Implement data backup strategies
3. Add user authentication
4. Scale with AWS Lambda for serverless processing
5. Implement data analytics with AWS Analytics
