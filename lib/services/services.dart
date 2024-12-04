import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:les_social/utils/file_utils.dart';

abstract class Service {
  Uuid uuid = Uuid();

  // Funkcja do przesyłania obrazów i pobierania URL
  Future<String> uploadImage(String endpoint, File file) async {
    String ext = FileUtils.getFileExtension(file);
    String fileName = "${uuid.v4()}.$ext";

    var request = http.MultipartRequest('POST', Uri.parse("https://lesmind.com/api/photos/upload_profile_pic.php"));     // eksperymntalnie!!!
    request.files.add(await http.MultipartFile.fromPath('file', file.path, filename: fileName));

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      String fileUrl = responseData['fileUrl']; // Przykładowo, odczytaj URL z odpowiedzi
      return fileUrl;
    } else {
      //print("Błąd: ${response.reasonPhrase}");
      throw Exception('Failed to upload image: ${response.reasonPhrase}');
    }
  }
}
