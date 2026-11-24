"""Application entry point for the context engine service."""

from __future__ import annotations

import time
from datetime import datetime, timezone
from enum import Enum
from typing import Any

from anomaly_detector import AnomalyDetector
from config import LEAK_HYSTERESIS_LPM, MONITOR_INTERVAL_SECONDS
from firebase_service import FirebaseService
from notification_service import NotificationService
from statistics_engine import StatisticalBaseline, StatisticsEngine


class MonitorState(str, Enum):
    """Leak-monitoring state machine states."""

    NORMAL = "NORMAL"
    LEAK_ACTIVE = "LEAK_ACTIVE"


def _extract_current_flow(water_data: dict[str, Any]) -> float:
    """Return the current flow value from a water snapshot."""
    try:
        return float(water_data.get("flowRate", 0.0))
    except (TypeError, ValueError):
        return 0.0


def _format_value(value: Any, unit: str = "") -> str:
    """Format a value for terminal output."""
    if value is None:
        return "N/A"
    if isinstance(value, (int, float)):
        suffix = f" {unit}" if unit else ""
        return f"{value:.2f}{suffix}"
    return str(value)


def _print_banner() -> None:
    print("====================================================")
    print("Context Engine Started")
    print("====================================================")
    print()


def _print_firebase_connection() -> None:
    print("Connected to Firebase")
    print()


def _print_monitoring() -> None:
    print("Monitoring...")
    print()


def _print_separator() -> None:
    print("----------------------------------------------------")


def _normalize_last_updated(value: Any) -> str | None:
    """Normalize lastUpdated values so repeated snapshots compare reliably."""
    if value is None:
        return None

    if isinstance(value, (int, float)):
        return str(int(value))

    if isinstance(value, str):
        stripped = value.strip()
        return stripped or None

    return str(value)


def _load_baseline_from_state(state: dict[str, Any]) -> StatisticalBaseline | None:
    baseline_payload = state.get("baseline")
    return StatisticalBaseline.from_dict(baseline_payload)


