import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/admin/controller/admin_controller.dart';
import 'package:redescomunicacionais/app/modules/news/utils/cities_codes.dart';
import 'package:redescomunicacionais/app/modules/user/utils/userRoles.dart';
import 'package:redescomunicacionais/app/modules/user/data/model/user_model.dart';
import 'package:redescomunicacionais/app/utils/components/popups.dart';
import 'package:redescomunicacionais/app/utils/theme/color_pallete.dart';
import 'package:redescomunicacionais/app/utils/widgets/blinking_loading_icon.dart';
import 'package:redescomunicacionais/app/utils/widgets/city_selector_widget.dart';

class AdminPage extends GetView<AdminController> {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('manage_users'.tr),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppColors.appBarBottomGradient(),
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
        child: Obx(() {
          // Se nenhuma cidade foi selecionada, mostra o Widget de Seleção
          if (controller.selectedCity.value == null) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Escolha a Cidade para Gerenciar os Editores e Administradores'.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                // Botão de "Visualizar todas as cidades"
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        controller.selectedCity.value = 'Todas'; // Bypassa o filtro
                      },
                      label: const Text(
                        'Visualizar todas as cidades',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent.withOpacity(0.8),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: CitySelectorWidget(
                    onCitySelected: (String cityName) {
                      debugPrint('Cidade selecionada: $cityName');
                      controller.selectedCity.value = cityName;
                    },
                  ),
                ),
              ],
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
                            'registered_users'.tr,
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Cidade: ${controller.selectedCity.value}',
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
                        'no_user_found'.tr,
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
                      DropdownMenuItem(value: 'user', child: Text('role_user'.tr)),
                      DropdownMenuItem(value: 'editor', child: Text('role_editor'.tr)),
                      DropdownMenuItem(value: 'admin', child: Text('role_admin'.tr)),
                    ],
                    onChanged: (newRole) async {
                      if (newRole != null && newRole != selectedUserCurrentRole) {
                        final result = await _showRoleChangeDialog(selectedUserEmail, selectedUserCurrentRole, newRole);
                        if (result != null && result['confirmed'] == true) {
                          Map<String, String> operationsCities = result['cities'] ?? <String, String>{};

                          if (selectedUserId.isNotEmpty) {
                            try {
                              await controller.userRepository.updateUserRole(
                                  selectedUserId, newRole, controller.user.email!, operationsCities);
                              PopUps.snackbar(
                                texto: 'Cargo atualizado com sucesso'.tr,
                                cor: Colors.green,
                              );
                            } catch (e) {
                              PopUps.snackbar(
                                texto: 'Ocorreu um erro ao atualizar o cargo'.tr,
                                cor: Colors.red,
                              );
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
                      tooltip: 'Alterar cidades de atuação',
                      onPressed: () async {
                        final Map<String, String>? updatedCities = await _showEditCitiesDialog(user);
                        
                        if (updatedCities != null && selectedUserId.isNotEmpty) {
                          try {
                            // Reaproveita o updateUserRole passando o MESMO cargo, apenas atualizando as cidades
                            await controller.userRepository.updateUserRole(
                                selectedUserId, selectedUserCurrentRole, controller.user.email!, updatedCities);
                            PopUps.snackbar(
                              texto: 'Cidades atualizadas com sucesso'.tr,
                              cor: Colors.green,
                            );
                            await controller.loadAllUsers();
                          } catch (e) {
                            PopUps.snackbar(
                              texto: 'Ocorreu um erro ao atualizar as cidades'.tr,
                              cor: Colors.red,
                            );
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

  // DIÁLOGO PARA EDITAR CIDADES DIRETAMENTE
  Future<Map<String, String>?> _showEditCitiesDialog(UserModel user) {
    // Clona as cidades atuais do usuário
    Map<String, String> selectedCities = Map<String, String>.from(user.operationsCities ?? {});
    final citiesMap = CitiesCodes().cities;

    return showDialog<Map<String, String>>(
      context: Get.context!,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.black87,
              title: Text(
                'Cidades de Atuação',
                style: const TextStyle(color: Colors.white),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selecione as cidades para:\n${user.email}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    ...citiesMap.entries.map((entry) {
                      return Theme(
                        data: ThemeData(unselectedWidgetColor: Colors.white70),
                        child: CheckboxListTile(
                          title: Text(
                            entry.value,
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          value: selectedCities.containsKey(entry.key),
                          activeColor: Colors.blue,
                          checkColor: Colors.white,
                          dense: true,
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (bool? checked) {
                            setState(() {
                              if (checked == true) {
                                selectedCities[entry.key] = entry.value;
                              } else {
                                selectedCities.remove(entry.key);
                              }
                            });
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: Text('cancel'.tr, style: const TextStyle(color: Colors.white70)),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Ao invés do map de confirmação, retorna direto o novo Map das cidades selecionadas
                    Navigator.of(context).pop(selectedCities);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                  child: Text('confirm'.tr, style: const TextStyle(color: Colors.black)),
                ),
              ],
            );
          },
        );
      },
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

  Future<Map<String, dynamic>?> _showRoleChangeDialog(
      String email, String currentRole, String newRole) {
    
    Map<String, String> selectedCities = {};
    final citiesMap = CitiesCodes().cities;

    return showDialog<Map<String, dynamic>>(
      context: Get.context!,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.black87,
              title: Text(
                'confirm_change'.tr,
                style: const TextStyle(color: Colors.white),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${'change_role_of'.tr} $email\n${'from_label'.tr}: ${_getRoleDisplayName(currentRole)}\n${'to_label'.tr}: ${_getRoleDisplayName(newRole)}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    if (newRole == 'editor') ...[
                      const SizedBox(height: 20),
                      const Text(
                        'Cidades de atuação:',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...citiesMap.entries.map((entry) {
                        return Theme(
                          data: ThemeData(
                              unselectedWidgetColor: Colors.white70),
                          child: CheckboxListTile(
                            title: Text(
                              entry.value,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 14),
                            ),
                            value: selectedCities.containsKey(entry.key),
                            activeColor: Colors.white,
                            checkColor: Colors.black,
                            dense: true,
                            controlAffinity:
                                ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (bool? checked) {
                              setState(() {
                                if (checked == true) {
                                  selectedCities[entry.key] = entry.value;
                                } else {
                                  selectedCities.remove(entry.key);
                                }
                              });
                            },
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: Text('cancel'.tr,
                      style: const TextStyle(color: Colors.white70)),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (newRole == 'editor' && selectedCities.isEmpty) {
                      PopUps.snackbar(
                        texto: 'Selecione pelo menos uma cidade para o editor.',
                        cor: Colors.orange,
                      );
                      return;
                    }
                    Navigator.of(context).pop({
                      'confirmed': true,
                      'cities': selectedCities,
                    });
                  },
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.white),
                  child: Text('confirm'.tr,
                      style: const TextStyle(color: Colors.black)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}