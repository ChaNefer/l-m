import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:les_social/models/status.dart';
import 'package:les_social/services/api_service.dart';
import 'package:les_social/view_models/status/status_view_model.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../services/auth_service.dart';

class ConfirmStatus extends StatefulWidget {
  @override
  State<ConfirmStatus> createState() => _ConfirmStatusState();
}

class _ConfirmStatusState extends State<ConfirmStatus> {
  late ApiService apiService;
  late AuthService _authService = AuthService();

  currentUserId() {
    return _authService.getCurrentUser;
  }
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    StatusViewModel viewModel = Provider.of<StatusViewModel>(context);
    return Scaffold(
      body: Center(
        child: AspectRatio(
          aspectRatio: 9 / 16,
          child: Image.file(viewModel.mediaUrl!),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 10.0,
        child: Container(
          constraints: BoxConstraints(maxHeight: 100.0),
          child: Flexible(
            child: TextFormField(
              style: TextStyle(
                fontSize: 15.0,
                color: Theme.of(context).textTheme.bodyLarge!.color,
              ),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(10.0),
                enabledBorder: InputBorder.none,
                border: InputBorder.none,
                hintText: "Wpisz podpis",
                hintStyle: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
              onSaved: (val) {
                viewModel.setDescription(val!);
              },
              onChanged: (val) {
                viewModel.setDescription(val);
              },
              maxLines: null,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(
          Icons.done,
          color: Colors.white,
        ),
        onPressed: () async {
          setState(() {
            loading = true;
          });

          try {
            // Upload media to backend (assuming it returns the uploaded content URL)
            String mediaUrl = await uploadMediaToBackend(viewModel.mediaUrl!);

            // Create StatusModel object
            StatusModel message = StatusModel(
              url: mediaUrl,
              caption: viewModel.description,
              time: DateTime.now(),
              statusId: Uuid().v1(),
              viewers: [],
            );

            // Call sendStatus with appropriate parameters
            viewModel.sendStatus('your_chat_id', message); // Replace 'your_chat_id' with actual chat ID

            setState(() {
              loading = false;
            });

            Navigator.pop(context);
          } catch (e) {
            setState(() {
              loading = false;
            });
            //print('Error sending status: $e');
            // Handle errors here
          }
        },
      ),
    );
  }

  Future<String> uploadMediaToBackend(File image) async {
    // Implement logic to upload image to your backend
    // Return URL of the uploaded content
    // Example:
    String mediaUrl = 'https://your-backend.com/upload/image';
    return mediaUrl;
  }
}
