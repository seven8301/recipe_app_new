import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/home_background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                // color: Color(0xFFF3F0FF),
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(48),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 48),
                  const Text(
                    'THE\nPANTRY',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF7B5EF0),
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                  IconButton(
                    iconSize: 32,
                    icon: const Icon(Icons.menu,  color: Color(0xFF7B5EF0)),
                    onPressed: () {
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildMenuButton(
                        context,
                        'INGREDIENTS',
                        Icons.restaurant_menu,
                        '/ingredients',
                      ),
                      const Spacer(flex: 1),
                      _buildMenuButton(
                        context,
                        'SNAP UR FOOD',
                        Icons.camera_alt,
                        '/snap-food',
                      ),
                      const Spacer(flex: 1),
                      _buildMenuButton(
                        context,
                        'RECOMMENDED',
                        Icons.book,
                        '/recipe-book',
                      ),
                      const Spacer(flex: 1),
                      _buildMenuButton(
                        context,
                        'PROFILE',
                        Icons.person,
                        '/profile',
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    String title,
    IconData icon,
    String route,
  ) {
    return Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        color: Color(0xFFF3F0FF),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () => Navigator.pushNamed(context, route),
          child: Row(
            children: [
              const SizedBox(width: 20),
              Container(
                padding: const EdgeInsets.all(8),
                child: Icon(icon, color:const Color(0xFF7B5EF0), size: 48),
              ),
              // const SizedBox(width: 30),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF7B5EF0),
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}