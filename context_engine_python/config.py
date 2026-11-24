"""Configuration constants for the context engine project."""

DATABASE_URL = "https://watermonitor-36e94-default-rtdb.asia-southeast1.firebasedatabase.app"
SERVICE_ACCOUNT_FILE = "serviceAccountKey.json"
MONITOR_INTERVAL_SECONDS = 10
BASELINE_MIN_SAMPLES = 10
BASELINE_RETRAIN_INTERVAL_SECONDS = 30 * 60
BASELINE_RETRAIN_HISTORY_RECORDS = 500
HISTORY_WINDOW_SIZE = 1000
LEAK_HYSTERESIS_LPM = 1.0
