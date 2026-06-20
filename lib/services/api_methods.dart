import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utility/helper.dart';

class ApiMethods {
  static final ApiMethods _apiCalling = ApiMethods._internal();

  ApiMethods._internal();

  factory ApiMethods() {
    return _apiCalling;
  }

  ///--------------Get Method (Pagination)-----------------------

  Future<String> getMethod({
    required String method,
    required Map<String, dynamic> body,
    Map<String, String>? header,
  }) async {
    if (await Helper.checkInternetConnection()) {
      try {
        debugPrint('Get Url: $method');

        if (header != null) {
          debugPrint('header:- ${header.toString()}');
        }
        log('Params11: $body');

        final response = await http.get(Uri.parse(method), headers: header);

        log('$method----> Response11: ${response.body} <----');

        // ✅ Handle empty response
        if (response.body.isEmpty) {
          _handleApiError(method, "Empty response");
          return '';
        }

        return response.body;
      } on SocketException catch (e) {
        _handleApiError(method, e);
        return '';
      } on FormatException catch (e) {
        _handleApiError(method, e);
        return '';
      } catch (e) {
        _handleApiError(method, e);
        return '';
      }
    } else {
      Helper.customToast("No internet");
      return '';
    }
  }

  ///--------------Get Method-----------------------

  Future<String> getMethodTwo({
    required String method,
    required Map<String, dynamic> body,
    Map<String, String>? header,
  }) async {
    if (await Helper.checkInternetConnection()) {
      try {
        debugPrint('Get Url: $method');

        if (header != null) {
          debugPrint('header:- ${header.toString()}');
        }
        log('Params: $body');

        final response = await http.get(
          Uri.parse(method).replace(queryParameters: body),
          headers: header,
        );

        log('$method----> Response: ${response.body} <----');

        // ✅ Handle empty response (prevents FormatException later)
        if (response.body.isEmpty) {
          Helper.customToast("Please close the app and reopen");
          return '';
        }

        return response.body;
      } on SocketException catch (e) {
        debugPrint('Socket Error:- $method ----> ${e.toString()} <----');
        Helper.customToast("Please close the app and reopen");
        return '';
      } on FormatException catch (e) {
        debugPrint('Format Error:- $method ----> ${e.toString()} <----');
        Helper.customToast("Please close the app and reopen");
        return '';
      } catch (e) {
        debugPrint('Error:- $method ----> ${e.toString()} <----');
        Helper.customToast("Please close the app and reopen");
        return '';
      }
    } else {
      Helper.customToast("No internet");
      return '';
    }
  }

  /// ============= Put Method =========================

  Future<String> putMethod({
    required String method,
    required Map<String, dynamic> body,
    required Map<String, String> header,
  }) async {

    try {

      debugPrint("PUT URL :- $method");
      debugPrint("PUT BODY :- $body");
      debugPrint("PUT HEADER :- $header");

      final response = await http.put(

        Uri.parse(method),

        headers: header,

        body: jsonEncode(body),
      );

      debugPrint(
        "PUT STATUS CODE :- ${response.statusCode}",
      );

      debugPrint(
        "PUT RESPONSE :- ${response.body}",
      );

      return response.body;

    } catch (e) {

      debugPrint(
        "PUT API ERROR :- ${e.toString()}",
      );

      rethrow;
    }
  }

  /// ============= Put Multipart ======================
  Future<String> putMultipartMethod({

    required String method,

    required Map<String, String> body,

    required Map<String, String> header,

    File? profileImage,

    List<File>? galleryImages,

  }) async {

    try {

      debugPrint(
        "MULTIPART PUT URL :- $method",
      );

      debugPrint(
        "MULTIPART PUT BODY :- $body",
      );

      debugPrint(
        "MULTIPART PUT HEADER :- $header",
      );

      final request =
      http.MultipartRequest(
        "PUT",
        Uri.parse(method),
      );

      /// HEADERS
      request.headers.addAll(header);

      /// BODY
      request.fields.addAll(body);

      /// PROFILE IMAGE
      if (profileImage != null) {

        request.files.add(

          await http.MultipartFile.fromPath(

            "profile_image",

            profileImage.path,
          ),
        );

        debugPrint(
          "PROFILE IMAGE :- ${profileImage.path}",
        );
      }

      /// GALLERY IMAGES
      if (galleryImages != null &&
          galleryImages.isNotEmpty) {

        for (File image in galleryImages) {

          request.files.add(

            await http.MultipartFile.fromPath(

              "gallery_images",

              image.path,
            ),
          );

          debugPrint(
            "GALLERY IMAGE :- ${image.path}",
          );
        }
      }

      /// RESPONSE
      final streamedResponse =
      await request.send();

      final response =
      await http.Response.fromStream(
        streamedResponse,
      );

      debugPrint(
        "MULTIPART PUT STATUS :- ${response.statusCode}",
      );

      debugPrint(
        "MULTIPART PUT RESPONSE :- ${response.body}",
      );

      return response.body;

    } catch (e) {

      debugPrint(
        "MULTIPART PUT ERROR :- ${e.toString()}",
      );

      rethrow;
    }
  }

