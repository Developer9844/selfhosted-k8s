import time
import random
from datetime import datetime

def get_next_period(period):
    return str(int(period) + 1).zfill(4)

def format_time():
    return datetime.now().strftime('%Y-%m-%d %H:%M:%S')

def predict_random():
    return random.choice(['B', 'S'])

def start_prediction():
    initial_period = input("Enter starting period (e.g., 0860): ").zfill(4)
    initial_result = input("Enter result for that period (B/S): ").upper()

    if initial_result not in ('B', 'S'):
        print("Invalid result. Please enter 'B' or 'S'.")
        return

    try:
        int(initial_period)
    except ValueError:
        print("Invalid period number.")
        return

    try:
        seconds_left = int(input("How many seconds left for current period?: "))
    except ValueError:
        print("Invalid seconds input.")
        return

    try:
        num_predictions = int(input("How many predictions do you want to simulate?: "))
    except ValueError:
        print("Invalid number of predictions.")
        return

    current_period = initial_period

    # Wait for current period to end
    print(f"\nWaiting {seconds_left} seconds for current period to end...")
    for sec in range(seconds_left, 0, -1):
        print(f"\r{format_time()} - Time left: {sec:2d}s", end='')
        time.sleep(1)
    print("\n")

    # Prediction loop (pure random)
    for _ in range(num_predictions):
        next_period = get_next_period(current_period)
        next_result = predict_random()

        print(f"{format_time()} - Period: {next_period}, Prediction: {next_result}")
        current_period = next_period

        for sec in range(30, 0, -1):
            print(f"\rNext prediction in: {sec:2d}s", end='')
            time.sleep(1)
        print("\n")

# Run it
start_prediction()
