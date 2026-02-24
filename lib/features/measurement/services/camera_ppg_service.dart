// TODO: Implement camera PPG service for real heart rate detection
// This is a placeholder for the Camera PPG implementation.
// In production, this would process camera frames to detect
// color changes in the fingertip caused by blood flow.

import 'dart:async';

typedef RRCallback = void Function(double rrIntervalMs);

class CameraPpgService {
  bool _isRunning = false;
  Timer? _simulationTimer;

  bool get isRunning => _isRunning;

  Future<void> start(RRCallback onRR) async {
    if (_isRunning) return;
    _isRunning = true;
    // TODO: Initialize camera and start processing frames
    // For now, emit simulated RR intervals
    _simulationTimer = Timer.periodic(
      const Duration(milliseconds: 900),
      (_) {
        if (_isRunning) {
          // Simulate RR between 750ms and 1100ms
          final rr = 750 + (DateTime.now().millisecond % 350).toDouble();
          onRR(rr);
        }
      },
    );
  }

  Future<void> stop() async {
    _isRunning = false;
    _simulationTimer?.cancel();
    // TODO: Dispose camera controller
  }

  void dispose() {
    stop();
  }
}
