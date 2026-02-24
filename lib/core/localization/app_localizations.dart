import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'en_US.dart';
import 'pt_BR.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  late final Map<String, String> _localizedStrings;

  Future<bool> load() async {
    _localizedStrings =
        locale.languageCode == 'en' ? enUSStrings : ptBRStrings;
    return true;
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  // Convenience getters
  String get appName => translate('app_name');
  String get login => translate('login');
  String get register => translate('register');
  String get email => translate('email');
  String get password => translate('password');
  String get forgotPassword => translate('forgot_password');
  String get logout => translate('logout');
  String get home => translate('home');
  String get history => translate('history');
  String get profile => translate('profile');
  String get reminders => translate('reminders');
  String get measurement => translate('measurement');
  String get startMeasurement => translate('start_measurement');
  String get results => translate('results');
  String get rmssd => translate('rmssd');
  String get sdnn => translate('sdnn');
  String get pnn50 => translate('pnn50');
  String get lf => translate('lf');
  String get hf => translate('hf');
  String get lfHfRatio => translate('lf_hf_ratio');
  String get sd1 => translate('sd1');
  String get sd2 => translate('sd2');
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get delete => translate('delete');
  String get settings => translate('settings');
  String get theme => translate('theme');
  String get language => translate('language');
  String get lightTheme => translate('light_theme');
  String get darkTheme => translate('dark_theme');
  String get portuguese => translate('portuguese');
  String get english => translate('english');
  String get noData => translate('no_data');
  String get syncStatus => translate('sync_status');
  String get offline => translate('offline');
  String get syncing => translate('syncing');
  String get synced => translate('synced');
  String get camera => translate('camera');
  String get bluetooth => translate('bluetooth');
  String get selectMethod => translate('select_method');
  String get duration => translate('duration');
  String get position => translate('position');
  String get sitting => translate('sitting');
  String get lying => translate('lying');
  String get standing => translate('standing');
  String get addReminder => translate('add_reminder');
  String get time => translate('time');
  String get days => translate('days');
  String get active => translate('active');
  String get inactive => translate('inactive');
  String get name => translate('name');
  String get confirmPassword => translate('confirm_password');
  String get passwordsDoNotMatch => translate('passwords_do_not_match');
  String get fieldRequired => translate('field_required');
  String get invalidEmail => translate('invalid_email');
  String get weakPassword => translate('weak_password');
  String get userNotFound => translate('user_not_found');
  String get wrongPassword => translate('wrong_password');
  String get error => translate('error');
  String get success => translate('success');
  String get loading => translate('loading');
  String get weeklySummary => translate('weekly_summary');
  String get lastMeasurements => translate('last_measurements');
  String get noMeasurements => translate('no_measurements');
  String get measurementDetail => translate('measurement_detail');
  String get date => translate('date');
  String get method => translate('method');
  String get device => translate('device');
  String get sendResetEmail => translate('send_reset_email');
  String get resetEmailSent => translate('reset_email_sent');
  String get noReminders => translate('no_reminders');
  String get viewAll => translate('view_all');
  String get placeFingerOnCamera => translate('place_finger_on_camera');
  String get measuringBluetooth => translate('measuring_bluetooth');
  String get finishMeasurement => translate('finish_measurement');
  String get cameraSubtitle => translate('camera_subtitle');
  String get bluetoothSubtitle => translate('bluetooth_subtitle');
  String get timeDomain => translate('time_domain');
  String get poincarePlot => translate('poincare_plot');
  String get frequencyDomain => translate('frequency_domain');
  String get hrvMetrics => translate('hrv_metrics');
  String get deleteTitle => translate('delete_title');
  String get deleteConfirmation => translate('delete_confirmation');
  String get calculatingHrv => translate('calculating_hrv');
  String get dayMon => translate('day_mon');
  String get dayTue => translate('day_tue');
  String get dayWed => translate('day_wed');
  String get dayThu => translate('day_thu');
  String get dayFri => translate('day_fri');
  String get daySat => translate('day_sat');
  String get daySun => translate('day_sun');

  String greeting(String name) =>
      translate('greeting').replaceAll('{name}', name);

  String waitForRrIntervals(int count) =>
      translate('wait_for_rr_intervals').replaceAll('{count}', '$count');

  String rrCount(int count) =>
      translate('rr_count').replaceAll('{count}', '$count');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'pt'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
