import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/admin/controller/admin_controller.dart';
import 'package:redescomunicacionais/app/modules/utils/news/cities_codes.dart';
import 'package:redescomunicacionais/app/modules/utils/user/userRoles.dart';
import 'package:redescomunicacionais/app/modules/user/data/model/user_model.dart';
import 'package:redescomunicacionais/app/modules/utils/popups/app_popups.dart';
import 'package:redescomunicacionais/app/modules/utils/theme/color_pallete.dart';
import 'package:redescomunicacionais/app/modules/utils/translations/locale_keys.dart';
import 'package:redescomunicacionais/app/modules/utils/widgets/blinking_loading_icon.dart';
import 'package:redescomunicacionais/app/modules/utils/widgets/city_selector_widget.dart';
import 'package:redescomunicacionais/app/modules/utils/app_bar/app_bars.dart';
import 'package:redescomunicacionais/app/modules/utils/theme/app_theme.dart';

class AdminPage extends GetView<AdminController> {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBars.build(
        title: LocaleKeys.manageUsers.tr,
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
        child: Obx(() {
          // Se nenhuma cidade foi selecionada, mostra o Widget de Seleção
          if (controller.selectedCity.value == null) {
            // O fundo desta tela é sempre escuro: usa o tema escuro no
            // seletor para o cabeçalho ficar legível
            return Theme(
              data: appThemeDataClassic,
              child: CitySelectorWidget(
                title: LocaleKeys.chooseCityToManageEditors.tr,
                onAllCitiesSelected: () =>
                    controller.selectedCity.value = 'Todas', // Bypassa o filtro
                onCitySelected: (String cityName) {
                  debugPrint('Cidade selecionada: $cityName');
                  controller.selectedCity.value = cityName;
                },
              ),
            );
          }
          
          // Tela da listagem de usuários com a cidade já selecionada
          return Column(
            children: [
              // Cabeçalho com o botão de voltar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () {
                        // Reseta a cidade para voltar à tela anterior
                        controller.selectedCity.value = null; 
                      },
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            LocaleKeys.registeredUsers.tr,
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            LocaleKeys.cityLabel.trParams({
                              // 'Todas' é o valor interno de "sem filtro"
                              'city': controller.selectedCity.value == 'Todas'
                                  ? LocaleKeys.allCities.tr
                                  : controller.selectedCity.value ?? '',
                            }),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Filtros (Todos, User, Editor, Admin)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(LocaleKeys.filterAll.tr, 'todos'),
                      const SizedBox(width: 8),
                      _buildFilterChip(LocaleKeys.filterUsers.tr, 'user'),
                      const SizedBox(width: 8),
                      _buildFilterChip(LocaleKeys.filterEditors.tr, 'editor'),
                      const SizedBox(width: 8),
                      _buildFilterChip(LocaleKeys.filterAdmins.tr, 'admin'),
                    ],
                  ),
                ),
              ),