  /// ============= Get Method without body ============

  Future<String> getMethod02({
    required String method,
    required Map<String, dynamic> body,
    Map<String, String>? header,
  }) async {
    if (await Helper.checkInternetConnection()) {
      try {
        debugPrint('Get Url (base): $method');
        if (header != null) debugPrint('header: $header');
        log('Query Params: $body');

        final uri = Uri.parse(method).replace(
          queryParameters: body.map(
                (key, value) => MapEntry(key, value.toString()),
          ),
        );

        final response = await http.get(uri, headers: header);

        log('$uri ----> Response: ${response.body} <----');

        // ✅ Handle empty response
        if (response.body.isEmpty) {
          Helper.customToast("Please close the app and reopen");
          return '';
        }

        return response.body;
      } on SocketException catch (e) {
        debugPrint('Socket Error: $method ----> ${e.toString()} <----');
        Helper.customToast("Please close the app and reopen");
        return '';
      } on FormatException catch (e) {
        debugPrint('Format Error: $method ----> ${e.toString()} <----');
        Helper.customToast("Please close the app and reopen");
        return '';
      } catch (e) {
        debugPrint('Error: $method ----> ${e.toString()} <----');
        Helper.customToast("Please close the app and reopen");
        return '';
      }
    } else {
      Helper.customToast("No internet");
      return '';
    }
  }

  ///--------------Post Method-----------------------

  Future<String> postMethod({
    required String method,
    required Map<String, dynamic> body,
    Map<String, String>? header,
  }) async {
    if (await Helper.checkInternetConnection()) {
      try {
        debugPrint('Post Url: $method');

        if (header != null) {
          debugPrint('header:- ${header.toString()}');
        }
        log('Params: $body');

        final response = await http.post(
          Uri.parse(method),
          body: jsonEncode(body),
          headers: header,
        );

        log('$method ----> Response: ${response.body} <----');

        // ✅ Handle empty response
        if (response.body.isEmpty) {
          Helper.customToast("Please close the app and reopen");
          return '';
        }

        return response.body;
      } on SocketException catch (e) {
        debugPrint('Socket Error:- $method ----> ${e.toString()} <----');
        Helper.customToast("Please close the app and reopen");
        return '';
      } on FormatException catch (e) {
        debugPrint('Format Error:- $method ----> ${e.toString()} <----');
        Helper.customToast("Please close the app and reopen");
        return '';
      } catch (e) {
        debugPrint('Error:- $method ----> ${e.toString()} <----');
        Helper.customToast("Please close the app and reopen");
        return '';
      }
    } else {
      Helper.customToast("No internet");
      return '';
    }
  }

  ///-------------- Delete Method-----------------------

  Future<String> deleteMethod({
    required String method,
    required Map<String, dynamic> body,
    Map<String, String>? header,
  }) async {
    if (await Helper.checkInternetConnection()) {
      try {
        debugPrint('Delete Url: $method');

        if (header != null) {
          debugPrint('header:- ${header.toString()}');
        }
        log('Params: $body');

        final response = await http.delete(
          Uri.parse(method),
          body: jsonEncode(body),
          headers: header,
        );

        log('$method ----> Response: ${response.body} <----');

        // ✅ Handle empty response
        if (response.body.isEmpty) {
          Helper.customToast("Please close the app and reopen");
          return '';
        }

        return response.body;
      } on SocketException catch (e) {
        debugPrint('Socket Error:- $method ----> ${e.toString()} <----');
        Helper.customToast("Please close the app and reopen");
        return '';
      } on FormatException catch (e) {
        debugPrint('Format Error:- $method ----> ${e.toString()} <----');
        Helper.customToast("Please close the app and reopen");
        return '';
      } catch (e) {
        debugPrint('Error:- $method ----> ${e.toString()} <----');
        Helper.customToast("Please close the app and reopen");
        return '';
      }
    } else {
      Helper.customToast("No internet");
      return '';
    }
  }

  void _handleApiError(String method, dynamic error) {
    debugPrint('Error:- $method ----> ${error.toString()} <----');

    // Show only one common message
    Helper.customToast("Please close the app and reopen");
  }
}