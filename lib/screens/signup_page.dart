import 'package:flutter/material.dart';
import 'package:recipe_app/api/user_api.dart';
import '../common/models/user_model.dart';
import '../common/values/server.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _nickname = TextEditingController();
  final _email = TextEditingController();
  final _pwd = TextEditingController();
  final _confirmPwd = TextEditingController();
  String _gender = 'Female';
  final List<String> _genders = [
    'Female',
    'Male',
    'Other',
    'Prefer not to say',
  ];
  final Set<String> _selectedPreferences = {};
  final List<String> _foodPreferences = [
    'Gluten-free',
    'Nut-free',
    'Dairy-free',
    'Vegan',
    'No pork',
    'No beef',
    'No Shrimp'
  ];
  bool _obscurePwd = true, _obscureConfirmPwd = true, _loading = false;
  String? _error;
  DateTime _birthday = DateTime.now().subtract(const Duration(days: 365 * 18));

  @override
  void dispose() {
    _username.dispose();
    _nickname.dispose();
    _email.dispose();
    _pwd.dispose();
    _confirmPwd.dispose();
    super.dispose();
  }

  List<Widget> _buildFoodPreferenceCheckboxes() {
    return _foodPreferences.map((preference) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          Transform.translate(
            offset: const Offset(-4, 0),
            child: Checkbox(
              value: _selectedPreferences.contains(preference),
              onChanged: _loading
                  ? null
                  : (isChecked) {
                      setState(() {
                        if (isChecked == true) {
                          _selectedPreferences.add(preference);
                        } else {
                          _selectedPreferences.remove(preference);
                        }
                      });
                    },
              materialTapTargetSize:
                  MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 120),
            child: Text(
              preference,

              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      );
    }).toList();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthday,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _birthday) {
      setState(() {
        _birthday = picked;
      });
    }
  }

  Future<void> _doSignUp() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_pwd.text != _confirmPwd.text) {
      setState(() => _error = 'Passwords do not match');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      logger.d('signUp: ${_gender}');
      logger.d('signUp: ${_birthday.toIso8601String().split('T')[0]}');
      final userInfo = SignUpUserInfo(
        username: _username.text.trim(),
        nickname: _nickname.text.trim(),
        email: _email.text.trim(),
        password: _pwd.text,
        gender: _gender,
        birthday: _birthday.toIso8601String().split('T')[0],

        foodPreferences: _selectedPreferences.toList(),
      );
      final res = await UserApi.signUp(userInfo);
      if (res != "") {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Error"),
            content: Text('$res'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
        );
        return;
      }
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          title: Text('Sign Up Success'),
          content: Text('Your account has been created successfully!'),
        ),
      );

      Future.delayed(const Duration(seconds: 1), () {
        Navigator.of(context).pop();
        Navigator.of(context).pushReplacementNamed('/login');
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF7B5EF0), Color(0xFF9B7DF7)],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),

                const Text(
                  'Create Account',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.person_add, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // const FlutterLogo(size: 72),
                          const SizedBox(height: 12),
                          // Text(
                          //   'Sign Up',
                          //   style: Theme.of(context).textTheme.headlineMedium,
                          // ),
                          // const SizedBox(height: 24),
                          if (_error != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                _error!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),


                          TextFormField(
                            controller: _username,
                            decoration: const InputDecoration(
                              labelText: 'Username',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Please enter username'
                                : null,
                          ),
                          const SizedBox(height: 12),


                          TextFormField(
                            controller: _nickname,
                            decoration: const InputDecoration(
                              labelText: 'Nickname',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.badge),
                            ),
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Please enter nickname'
                                : null,
                          ),
                          const SizedBox(height: 12),


                          TextFormField(
                            controller: _email,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.mail),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) => (v == null || !v.contains('@'))
                                ? 'Enter a valid email'
                                : null,
                          ),
                          const SizedBox(height: 12),

                          DropdownButtonFormField<String>(
                            value: _gender,
                            items: _genders
                                .map(
                                  (g) => DropdownMenuItem(
                                    value: g,
                                    child: Text(g),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) {
                              if (v == null) return;
                              setState(() => _gender = v);
                            },
                            decoration: const InputDecoration(
                              labelText: 'Gender',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.transgender),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => _selectDate(context),
                              style: OutlinedButton.styleFrom(
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(2),
                                  side: BorderSide(color: Colors.black87, width: 1),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Birthday',
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        '${_birthday.year}-${_birthday.month.toString().padLeft(2, '0')}-${_birthday.day.toString().padLeft(2, '0')}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                  const Icon(Icons.calendar_today, size: 20),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black87,
                                width: 1,
                              ),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(4),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Food Preference',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  alignment: WrapAlignment.start,
                                  crossAxisAlignment: WrapCrossAlignment.start,
                                  spacing: 12,
                                  runSpacing: 8,
                                  children: _buildFoodPreferenceCheckboxes(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _pwd,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePwd
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () =>
                                    setState(() => _obscurePwd = !_obscurePwd),
                              ),
                            ),
                            obscureText: _obscurePwd,
                            validator: (v) => (v == null || v.length < 6)
                                ? 'Min 6 characters'
                                : null,
                          ),
                          const SizedBox(height: 12),


                          TextFormField(
                            controller: _confirmPwd,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPwd
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () => setState(
                                  () =>
                                      _obscureConfirmPwd = !_obscureConfirmPwd,
                                ),
                              ),
                            ),
                            obscureText: _obscureConfirmPwd,
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Please confirm password'
                                : null,
                          ),
                          const SizedBox(height: 16),


                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: _loading ? null : _doSignUp,
                              child: _loading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Sign Up'),
                            ),
                          ),


                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text(
                              'Already have an account? Sign in',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}