#!/bin/bash
# Create directory structure if it doesn't exist
mkdir -p modules/api-gateway/lambda-functions/
mkdir -p temp-lambda

# Create Lambda function file
cat > temp-lambda/index.js << 'EOF'
// Simple API Gateway Lambda Authorizer
exports.handler = async (event, context) => {
  console.log('Event:', JSON.stringify(event, null, 2));
  
  // Get the Authorization header
  const authHeader = event.headers ? event.headers.Authorization || event.headers.authorization : null;
  
  if (!authHeader) {
    console.log('Authorization header not found');
    return generatePolicy('user', 'Deny', event.methodArn);
  }
  
  // Simple token validation logic
  try {
    if (authHeader.startsWith('Bearer ')) {
      const userId = 'user123'; // In production, extract from verified token
      return generatePolicy(userId, 'Allow', event.methodArn);
    } else {
      return generatePolicy('user', 'Deny', event.methodArn);
    }
  } catch (error) {
    console.log('Error validating token:', error);
    return generatePolicy('user', 'Deny', event.methodArn);
  }
};

// Helper function to generate an IAM policy
function generatePolicy(principalId, effect, resource) {
  const authResponse = {
    principalId: principalId
  };
  
  if (effect && resource) {
    const policyDocument = {
      Version: '2012-10-17',
      Statement: [
        {
          Action: 'execute-api:Invoke',
          Effect: effect,
          Resource: resource
        }
      ]
    };
    
    authResponse.policyDocument = policyDocument;
  }
  
  // Optional context
  authResponse.context = {
    userId: principalId,
    environment: process.env.ENVIRONMENT
  };
  
  return authResponse;
}
EOF

# Create the ZIP file
cd temp-lambda
zip -r authorizer.zip index.js

# Move to the target directory
mv authorizer.zip ../modules/api-gateway/lambda-functions/

# Clean up
cd ..
rm -rf temp-lambda

echo "Lambda authorizer ZIP file created at: modules/api-gateway/lambda-functions/authorizer.zip"