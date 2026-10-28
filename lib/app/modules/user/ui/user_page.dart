import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:redescomunicacionais/app/modules/user/controller/user_controller.dart';
import 'package:redescomunicacionais/app/modules/user/data/model/user_model.dart';
import 'package:redescomunicacionais/app/modules/user/utils/userRoles.dart';
import 'package:redescomunicacionais/app/utils/theme/color_pallete.dart';
import 'package:redescomunicacionais/app/utils/widgets/blinking_loading_icon.dart';
import 'package:redescomunicacionais/app/utils/widgets/city_selector_widget.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State createState() => _UserPageState();
}

class _UserPageState extends State {
  final TextEditingController _nameController = TextEditingController();
  bool _isNameInitialized = false;

  // Valor usado pela Home para "todas as cidades"
  static const String _allCitiesValue = 'Todas';

  UserController get controller => Get.find();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future _confirmDeleteAccount(BuildContext context) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('confirm_deletion'.tr),
          content: Text(
            'confirm_delete_account_message'.tr,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('cancel'.tr),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'delete_account'.tr,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await controller.deleteCurrentUserAccount();
  }

  // Painel para escolher a cidade favorita
  void _showCitySelector(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (_, __) {
            return SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'favorite_city'.tr,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _selectCity(sheetContext, _allCitiesValue),
                        icon: const Icon(Icons.public),
                        label: Text('all_cities'.tr),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: CitySelectorWidget(
                      onCitySelected: (cityName) =>
                          _selectCity(sheetContext, cityName),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _selectCity(BuildContext sheetContext, String cityName) async {
    Navigator.pop(sheetContext);
    await controller.updateFavoriteCity(cityName);
  }

  String _favoriteCityLabel(UserModel user) {
    final city = user.selectedAppCity;
    if (city == null || city.isEmpty) return 'no_city_selected'.tr;
    if (city == _allCitiesValue) return 'all_cities'.tr;
    return city;
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required Widget child,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(
        alpha: 0.4,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, IconData icon, String title) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, UserModel user) {
    final theme = Theme.of(context);
    final imageUrl = user.urlImage?.trim() ?? '';
    final role = user.role ?? UserRoles.user;

    return Column(
      children: [
        CircleAvatar(
          radius: 44,
          backgroundColor: theme.colorScheme.primaryContainer,
          backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
          child: imageUrl.isEmpty
              ? Icon(
                  Icons.person_outline,
                  size: 44,
                  color: theme.colorScheme.onPrimaryContainer,
                )
              : null,
        ),
        const SizedBox(height: 12),
        Text(
          user.name ?? '',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          user.email ?? '',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        Chip(
          avatar: Icon(
            Icons.verified_user_outlined,
            size: 18,
            color: theme.colorScheme.onSecondaryContainer,
          ),
          label: Text('role_$role'.tr),
          backgroundColor: theme.colorScheme.secondaryContainer,
          labelStyle: TextStyle(
            color: theme.colorScheme.onSecondaryContainer,
            fontWeight: FontWeight.w600,
          ),
          side: BorderSide.none,
        ),
      ],
    );
  }

  Widget _buildNameCard(BuildContext context, UserModel user) {
    final theme = Theme.of(context);

    return _buildSectionCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionTitle(context, Icons.badge_outlined, 'your_data'.tr),
          const SizedBox(height: 4),
          Text(
            'update_display_name'.tr,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: 'name'.tr,
              hintText: 'enter_your_name'.tr,
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: controller.isSavingData.value
                ? null
                : () {
                    FocusScope.of(context).unfocus();
                    controller.saveCurrentUserName(_nameController.text);
                  },
            icon: controller.isSavingData.value
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: BlinkingLoadingIcon(
                      size: 16,
                      color: theme.colorScheme.onSurface,
                    ),
                  )
                : const Icon(Icons.save_outlined),
            label: Text('save_changes'.tr),
          ),
          if (user.createdAt != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  '${'member_since'.tr} ${DateFormat('dd/MM/yyyy').format(user.createdAt!.toLocal())}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFavoriteCityCard(BuildContext context, UserModel user) {
    final theme = Theme.of(context);

    return _buildSectionCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionTitle(
              context, Icons.location_city_outlined, 'favorite_city'.tr),
          const SizedBox(height: 4),
          Text(
            'favorite_city_info'.tr,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  _favoriteCityLabel(user),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => _showCitySelector(context),
                icon: const Icon(Icons.edit_location_alt_outlined),
                label: Text('change_city'.tr),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOperationCitiesCard(BuildContext context, UserModel user) {
    final theme = Theme.of(context);
    final cities = user.operationsCities?.values.toList() ?? <String>[];

    return _buildSectionCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionTitle(
              context, Icons.map_outlined, 'operation_cities'.tr),
          const SizedBox(height: 4),
          Text(
            'operation_cities_info'.tr,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          if (cities.isEmpty)
            Text(
              'no_operation_cities'.tr,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: cities
                  .map((city) => Chip(
                        label: Text(city),
                        avatar: const Icon(Icons.place_outlined, size: 16),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildDangerZoneCard(BuildContext context) {
    final theme = Theme.of(context);

    return _buildSectionCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'danger_zone'.tr,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'delete_account_warning'.tr,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: controller.isDeletingAccount.value
                ? null
                : () => _confirmDeleteAccount(context),
            icon: controller.isDeletingAccount.value
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: BlinkingLoadingIcon(
                      size: 16,
                      color: Colors.red,
                    ),
                  )
                : const Icon(Icons.delete_outline),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
              side: BorderSide(color: theme.colorScheme.error),
            ),
            label: Text('delete_account'.tr),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('profile'.tr),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppColors.appBarBottomGradient(),
          ),
        ),
        iconTheme: IconThemeData(
          color: theme.colorScheme.onSurface,
        ),
      ),
      body: Obx(
        () {
          if (controller.isDataLoading.value) {
            _isNameInitialized = false;

            return const Center(
              child: BlinkingLoadingIcon(
                size: 36,
              ),
            );
          }

          final user = controller.currentUser.value;

          if (!_isNameInitialized) {
            _nameController.text = user.name ?? '';
            _isNameInitialized = true;
          }

          final bool canOperateCities =
              user.role == UserRoles.editor || user.role == UserRoles.admin;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context, user),
                  const SizedBox(height: 20),
                  _buildNameCard(context, user),
                  const SizedBox(height: 16),
                  _buildFavoriteCityCard(context, user),
                  if (canOperateCities) ...[
                    const SizedBox(height: 16),
                    _buildOperationCitiesCard(context, user),
                  ],
                  const SizedBox(height: 16),
                  _buildDangerZoneCard(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
