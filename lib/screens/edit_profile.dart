import 'package:flutter/material.dart';
import 'package:recipe_app/api/user_api.dart';
import 'package:recipe_app/common/models/user_model.dart';

class EditProfilePage extends StatefulWidget {
  final UserInfo profile;

  const EditProfilePage({Key? key, required this.profile}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _ageCtrl;
  String _gender = 'Prefer not to say';


  final TextEditingController _currentPwCtrl = TextEditingController();
  final TextEditingController _newPwCtrl = TextEditingController();
  final TextEditingController _confirmPwCtrl = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _saving = false;

  final List<String> _genders = [
    'Female',
    'Male',
    'Other',
    'Prefer not to say',
  ];

  final List<String> _foodPreferences = [
    'Gluten-free',
    'Nut-free',
    'Dairy-free',
    'Vegan',
    'No pork',
    'No beef',
    'No Shrimp'
  ];
  List<String> selectedFoodPreferences = [];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.profile.nickname);
    _emailCtrl = TextEditingController(text: widget.profile.email);
    _gender = widget.profile.gender.isNotEmpty
        ? widget.profile.gender
        : 'Prefer not to say';
    _ageCtrl = TextEditingController(text: widget.profile.birthday ?? '');
    selectedFoodPreferences = widget.profile.foodPreferences
        .split(',')
        .map((item) => item.trim())
        .toList();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _ageCtrl.dispose();
    _currentPwCtrl.dispose();
    _newPwCtrl.dispose();
    _confirmPwCtrl.dispose();
    super.dispose();
  }

  String? _validateAge(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final n = int.tryParse(v.trim());
    if (n == null) return 'Please enter a valid number';
    if (n < 0 || n > 150) return 'Please enter a reasonable age';
    return null;
  }

  String? _validatePasswordFields() {
    final cur = _currentPwCtrl.text;
    final n = _newPwCtrl.text;
    final c = _confirmPwCtrl.text;


    if (cur.isEmpty && n.isEmpty && c.isEmpty) return null;


    if (cur.isEmpty) return 'Please enter your current password to change it';
    if (n.isEmpty) return 'Please enter a new password';
    if (n.length < 6) return 'New password must be at least 6 characters';
    if (n != c) return 'New passwords do not match';
    return null;
  }

  Future<void> _onSave() async {
    if (selectedFoodPreferences.isEmpty){
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Error"),
          content: Text('Please select at least one food preference'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK"),
            ),
          ],
        ),
      );
      return;
    }
    widget.profile.nickname = _nameCtrl.text.trim();
    widget.profile.gender = _gender;
    widget.profile.birthday = _ageCtrl.text.trim();
    widget.profile.email = _emailCtrl.text.trim();
    widget.profile.foodPreferences = selectedFoodPreferences.join(',');
    final res = await UserApi.updateProfile(widget.profile);
    if (!res!) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile update failed'),
          duration: const Duration(seconds: 1),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Profile has been saved'),
        duration: const Duration(seconds: 2),
      ),
    );
    setState(() => _saving = false);

    Navigator.of(context).pop(widget.profile);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final purple = const Color(0xFF7C4DFF);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: purple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;
          final horizontalPadding = isWide ? constraints.maxWidth * 0.2 : 20.0;
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 20,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 52,
                    backgroundColor: Color(0xFF7B5EF0),
                    child: Icon(Icons.person, size: 64, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.profile.nickname,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(widget.profile.email, style: theme.textTheme.bodySmall),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFFE4DBFF),
                                spreadRadius: 0,
                                blurRadius: 3,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _nameCtrl,
                            decoration: InputDecoration(
                              labelText: 'Name',
                              hintText: 'Enter your name',
                              fillColor: Colors.white,
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty)
                                return 'Name cannot be empty';
                              if (v.trim().length < 2)
                                return 'Name is too short';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFFE4DBFF),
                                spreadRadius: 0,
                                blurRadius: 3,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _emailCtrl,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: 'Enter your name',
                              fillColor: Colors.white,
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFFE4DBFF),
                                      spreadRadius: 0,
                                      blurRadius: 3,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: DropdownButtonFormField<String>(
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
                                  decoration: InputDecoration(
                                    labelText: 'Gender',
                                    hintText: 'Enter your name',
                                    fillColor: Colors.white,
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFFE4DBFF),
                                      spreadRadius: 0,
                                      blurRadius: 3,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: TextFormField(
                                  controller: _ageCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Age',
                                    hintText: 'Enter your age',
                                    fillColor: Colors.white,
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  validator: _validateAge,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFE4DBFF),
                                spreadRadius: 0,
                                blurRadius: 3,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Food Preferences',
                                  style: TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _foodPreferences.map((preference) {

                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (selectedFoodPreferences.contains(
                                            preference,
                                          )) {
                                            selectedFoodPreferences.remove(
                                              preference,
                                            );
                                          } else {
                                            selectedFoodPreferences.add(
                                              preference,
                                            );
                                          }
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              selectedFoodPreferences.contains(
                                                preference,
                                              )
                                              ? const Color(
                                                  0xFFA489FF,
                                                )
                                              : const Color(0xFFF3F4F6),

                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              selectedFoodPreferences.contains(
                                                    preference,
                                                  )
                                                  ? Icons.check_circle
                                                  : Icons.circle_outlined,
                                              size: 16,
                                              color:
                                                  selectedFoodPreferences
                                                      .contains(preference)
                                                  ? Colors.white
                                                  : const Color(0xFF6B7280),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              preference,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color:
                                                    selectedFoodPreferences
                                                        .contains(preference)
                                                    ? Colors.white
                                                    : const Color(0xFF1F2937),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _saving ? null : _onSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(
                              0xFFA489FF,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            minimumSize: const Size(double.infinity - 32, 0),
                          ),
                          child: _saving
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Save',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                        // const SizedBox(height: 12),
                        // OutlinedButton(
                        //   onPressed: _saving
                        //       ? null
                        //       : () => Navigator.of(context).pop(),
                        //   style: OutlinedButton.styleFrom(
                        //     padding: const EdgeInsets.symmetric(
                        //       vertical: 14,
                        //     ),
                        //     shape: RoundedRectangleBorder(
                        //       borderRadius: BorderRadius.circular(30),
                        //     ),
                        //   ),
                        //   child: const Text('Cancel'),
                        // )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}