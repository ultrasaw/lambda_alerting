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
            if result and result != "N/A": # not None or an empty string, & not "N/A"
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

    # Find the ARN in responseElements
    response_elements = detail.get('responseElements', {})
    resource_arn = find_arn(response_elements)

    # Log extracted details
    logger.info(f"Time: {event_time}")
    logger.info(f"Action: {event_name}")
    logger.info(f"Initiator: {initiator}")
    logger.info(f"Resource ARN: {resource_arn}")

    return {
        'statusCode': 200,
        'body': json.dumps({
            'Time': event_time,
            'Action': event_name,
            'Initiator': initiator,
            'ResourceARN': resource_arn
        })
    }
