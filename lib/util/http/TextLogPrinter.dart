import 'package:wise_util/util/http/ReqContext.dart';

class TextLogPrinter {
  static String buildLog(ReqContext context, bool reqLog) {
    StringBuffer builder = new StringBuffer();
    if (reqLog) {
      builder.writeln(
          "--------------------------------------request--------------------------------------------");
    } else {
      builder.writeln(
          "--------------------------------------response-------------------------------------------");
    }

    // Restful请求的接口地址
    if (context.getPath() != null) {
      builder.write("[path]          ");
      builder.writeln(context.getPath());
    }

    // contentType、header
    if (reqLog) {
      if (null != context.getHttppMethod()) {
        builder.write("[httpMethod]    ");
        builder.writeln(context.getHttppMethod());
      }
      if (null != context.getContentType()) {
        builder.write("[contentType]   ");
        builder.writeln(context.getContentType());
      }
      if (null != context.getHttpHeader()) {
        builder.write("[header]        ");
        builder.writeln(context.getHttpHeader());
      }
    } else {
      if (null != context.getRespContextType()) {
        builder.write("[contentType]   ");
        builder.writeln(context.getRespContextType());
      }
      if (null != context.getHttpRespHeader()) {
        builder.write("[header]        ");
        builder.writeln(context.getHttpRespHeader());
      }
    }

    // 报文序列号
    if (null != context.getPsn()) {
      builder.write("[psn]           ");
      builder.writeln(context.getPsn());
    }

    // 接口报文
    if (reqLog) {
      if (context.getReqBody() != null) {
        builder
            .write("[packet]        ");
        builder.writeln(_getBody(context.getReqBody()));
      }
    } else {
      if (null != context.getRespBody()) {
        builder
            .write("[packet]        ");
        builder.writeln(_getBody(context.getRespBody()));
      }
    }

    builder.writeln(
        "-----------------------------------------------------------------------------------------");
    print("报文格式${builder.toString()}");
    return builder.toString();
  }

   static String _getBody(String? body) {
    if(null ==body||body.isEmpty) {
      return "";
    }
      if (body.length > 1000) {
        body = body.substring(0, 1000) + "...";
      }
    return body;
  }
}
