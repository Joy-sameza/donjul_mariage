import 'dart:async';
import 'package:flutter/material.dart';
import 'package:marriage_app/config/config.dart';
import 'package:marriage_app/functional_classes/get_data.dart';
import 'package:marriage_app/models/user.dart';
import 'package:marriage_app/widgets/custom_error.dart';
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
  final _scrollController = ScrollController();
  bool _errorLoading = false;
  bool _isListEmpty = false;
  bool _isLoading = false;
  bool _timeoutLoading = false;
  bool _hasMore = true;
  int? currentPage;

  _scrollControllerListener() {
    double triggerPoint = _scrollController.position.maxScrollExtent - 40.0;
    if (_scrollController.position.pixels >= triggerPoint &&
        _hasMore &&
        !_isLoading) {
      _loadUsers();
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollControllerListener);
    _loadUsers();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Configuration.primaryAppColor,
        title: Text(
          'User List',
          style: Theme.of(context).textTheme.displaySmall,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 8, right: 8, top: 16),
        child: _timeoutLoading
            ? CustomError(
                errorMessage: 'Check your internet connection',
                exception: TimeoutException('Timeout loading data'),
                onRetry: _retryLoading,
              )
            : _buildUserList(screenWidth),
      ),
    );
  }

  Widget _buildUserList(double screenWidth) {
    if (_errorLoading) {
      return ListError(retry: _retryLoading);
    }
    if (_isListEmpty) {
      return const LoadingEmpty(message: 'No user found');
    }
    return RefreshIndicator(
      displacement: 50,
      onRefresh: _retryLoading,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _isLoading ? 15 : _userList.length + 1,
        itemBuilder: (context, index) {
          if (_isLoading && index >= _userList.length) {
            return _buildUserShimmer(context, index);
          }
          if (index == _userList.length && _hasMore && !_isLoading) {
            return _buildUserShimmer(context, index);
          }
          if (index == _userList.length && !_hasMore && !_isLoading) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Center(
                child: Text(
                  'No more users',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onBackground
                            .withOpacity(0.7),
                      ),
                ),
              ),
            );
          }
          return _buildUser(context, index, screenWidth);
        },
      ),
    );
  }

  Future<void> _retryLoading() {
    _userList.clear();
    _errorLoading = false;
    _isListEmpty = false;
    _isLoading = false;
    _timeoutLoading = false;
    _hasMore = true;
    currentPage = 0;
    return _loadUsers();
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
          ),
        ),
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

    return Column(
      children: [
        ListTile(
          onTap: () {
            Navigator.pushNamed(context, '/admin/user_details', arguments: {
              'index': index,
              'avatarRadius': avatarRadius,
              'avatarText': avatarText,
              'user': user,
            });
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          onLongPress: () {
            // Navigator.pushNamed(context, '/admin/user_edit', arguments: {
            //
            // });
          },
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
    );
  }

  Future<void> _loadUsers() async {
    if (_isLoading) {
      return;
    }
    setState(() => _isLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? adminId = prefs.getInt('admin_id');
    GetData getData = GetData();
    await getData.loadUsersORGuest(
      adminId: adminId ?? 0,
      isGuest: false,
      page: (currentPage ?? 0) + 1,
    );
    if (getData.status != 200 && getData.status != 408) {
      setState(() => _isLoading = false);
      setState(() => _errorLoading = true);
      return;
    }
    if (getData.status == 408) {
      setState(() => _isLoading = false);
      setState(() => _timeoutLoading = true);
      return;
    }
    var x = getData.data as Map<String, dynamic>;
    var requestPage = x['page'] as int;
    var perPage = x['per_page'] as int;
    var totalItems = x['total_items'] as int;
    if (totalItems == 0) {
      setState(() {
        _isLoading = false;
        _isListEmpty = true;
      });
    }
    var temp = x['users'] as List;
    if (perPage * requestPage >= totalItems) {
      setState(() {
        _isLoading = false;
        _hasMore = false;
      });
    }
    currentPage = requestPage;
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
    prefs.setInt('user_count', x['total_items']);
    setState(() => _isLoading = false);
  }
}
