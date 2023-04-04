import json, boto3, csv, random, datetime
from io import StringIO
from functools import partial


# Expects a tsv of events with a header row: `name    year    link    cat\n`
def pull_events_tsv_from_s3(s3_session_client: boto3.Session.client,
                            bucket_name: str='chrono-events-api', 
                            object_key: str='events.tsv'):
    """Pull the events tsv from S3 and returns a list of dict values"""
    file_obj = s3_session_client.get_object(Bucket=bucket_name, Key=object_key)
    file_content = file_obj['Body'].read().decode('utf-8')

    tsv_content = csv.reader(StringIO(file_content), delimiter='\t')
    tsv_values = [row for row in tsv_content]
    
    list_of_event_dicts = [{'name':x[0], 'year':x[1], 'link':x[2], 'cat':x[3]} for x in tsv_values[1:]]
    
    return list_of_event_dicts


def seed_value() -> int:
    """calculate num days since a set date in UTC"""
    start_date = datetime.datetime(2023, 4, 1, tzinfo=datetime.timezone.utc)
    current_date = datetime.datetime.utcnow().replace(tzinfo=datetime.timezone.utc)
    delta = current_date - start_date
    return delta.days


def random_shuffle_by_seed(list_of_event_dicts: list, seed_value: int=69) -> list:
    """take a list of event dicts and shuffle it based on a seed value"""
    random.seed(seed_value)
    shuffled_event_dicts = random.shuffle(list_of_event_dicts)
    
    return shuffled_event_dicts

def cat_is_filter_value(event: dict, filter_value: str=None) -> bool:
    if filter_value is None: return True
    cats = event['cat'].split(',')
    return filter_value in cats


def handler(event, context):

    s3 = boto3.client('s3')    
    bucket_name = 'chrono-events-api'
    object_key = 'events.tsv'
    num_events = 6

    dict_values = pull_events_tsv_from_s3(s3, bucket_name, object_key)
    
    if event.get('queryStringParameters'):
        cat_filter = event['queryStringParameters'].get('cat_filter', None)
        partial_filter_by_cat = partial(cat_is_filter_value, filter_value=cat_filter)
        dict_values = list(filter(partial_filter_by_cat, dict_values))

        num_events = int(event['queryStringParameters'].get('num_events', num_events))


    seed_val = seed_value()
    random.seed(seed_val)
    random.shuffle(dict_values)
    
    response = {
        'statusCode': 200,
        'body': json.dumps({
            'seed_value': seed_val,
            'event_list': dict_values[:num_events]
        })
    }
    return response


