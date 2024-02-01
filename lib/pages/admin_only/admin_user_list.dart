import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:marriage_app/config/config.dart';
import 'package:marriage_app/functional_classes/get_data.dart';
import 'package:marriage_app/functional_classes/user.dart';
import 'package:marriage_app/widgets/list_empty.dart';
import 'package:marriage_app/widgets/list_loading_err.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class UserList extends StatefulWidget {
  const UserList({super.key});

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  late final List<User> _userList = [];
  bool _errorLoading = false;
  bool _isListEmpty = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    return Scaffold(
      appBar: AppBar(
        title:
            Text('User List', style: Theme.of(context).textTheme.displayMedium),
        backgroundColor: Configuration.primaryAppColor,
        centerTitle: true,
        toolbarHeight: screenHeight * 0.15,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 8, right: 8, top: 16, bottom: 0),
        child: ListView.builder(
          itemCount: _isLoading ? 15 : _userList.length,
          itemBuilder: (context, index) => _isLoading
              ? _buildUserShimmer(context, index)
              : _errorLoading
                  ? const ListError()
                  : _isListEmpty
                      ? const LoadingEmpty()
                      : _buildUser(context, index, screenWidth),
        ),
      ),
    );
  }

  Widget _buildUserShimmer(BuildContext context, int index) {
    final shimmerBaseColor = Configuration.mainGrey.withOpacity(0.6);
    final shimmerHighlightColor = Configuration.mainGrey.withOpacity(0.4);

    return ListTile(
      leading: Shimmer.fromColors(
        baseColor: shimmerBaseColor,
        highlightColor: shimmerHighlightColor,
        period: const Duration(milliseconds: 1000),
        child: const CircleAvatar(),
      ),
      title: Shimmer.fromColors(
        baseColor: shimmerBaseColor,
        highlightColor: shimmerHighlightColor,
        child: Container(
            decoration: const BoxDecoration(
              color: Configuration.primaryAppColor,
            ),
            child: const SizedBox(
              width: double.infinity,
              height: 20,
            )),
      ),
    );
  }

  Widget _buildUser(BuildContext context, int index, double screenWidth) {
    final double avatarRadius = screenWidth * 0.06;
    final double dividerIndent = screenWidth * 0.175;
    final User user = _userList[index];
    final String userName = user.actualName;
    final nameList = userName.split(' ');
    String avatarText = '';
    for (String name in nameList) {
      avatarText += name[0];
      if (avatarText.length == 2) {
        break;
      }
    }
    avatarText = avatarText.toUpperCase();

    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, '/admin/user_details', arguments: {
          'index': index,
          'avatarRadius': avatarRadius,
          'avatarText': avatarText,
          'user': user,
        });
      },
      style: const ButtonStyle(
        backgroundColor: MaterialStatePropertyAll(Colors.transparent),
        elevation: MaterialStatePropertyAll(0),
        padding: MaterialStatePropertyAll(
          EdgeInsets.all(0),
        ),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Hero(
              tag: "${user.username}$index",
              child: CircleAvatar(
                radius: avatarRadius,
                child: Text(avatarText),
              ),
            ),
            title: Text(userName,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          if (index < _userList.length - 1)
            Divider(
              thickness: 1,
              // color: Colors.black,
              indent: dividerIndent,
              height: 2,
            ),
        ],
      ),
    );
  }

  void _loadUsers() async {
    setState(() => _isLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? adminId = prefs.getInt('admin_id');
    GetData getData = GetData();
    await getData.loadUsers(adminId: adminId ?? 0);
    // Future.delayed(const Duration(milliseconds: 1500));
    if (getData.status != 200) {
      setState(() => _isLoading = false);
      setState(() => _errorLoading = true);
      return;
    }
    var temp = getData.data as List;
    if (kDebugMode) {
      print(temp);
    }
    if (temp.isEmpty) {
      setState(() => _isLoading = false);
      setState(() => _isListEmpty = true);
      return;
    }
    temp.sort((a, b) => a['actual_name']
        .toString()
        .toLowerCase()
        .compareTo(b['actual_name'].toString().toLowerCase()));
    for (Map<String, dynamic> user in temp) {
      _userList.add(User.fromJson(user));
    }
    prefs.setInt('user_count', _userList.length);
    setState(() => _isLoading = false);
  }
}
