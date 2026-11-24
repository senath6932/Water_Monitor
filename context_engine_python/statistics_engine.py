"""Statistical processing for the context engine."""

from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timezone
from typing import Any

import numpy as np

from config import BASELINE_MIN_SAMPLES, HISTORY_WINDOW_SIZE


@dataclass(slots=True)
class StatisticalBaseline:
    """Persisted statistical model learned from normal history."""

    sample_count: int
    mean: float
    median: float
    std: float
    threshold: float
    minimum: float
    maximum: float
    history_record_count: int
    learned_at: str

    def to_dict(self) -> dict[str, Any]:
        return {
            "sampleCount": self.sample_count,
            "mean": self.mean,
            "median": self.median,
            "std": self.std,
            "threshold": self.threshold,
            "minimum": self.minimum,
            "maximum": self.maximum,
            "historyRecordCount": self.history_record_count,
            "learnedAt": self.learned_at,
        }

    @classmethod
    def from_dict(cls, payload: Any) -> StatisticalBaseline | None:
        if not isinstance(payload, dict):
            return None

        try:
            return cls(
                sample_count=int(payload.get("sampleCount", 0)),
                mean=float(payload.get("mean")),
                median=float(payload.get("median")),
                std=float(payload.get("std")),
                threshold=float(payload.get("threshold")),
                minimum=float(payload.get("minimum")),
                maximum=float(payload.get("maximum")),
                history_record_count=int(payload.get("historyRecordCount", 0)),
                learned_at=str(payload.get("learnedAt") or ""),
            )
        except (TypeError, ValueError):
            return None


class StatisticsEngine:
    """Compute a stable statistical baseline from historical water flow."""

    def __init__(self) -> None:
        self._last_history_records: list[Any] = []
        self._last_recent_records: list[Any] = []
        self._last_included_records: list[Any] = []
        self._last_excluded_leak_records: list[Any] = []
        self._last_summary: dict[str, int] = {
            "totalHistoryRecords": 0,
            "includedNormalSamples": 0,
            "excludedLeakSamples": 0,
        }

    def learn_baseline(self, history: Any) -> StatisticalBaseline | None:
        """Build a statistical baseline from recent normal history records only."""
        flow_rates = self.get_flow_rates(history)
        if len(flow_rates) < BASELINE_MIN_SAMPLES:
            return None

        values = np.asarray(flow_rates, dtype=float)
        mean = float(np.mean(values))
        median = float(np.median(values))
        std = float(np.std(values, ddof=0))
        minimum = float(np.min(values))
        maximum = float(np.max(values))
        threshold = mean + (2.0 * std)
        learned_at = datetime.now(timezone.utc).isoformat(timespec="seconds")

        return StatisticalBaseline(
            sample_count=int(values.size),
            mean=mean,
            median=median,
            std=std,
            threshold=threshold,
            minimum=minimum,
            maximum=maximum,
            history_record_count=len(self._last_history_records),
            learned_at=learned_at,
        )

    def get_flow_rates(self, history: Any) -> list[float]:
        """Extract valid recent flow-rate values from normal history records."""
        raw_records = self._iter_records(history)
        self._last_history_records = list(raw_records)

        recent_records = self._get_recent_records(raw_records)
        self._last_recent_records = list(recent_records)

        flow_rates: list[float] = []
        included_records: list[Any] = []
        excluded_leak_records: list[Any] = []

        for record in recent_records:
            if self._is_leak_record(record):
                excluded_leak_records.append(record)
                continue

            value = self._extract_flow_rate(record)
            if value is None:
                continue

            included_records.append(record)
            flow_rates.append(value)

        self._last_included_records = included_records
        self._last_excluded_leak_records = excluded_leak_records
        self._last_summary = {
            "totalHistoryRecords": len(raw_records),
            "includedNormalSamples": len(flow_rates),
            "excludedLeakSamples": len(excluded_leak_records),
        }

        return flow_rates

    def calculate_mean(self, flow_rates: list[float]) -> float:
        """Calculate the mean flow rate."""
        if not flow_rates:
            return 0.0
        return float(np.mean(np.asarray(flow_rates, dtype=float)))

    def calculate_standard_deviation(self, flow_rates: list[float]) -> float:
        """Calculate the population standard deviation of flow rates."""
        if not flow_rates:
            return 0.0
        return float(np.std(np.asarray(flow_rates, dtype=float), ddof=0))

    def calculate_dynamic_threshold(self, flow_rates: list[float]) -> dict[str, float | int] | None:
        """Calculate summary statistics and a dynamic leak threshold."""
        if len(flow_rates) < BASELINE_MIN_SAMPLES:
            return None

        values = np.asarray(flow_rates, dtype=float)
        mean = float(np.mean(values))
        median = float(np.median(values))
        std = float(np.std(values, ddof=0))
        minimum = float(np.min(values))
        maximum = float(np.max(values))
        threshold = mean + (2.0 * std)

        return {
            "sampleCount": int(values.size),
            "mean": mean,
            "median": median,
            "std": std,
            "minimum": minimum,
            "maximum": maximum,
            "threshold": threshold,
        }

    def get_last_summary(self) -> dict[str, int]:
        """Return the latest history sample summary."""
        return dict(self._last_summary)

    def get_last_excluded_leak_records(self) -> list[Any]:
        """Return the latest excluded leak records for debugging."""
        return list(self._last_excluded_leak_records)

    def _get_recent_records(self, records: list[Any]) -> list[Any]:
        sorted_records = list(records)
        sorted_records.sort(key=self._record_timestamp, reverse=True)
        return sorted_records[:HISTORY_WINDOW_SIZE]

    def _iter_records(self, history: Any) -> list[Any]:
        if isinstance(history, dict):
            return list(history.values())
        if isinstance(history, list):
            return list(history)
        return []

    def _is_leak_record(self, record: Any) -> bool:
        if not isinstance(record, dict):
            return False
        return record.get("leakDetected") is True

    def _record_timestamp(self, record: Any) -> int:
        if not isinstance(record, dict):
            return 0

        raw_timestamp = record.get("lastUpdated")
        if raw_timestamp is None:
            raw_timestamp = record.get("timestamp")

        if isinstance(raw_timestamp, (int, float)):
            return int(raw_timestamp)

        if isinstance(raw_timestamp, str):
            try:
                parsed = datetime.strptime(raw_timestamp, "%Y-%m-%dT%H-%M-%SZ")
            except ValueError:
                try:
                    return int(raw_timestamp)
                except (TypeError, ValueError):
                    return 0
            return int(parsed.replace(tzinfo=timezone.utc).timestamp())

        try:
            return int(raw_timestamp)
        except (TypeError, ValueError):
            return 0

    def _extract_flow_rate(self, record: Any) -> float | None:
        if not isinstance(record, dict):
            return None

        if "flowRate" not in record:
            return None

        raw_value = record.get("flowRate")
        if raw_value is None:
            return None

        try:
            flow_rate = float(raw_value)
        except (TypeError, ValueError):
            return None

        if np.isnan(flow_rate) or not np.isfinite(flow_rate):
            return None

        if flow_rate < 0.2:
            return None

        return flow_rate
