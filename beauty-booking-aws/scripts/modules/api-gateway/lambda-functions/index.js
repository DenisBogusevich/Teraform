// Simple API Gateway Lambda Authorizer for LocalStack
exports.handler = async (event, context) => {
  console.log('Event:', JSON.stringify(event, null, 2));
  
  // For local development, we'll allow all requests
  const userId = 'user123';
  return {
    principalId: userId,
    policyDocument: {
      Version: '2012-10-17',
      Statement: [
        {
          Action: 'execute-api:Invoke',
          Effect: 'Allow',
          Resource: event.methodArn || '*'
        }
      ]
    },
    context: {
      userId: userId,
      environment: 'local'
    }
  };
};
