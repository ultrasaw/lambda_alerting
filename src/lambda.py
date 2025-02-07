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
            if result is not None:
                return result
    elif isinstance(obj, list):
        for item in obj:
            result = find_arn(item)
            if result is not None:
                return result
    return None

def lambda_handler(event, context):
    """
    Event handler / logger.
    """
    # Log the full event for debugging
    logger.info("Received event: " + json.dumps(event, indent=2))

    detail = event.get('detail', {})
    event_time = event.get('time')

    if 'configRuleName' in detail:
        compliance_type = detail.get('newEvaluationResult', {}).get('complianceType')
        annotation = detail.get('newEvaluationResult', {}).get('annotation', '')
        action = f"{compliance_type}: {annotation}" if compliance_type else None
        initiator = detail.get('awsAccountId')
        resource_identifier = detail.get('resourceId')
    elif detail.get('eventSource') == 's3.amazonaws.com':
        action = detail.get('eventName')
        user_identity = detail.get('userIdentity', {})
        initiator = user_identity.get('userName')
        resources = detail.get('resources', [])
        resource_identifier = next((res.get('ARN') for res in resources if res.get('type') == 'AWS::S3::Bucket'), None)
    else:
        event_name = detail.get('eventName')
        action = event_name
        user_identity = detail.get('userIdentity', {})
        initiator = user_identity.get('userName')
        response_elements = detail.get('responseElements', {})

        if 'accessKey' in response_elements:
            resource_identifier = response_elements['accessKey'].get('userName')
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
            'Time': event_time or "N/A",
            'Action': action or "N/A",
            'Initiator': initiator or "N/A",
            'ResourceIdentifier': resource_identifier or "N/A"
        })
    }
