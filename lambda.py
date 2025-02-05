# import os
# import logging

# # Configure the logger
# logger = logging.getLogger()
# logger.setLevel(logging.INFO)

# def lambda_handler(event, context):
#     # Log environment variables
#     logger.info('## ENVIRONMENT VARIABLES')
#     logger.info(f"AWS_LAMBDA_LOG_GROUP_NAME: {os.environ.get('AWS_LAMBDA_LOG_GROUP_NAME')}")
#     logger.info(f"AWS_LAMBDA_LOG_STREAM_NAME: {os.environ.get('AWS_LAMBDA_LOG_STREAM_NAME')}")
    
#     # Log the received event
#     logger.info('## EVENT')
#     logger.info(event)
    
#     return {
#         'statusCode': 200,
#         'body': 'Function executed successfully!'
#     }

def lambda_handler(event, context):
    return {
        'statusCode': 200,
        'body': 'Hello from AWS Lambda!'
    }
