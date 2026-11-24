"""Firebase connectivity for the context engine."""

from __future__ import annotations

from typing import Any

import firebase_admin
from firebase_admin import credentials, db

from config import DATABASE_URL, SERVICE_ACCOUNT_FILE


class FirebaseService:
    """Read-only Firebase service for the context engine."""

    def __init__(self) -> None:
        self._app: firebase_admin.App | None = None
        self._owns_app = False

    def connect(self) -> None:
        """Initialize Firebase Admin SDK once."""
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

    def get_water_data(self) -> dict[str, Any]:
        """Return the current `/water` node as a dictionary."""
        self.connect()
        snapshot = db.reference("water").get() or {}
        return snapshot if isinstance(snapshot, dict) else {}

    def get_history(self) -> Any:
        """Return the `/history` node."""
        self.connect()
        return db.reference("history").get()

    def get_history_record_count(self) -> int:
        """Return the number of history records currently stored in Firebase."""
        history = self.get_history()
        if isinstance(history, dict):
            return len(history)
        if isinstance(history, list):
            return len(history)
        return 0

    def get_settings(self) -> dict[str, Any]:
        """Return the current `/settings` node as a dictionary."""
        self.connect()
        snapshot = db.reference("settings").get() or {}
        return snapshot if isinstance(snapshot, dict) else {}

    def get_context_engine_state(self) -> dict[str, Any]:
        """Return the persisted Context Engine state from Firebase settings."""
        self.connect()
        snapshot = db.reference("settings/contextEngine").get() or {}
        return snapshot if isinstance(snapshot, dict) else {}

    def save_context_engine_state(self, state: dict[str, Any]) -> None:
        """Persist Context Engine state without disturbing the rest of settings."""
        self.connect()
        db.reference("settings/contextEngine").update(state)

    def close(self) -> None:
        """Tear down the Firebase app if it was initialized here."""
        if self._app is not None and self._owns_app:
            firebase_admin.delete_app(self._app)

        self._app = None
        self._owns_app = False
