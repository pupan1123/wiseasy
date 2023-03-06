import 'package:intl/intl.dart';

import '/config/wise_config.dart';
import 'currency_update.dart';

class CurrencyFormatter {
  ///格式化货币
  static String format(number, {bool showSymbol = false, String? currencyName}) {
    if (number == null) {
      number = 0;
    } else if (number is String) {
      try {
        number = number.isEmpty ? 0 : double.parse(number);
      } catch (e) {
        number = 0;
      }
    }
    var currencyFormat = showSymbol
        ? _getSimpleCurrency(currencyName: currencyName)
        : _getCurrency(currencyName: currencyName);
    String currencyAmount = currencyFormat.format(number);
    Map<String, String>? updateCurrency = currencyUpdate[currencyName];
    if (showSymbol && null != updateCurrency) {
      if (updateCurrency["new_currency"] ==
          getSymbol(currencyName: currencyName)) {
        return currencyAmount;
      } else {
        String? replace = updateCurrency["old_currency"];
        print("替换字符串$currencyAmount");
        print("替换字符串$replace");
        return currencyAmount.replaceAll(
            RegExp(replace!), updateCurrency["new_currency"]!);
      }
    } else {
      return currencyAmount;
    }
  }

  ///获取货币符号
  static String getSymbol({String? currencyName}) {
    return _getSimpleCurrency(currencyName: currencyName).currencySymbol;
  }

  ///获取小数分隔符
  static String getDecimalSeparator({String? currencyName}) {
    String temp = format(0, showSymbol: false, currencyName: currencyName);
    if (temp.contains(",")) {
      return ",";
    } else if (temp.contains(".")) {
      return ".";
    } else {
      return "";
    }
  }

  ///获取小数位数
  static int getDecimalPlaces({String? currencyName}) {
    return _getSimpleCurrency(currencyName: currencyName).decimalDigits ?? 2;
  }

  ///获取简单金额,例如:$1.00
  static NumberFormat _getSimpleCurrency({String? currencyName}) {
    String name = WiseConfig.getCurrency();
    String locale = WiseConfig.getRegion();
    if (null != currencyName) {
      name = currencyName;
    }
    return NumberFormat.simpleCurrency(name: name, locale: locale);
  }

  ///获取金额,例如:USD 1.00
  static NumberFormat _getCurrency({String? currencyName}) {
    String name = WiseConfig.getCurrency();
    String locale = WiseConfig.getRegion();
    if (null != currencyName) {
      name = currencyName;
    }
    return NumberFormat.currency(name: name, locale: locale);
  }
}
