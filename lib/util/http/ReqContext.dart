class ReqContext {
  String? psn;
  String? path;
  String? httpMethod;
  String? contentType;
  String? respContentType;
  String? httpHeader;
  String? respHttpHeader;
  String? reqBody;
  String? respBody;

  setPsn(String psn) {
    this.psn = psn;
  }

  String? getHttpHeader() {
    return httpHeader;
  }

  setHttpHeader(String head) {
    httpHeader = head;
  }

  setHttpRespHeader(String header) {
    respHttpHeader = header;
  }

  String? getHttpRespHeader() {
    return respHttpHeader;
  }

  setRespContextType(String type) {
    respContentType = type;
  }

  setRespBody(String respBody) {
    this.respBody = respBody;
  }

  String? getRespBody() {
    return respBody;
  }

  String? getRespContextType() {
    return respContentType;
  }

  String? getReqBody() {
    return reqBody;
  }

  setReqBody(String body) {
    this.reqBody = body;
  }

  String? getPsn() {
    return psn;
  }

  setPath(String path) {
    this.path = path;
  }

  String? getPath() {
    return path;
  }

  String? getHttppMethod() {
    return httpMethod;
  }

  setHttpMethod(String method) {
    httpMethod = method;
  }

  String? getContentType() {
    return contentType;
  }

  setContentType(String type) {
    this.contentType = type;
  }
}
