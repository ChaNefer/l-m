import 'package:flutter/src/widgets/framework.dart';
import 'package:les_social/services/user_service.dart';
import 'package:les_social/view_models/more_about/more_about_view_model.dart';
import 'package:les_social/view_models/user/user_provider.dart';
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
import '../services/api_service.dart';

List<SingleChildWidget> providers = [
  Provider<ApiService>(create: (_) => ApiService(_)),
  ChangeNotifierProvider(create: (_) => UserService(_)),
  ChangeNotifierProvider(create: (_) => RegisterViewModel()),
  ChangeNotifierProvider(create: (_) => LoginViewModel(Provider.of<ApiService>(_, listen: false))),
  ChangeNotifierProvider(create: (_) => PostsViewModel(_)),
  ChangeNotifierProvider(create: (_) => UserProvider(userService: UserService(_))),
  ChangeNotifierProvider(create: (_) => EditProfileViewModel(userService: UserService(_))),
  ChangeNotifierProvider(create: (_) => ConversationViewModel()),
  ChangeNotifierProvider(create: (_) => StatusViewModel(_)),
  ChangeNotifierProvider(create: (_) => UserViewModel()),
  ChangeNotifierProvider(create: (_) => ThemeProvider()),
  ChangeNotifierProvider(create: (_) => MoreAboutViewModel(_)),
  // ChangeNotifierProvider(create: (_) => UpdateProfileViewModel())
];
