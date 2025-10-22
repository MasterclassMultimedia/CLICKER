class AWSConfig {
  // AWS Configuration
  static const String region = 'us-east-1'; // Change to your preferred region
  static const String accessKeyId = 'YOUR_ACCESS_KEY_ID'; // Replace with your AWS access key
  static const String secretAccessKey = 'YOUR_SECRET_ACCESS_KEY'; // Replace with your AWS secret key
  
  // DynamoDB Configuration
  static const String tableName = 'ColorClickerData';
  
  // API Gateway Configuration (if using API Gateway instead of direct DynamoDB)
  static const String apiGatewayUrl = 'https://your-api-gateway-url.amazonaws.com/prod';
  
  // Environment variables (recommended for production)
  static String get accessKey => const String.fromEnvironment('AWS_ACCESS_KEY_ID', defaultValue: accessKeyId);
  static String get secretKey => const String.fromEnvironment('AWS_SECRET_ACCESS_KEY', defaultValue: secretAccessKey);
  static String get awsRegion => const String.fromEnvironment('AWS_REGION', defaultValue: region);
}
