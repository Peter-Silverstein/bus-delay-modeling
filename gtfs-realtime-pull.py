import requests
import pandas as pd
from google.transit import gtfs_realtime_pb2
from google.protobuf.json_format import MessageToDict
from datetime import datetime
from datetime import timedelta
import pytz
import psycopg

# Setting up PostgreSQL connection
# conn = psycopg.connect(database = "postgres", 
                        # user = "postgres", 
                        # host= 'localhost',
                        # password = "Parkour",
                        # port = 5432)

# Define API details
API_KEY = "2c97496e-e814-4cd6-bb23-14413a2a480d"
FEED_URL = f"http://api.pugetsound.onebusaway.org/api/gtfs_realtime/trip-updates-for-agency/1.pb?key={API_KEY}"

# Function to fetch GTFS-Realtime feed
def fetch_gtfs_realtime(feed_url):
    response = requests.get(feed_url)
    response.raise_for_status()  # Raise an exception for HTTP errors
    return response.content

# Function to parse GTFS-Realtime feed
def parse_gtfs_feed(feed_content):
    feed = gtfs_realtime_pb2.FeedMessage()
    feed.ParseFromString(feed_content)
    return MessageToDict(feed)

# Function to extract trip data
def extract_trip_data(parsed_feed):
    trip_data = []
    for entity in parsed_feed.get("entity", []):
        if "tripUpdate" in entity:
            trip_update = entity["tripUpdate"]
            trip_id = trip_update.get("trip", {}).get("tripId", "")
            route_id = trip_update.get("trip", {}).get("routeId", "")
            agency_id = trip_update.get("trip", {}).get("agencyId", "")
            stop_time_updates = trip_update.get("stopTimeUpdate", [])
            
            for stop_time_update in stop_time_updates:
                stop_id = stop_time_update.get("stopId", "")
                arrival_time = stop_time_update.get("arrival", {}).get("time", "")
                departure_time = stop_time_update.get("departure", {}).get("time", "")
                
                # Append relevant data as a dictionary
                trip_data.append({
                    "trip_id": trip_id,
                    "route_id": route_id,
                    "agency_id": agency_id,
                    "stop_id": stop_id,
                    "arrival_time": arrival_time,
                    "departure_time": departure_time,
                })
    return trip_data

# Function to convert Unix time to date and seconds after midnight in PST
def convert_to_date_and_seconds(unix_time):
    if unix_time:
        utc_time = datetime.utcfromtimestamp(int(unix_time))
        pst_time = utc_time - timedelta(hours=8)  # Adjust for PST (UTC-8)
        date = pst_time.date()
        seconds_after_midnight = (pst_time - pst_time.replace(hour=0, minute=0, second=0, microsecond=0)).seconds
        return date, seconds_after_midnight
    return None, None

# Current time
SEA_tz = pytz.timezone("America/Los_Angeles")
currentTime = datetime.now(SEA_tz)
currentTime_sec = currentTime.hour * 3600 + currentTime.minute * 60 + currentTime.second 

# Main workflow
try:
    # Fetch and parse feed
    feed_content = fetch_gtfs_realtime(FEED_URL)
    parsed_feed = parse_gtfs_feed(feed_content)
    
    # Extract relevant data
    trips = extract_trip_data(parsed_feed)
    
    # Convert to DataFrame and save as CSV
    df = pd.DataFrame(trips)

    # Apply the conversion function to arrival and departure times
    df["arrival_date"], df["arrival_seconds"] = zip(*df["arrival_time"].apply(convert_to_date_and_seconds))
    df["departure_date"], df["departure_seconds"] = zip(*df["departure_time"].apply(convert_to_date_and_seconds))

    # Add column to indicate whether the update occurred in the past or future (i.e., is it forecasted or not?)
    df['future'] = [1 if x > currentTime_sec else 0 for x in df['arrival_seconds']]

    # Add column with date and time of request for future filtering
    df['timestamp'] = currentTime

    # Remove observations that are in the future
    # past_df = df[df['future'] == 0]
    
    print(past_df.head())  # Display the first few rows of the dataset
    
    # Save to CSV file
    past_df.to_csv("realtime_trip_data.csv", index=False)
except Exception as e:
    print(f"Error: {e}")