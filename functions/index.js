const admin = require('firebase-admin');
const { onValueWritten } = require('firebase-functions/v2/database');

admin.initializeApp();

const NORMAL_RECORD_INTERVAL_MS = 5 * 60 * 1000;
const HISTORY_STATE_PATH = '/history_state';

exports.mirrorWaterToHistory = onValueWritten('/water', async (event) => {
  const after = event.data.after.val();

  if (!after || typeof after !== 'object') {
    return;
  }

  const now = Date.now();
  const currentStatus = Boolean(after.leakDetected) ? 'leak' : 'normal';
  const stateRef = admin.database().ref(HISTORY_STATE_PATH);
  const stateSnapshot = await stateRef.get();
  const state = stateSnapshot.val() || {};
  const previousStatus = state.lastStatus || null;
  const lastNormalRecordedAt = Number(state.lastNormalRecordedAt) || 0;
  const statusChanged = previousStatus !== currentStatus;
  const shouldRecordNormalSnapshot =
    currentStatus === 'normal' &&
    now - lastNormalRecordedAt >= NORMAL_RECORD_INTERVAL_MS;
  const shouldRecord = statusChanged || shouldRecordNormalSnapshot;

  await stateRef.set({
    lastStatus: currentStatus,
    lastSeenAt: now,
    lastNormalRecordedAt:
      currentStatus === 'normal' && shouldRecord ? now : lastNormalRecordedAt,
  });

  if (!shouldRecord) {
    return;
  }

  const historyEntry = {
    flowRate: Number(after.flowRate) || 0,
    totalUsage: Number(after.totalUsage) || 0,
    dailyUsage: Number(after.dailyUsage) || 0,
    leakDetected: Boolean(after.leakDetected),
    lastUpdated: now,
    sourceUpdatedAt: Number(after.lastUpdated) || 0,
    status: currentStatus,
  };

  await admin.database().ref('history').push(historyEntry);
});
