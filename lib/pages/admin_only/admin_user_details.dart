import 'package:flutter/material.dart';
import 'package:marriage_app/config/config.dart';
import 'package:marriage_app/data_layer/delete_data.dart';
import 'package:marriage_app/functions/snack_bar_method.dart';
import 'package:marriage_app/models/user.dart';
import 'package:marriage_app/utils/enums.dart';
import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';

class UserDetails extends StatefulWidget {
  const UserDetails({super.key});

  @override
  State<UserDetails> createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  AdminActionOnUser? _userAction;
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final int index = args['index'] as int;
    final User user = args['user'] as User;
    final double avatarRadius = args['avatarRadius'] as double;
    final String avatarText = args['avatarText'] as String;
    final int adminId = args['adminId'] as int;
    final double screenHeight = MediaQuery.of(context).size.height;

    final ColorScheme appColorScheme = Theme.of(context).colorScheme;
    final TextTheme appTextTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton<AdminActionOnUser>(
            initialValue: _userAction,
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              switch (value) {
                case AdminActionOnUser.edit:
                  Navigator.pushNamed(context, '/admin/add_user', arguments: {
                    'user': user,
                    'submitAction': 'update',
                  });
                  break;
                case AdminActionOnUser.delete:
                  Map<String, dynamic> deleteData = await DeleteData(
                    adminId: adminId,
                    userId: user.id,
                  ).deleteData(relativePath: 'delete');

                  bool hasError = deleteData['status'] != 200;
                  // ignore: use_build_context_synchronously
                  snackBarMethod(
                    context: context,
                    message: deleteData['message']!,
                    hasError: hasError,
                  );
                  if (!context.mounted) return;
                  Navigator.pop(context, [!hasError, index]);
                  break;
              }
            },
            itemBuilder: (itemContext) {
              return [
                const PopupMenuItem(
                  value: AdminActionOnUser.edit,
                  child: Text('Edit the user'),
                ),
                const PopupMenuItem(
                  value: AdminActionOnUser.delete,
                  child: Text('Delete the user'),
                ),
              ];
            },
          )
        ],
        backgroundColor: Configuration.primaryAppColor,
        toolbarHeight: screenHeight * 0.075,
      ),
      body: Column(
        children: [
          _buildHero(avatarRadius, avatarText, appTextTheme, user,
              appColorScheme, index),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: screenHeight * 0.6,
                child: _buildUserDetails([
                  {'key': 'User name', 'value': user.username},
                  {'key': 'Actual name', 'value': user.actualName},
                  {'key': 'Phone number', 'value': user.telephone},
                ], appColorScheme, appTextTheme),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Center _buildHero(
      double avatarRadius,
      String avatarText,
      TextTheme appTextTheme,
      User user,
      ColorScheme appColorScheme,
      int index) {
    return Center(
      child: Container(
        color: Configuration.primaryAppColor,
        width: double.infinity,
        child: Column(
          children: [
            Hero(
              tag: "${user.username}$index",
              child: CircleAvatar(
                radius: avatarRadius * 2,
                child: Text(avatarText, style: appTextTheme.titleLarge),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              user.username,
              style: TextStyle(
                color: appColorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: appTextTheme.titleLarge!.fontSize! * 1.15,
              ),
            ),
            const Padding(padding: EdgeInsets.only(top: 16.0))
          ],
        ),
      ),
    );
  }

  Widget _buildUserDetails(List<Map<String, String>> data,
      ColorScheme appColorScheme, TextTheme appTextTheme) {
    const double padding = 8.0;
    return Column(children: [
      Center(
        child: Text(
          'User details',
          style: TextStyle(
            fontSize: appTextTheme.titleLarge!.fontSize,
            fontWeight: FontWeight.bold,
            color: appColorScheme.onPrimaryContainer,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: padding),
        child: Divider(
          color: appColorScheme.outline,
        ),
      ),
      const SizedBox(height: 10),
      for (int i = 0; i < data.length; i++)
        Padding(
          padding: const EdgeInsets.only(left: padding),
          child: Row(
            children: [
              Text(
                '${data[i]['key']}: ',
                style: TextStyle(
                  color: appColorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                  fontSize: appTextTheme.bodyLarge!.fontSize! * 1.2,
                ),
              ),
              if (i < data.length - 1)
                Expanded(
                  child: SelectableText(
                    data[i]['value']!,
                    style: TextStyle(
                      color: appColorScheme.onPrimaryContainer,
                      fontSize: appTextTheme.bodyMedium!.fontSize! * 1.25,
                      fontWeight: FontWeight.w500,
                    ),
                    // overflow: TextOverflow.ellipsis,
                    // softWrap: false,
                    // maxLines: 2,
                  ),
                )
              else
                GestureDetector(
                  onTap: () async {
                    final Uri url = Uri(scheme: 'tel', path: data[i]['value']!);
                    if (await canLaunchUrl(url)) {
                      launchUrl(url);
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                  child: Link(
                    uri: Uri(scheme: 'tel', path: data[i]['value']!),
                    builder: (context, followLink) {
                      return SelectableText(
                        data[i]['value']!,
                        style: TextStyle(
                          color: appColorScheme.secondary,
                          decoration: TextDecoration.underline,
                          decorationColor: appColorScheme.secondary,
                          decorationThickness: 2,
                          fontSize: appTextTheme.bodyMedium!.fontSize! * 1.25,
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
    ]);
  }
}
