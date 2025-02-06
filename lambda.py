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

    # Extract general details
    event_time = event.get('time', 'N/A')
    detail = event.get('detail', {})
    event_name = detail.get('eventName', 'N/A')

    # Extract initiator
    user_identity = detail.get('userIdentity', {})
    initiator = user_identity.get('userName', 'N/A')

    # Extract responseElements
    response_elements = detail.get('responseElements', {})

    # If 'accessKey' exists, return its userName instead of ARN
    if 'accessKey' in response_elements:
        resource_identifier = response_elements['accessKey'].get('userName', 'N/A')
    else:
        resource_identifier = find_arn(response_elements)

    # Log extracted details
    logger.info(f"Time: {event_time}")
    logger.info(f"Action: {event_name}")
    logger.info(f"Initiator: {initiator}")
    logger.info(f"ResourceIdentifier: {resource_identifier}")

    return {
        'statusCode': 200,
        'body': json.dumps({
            'Time': event_time,
            'Action': event_name,
            'Initiator': initiator,
            'ResourceIdentifier': resource_identifier
        })
    }
