// import 'dart:io';
//
// import 'package:nae/core/my_settings.dart';
// import 'package:nae/share/utils.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart';
// import 'package:http_parser/http_parser.dart';
// import 'package:mime/mime.dart';
//
// Future<String> myHttpGet(BuildContext context, String url, Map<String, String> params, GlobalKey<ScaffoldState> key, VoidCallback logOut, MySettings settings) async {
//   Response? res;
//   try {
//     if (settings.timeOut > 0) {
//       res = await get(Uri.parse(url), headers: {}..addAll(params)..addAll(Utils.httpSimpleJsonHeader("Bearer ${settings.token}", "", settings.userLogin, settings.userPsw)) ).timeout(Duration(seconds: settings.timeOut), onTimeout : () => _onTimeout());
//     } else {
//       res = await get(Uri.parse(url), headers: {}..addAll(params)..addAll(Utils.httpSimpleJsonHeader("Bearer ${settings.token}", "", settings.userLogin, settings.userPsw)) );
//     }
//   } catch(e) {
//     debugPrint(e.toString());
//     return "";
//   }
//
//   if (res.statusCode == 404) {
//     try {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ma'lumot yo'q.")));
//     } catch(_) {}
//
//     return "";
//   }
//
//   if (res.statusCode == 401) {
//     try {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Login yoki parol noto'g'ri.")));
//     } catch(_) {}
//     logOut();
//     return "";
//   }
//
//   if (res.statusCode != 200) {
//     try {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Serverda xatolik yuz berdi.")));
//     } catch(_) {}
//     return "";
//   }
//
//   return res.body;
// }
//
// _onTimeout() {
//   debugPrint("Time Out occurs");
// }
//
// Future<String> myHttpDelete(BuildContext context, String url, Map<String, String> params, GlobalKey<ScaffoldState> key, VoidCallback logOut, MySettings settings) async {
//   Response? res;
//   try {
//     res = await delete(Uri.parse(url),
//         headers: {}..addAll(params)..addAll(Utils.httpSimpleJsonHeader("Bearer ${settings.token}", "", settings.userLogin, settings.userPsw)) );
//   } catch(_) {
//     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Internet bilan aloqa yo'q.")));
//     return "";
//   }
//
//   if (res.statusCode == 404) {
//     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Server bilan aloqa yo'q.")));
//     return "";
//   }
//
//   if (res.statusCode == 401) {
//     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Login yoki parol noto'g'ri.")));
//     logOut();
//     return "";
//   }
//
//   if (res.statusCode != 200) {
//     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Serverda xatolik yuz berdi.")));
//     return "";
//   }
//
//   return res.body;
// }
//
// Future<String> myHttpPost(BuildContext context, String url, String body, Map<String, String> params, GlobalKey<ScaffoldState>? key, VoidCallback logOut, MySettings settings) async {
//   Response? res;
//   try {
//     if (settings.timeOut > 0) {
//       res = await post(Uri.parse(url),
//           headers: {}..addAll(params)..addAll(Utils.httpSimpleJsonHeader("Bearer ${settings.token}", "", settings.userLogin, settings.userPsw)),
//           body: body).timeout(
//           Duration(seconds: settings.timeOut), onTimeout: () => _onTimeout());
//     } else {
//       res = await post(Uri.parse(url),
//           headers: {}..addAll(params)..addAll(Utils.httpSimpleJsonHeader("Bearer ${settings.token}", "", settings.userLogin, settings.userPsw)),
//           body: body);
//     }
//   } catch(_) {
//     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Internet bilan aloqa yo'q.")));
//     return "";
//   }
//
//   if (res.statusCode == 404) {
//     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Server bilan aloqa yo'q.")));
//     return "";
//   }
//
//   if (res.statusCode == 401) {
//     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Login yoki parol noto'g'ri.")));
//     logOut();
//     return "";
//   }
//
//   if (res.statusCode != 200) {
//     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Serverda xatolik yuz berdi.")));
//     return "";
//   }
//
//   return res.body;
// }
//
// Future<String> myHttpPut(BuildContext context, String url, String body, Map<String, String> params, GlobalKey<ScaffoldState> key, VoidCallback logOut, MySettings settings) async {
//   Response? res;
//   try {
//     if (settings.timeOut > 0) {
//       res = await put(Uri.parse(url),
//           headers: {}..addAll(params)..addAll(Utils.httpSimpleJsonHeader("Bearer ${settings.token}", "", settings.userLogin, settings.userPsw)),
//           body: body).timeout(const Duration(seconds: 120), onTimeout: () => _onTimeout());
//     } else {
//       res = await put(Uri.parse(url),
//           headers: {}..addAll(params)..addAll(Utils.httpSimpleJsonHeader("Bearer ${settings.token}", "", settings.userLogin, settings.userPsw)),
//           body: body);
//     }
//   } catch(_) {
//     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Нет связь с сервером.")));
//     return "";
//   }
//
//   if (res.statusCode == 401) {
//     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Login yoki parol noto'g'ri.")));
//     logOut();
//     return "";
//   }
//
//   if (res.statusCode != 200) {
//     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Serverda xatolik yuz berdi.")));
//     return "";
//   }
//
//   return res.body;
// }
//
// Future<String> myHttpPostFile(BuildContext context, String phone, String psw, String db, String url, Map<String, String> body, File image, File image2, GlobalKey<ScaffoldState> key, VoidCallback logOut) async {
//   final mimeTypeData = lookupMimeType(image.path, headerBytes: [0xFF, 0xD8])!.split('/');
//   final imageUploadRequest = MultipartRequest('POST', Uri.parse(url));
//   final file = await MultipartFile.fromPath('file1', image.path, contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));
//
//   imageUploadRequest.headers['phone'] = phone;
//   imageUploadRequest.headers['psw'] = psw;
//   imageUploadRequest.headers['db'] = db;
//   imageUploadRequest.files.add(file);
//   imageUploadRequest.fields.addAll(body);
//   try {
//     final streamedResponse = await imageUploadRequest.send();
//     final response = await Response.fromStream(streamedResponse);
//     if (response.statusCode != 200) {
//       return "";
//     }
//     final String responseData = response.body;
//     return responseData;
//   } catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Server bilan aloqa yo'q.")));
//     debugPrint(e.toString());
//     return "";
//   }
// }
//
//
// Future<String> myHttpPostPic(BuildContext context, String phone, String psw, String db, String url, Map<String, String> body, File image, File image2, GlobalKey<ScaffoldState> key, VoidCallback logOut) async {
//   final mimeTypeData = lookupMimeType(image.path, headerBytes: [0xFF, 0xD8])!.split('/');
//   final imageUploadRequest = MultipartRequest('POST', Uri.parse(url));
//   final file = await MultipartFile.fromPath('photo', image.path, contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));
//
//   imageUploadRequest.headers['phone'] = phone;
//   imageUploadRequest.headers['psw'] = psw;
//   imageUploadRequest.files.add(file);
//   imageUploadRequest.fields.addAll(body);
//   try {
//     final streamedResponse = await imageUploadRequest.send();
//     final response = await Response.fromStream(streamedResponse);
//     if (response.statusCode != 200) {
//       return "";
//     }
//     final String responseData = response.body;
//     return responseData;
//   } catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Server bilan aloqa yo'q.")));
//     debugPrint(e.toString());
//     return "";
//   }
// }