class ContextEngineApp:
    """Stateful runner for the water-monitoring context engine."""

    def __init__(self) -> None:
        self.firebase_service = FirebaseService()
        self.notification_service = NotificationService()
        self.statistics_engine = StatisticsEngine()
        self.anomaly_detector = AnomalyDetector(self.statistics_engine)
        self.previous_last_updated: str | None = None
        self.monitor_state = MonitorState.NORMAL
        self.active_leak_event_id: str | None = None
        self.history_records_since_retrain = 0
        self.connected = False

    def run(self) -> None:
        """Start the monitoring loop."""
        _print_banner()

        try:
            self._connect_and_bootstrap()
            _print_monitoring()

            while True:
                try:
                    self._monitor_once()
                except KeyboardInterrupt:
                    raise
                except Exception:
                    self.connected = False
                    self.firebase_service.close()
                    self.notification_service.close()
                    time.sleep(MONITOR_INTERVAL_SECONDS)
                    self._connect_and_bootstrap()
                    _print_monitoring()
        finally:
            self.firebase_service.close()
            self.notification_service.close()

    def _connect_and_bootstrap(self) -> None:
        self.firebase_service.connect()
        self.connected = True
        _print_firebase_connection()
        self._load_persisted_state()
        self._ensure_baseline()

    def _load_persisted_state(self) -> None:
        state = self.firebase_service.get_context_engine_state()
        baseline = _load_baseline_from_state(state)
        if baseline is not None:
            self.anomaly_detector.load_baseline(baseline)
        else:
            self.anomaly_detector.load_baseline(None)

        self.previous_last_updated = _normalize_last_updated(state.get("lastProcessedWaterUpdated"))
        self.monitor_state = self._load_monitor_state(state)
        active_event_id = state.get("activeLeakEventId")
        self.active_leak_event_id = str(active_event_id) if active_event_id else None

        raw_retrain_count = state.get("historyRecordsSinceRetrain", 0)
        try:
            persisted_retrain_count = int(raw_retrain_count)
        except (TypeError, ValueError):
            persisted_retrain_count = 0

        if baseline is not None:
            current_history_count = self.firebase_service.get_history_record_count()
            history_gap = max(0, current_history_count - baseline.history_record_count)
            self.history_records_since_retrain = max(persisted_retrain_count, history_gap)
        else:
            self.history_records_since_retrain = persisted_retrain_count

    def _load_monitor_state(self, state: dict[str, Any]) -> MonitorState:
        raw_state = state.get("monitorState")
        if isinstance(raw_state, str):
            normalized = raw_state.strip().upper()
            if normalized in MonitorState.__members__:
                return MonitorState[normalized]
        if state.get("leakActive") is True:
            return MonitorState.LEAK_ACTIVE
        return MonitorState.NORMAL

    def _ensure_baseline(self) -> None:
        if self.anomaly_detector.baseline is not None:
            return

        history = self.firebase_service.get_history()
        learned = self.anomaly_detector.learn_baseline(history)
        if learned is not None:
            self.history_records_since_retrain = 0
            self._save_baseline(learned)

    def _monitor_once(self) -> None:
        if not self.connected:
            self._connect_and_bootstrap()

        water_data = self.firebase_service.get_water_data()
        current_last_updated = _normalize_last_updated(water_data.get("lastUpdated"))

        if current_last_updated is None or current_last_updated == self.previous_last_updated:
            _print_separator()
            print("Waiting for new sensor data...")
            _print_separator()
            print()
            time.sleep(MONITOR_INTERVAL_SECONDS)
            return

        self.history_records_since_retrain += 1
        self._maybe_retrain_baseline()
        if self.anomaly_detector.baseline is None:
            _print_separator()
            print("Waiting for new sensor data...")
            _print_separator()
            print()
            self.previous_last_updated = current_last_updated
            self._save_runtime_state()
            time.sleep(MONITOR_INTERVAL_SECONDS)
            return

        current_flow = _extract_current_flow(water_data)
        leak_active = self.monitor_state == MonitorState.LEAK_ACTIVE
        result = self.anomaly_detector.detect_leak(
            current_flow,
            leak_active=leak_active,
            hysteresis_lpm=LEAK_HYSTERESIS_LPM,
        )

        threshold = result.get("threshold")
        threshold_value = float(threshold) if threshold is not None else None
        entered_leak = bool(result.get("enteredLeak"))
        exited_leak = bool(result.get("exitedLeak"))
        new_state = MonitorState.LEAK_ACTIVE if result.get("state") == MonitorState.LEAK_ACTIVE.value else MonitorState.NORMAL
        status_text = "LEAK DETECTED" if new_state == MonitorState.LEAK_ACTIVE else "NORMAL"

        _print_separator()
        print(f"Current Flow : {_format_value(current_flow, 'L/min')}")
        print(f"Threshold : {_format_value(threshold_value, 'L/min')}")
        print(f"Status : {status_text}")

        if entered_leak:
            event_id = self.active_leak_event_id or current_last_updated or self._build_fallback_event_id()
            created = self.notification_service.create_alert(
                current_flow=current_flow,
                threshold=threshold_value if threshold_value is not None else current_flow,
                event_id=event_id,
                last_updated=current_last_updated,
            )
            if created:
                print("Firebase Alert Created")
                sent_count = self.notification_service.send_push_notification(
                    current_flow=current_flow,
                    threshold=threshold_value if threshold_value is not None else current_flow,
                    event_id=event_id,
                )
                if sent_count > 0:
                    print("Push Notification Sent")
            self.active_leak_event_id = event_id
            self.monitor_state = MonitorState.LEAK_ACTIVE
        elif exited_leak:
            self.monitor_state = MonitorState.NORMAL
            self.active_leak_event_id = None
        else:
            self.monitor_state = new_state
            if self.monitor_state == MonitorState.NORMAL:
                self.active_leak_event_id = None

        _print_separator()
        print()

        self.previous_last_updated = current_last_updated
        self._save_runtime_state()
        time.sleep(MONITOR_INTERVAL_SECONDS)

    def _maybe_retrain_baseline(self) -> None:
        if not self.anomaly_detector.should_retrain(self.history_records_since_retrain):
            return

        history = self.firebase_service.get_history()
        learned = self.anomaly_detector.learn_baseline(history)
        if learned is None:
            return

        self.history_records_since_retrain = 0
        self._save_baseline(learned)

    def _save_baseline(self, baseline: StatisticalBaseline) -> None:
        payload = {
            "baseline": baseline.to_dict(),
            "lastBaselineLearnedAt": baseline.learned_at,
            "lastBaselineHistoryCount": baseline.history_record_count,
            "historyRecordsSinceRetrain": 0,
        }
        self.firebase_service.save_context_engine_state(payload)
        self.anomaly_detector.record_retrain_cycle()
        self._save_runtime_state()

    def _save_runtime_state(self) -> None:
        payload = {
            "monitorState": self.monitor_state.value,
            "leakActive": self.monitor_state == MonitorState.LEAK_ACTIVE,
            "activeLeakEventId": self.active_leak_event_id,
            "lastProcessedWaterUpdated": self.previous_last_updated,
            "historyRecordsSinceRetrain": self.history_records_since_retrain,
            "baseline": self.anomaly_detector.baseline.to_dict()
            if self.anomaly_detector.baseline is not None
            else None,
        }
        self.firebase_service.save_context_engine_state(payload)

    def _build_fallback_event_id(self) -> str:
        now = datetime.now(timezone.utc)
        return now.strftime("%Y%m%d%H%M%S%f")


def main() -> None:
    """Start the context engine application."""
    app = ContextEngineApp()

    try:
        app.run()
    except FileNotFoundError:
        print("Error: serviceAccountKey.json was not found in the project root.")
    except KeyboardInterrupt:
        print("Stopping Context Engine...")
    except Exception as exc:
        print(f"Error: unable to connect to Firebase or read data: {exc}")


if __name__ == "__main__":
    main()
