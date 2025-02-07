import json
import logging

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def find_arn(obj):
    """
    Recursively searches for an ARN in a nested dictionary or list.
    """
    if isinstance(obj, dict):
        for key, value in obj.items():
            if isinstance(value, str) and value.startswith("arn:"):
                return value
            result = find_arn(value)
            if result and result != "N/A":
                return result
    elif isinstance(obj, list):
        for item in obj:
            result = find_arn(item)
            if result and result != "N/A":
                return result
    return "N/A"

def lambda_handler(event, context):
    """
    Event handler / logger.
    """
    # Log the full event for debugging
    logger.info("Received event: " + json.dumps(event, indent=2))

    detail = event.get('detail', {})
    event_time = event.get('time', 'N/A')

    if 'configRuleName' in detail:
        # Extract details specific to AWS Config compliance change events
        compliance_type = detail.get('newEvaluationResult', {}).get('complianceType', 'N/A')
        annotation = detail.get('newEvaluationResult', {}).get('annotation', '')
        action = f"{compliance_type}: {annotation}"
        initiator = detail.get('awsAccountId', 'N/A')
        resource_identifier = detail.get('resourceId', 'N/A')
    elif detail.get('eventSource') == 's3.amazonaws.com':
        # Extract details specific to AWS S3 events
        action = detail.get('eventName', 'N/A')
        user_identity = detail.get('userIdentity', {})
        initiator = user_identity.get('userName', 'N/A')
        resources = detail.get('resources', [])
        resource_identifier = next((res.get('ARN', 'N/A') for res in resources if res.get('type') == 'AWS::S3::Bucket'), 'N/A')
    else:
        # Extract general details
        event_name = detail.get('eventName', 'N/A')
        action = event_name
        user_identity = detail.get('userIdentity', {})
        initiator = user_identity.get('userName', 'N/A')
        response_elements = detail.get('responseElements', {})

        # If 'accessKey' exists, return its userName instead of ARN
        if 'accessKey' in response_elements:
            resource_identifier = response_elements['accessKey'].get('userName', 'N/A')
        else:
            resource_identifier = find_arn(response_elements)

    # Log extracted details
    logger.info(f"Time: {event_time}")
    logger.info(f"Action: {action}")
    logger.info(f"Initiator: {initiator}")
    logger.info(f"ResourceIdentifier: {resource_identifier}")

    return {
        'statusCode': 200,
        'body': json.dumps({
            'Time': event_time,
            'Action': action,
            'Initiator': initiator,
            'ResourceIdentifier': resource_identifier
        })
    }
