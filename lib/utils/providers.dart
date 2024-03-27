import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:les_social/view_models/auth/login_view_model.dart';
import 'package:les_social/view_models/auth/posts_view_model.dart';
import 'package:les_social/view_models/auth/register_view_model.dart';
import 'package:les_social/view_models/conversation/conversation_view_model.dart';
import 'package:les_social/view_models/profile/edit_profile_view_model.dart';
import 'package:les_social/view_models/status/status_view_model.dart';
import 'package:les_social/view_models/theme/theme_view_model.dart';
import 'package:les_social/view_models/user/user_view_model.dart';
import '../view_models/update_profile/update_profile_view_model.dart';

List<SingleChildWidget> providers = [
  ChangeNotifierProvider(create: (_) => RegisterViewModel()),
  ChangeNotifierProvider(create: (_) => LoginViewModel()),
  ChangeNotifierProvider(create: (_) => PostsViewModel()),
  ChangeNotifierProvider(create: (_) => EditProfileViewModel()),
  ChangeNotifierProvider(create: (_) => ConversationViewModel()),
  ChangeNotifierProvider(create: (_) => StatusViewModel()),
  ChangeNotifierProvider(create: (_) => UserViewModel()),
  ChangeNotifierProvider(create: (_) => ThemeProvider()),
  // ChangeNotifierProvider(create: (_) => UpdateProfileViewModel())
];