import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:marriage_app/config/config.dart';
import 'package:marriage_app/data_layer/get_data.dart';
import 'package:marriage_app/models/user.dart';
import 'package:marriage_app/widgets/custom_error.dart';
import 'package:marriage_app/widgets/list_empty.dart';
import 'package:marriage_app/widgets/list_loading_err.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:very_good_infinite_list/very_good_infinite_list.dart';

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
  int? currentPage, _adminId;
  bool _socketException = false;

  _scrollControllerListener() {
    double triggerPoint = _scrollController.position.maxScrollExtent - 200.0;
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
  void reassemble() {
    ScrollPosition currentPos = _scrollController.position;
    super.reassemble();
    _scrollController.animateTo(
      currentPos.pixels,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    // final double screenHeight = screenSize.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Configuration.primaryAppColor,
        title: Text(
          'User List',
          style: Theme.of(context).textTheme.displaySmall,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
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
    if (_socketException) {
      return ListError(
        retry: _retryLoading,
        exception: const SocketException('No internet connection'),
      );
    }
    return RefreshIndicator(
      displacement: 50,
      onRefresh: _retryLoading,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _isLoading ? 15 : _userList.length + 1,
        itemBuilder: (context, index) {
          if (_isLoading && index >= _userList.length) {
            return _buildUserShimmer(context);
          }
          if (index == _userList.length && _hasMore && !_isLoading) {
            return _buildUserShimmer(context);
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

  Widget _buildUserShimmer(BuildContext context) {
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

  Widget _buildUser(BuildContext context, int indexInList, double screenWidth) {
    final double avatarRadius = screenWidth * 0.06;
    final double dividerIndent = screenWidth * 0.175;
    final User user = _userList[indexInList];
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
          onTap: () async {
            var result = await Navigator.pushNamed(
                context, '/admin/user_details',
                arguments: {
                  'index': indexInList,
                  'avatarRadius': avatarRadius,
                  'avatarText': avatarText,
                  'user': user,
                  'adminId': _adminId
                });

            var [isSuccess, indx] = result as List;
            if (isSuccess) {
              setState(() {
                _userList.removeAt(indx);
              });
            }
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          leading: Hero(
            tag: "${user.username}$indexInList",
            child: CircleAvatar(
              radius: avatarRadius,
              child: Text(avatarText),
            ),
          ),
          title: Text(userName,
              style: const TextStyle(fontWeight: FontWeight.w500)),
        ),
        if (indexInList < _userList.length - 1)
          Divider(
            thickness: 1,
            // color: Colors.black,
            indent: dividerIndent,
            height: 2,
          ),
      ],
    );
  }

  getAdminId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? adminId = prefs.getInt('admin_id');
    _adminId = adminId ?? 0;
  }

  Future<void> _loadUsers() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? adminId = prefs.getInt('admin_id');
    _adminId = adminId ?? 0;
    GetData getData = GetData();
    await getData.loadUsersORGuest(
      adminId: _adminId ?? 0,
      isGuest: false,
      page: (currentPage ?? 0) + 1,
    );
    if (getData.status == 503) {
      setState(() {
        _isLoading = false;
        _socketException = true;
      });
      return;
    }
    if (getData.status != 200 &&
        getData.status != 408 &&
        getData.status != 503) {
      setState(() => _isLoading = false);
      setState(() => _errorLoading = true);
      return;
    }
    if (getData.status == 408) {
      setState(() {
        _isLoading = false;
        _timeoutLoading = true;
      });
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
        _hasMore = false;
      });
      return;
    }
    var temp = x['users'] as List;
    if (perPage * requestPage >= totalItems) {
      setState(() {
        _isLoading = false;
        _hasMore = false;
      });
    }
    currentPage = requestPage;

    final List<User> tempUserList = <User>[];
    for (Map<String, dynamic> user in temp) {
      tempUserList.add(User.fromJson(user));
    }
    prefs.setInt('user_count', x['total_items']);
    setState(() {
      _userList.addAll(tempUserList);
      _isLoading = false;
    });
  }

  Widget listContent() {
    return InfiniteList(
      itemCount: _userList.length,
      itemBuilder: (BuildContext context, int index) {
        return _buildUser(context, index, MediaQuery.of(context).size.width);
      },
      onFetchData: _loadUsers,
      loadingBuilder: _buildUserShimmer,
      hasReachedMax: !_hasMore,
      separatorBuilder: (context, index) {
        return const Divider();
      },
      isLoading: _isLoading,
      hasError: _errorLoading,
      scrollController: _scrollController,
    );
  }
}
