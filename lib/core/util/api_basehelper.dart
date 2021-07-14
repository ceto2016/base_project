import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ApiBaseHelper {
  final String _baseUrl = "https://www.hermosaapp.com/api/v1/";
  String local = "ar";
  ApiBaseHelper(local);
  Future<dynamic> get(String url) async {
    var responseJson;
    try {
      final response = await http.get(Uri.parse(_baseUrl + url), headers: {
        "Accept": "application/json",
        "Content-Language": local,
        "Content-Type": "application/json"
      });
      responseJson = _returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  Future<dynamic> post(String url, Map<String, dynamic> body) async {
    var responseJson;
    try {
      final response = await http
          .post(Uri.parse(_baseUrl + url), body: json.encode(body), headers: {
        "Accept": "application/json",
        "Content-Language": local,
        "Content-Type": "application/json"
      });
      responseJson = _returnResponse(response);
    } on SocketException {
      throw FetchDataException('NO_INTERNET');
    }
    return responseJson;
  }

  dynamic _returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        var responseJson = json.decode(response.body.toString());
        print(responseJson);
        return responseJson;
      case 400:
        throw BadRequestException(response.body.toString());
      case 422:
        throw response.body.toString();
      case 401:
      case 403:
        throw UnauthorisedException(response.body.toString());
      case 500:
      default:
        print(
            'Error occured while Communication with Server with StatusCode : ${response.statusCode} ${response.body}');
        throw FetchDataException(
            'Error occured while Communication with Server with StatusCode : ${response.statusCode} ${response.body}');
    }
  }
}

class AppException implements Exception {
  final _message;
  final _prefix;

  AppException([this._message, this._prefix]);

  String toString() {
    return "$_prefix$_message";
  }
}

class FetchDataException extends AppException {
  FetchDataException([String? message]) : super(message, "");
}

class BadRequestException extends AppException {
  BadRequestException([message]) : super(message, "Invalid Request: ");
}

class UnauthorisedException extends AppException {
  UnauthorisedException([message]) : super(message, "Unauthorised: ");
}

class InvalidInputException extends AppException {
  InvalidInputException([String? message]) : super(message, "Invalid Input: ");
}