              // Lista de usuários
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: BlinkingLoadingIcon(
                        size: 36,
                        color: Colors.white,
                      ),
                    );
                  }

                  String filter = controller.selectedRoleFilter.value;
                  String selectedCity = controller.selectedCity.value ?? 'Todas';

                  List<UserModel> filteredUsers = controller.users.where((u) {
                    // Filtro 1: Cargo
                    bool matchesRole = filter == 'todos' ? true : u.role == filter;
                    
                    // Filtro 2: Cidade
                    bool matchesCity = true;
                    if (selectedCity != 'Todas') {
                      // Verifica se o usuário tem a cidade listada em suas operationsCities
                      matchesCity = u.operationsCities != null && u.operationsCities!.containsValue(selectedCity);
                    }
                    
                    return matchesRole && matchesCity;
                  }).toList()
                    ..sort((a, b) => a.email!.compareTo(b.email!));

                  if (filteredUsers.isEmpty) {
                    return Center(
                      child: Text(
                        LocaleKeys.noUserFound.tr,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      UserModel user = filteredUsers[index];
                      return _buildUserCard(user);
                    },
                  );
                }),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    String selectedUserEmail = user.email!;
    String selectedUserId = user.id!;
    String selectedUserCurrentRole = user.role!;

    // Gera iniciais do email
    String initials = selectedUserEmail.isNotEmpty ? selectedUserEmail[0].toUpperCase() : 'U';

    // Cor baseada na role
    Color roleColor = _getRoleColor(selectedUserCurrentRole);
    
    // Verifica se o usuário logado no app é admin para liberar funções restritas
    bool isCurrentUserAdmin = controller.user.role!.toLowerCase() == UserRoles.admin;

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
            // Avatar
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
                    selectedUserEmail,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: roleColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getRoleDisplayName(selectedUserCurrentRole),
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

            // Ações: Dropdown de Permissões + Botão de Cidades
            Row(
              children: [
                // Dropdown de permissões
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: DropdownButton<String>(
                    value: selectedUserCurrentRole,
                    underline: const SizedBox(),
                    dropdownColor: Colors.black87,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                    style: const TextStyle(color: Colors.white),
                    items: [
                      DropdownMenuItem(value: 'user', child: Text(UserRoles.label(UserRoles.user))),
                      DropdownMenuItem(value: 'editor', child: Text(UserRoles.label(UserRoles.editor))),
                      DropdownMenuItem(value: 'admin', child: Text(UserRoles.label(UserRoles.admin))),
                    ],
                    onChanged: (newRole) async {
                      if (newRole != null && newRole != selectedUserCurrentRole) {
                        // null = cancelou; senão, as cidades escolhidas
                        final Map<String, String>? operationsCities =
                            await _showRoleChangeDialog(selectedUserEmail, selectedUserCurrentRole, newRole);
                        if (operationsCities != null) {
                          if (selectedUserId.isNotEmpty) {
                            try {
                              await controller.userRepository.updateUserRole(
                                  selectedUserId, newRole, controller.user.email!, operationsCities);
                              AppPopups.success(LocaleKeys.roleUpdatedSuccess.tr);
                            } catch (e) {
                              debugPrint('Erro ao atualizar o cargo: $e');
                              AppPopups.error(LocaleKeys.roleUpdateError.tr);
                            }
                          }
                          await controller.loadAllUsers();
                        }
                      }
                    },
                  ),
                ),
                
                // Botão dedicado para alterar APENAS as cidades 
                // visível somente para Admins olhando para editores ou admins
                if (isCurrentUserAdmin && (selectedUserCurrentRole == UserRoles.editor || selectedUserCurrentRole == UserRoles.admin))
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: IconButton(
                      icon: const Icon(Icons.edit_location_alt, color: Colors.blueAccent),
                      tooltip: LocaleKeys.changeOperationCities.tr,
                      onPressed: () async {
                        final Map<String, String>? updatedCities = await _showEditCitiesDialog(user);
                        
                        if (updatedCities != null && selectedUserId.isNotEmpty) {
                          try {
                            // Reaproveita o updateUserRole passando o MESMO cargo, apenas atualizando as cidades
                            await controller.userRepository.updateUserRole(
                                selectedUserId, selectedUserCurrentRole, controller.user.email!, updatedCities);
                            AppPopups.success(LocaleKeys.citiesUpdatedSuccess.tr);
                            await controller.loadAllUsers();
                          } catch (e) {
                            debugPrint('Erro ao atualizar as cidades: $e');
                            AppPopups.error(LocaleKeys.citiesUpdateError.tr);
                          }
                        }
                      },
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Folha para editar só as cidades de atuação. Retorna o novo mapa ou null.
  Future<Map<String, String>?> _showEditCitiesDialog(UserModel user) {
    return AppPopups.custom<Map<String, String>>(
      _CitiesSheet(
        title: LocaleKeys.operationCities.tr,
        message: LocaleKeys.selectCitiesFor.trParams({'email': user.email ?? ''}),
        icon: Icons.edit_location_alt_outlined,
        initialCities: user.operationsCities ?? {},
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
          controller.selectedRoleFilter.value = filterValue;
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

  String _getRoleDisplayName(String role) =>
      UserRoles.label(role.toLowerCase());

  // Confirma a troca de papel. Para editor, pede também as cidades.
  // Retorna as cidades escolhidas (vazio se não for editor) ou null se cancelar.
  Future<Map<String, String>?> _showRoleChangeDialog(
      String email, String currentRole, String newRole) {
    final bool isEditor = newRole == UserRoles.editor;

    return AppPopups.custom<Map<String, String>>(
      _CitiesSheet(
        title: LocaleKeys.confirmChange.tr,
        message: LocaleKeys.changeRoleMessage.trParams({
          'email': email,
          'from': _getRoleDisplayName(currentRole),
          'to': _getRoleDisplayName(newRole),
        }),
        icon: Icons.manage_accounts_outlined,
        initialCities: const {},
        showCities: isEditor,
        requireCity: isEditor,
      ),
    );
  }
}

// Folha com a lista de cidades de atuação para marcar.
// Retorna o mapa escolhido ao confirmar ou null ao cancelar.
class _CitiesSheet extends StatefulWidget {
  final String title;
  final String message;
  final IconData icon;
  final Map<String, String> initialCities;
  final bool showCities;
  final bool requireCity;

  const _CitiesSheet({
    required this.title,
    required this.message,
    required this.icon,
    required this.initialCities,
    this.showCities = true,
    this.requireCity = false,
  });

  @override
  State<_CitiesSheet> createState() => _CitiesSheetState();
}

class _CitiesSheetState extends State<_CitiesSheet> {
  late final Map<String, String> _selected =
      Map<String, String>.from(widget.initialCities);
  final Map<String, String> _cities = CitiesCodes().cities;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bool canConfirm = !widget.requireCity || _selected.isNotEmpty;

    return AppSheet(
      title: widget.title,
      message: widget.message,
      icon: widget.icon,
      iconColor: scheme.primary,
      actions: [
        AppSheetButton.primary(
          label: LocaleKeys.confirm.tr,
          onPressed:
              canConfirm ? () => Navigator.of(context).pop(_selected) : null,
        ),
        AppSheetButton.secondary(
          label: LocaleKeys.cancel.tr,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
      child: !widget.showCities
          ? null
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleKeys.operationCitiesLabel.tr,
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (widget.requireCity && _selected.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      LocaleKeys.selectAtLeastOneCityForEditor.tr,
                      style: TextStyle(color: scheme.error, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 8),
                ..._cities.entries.map((entry) {
                  return CheckboxListTile(
                    title: Text(entry.value),
                    value: _selected.containsKey(entry.key),
                    dense: true,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (bool? checked) {
                      setState(() {
                        if (checked == true) {
                          _selected[entry.key] = entry.value;
                        } else {
                          _selected.remove(entry.key);
                        }
                      });
                    },
                  );
                }),
              ],
            ),
    );
  }
}