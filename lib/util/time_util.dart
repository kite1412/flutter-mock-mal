
class Time {
  final int hour;
  final int minute;

  const Time({
    required this.hour,
    required this.minute
  });
}

class TimeUtil {

  // adjust the time from JST (japan standard time) to local time
  // note: JST: UTC+09:00
  static String adjustToLocal(Time time) {
    final timezoneOffset = DateTime.now().timeZoneOffset.inHours;
    final hour = realmOf23(time.hour, timezoneOffset - 9);
    final fixed = Time(hour: hour, minute: time.minute);
    return _adjustTime(fixed);
  }

  static int localizedHour(Time time) {
    final timezoneOffset = DateTime.now().timeZoneOffset.inHours;
    final hour = realmOf23(time.hour, timezoneOffset - 9);
    final fixed = Time(hour: hour, minute: time.minute);
    return fixed.hour;
  }

  static int needAdjustment(Time time) {
    final timezoneOffset = DateTime.now().timeZoneOffset.inHours;
    if ((time.hour + (timezoneOffset - 9)) > 23) {
      return 1;
    } else if ((time.hour + (timezoneOffset - 9)) < 0) {
      return -1;
    } else {
      return 0;
    }
  }

  static int realmOf23(int i, int operationNumber) {
    int number = i;
    if (operationNumber < 0) {
      for (int i = operationNumber; i < 0; i++) {
        if (number == 0) {
          number = 23;
        } else {
          number += -1;
        }
      }
    } else {
      for (int i = operationNumber; i > 0; i--) {
        if (number == 23) {
          number = 0;
        } else {
          number += 1;
        }
      }
    }
    return number;
  }

  static String _adjustTime(Time time) {
    String hour = time.hour.toString();
    String minute = time.minute.toString();
    if (time.hour < 10) {
      hour = hour.padLeft(2, "0");
    }
    if (time.minute < 10) {
      minute = minute.padLeft(2, "0");
    }
    return "$hour:$minute";
  }
}