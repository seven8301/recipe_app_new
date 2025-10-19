import 'package:flutter/material.dart';
import 'package:recipe_app/common/models/user_model.dart';
import '../api/user_api.dart';
import '../common/values/server.dart';
import '../services/auth_service.dart';

import 'edit_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late UserInfo _user;
  bool _isLoading = false;
  List<String> foodPreferencesList = [];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      setState(() => _isLoading = true);
      final userInfo = await UserApi.aboutMe();
      logger.d('User info: $userInfo');
      if (userInfo != null) {
        setState(() => _user = userInfo);
        if (_user.foodPreferences != null && _user.foodPreferences.isNotEmpty) {
          foodPreferencesList = _user.foodPreferences
              .split(',')
              .map((item) => item.trim())
              .toList();
        }
      } else {
        logger.e('User info is null');
      }
    } catch (e) {
      logger.e('Failed to load user info: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF7B5EF0), Color(0xFF9B7DF7)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Profile',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF6F2FF),
                    borderRadius: BorderRadius.all(Radius.circular(28)),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        const CircleAvatar(
                          radius: 52,
                          backgroundColor: Color(0xFF7B5EF0),
                          child: Icon(
                            Icons.person,
                            size: 64,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _user.nickname.toString(),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _user.email.toString(),
                          style: const TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${_user.gender}${_user.birthday != "" ? ' · ${_user.birthday} yrs' : ''}',
                          style: const TextStyle(color: Colors.black45),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _StatItem(
                                value: _user.userRecipeCount.toString(),
                                label: 'Recipes Viewed',
                              ),
                              const _DividerV(),
                              _StatItem(
                                value: _user.userCollectRecipeCount.toString(),
                                label: 'Collections',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 8),
                                decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Food Preference",
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    FoodPreferenceList(
                                      preferences: foodPreferencesList,
                                      itemHeight: 24,
                                      itemPadding: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () async {
                              final updated = await Navigator.push<UserInfo>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EditProfilePage(profile: _user),
                                ),
                              );
                              if (updated != null) {
                                setState(() => _user = updated);
                                foodPreferencesList = _user.foodPreferences
                                    .split(',')
                                    .map(
                                      (item) => item.trim(),
                                    )
                                    .toList();
                              }
                            },
                            child: const Text('Edit Profile'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.tonal(
                            onPressed: () async {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Logout?'),
                                  content: const Text(
                                    'You will need to sign in again.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    FilledButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Logout'),
                                    ),
                                  ],
                                ),
                              );
                              if (ok == true) {
                                await AuthService().logout();
                                if (context.mounted) {
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                    '/login',
                                    (route) => false,
                                  );
                                }
                              }
                            },
                            child: const Text('Logout'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (label == 'Recipes Viewed') {
          Navigator.pushNamed(context, '/history', arguments: {'view-type': 1});
        } else if (label == 'Ingredients') {
          Navigator.pushNamed(context, '/history', arguments: {'view-type': 2});
        } else if (label == 'Collections') {
          Navigator.pushNamed(context, '/history', arguments: {'view-type': 3});
        }
      },
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}

class _DividerV extends StatelessWidget {
  const _DividerV();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 36, color: Colors.black12);
  }
}

class FoodPreferenceList extends StatelessWidget {
  final List<String> preferences;
  final double itemHeight;
  final double itemPadding;
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final double textSize;
  final double? itemWidth;

  const FoodPreferenceList({
    super.key,
    required this.preferences,
    this.itemHeight = 32,
    this.itemPadding = 32,
    this.backgroundColor = const Color(0xFFCFBEFF),
    this.textColor = const Color(0xFF6B4FE8),
    this.borderRadius = 16,
    this.textSize = 14,
    this.itemWidth,
  });

  @override
  Widget build(BuildContext context) {
    final displayList = preferences.isEmpty ? ["None"] : preferences;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: displayList
            .map(
              (pref) => Padding(
                padding: EdgeInsets.symmetric(horizontal: itemPadding),
                child: _buildPreferenceItem(pref),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildPreferenceItem(String preference) {
    return Container(
      width: itemWidth,
      height: itemHeight,
      padding: EdgeInsets.symmetric(horizontal: itemPadding / 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Text(
          preference.trim(),
          style: TextStyle(
            color: textColor,
            fontSize: textSize,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}