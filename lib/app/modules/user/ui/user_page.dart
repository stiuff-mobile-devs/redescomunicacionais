import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/user/controller/user_controller.dart';
import 'package:redescomunicacionais/app/modules/user/data/model/user_model.dart';
import 'package:redescomunicacionais/app/modules/utils/popups/app_popups.dart';
import 'package:redescomunicacionais/app/modules/utils/user/userRoles.dart';
import 'package:redescomunicacionais/app/modules/utils/translations/app_translations.dart';
import 'package:redescomunicacionais/app/modules/utils/translations/locale_keys.dart';
import 'package:redescomunicacionais/app/modules/utils/widgets/blinking_loading_icon.dart';
import 'package:redescomunicacionais/app/modules/utils/widgets/city_selector_widget.dart';
import 'package:redescomunicacionais/app/modules/utils/app_bar/app_bars.dart';

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
    final bool confirm = await AppPopups.confirm(
      title: LocaleKeys.confirmDeletion.tr,
      message: LocaleKeys.confirmDeleteAccountMessage.tr,
      icon: Icons.person_remove_outlined,
      confirmText: LocaleKeys.deleteAccount.tr,
      destructive: true,
    );

    if (!confirm) return;

    await controller.deleteCurrentUserAccount();
  }

  // Folha para escolher a cidade favorita (a lista de cidades precisa de
  // altura fixa, por isso usa AppPopups.custom)
  Future<void> _showCitySelector(BuildContext context) async {
    final String? cityName = await AppPopups.custom<String>(
      Builder(
        builder: (sheetContext) {
          final theme = Theme.of(sheetContext);

          return SizedBox(
            height: MediaQuery.of(sheetContext).size.height * 0.75,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Text(
                    LocaleKeys.favoriteCity.tr,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppSheetButton.primary(
                    label: LocaleKeys.allCities.tr,
                    onPressed: () =>
                        Navigator.of(sheetContext).pop(_allCitiesValue),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: CitySelectorWidget(
                      onCitySelected: (city) =>
                          Navigator.of(sheetContext).pop(city),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    if (cityName != null) await controller.updateFavoriteCity(cityName);
  }

  String _favoriteCityLabel(UserModel user) {
    final city = user.selectedAppCity;
    if (city == null || city.isEmpty) return LocaleKeys.noCitySelected.tr;
    if (city == _allCitiesValue) return LocaleKeys.allCities.tr;
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
          label: Text(UserRoles.label(role)),
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
          _buildSectionTitle(context, Icons.badge_outlined, LocaleKeys.yourData.tr),
          const SizedBox(height: 4),
          Text(
            LocaleKeys.updateDisplayName.tr,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: LocaleKeys.name.tr,
              hintText: LocaleKeys.enterYourName.tr,
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
            label: Text(LocaleKeys.saveChanges.tr),
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
                  LocaleKeys.memberSince.trParams({
                    'date': AppTranslation.formatDate(user.createdAt!.toLocal()),
                  }),
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
              context, Icons.location_city_outlined, LocaleKeys.favoriteCity.tr),
          const SizedBox(height: 4),
          Text(
            LocaleKeys.favoriteCityInfo.tr,
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
                label: Text(LocaleKeys.change.tr),
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
              context, Icons.map_outlined, LocaleKeys.operationCities.tr),
          const SizedBox(height: 4),
          Text(
            LocaleKeys.operationCitiesInfo.tr,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          if (cities.isEmpty)
            Text(
              LocaleKeys.noOperationCities.tr,
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
            LocaleKeys.dangerZone.tr,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            LocaleKeys.deleteAccountWarning.tr,
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
            label: Text(LocaleKeys.deleteAccount.tr),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBars.build(title: LocaleKeys.profile.tr),
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
