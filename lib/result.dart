class Result {
  late bool status;
  late int code;
  late String msg;
  Result.fromMap(Map info) {
    status = info['status'] ?? false;
    code = int.tryParse("${info['code']}") ?? 0;
    msg = info['msg'] ?? "";
  }
}
