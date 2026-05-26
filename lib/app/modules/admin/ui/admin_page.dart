import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/admin/controller/admin_controller.dart';
import 'package:redescomunicacionais/app/modules/user/utils/userRoles.dart';
import 'package:redescomunicacionais/app/utils/theme/color_pallete.dart';
import 'package:redescomunicacionais/app/utils/widgets/blinking_loading_icon.dart';

class AdminPage extends GetView<AdminController> {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('manage_users'.tr),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppColors.appBarTopGradient(),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadAllUsers(),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: AppColors.darkBlueToBlackGradient(),
        ),
        child: Column(
          children: [
            // Cabeçalho
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'registered_users'.tr,
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Filtros
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('filter_all'.tr, 'todos'),
                    const SizedBox(width: 8),
                    _buildFilterChip('filter_users'.tr, 'user'),
                    const SizedBox(width: 8),
                    _buildFilterChip('filter_editors'.tr, 'editor'),
                    const SizedBox(width: 8),
                    _buildFilterChip('filter_admins'.tr, 'admin'),
                  ],
                ),
              ),
            ),

            // Lista de usuários
            Expanded(
              child: GetBuilder<AdminController>(
                builder: (adminController) {
                  if (controller.isLoadingUserController().value) {
                    return const Center(
                      child: BlinkingLoadingIcon(
                        size: 36,
                        color: Colors.white,
                      ),
                    );
                  }

                  final filteredUsers = controller.getFilteredAndSortedUsers();
                  if (filteredUsers.isEmpty) {
                    return Center(
                      child: Text(
                        'no_user_found'.tr,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      return _buildUserCard(user);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    String email = user['email'] ?? '';
    String userId = user['id'] ?? '';
    String currentRole = user['role'] ?? 'user';

    // Gera iniciais do email
    String initials = email.isNotEmpty ? email[0].toUpperCase() : 'U';

    // Cor baseada na role
    Color roleColor = _getRoleColor(currentRole);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.black.withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: roleColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar único com iniciais
            CircleAvatar(
              radius: 25,
              backgroundColor: roleColor.withOpacity(0.2),
              child: Text(
                initials,
                style: TextStyle(
                  color: roleColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Informações do usuário
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    email,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: roleColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getRoleDisplayName(currentRole),
                      style: TextStyle(
                        color: roleColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Dropdown para alterar role
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: DropdownButton<String>(
                value: currentRole,
                underline: const SizedBox(),
                dropdownColor: Colors.black87,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                style: const TextStyle(color: Colors.white),
                items: [
                  DropdownMenuItem(value: 'user', child: Text('role_user'.tr)),
                  DropdownMenuItem(
                      value: 'editor', child: Text('role_editor'.tr)),
                  DropdownMenuItem(value: 'admin', child: Text('role_admin'.tr)),
                ],
                onChanged: (newRole) async {
                  if (newRole != null) {
                    // Confirma a alteração
                    bool? confirm =
                        await _showConfirmDialog(email, currentRole, newRole);
                    if (confirm == true) {
                      controller.addProfile(
                          email, newRole, controller.user?.email ?? '');
                      // Atualiza documento de role
                      if (userId.isNotEmpty) {
                        await controller.updateRoleDocument(
                            userId, newRole, controller.user?.email ?? '');
                      }
                      // Recarrega a lista
                      controller.loadAllUsers();
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case UserRoles.admin:
        return Colors.red;
      case UserRoles.editor:
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  Widget _buildFilterChip(String label, String filterValue) {
    return Obx(() {
      final isSelected = controller.selectedRoleFilter.value == filterValue;
      return FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          controller.setRoleFilter(filterValue);
        },
        backgroundColor:
            isSelected ? Colors.blue : Colors.black.withOpacity(0.4),
        selectedColor: Colors.blue,
        side: BorderSide(
          color: isSelected ? Colors.blue : Colors.white24,
          width: 1,
        ),
      );
    });
  }

  String _getRoleDisplayName(String role) {
    switch (role.toLowerCase()) {
      case UserRoles.admin:
        return 'role_admin'.tr;
      case UserRoles.editor:
        return 'role_editor'.tr;
      default:
        return 'role_user'.tr;
    }
  }

  Future<bool?> _showConfirmDialog(
      String email, String currentRole, String newRole) {
    return showDialog<bool>(
      context: Get.context!,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        title: Text(
          'confirm_change'.tr,
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '${'change_role_of'.tr} $email\n${'from_label'.tr}: ${_getRoleDisplayName(currentRole)}\n${'to_label'.tr}: ${_getRoleDisplayName(newRole)}',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child:
                Text('cancel'.tr, style: const TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            child:
                Text('confirm'.tr, style: const TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
