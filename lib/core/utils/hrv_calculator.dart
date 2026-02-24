import 'dart:math';

class HRVCalculator {
  HRVCalculator._();

  /// Root Mean Square of Successive Differences (ms)
  static double calcRMSSD(List<double> rr) {
    if (rr.length < 2) return 0;
    double sum = 0;
    for (int i = 1; i < rr.length; i++) {
      final diff = rr[i] - rr[i - 1];
      sum += diff * diff;
    }
    return sqrt(sum / (rr.length - 1));
  }

  /// Standard Deviation of NN intervals (ms)
  static double calcSDNN(List<double> rr) {
    if (rr.isEmpty) return 0;
    final mean = rr.reduce((a, b) => a + b) / rr.length;
    final sumSq =
        rr.map((r) => pow(r - mean, 2).toDouble()).reduce((a, b) => a + b);
    return sqrt(sumSq / rr.length);
  }

  /// Percentage of successive RR intervals differing by > 50 ms
  static double calcPNN50(List<double> rr) {
    if (rr.length < 2) return 0;
    int count = 0;
    for (int i = 1; i < rr.length; i++) {
      if ((rr[i] - rr[i - 1]).abs() > 50) count++;
    }
    return (count / (rr.length - 1)) * 100;
  }

  /// Poincaré plot descriptors SD1 and SD2
  static Map<String, double> calcPoincare(List<double> rr) {
    final rmssd = calcRMSSD(rr);
    final sdnn = calcSDNN(rr);
    final sd1 = rmssd / sqrt(2);
    final sd2Sq = 2 * pow(sdnn, 2) - pow(sd1, 2);
    final sd2 = sd2Sq > 0 ? sqrt(sd2Sq) : 0.0;
    return {'sd1': sd1, 'sd2': sd2};
  }

  /// Simplified frequency-domain analysis using spectral estimation
  /// LF band: 0.04–0.15 Hz, HF band: 0.15–0.40 Hz
  static Map<String, double> calcFrequencyDomain(List<double> rr) {
    if (rr.length < 4) {
      return {'lf': 0, 'hf': 0, 'lf_hf_ratio': 0};
    }

    // Compute mean RR (in seconds for frequency calculation)
    final meanRR = rr.reduce((a, b) => a + b) / rr.length / 1000.0;
    final fs = 1.0 / meanRR; // Sampling frequency

    // Detrend
    final mean = rr.reduce((a, b) => a + b) / rr.length;
    final detrended = rr.map((r) => r - mean).toList();

    final n = detrended.length;
    double lf = 0;
    double hf = 0;

    // Discrete Fourier Transform power estimation
    for (int k = 1; k < n ~/ 2; k++) {
      final freq = k * fs / n;
      double re = 0;
      double im = 0;
      for (int t = 0; t < n; t++) {
        final angle = 2 * pi * k * t / n;
        re += detrended[t] * cos(angle);
        im -= detrended[t] * sin(angle);
      }
      final power = (re * re + im * im) / n;

      if (freq >= 0.04 && freq < 0.15) {
        lf += power;
      } else if (freq >= 0.15 && freq <= 0.40) {
        hf += power;
      }
    }

    final lfHfRatio = hf > 0 ? lf / hf : 0.0;
    return {'lf': lf, 'hf': hf, 'lf_hf_ratio': lfHfRatio};
  }

  /// Mean heart rate in bpm from RR intervals (ms)
  static double calcMeanHR(List<double> rr) {
    if (rr.isEmpty) return 0;
    final meanRR = rr.reduce((a, b) => a + b) / rr.length;
    return meanRR > 0 ? 60000 / meanRR : 0;
  }

  /// Compute all HRV metrics at once
  static Map<String, double> calcAll(List<double> rrIntervals) {
    final poincare = calcPoincare(rrIntervals);
    final freq = calcFrequencyDomain(rrIntervals);

    return {
      'rmssd': calcRMSSD(rrIntervals),
      'sdnn': calcSDNN(rrIntervals),
      'pnn50': calcPNN50(rrIntervals),
      'sd1': poincare['sd1']!,
      'sd2': poincare['sd2']!,
      'lf': freq['lf']!,
      'hf': freq['hf']!,
      'lf_hf_ratio': freq['lf_hf_ratio']!,
      'mean_hr': calcMeanHR(rrIntervals),
    };
  }
}
