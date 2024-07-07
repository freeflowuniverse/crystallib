import redis
import random
import time
from datetime import datetime, timedelta

# Connect to Redis
r = redis.Redis(host='localhost', port=6379, db=0)

# Load Lua script from file
def load_lua_script(filename):
    with open(filename, 'r') as file:
        return file.read()

# Load the Lua script
lua_script = load_lua_script('stats_add.lua')

# Register the Lua script with Redis
update_stat = r.register_script(lua_script)

# Test function
def run_test(key:str):
    start_date = datetime(2023, 1, 1)
    end_date = datetime(2023, 2, 1)
    current_date = start_date
    
    # Generate and feed data for a year
    while current_date < end_date:
        # Generate a random value (you can modify this to simulate your actual data pattern)
        value = random.gauss(100, 40)  # Mean of 100, standard deviation of 20
        
        # Call the Lua script
        timestamp = int(current_date.timestamp())
        update_stat(keys=[key], args=[value, timestamp])
        
        # Move to next time step (let's say every 5 minutes)
        current_date += timedelta(minutes=5)
    
    # Retrieve and display results
    print("Test completed. Results:")
    
    # Current state
    state = r.hgetall(f"{key}:state")
    print("\nCurrent State:")
    for k, v in state.items():
        print(f"{k.decode()}: {v.decode()}")
    
    # Recent window data
    window = r.lrange(f"{key}:window", 0, -1)
    print("\nRecent Window Data (last 10 entries):")
    for v in window[:10]:
        print(v.decode())
    
    # Hourly snapshots
    hourly = r.hgetall(f"{key}:hourly")
    print("\nHourly Snapshots:")
    for k, v in hourly.items():
        hour = datetime.fromtimestamp(int(k.decode()) * 3600)
        print(f"{hour}: {v.decode()}")
    
    # Daily snapshots
    daily = r.hgetall(f"{key}:daily")
    print("\nDaily Snapshots:")
    for k, v in daily.items():
        day = datetime.fromtimestamp(int(k.decode()) * 86400)
        print(f"{day.date()}: {v.decode()}")

# Run the test
if __name__ == "__main__":
    
    for i in range(800):
        print(i)
        run_test(key = f"stats:stats{i+200}")