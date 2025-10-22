#!/bin/bash

# AWS Setup Script for Color Clicker App
# This script helps you set up the necessary AWS resources

echo "🚀 Setting up AWS resources for Color Clicker App..."

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI not found. Please install it first:"
    echo "   https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
    exit 1
fi

# Check if user is logged in
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS CLI not configured. Please run:"
    echo "   aws configure"
    exit 1
fi

echo "✅ AWS CLI is configured"

# Create DynamoDB table
echo "📊 Creating DynamoDB table..."
aws dynamodb create-table \
    --table-name ColorClickerData \
    --attribute-definitions \
        AttributeName=id,AttributeType=S \
    --key-schema \
        AttributeName=id,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region us-east-1

if [ $? -eq 0 ]; then
    echo "✅ DynamoDB table created successfully"
else
    echo "⚠️  DynamoDB table might already exist (this is okay)"
fi

# Create IAM policy for the app
echo "🔐 Creating IAM policy..."
cat > color-clicker-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:GetItem",
                "dynamodb:PutItem",
                "dynamodb:UpdateItem",
                "dynamodb:DeleteItem"
            ],
            "Resource": "arn:aws:dynamodb:us-east-1:*:table/ColorClickerData"
        }
    ]
}
EOF

aws iam create-policy \
    --policy-name ColorClickerPolicy \
    --policy-document file://color-clicker-policy.json \
    --region us-east-1

if [ $? -eq 0 ]; then
    echo "✅ IAM policy created successfully"
else
    echo "⚠️  IAM policy might already exist (this is okay)"
fi

# Clean up
rm color-clicker-policy.json

echo ""
echo "🎉 AWS setup completed!"
echo ""
echo "Next steps:"
echo "1. Create an IAM user with the ColorClickerPolicy attached"
echo "2. Generate access keys for the user"
echo "3. Update lib/aws_config.dart with your credentials"
echo "4. Set up API Gateway (see AWS_SETUP.md for details)"
echo ""
echo "For detailed instructions, see AWS_SETUP.md"
