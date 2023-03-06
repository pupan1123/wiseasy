import 'screen_util.dart';

extension ScreenSizeExtension on num {
  ///[ScreenUtil.setWidth]
  double get w => ScreenUtil().setWidth(this);

  ///[ScreenUtil.setHeight]
  double get h => ScreenUtil().setHeight(this);

  ///[ScreenUtil.radius]
  double get r => ScreenUtil().radius(this);

  ///[ScreenUtil.setSp]
  double get sp => ScreenUtil().setSp(this);

  ///屏幕宽度的倍数
  double get sw => ScreenUtil().screenWidth * this;

  ///屏幕高度的倍数
  double get sh => ScreenUtil().screenHeight * this;
}
