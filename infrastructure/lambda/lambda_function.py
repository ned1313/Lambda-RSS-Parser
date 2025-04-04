import os
import feedparser
from datetime import datetime, timedelta
import time

def lambda_handler(event, context):
    # Get RSS URL from environment variable
    rss_url = os.environ.get('RSS_FEED_URL')
    if not rss_url:
        return {
            'statusCode': 400,
            'body': 'RSS_URL environment variable not set'
        }
    
    # Get time span from environment variable (default to 1 hour)
    try:
        time_span = int(os.environ.get('TIME_SPAN', 1))
    except ValueError:
        time_span = 1
    
    # Parse the RSS feed
    feed = feedparser.parse(rss_url)
    
    # Get current time and time span ago
    now = datetime.now()
    time_ago = now - timedelta(hours=time_span)
    
    # Filter items from specified time span
    new_items = []
    for entry in feed.entries:
        # Convert published time to datetime
        published_time = datetime.fromtimestamp(time.mktime(entry.published_parsed))
        
        if published_time > time_ago:
            new_items.append({
                'title': entry.title,
                'link': entry.link,
                'content': entry.content[0].value if 'content' in entry else entry.summary
            })
    
    return {
        'statusCode': 200,
        'body': new_items
    }
