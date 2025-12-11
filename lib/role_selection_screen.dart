import 'package:flutter/material.dart';
import 'package:flutter_application_1cuadermo/login_screen.dart';
import 'package:flutter_application_1cuadermo/models/user_type.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Rol'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildRoleButton(
              context,
              label: 'Profesor',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(userType: UserType.teacher),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildRoleButton(
              context,
              label: 'Estudiante',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(userType: UserType.student),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildRoleButton(
              context,
              label: 'Administrador',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(userType: UserType.admin),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleButton(BuildContext context, {required String label, required VoidCallback onPressed}) {
    return SizedBox(
      width: 200,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          backgroundColor: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 5,
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}