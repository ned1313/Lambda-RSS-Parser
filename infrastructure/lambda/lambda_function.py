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
    
    # Parse the RSS feed
    feed = feedparser.parse(rss_url)
    
    # Get current time and time 1 hour ago
    now = datetime.now()
    one_hour_ago = now - timedelta(hours=1)
    
    # Filter items from last hour
    new_items = []
    for entry in feed.entries:
        # Convert published time to datetime
        published_time = datetime.fromtimestamp(time.mktime(entry.published_parsed))
        
        if published_time > one_hour_ago:
            new_items.append({
                'title': entry.title,
                'link': entry.link
            })
    
    return {
        'statusCode': 200,
        'body': new_items
    }
