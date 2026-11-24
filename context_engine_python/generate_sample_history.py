"""Generate realistic sample water usage history and upload it to Firebase."""

from __future__ import annotations

import random
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import Iterable

try:
    import firebase_admin
    from firebase_admin import credentials, db
except ImportError as exc:  # pragma: no cover - runtime dependency check
    raise SystemExit(
        "Missing dependency: firebase-admin. Install it before running this script."
    ) from exc


DATABASE_URL = "https://watermonitor-36e94-default-rtdb.asia-southeast1.firebasedatabase.app"
RECORD_COUNT = 1000
INTERVAL_SECONDS = 10

CATEGORY_SPECS: list[tuple[str, float, tuple[float, float], bool]] = [
    ("night", 0.10, (0.0, 0.2), False),
    ("normal", 0.40, (0.8, 2.5), False),
    ("morning", 0.25, (2.5, 5.5), False),
    ("evening", 0.15, (2.5, 5.0), False),
    ("high_usage", 0.05, (5.5, 7.5), False),
    ("leak", 0.05, (8.0, 12.0), True),
]


def resolve_service_account_file() -> Path:
    """Find the Firebase service account file without touching other projects."""
    script_dir = Path(__file__).resolve().parent
    candidates = [
        script_dir / "context_engine_python" / "serviceAccountKey.json",
        script_dir / "serviceAccountKey.json",
    ]

    for candidate in candidates:
        if candidate.exists():
            return candidate

    raise FileNotFoundError(
        "Could not find serviceAccountKey.json in the repo root or context_engine_python/."
    )


def make_timestamp_key(timestamp: datetime) -> str:
    """Create a Firebase-safe key for the record timestamp."""
    return timestamp.strftime("%Y-%m-%dT%H-%M-%SZ")


def category_counts(total_records: int) -> dict[str, int]:
    """Convert category percentages into exact record counts."""
    counts: dict[str, int] = {}
    allocated = 0

    for index, (name, percentage, _, _) in enumerate(CATEGORY_SPECS):
        if index == len(CATEGORY_SPECS) - 1:
            count = total_records - allocated
        else:
            count = round(total_records * percentage)
            allocated += count
        counts[name] = count

    return counts


def build_category_sequence(rng: random.Random, total_records: int) -> list[str]:
    """Build a shuffled list that preserves the requested distribution exactly."""
    counts = category_counts(total_records)
    categories: list[str] = []

    for name, count in counts.items():
        categories.extend([name] * count)

    rng.shuffle(categories)
    return categories


def generate_history_records(
    rng: random.Random,
) -> tuple[list[tuple[str, dict[str, object]]], dict[str, int], list[float]]:
    """Build the 1,000 history records requested by the user."""
    now = datetime.now(timezone.utc).replace(microsecond=0)
    start_time = now - timedelta(seconds=(RECORD_COUNT - 1) * INTERVAL_SECONDS)
    categories = build_category_sequence(rng, RECORD_COUNT)

    records: list[tuple[str, dict[str, object]]] = []
    counts = {name: 0 for name, _, _, _ in CATEGORY_SPECS}
    flow_values: list[float] = []
    total_usage = round(rng.uniform(2500.0, 8000.0), 2)
    daily_usage = 0.0
    current_day = None

    flow_ranges = {name: flow_range for name, _, flow_range, _ in CATEGORY_SPECS}

    for index in range(RECORD_COUNT):
        timestamp = start_time + timedelta(seconds=index * INTERVAL_SECONDS)
        if current_day != timestamp.date():
            current_day = timestamp.date()
            daily_usage = 0.0

        timestamp_key = make_timestamp_key(timestamp)
        category = categories[index]
        low, high = flow_ranges[category]
        flow_rate = round(rng.uniform(low, high), 2)

        counts[category] += 1
        flow_values.append(flow_rate)

        usage_increment = flow_rate * (INTERVAL_SECONDS / 60.0)
        total_usage = round(total_usage + usage_increment, 2)
        daily_usage = round(daily_usage + usage_increment, 2)

        records.append(
            (
                timestamp_key,
                {
                    "flowRate": flow_rate,
                    "totalUsage": total_usage,
                    "dailyUsage": daily_usage,
                    "leakDetected": category == "leak",
                    "lastUpdated": timestamp_key,
                },
            )
        )

    return records, counts, flow_values


def upload_history(records: Iterable[tuple[str, dict[str, object]]]) -> int:
    """Upload the generated records to `/history`."""
    service_account_file = resolve_service_account_file()

    if not firebase_admin._apps:
        cred = credentials.Certificate(str(service_account_file))
        firebase_admin.initialize_app(cred, {"databaseURL": DATABASE_URL})

    history_payload = {key: value for key, value in records}
    db.reference("history").set(history_payload)
    return len(history_payload)


def main() -> None:
    rng = random.Random()

    records, counts, flow_values = generate_history_records(rng)
    uploaded_records = upload_history(records)

    print(f"Total records: {len(records)}")
    print(f"Normal records: {counts['normal']}")
    print(f"Night records: {counts['night']}")
    print(f"Morning records: {counts['morning']}")
    print(f"Evening records: {counts['evening']}")
    print(f"High usage records: {counts['high_usage']}")
    print(f"Leak records: {counts['leak']}")
    print(f"Uploaded records: {uploaded_records}")
    print(f"Minimum flow: {min(flow_values):.2f}")
    print(f"Maximum flow: {max(flow_values):.2f}")
    print(f"Average flow: {sum(flow_values) / len(flow_values):.2f}")
    print("Finished")


if __name__ == "__main__":
    main()
