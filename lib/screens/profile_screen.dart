import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import '../services/preferences_service.dart';
import '../widgets/bottom_nav.dart';

class ProfileScreen extends StatefulWidget {

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();

}

class _ProfileScreenState extends State<ProfileScreen> {

  User? _user;
  bool _loading = true;
  bool _editing = false;
  bool _saving = false;

  final UserRepository _userRepository = UserRepository();

  // Controllers para los campos editables.
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();

  // ==========================================================
  // Lifecycle.
  // ==========================================================

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  // ==========================================================
  // Cargar usuario logueado desde SQLite.
  // ==========================================================

  Future<void> _loadUser() async {

    final int? userId = await PreferencesService.loadUserId();

    if (userId == null) {
      setState(() => _loading = false);
      return;
    }

    final user = await _userRepository.getUserById(userId);

    if (user != null) {
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      _phoneController.text = user.phone ?? '';
      _bioController.text = user.bio ?? '';
    }

    setState(() {
      _user = user;
      _loading = false;
    });

  }

  // ==========================================================
  // Guardar cambios.
  // ==========================================================

  Future<void> _saveChanges() async {

    if (_user == null) return;

    setState(() => _saving = true);

    final updated = _user!.copyWith(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
    );

    await _userRepository.updateUser(updated);

    setState(() {
      _user = updated;
      _editing = false;
      _saving = false;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil actualizado')),
    );

  }

  // ==========================================================
  // Cancelar edicion.
  // ==========================================================

  void _cancelEdit() {
    _firstNameController.text = _user!.firstName;
    _lastNameController.text = _user!.lastName;
    _phoneController.text = _user!.phone ?? '';
    _bioController.text = _user!.bio ?? '';
    setState(() => _editing = false);
  }

  // ==========================================================
  // Logout.
  // ==========================================================

  Future<void> _logout() async {
    await PreferencesService.clearUserId();
    await PreferencesService.clearRole();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  // ==========================================================
  // Build.
  // ==========================================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          if (!_loading && _user != null && !_editing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _editing = true),
            ),
          if (!_loading && _user != null && _editing)
            TextButton(
              onPressed: _cancelEdit,
              child: const Text('Cancelar'),
            ),
        ],
      ),

      body: _loading

          ? const Center(child: CircularProgressIndicator())

          : _user == null

              ? const Center(child: Text('No se pudo cargar el perfil.'))

              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [

                      // Avatar
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.blue,
                        child: Text(
                          '${_user!.firstName[0]}${_user!.lastName[0]}'.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Nombre
                      _buildField(
                        label: 'Nombres',
                        controller: _firstNameController,
                        enabled: _editing,
                      ),

                      const SizedBox(height: 16),

                      // Apellido
                      _buildField(
                        label: 'Apellidos',
                        controller: _lastNameController,
                        enabled: _editing,
                      ),

                      const SizedBox(height: 16),

                      // Email (solo lectura)
                      _buildField(
                        label: 'Correo electronico',
                        controller: TextEditingController(text: _user!.email),
                        enabled: false,
                      ),

                      const SizedBox(height: 16),

                      // Telefono
                      _buildField(
                        label: 'Telefono',
                        controller: _phoneController,
                        enabled: _editing,
                        keyboardType: TextInputType.phone,
                        hint: 'Ej: 951123456',
                      ),

                      const SizedBox(height: 16),

                      // Bio
                      _buildField(
                        label: 'Biografia',
                        controller: _bioController,
                        enabled: _editing,
                        maxLines: 3,
                        hint: 'Cuentanos sobre ti...',
                      ),

                      const SizedBox(height: 32),

                      // Boton guardar
                      if (_editing)
                        ElevatedButton(
                          onPressed: _saving ? null : _saveChanges,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: _saving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Guardar cambios'),
                        ),

                      const SizedBox(height: 16),

                      // Boton logout
                      OutlinedButton.icon(
                        icon: const Icon(Icons.logout),
                        label: const Text('Cerrar sesion'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: _logout,
                      ),

                    ],
                  ),
                ),

      bottomNavigationBar: const BottomNav(
        currentIndex: 3,
      ),

    );

  }

  // ==========================================================
  // Helper: campo de texto.
  // ==========================================================

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
        ),
      ],
    );
  }

}
