import 'package:dio/dio.dart';
import 'package:wise_util/business/log/wise_log.dart';
import 'package:wise_util/util/http/ReqContext.dart';

import 'TextLogPrinter.dart';

class HttpLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    ReqContext context = new ReqContext();
    context.setPath(options.baseUrl + options.path);
    context.setHttpMethod(options.method);
    context.setContentType(options.contentType!);
    context.setHttpHeader(options.headers.mapToStructureString());
    if (options.headers.containsKey("X-Psn")) {
      context.setPsn(options.headers["X-Psn"]);
    }
    final data = options.data;
    if (data != null) {
      if (data is Map) {
        context.setReqBody(data.mapToStructureString());
      } else if (data is FormData) {
        final formDataMap = Map()
          ..addEntries(data.fields)
          ..addEntries(data.files);
        context.setReqBody(formDataMap.mapToStructureString());
      } else {
        context.setReqBody(data.toString());
      }
    }
    WiseLog.request(TextLogPrinter.buildLog(context, true));
    handler.next(options);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    String errorStr = "\n==================== RESPONSE ====================\n"
        "- URL:\n${err.requestOptions.baseUrl + err.requestOptions.path}\n"
        "- METHOD: ${err.requestOptions.method}\n";
    errorStr +=
        "- HEADER:${err.requestOptions.headers.mapToStructureString()}\n";
    if (err.response != null && err.response!.data != null) {
      errorStr += "- ERROR:\n${_parseResponse(err.response!)}\n";
    } else {
      errorStr += "- ERROR-TYPE: ${err.type}\n";
      errorStr += "- MSG: ${err.message}\n";
    }
    WiseLog.request(errorStr);
    handler.next(err);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    String responseStr = "";
    response.headers.forEach(
        (key, list) => responseStr += "\n  " + "\"$key\" : \"$list\",");

    ReqContext context = new ReqContext();
    context.setPath(response.requestOptions.uri.toString());
    context.setHttpMethod(response.requestOptions.method);
    context.setRespContextType(response.requestOptions.contentType!);
    context.setHttpRespHeader(responseStr);
    if (response.requestOptions.headers.containsKey("X-Psn")) {
      context.setPsn(response.requestOptions.headers["X-Psn"]);
    }
    context.setRespBody(_parseResponse(response));
    WiseLog.request(TextLogPrinter.buildLog(context, false));
    WiseLog.request(responseStr);
    handler.next(response);
  }

  void printWrapped(String text) {
    final pattern = new RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }

  String _parseResponse(Response response) {
    String responseStr = "";
    var data = response.data;
    if (data is Map)
      responseStr += data.mapToStructureString();
    else if (data is List)
      responseStr += data.listToStructureString();
    else
      responseStr += response.data.toString();
    return responseStr;
  }
}

///Map拓展，MAp转字符串输出
extension Map2StringEx on Map {
  String mapToStructureString({int indentation = 2}) {
    String result = "";
    String indentationStr = " " * indentation;
    if (true) {
      result += "{";
      this.forEach((key, value) {
        if (value is Map) {
          var temp = value.mapToStructureString(indentation: indentation + 2);
          result += "\n$indentationStr" + "\"$key\" : $temp,";
        } else if (value is List) {
          result += "\n$indentationStr" +
              "\"$key\" : ${value.listToStructureString(indentation: indentation + 2)},";
        } else {
          result += "\n$indentationStr" + "\"$key\" : \"$value\",";
        }
      });
      result = result.substring(0, result.length - 1);
      result += indentation == 2 ? "\n}" : "\n${" " * (indentation - 1)}}";
    }

    return result;
  }
}

///List拓展，List转字符串输出
extension List2StringEx on List {
  String listToStructureString({int indentation = 2}) {
    String result = "";
    String indentationStr = " " * indentation;
    if (true) {
      result += "$indentationStr[";
      this.forEach((value) {
        if (value is Map) {
          var temp = value.mapToStructureString(indentation: indentation + 2);
          result += "\n$indentationStr" + "\"$temp\",";
        } else if (value is List) {
          result += value.listToStructureString(indentation: indentation + 2);
        } else {
          result += "\n$indentationStr" + "\"$value\",";
        }
      });
      result = result.substring(0, result.length - 1);
      result += "\n$indentationStr]";
    }
    return result;
  }
}
