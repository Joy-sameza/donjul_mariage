import 'package:flutter/material.dart';
import 'package:marriage_app/config/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum HeaderActions { logout }

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  late int usersTotal = 0;

  Future<void> getUsersTotal() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    usersTotal = preferences.getInt('user_count') ?? 0;
    setState(() {
      usersTotal = usersTotal;
    });
  }

  @override
  void initState() {
    super.initState();
    getUsersTotal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton(
            onSelected: (value) async {
              if (value == HeaderActions.logout) {
                SharedPreferences preferences =
                    await SharedPreferences.getInstance();
                await preferences.clear();
                // ignore: use_build_context_synchronously
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<HeaderActions>(
                  value: HeaderActions.logout,
                  child: Text(
                    'Logout',
                    style: TextStyle(
                      fontWeight:
                          Theme.of(context).textTheme.titleMedium?.fontWeight,
                    ),
                  ),
                ),
              ];
            },
          )
        ],
        backgroundColor: Configuration.primaryAppColor,
        title: Text(
          'Donjul Marriage',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onBackground,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 48),
        child: Column(
          children: _superButtonList(context, [
            [
              {
                'icon': Icons.person_add_alt,
                'buttonText': 'Add user',
                'buttonSubData': '',
                'routeName': '/admin/add_user',
              },
              {
                'icon': Icons.list_alt,
                'buttonText': 'User list',
                'buttonSubData': '$usersTotal user${usersTotal > 1 ? 's' : ''}',
                'routeName': '/admin/user_list',
              }
            ],
            [
              {
                'icon': Icons.person_add,
                'buttonText': 'Add guest',
                'buttonSubData': '',
                'routeName': '/admin/add_guest',
              },
              {
                'icon': Icons.list,
                'buttonText': 'Guest list',
                'buttonSubData': '0 guest',
                'routeName': '/admin/guest_list',
              }
            ],
          ]),
        ),
      ),
    );
  }

  List<Widget> _superButtonList(
      BuildContext context, List<List<Map<String, dynamic>>> rowsData) {
    List<Widget> out = [
      Text(
        'Actions',
        style: TextStyle(
          fontSize: Theme.of(context).textTheme.titleLarge!.fontSize! * 1.25,
          height: Theme.of(context).textTheme.titleLarge!.height! * 1.25,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onBackground,
        ),
      ),
      const Divider(),
    ];
    for (var i = 0; i < rowsData.length; i++) {
      out.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ..._buildExpandedButtons(context, rowsData[i]),
        ],
      ));
      if (i < rowsData.length - 1) {
        out.add(SizedBox(height: MediaQuery.of(context).size.height * 0.02));
      }
    }
    return out;
  }

  List _buildExpandedButtons(
      BuildContext context, List<Map<String, dynamic>> data) {
    List<Widget> out = [];
    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width - (16 * 2);

    for (int i = 0; i < data.length; i++) {
      final icon = data[i]['icon'];
      final String buttonText = data[i]['buttonText'];
      final String? buttonSubData = data[i]['buttonSubData'];
      final String routeName = data[i]['routeName'];
      out.add(Expanded(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, routeName);
          },
          style: ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(
                Theme.of(context).colorScheme.primaryContainer),
            elevation: const MaterialStatePropertyAll(0),
            shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15))),
          ),
          child: Padding(
            padding: (buttonSubData!.isEmpty)
                ? const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4)
                : const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(icon),
                (buttonSubData.isNotEmpty)
                    ? Column(
                        children: [
                          Text(
                            buttonText,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(),
                          Text(
                            buttonSubData,
                            style: TextStyle(
                                fontSize: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .fontSize! *
                                    0.8),
                          ),
                        ],
                      )
                    : Text(
                        buttonText,
                        style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
              ],
            ),
          ),
        ),
      ));
      if (i < data.length - 1) {
        out.add(SizedBox(width: width * 0.05));
      }
    }
    return out;
  }
}
