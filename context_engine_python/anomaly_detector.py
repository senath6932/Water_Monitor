"""Anomaly detection for the context engine."""

from __future__ import annotations

from datetime import datetime, timedelta, timezone
from typing import Any

from config import (
    BASELINE_RETRAIN_HISTORY_RECORDS,
    BASELINE_RETRAIN_INTERVAL_SECONDS,
    LEAK_HYSTERESIS_LPM,
)
from statistics_engine import StatisticalBaseline, StatisticsEngine


class AnomalyDetector:
    """Detect anomalous water flow using a persisted statistical baseline."""

    def __init__(self, statistics_engine: StatisticsEngine | None = None) -> None:
        self._statistics_engine = statistics_engine or StatisticsEngine()
        self._baseline: StatisticalBaseline | None = None
        self._last_retrained_at: datetime | None = None

    @property
    def baseline(self) -> StatisticalBaseline | None:
        return self._baseline

    @property
    def has_baseline(self) -> bool:
        return self._baseline is not None

    def load_baseline(self, baseline: StatisticalBaseline | None) -> None:
        """Load a baseline learned earlier or restored from Firebase."""
        self._baseline = baseline
        if baseline is None:
            self._last_retrained_at = None
            return

        self._last_retrained_at = self._parse_timestamp(baseline.learned_at) or datetime.now(
            timezone.utc
        )

    def learn_baseline(self, history: Any) -> StatisticalBaseline | None:
        """Learn a new baseline from history without touching live monitoring."""
        baseline = self._statistics_engine.learn_baseline(history)
        if baseline is not None:
            self.load_baseline(baseline)
        return baseline

    def should_retrain(self, records_since_retrain: int, now: datetime | None = None) -> bool:
        """Return True when the stored baseline should be refreshed."""
        if self._baseline is None:
            return True

        now = now or datetime.now(timezone.utc)
        if self._last_retrained_at is None:
            return True

        if (now - self._last_retrained_at) >= timedelta(seconds=BASELINE_RETRAIN_INTERVAL_SECONDS):
            return True

        return records_since_retrain >= BASELINE_RETRAIN_HISTORY_RECORDS

    def detect_leak(
        self,
        current_flow: float,
        leak_active: bool = False,
        hysteresis_lpm: float = LEAK_HYSTERESIS_LPM,
    ) -> dict[str, Any]:
        """Compare the current flow against the stored threshold with hysteresis."""
        if self._baseline is None:
            return {
                "ready": False,
                "state": "WAITING FOR BASELINE",
                "isLeak": False,
                "enteredLeak": False,
                "exitedLeak": False,
                "shouldNotify": False,
                "currentFlow": current_flow,
                "sampleCount": 0,
                "mean": None,
                "median": None,
                "std": None,
                "minimum": None,
                "maximum": None,
                "threshold": None,
                "exitThreshold": None,
            }

        threshold = float(self._baseline.threshold)
        hysteresis_lpm = max(0.0, float(hysteresis_lpm))
        exit_threshold = threshold - hysteresis_lpm
        enter_leak = current_flow > threshold
        exit_leak = current_flow < exit_threshold

        if leak_active:
            leak_active_now = not exit_leak
            entered_leak = False
            exited_leak = exit_leak
        else:
            leak_active_now = enter_leak
            entered_leak = enter_leak
            exited_leak = False

        return {
            "ready": True,
            "state": "LEAK_ACTIVE" if leak_active_now else "NORMAL",
            "isLeak": leak_active_now,
            "enteredLeak": entered_leak,
            "exitedLeak": exited_leak,
            "shouldNotify": entered_leak,
            "currentFlow": current_flow,
            "sampleCount": self._baseline.sample_count,
            "mean": self._baseline.mean,
            "median": self._baseline.median,
            "std": self._baseline.std,
            "minimum": self._baseline.minimum,
            "maximum": self._baseline.maximum,
            "threshold": threshold,
            "exitThreshold": exit_threshold,
        }

    def record_retrain_cycle(self) -> None:
        """Mark the stored baseline as freshly retrained."""
        if self._baseline is None:
            return

        self._last_retrained_at = datetime.now(timezone.utc)

    def _parse_timestamp(self, value: Any) -> datetime | None:
        if not value:
            return None

        if isinstance(value, datetime):
            return value if value.tzinfo else value.replace(tzinfo=timezone.utc)

        if isinstance(value, str):
            try:
                parsed = datetime.fromisoformat(value.replace("Z", "+00:00"))
            except ValueError:
                return None
            return parsed if parsed.tzinfo else parsed.replace(tzinfo=timezone.utc)

        return None
