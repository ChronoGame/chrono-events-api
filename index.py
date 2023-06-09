import json, boto3, csv, random, datetime
from io import StringIO
from functools import partial
from collections import defaultdict


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


def calculate_days_since_start() -> int:
    """calculate num days since a set date in UTC"""
    start_date = datetime.datetime(2023, 4, 1, tzinfo=datetime.timezone.utc)
    current_date = datetime.datetime.utcnow().replace(tzinfo=datetime.timezone.utc)
    delta = current_date - start_date
    return delta.days


def cat_is_filter_value(event: dict, filter_value: str=None) -> bool:
    if filter_value is None: return True
    cats = event['cat'].split(',')
    return filter_value in cats


def get_all_cats_from_events_tsv(list_of_event_dicts:list):
    all_cats = []
    for event in list_of_event_dicts:
        cats = event['cat'].split(',')
        all_cats.append(cats)

    cat_counts = defaultdict(int)
    for cat_list in all_cats:
        for cat in cat_list:
            cat_counts[cat] += 1
    
    return dict(cat_counts)


def handle_events_path(event, list_of_event_dicts, num_events=6):
    randint_game_id = random.randint(1,1e6)
    game_id = calculate_days_since_start()

    if event.get('queryStringParameters'):
        cat_filter = event['queryStringParameters'].get('cat_filter', None)
        partial_filter_by_cat = partial(cat_is_filter_value, filter_value=cat_filter)

        list_of_event_dicts = list(filter(partial_filter_by_cat, list_of_event_dicts))
        
        num_events = int(event['queryStringParameters'].get('num_events', num_events)) 

        random_param = event['queryStringParameters'].get('random', 1)
        if random_param == 'true':
            random.shuffle(list_of_event_dicts)
            game_id = f'rand_{randint_game_id}'
        else:
            random.seed(game_id)
            random.shuffle(list_of_event_dicts)
    
    response = {
        'statusCode': 200,
        'headers': {
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
        },
        'body': json.dumps({
            'seed_value': game_id,
            'game_id': game_id,
            'event_list': list_of_event_dicts[:num_events],
            'bonus_list': list_of_event_dicts[num_events:num_events*2]
        })
    }
    return response


def handle_categories_path(list_of_event_dicts):
    all_cats = get_all_cats_from_events_tsv(list_of_event_dicts)
    response = {
        'statusCode': 200,
        'headers': {
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
        },
        'body': json.dumps({
            'all_cats': all_cats,
        })
    }

    return response

def handle_alerts_path():
    response = {
        'statusCode': 200,
        'headers': {
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
        },
        'body': json.dumps({
            'alert': 'hello world',
        })
    }

    return response


def handler(event, context):
    s3 = boto3.client('s3')    

    # session = boto3.Session(profile_name='tjwdev')
    # # Create an S3 client using the session
    # s3 = session.client('s3')

    bucket_name = 'chrono-events-api'
    object_key = 'events.tsv'

    dict_values = pull_events_tsv_from_s3(s3, bucket_name, object_key)
    
    if event['path'] == '/events':
        response = handle_events_path(event, dict_values, num_events=1)
    elif event['path'] == '/categories':
        response = handle_categories_path(dict_values)
    elif event['path'] == '/alerts':
        response = handle_alerts_path()
    else:
        response = {'statusCode':400, 'body':'not found'}
    return response