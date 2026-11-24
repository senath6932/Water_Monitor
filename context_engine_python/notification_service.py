"""Firebase alert creation and push notifications for the context engine."""

from __future__ import annotations

from datetime import datetime, timezone
from typing import Any

import firebase_admin
from firebase_admin import credentials, db, messaging

from config import DATABASE_URL, SERVICE_ACCOUNT_FILE


class NotificationService:
    """Create Firebase alerts for detected leaks and notify devices."""

    def __init__(self) -> None:
        self._app: firebase_admin.App | None = None
        self._owns_app = False

    def _connect(self) -> None:
        """Initialize Firebase Admin SDK if needed."""
        if self._app is not None:
            return

        if not firebase_admin._apps:
            cred = credentials.Certificate(SERVICE_ACCOUNT_FILE)
            self._app = firebase_admin.initialize_app(
                cred,
                {"databaseURL": DATABASE_URL},
            )
            self._owns_app = True
            return

        self._app = firebase_admin.get_app()
        self._owns_app = False

    def create_alert(
        self,
        current_flow: float,
        threshold: float,
        event_id: str,
        last_updated: str | int | float | None = None,
    ) -> bool:
        """Create a leak alert for a new leak event."""
        self._connect()

        alert_key = self._build_alert_key(event_id)
        alert_ref = db.reference("alerts").child(alert_key)
        if alert_ref.get() is not None:
            return False

        now_ms = int(datetime.now(timezone.utc).timestamp() * 1000)
        alert = {
            "title": "Possible Water Leak",
            "message": "Current flow exceeded the learned statistical threshold.",
            "severity": "critical",
            "type": "statisticalLeak",
            "eventId": event_id,
            "currentFlow": float(current_flow),
            "threshold": float(threshold),
            "lastUpdated": last_updated,
            "timestamp": now_ms,
        }

        alert_ref.set(alert)
        return True

    def send_push_notification(
        self,
        current_flow: float,
        threshold: float,
        event_id: str,
    ) -> int:
        """Send a statistical leak push notification to all registered devices."""
        self._connect()

        now_ms = int(datetime.now(timezone.utc).timestamp() * 1000)
        tokens = self._get_device_tokens()
        sent_count = 0

        for device_id, token in tokens:
            try:
                message = messaging.Message(
                    token=token,
                    notification=messaging.Notification(
                        title="Possible Water Leak",
                        body="Current flow exceeded the learned statistical threshold.",
                    ),
                    data={
                        "type": "statisticalLeak",
                        "eventId": event_id,
                        "currentFlow": str(float(current_flow)),
                        "threshold": str(float(threshold)),
                        "timestamp": str(now_ms),
                    },
                )
                messaging.send(message)
                sent_count += 1
            except Exception:
                continue

        return sent_count

    def close(self) -> None:
        """Tear down the Firebase app if it was initialized here."""
        if self._app is not None and self._owns_app:
            firebase_admin.delete_app(self._app)

        self._app = None
        self._owns_app = False

    def _get_device_tokens(self) -> list[tuple[str, str]]:
        """Return all registered device IDs and their tokens."""
        snapshot = db.reference("deviceTokens").get()
        if not isinstance(snapshot, dict):
            return []

        tokens: list[tuple[str, str]] = []
        for device_id, raw_value in snapshot.items():
            token = self._extract_token(raw_value)
            if token:
                tokens.append((str(device_id), token))
        return tokens

    def _extract_token(self, raw_value: Any) -> str | None:
        """Pull a token string from a deviceTokens record."""
        if isinstance(raw_value, dict):
            token = raw_value.get("token")
            if token:
                return str(token)
            return None

        if raw_value:
            return str(raw_value)

        return None

    def _build_alert_key(self, event_id: str) -> str:
        """Create a Firebase-safe alert key from an event ID."""
        key = str(event_id).strip() or "event"
        safe_chars: list[str] = []
        for char in key:
            if char.isalnum() or char in {"-", "_"}:
                safe_chars.append(char)
            else:
                safe_chars.append("-")
        return "".join(safe_chars)
