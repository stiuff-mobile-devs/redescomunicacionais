import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/user/controller/user_controller.dart';
import 'package:redescomunicacionais/app/modules/user/data/model/user_model.dart';
import 'package:redescomunicacionais/app/routes/app_routes.dart';
import 'package:redescomunicacionais/app/utils/widgets/blinking_loading_icon.dart';

class UserPage extends GetView<UserController> {
  const UserPage({super.key});

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
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
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;
    await controller.deleteCurrentUserAccount();
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required Widget child,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(
        () {
          if (controller.isDataLoading.value) {
            return const Center(
              child: BlinkingLoadingIcon(
                size: 36,
              ),
            );
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionCard(
                    context: context,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor:
                                  theme.colorScheme.primaryContainer,
                              child: Icon(
                                Icons.person_outline,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'your_data'.tr,
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'update_display_name'.tr,
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: controller.nameController,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            labelText: 'name'.tr,
                            hintText: 'enter_your_name'.tr,
                            prefixIcon: const Icon(Icons.badge_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.outlineVariant,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.mail_outline,
                                size: 18,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  controller.currentUser.value?.email ?? '',
                                  style: theme.textTheme.bodyMedium,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: controller.isSavingData.value
                              ? null
                              : () async {
                                  final UserModel? updatedUser =
                                      await controller.saveCurrentUserName();
                                  if (updatedUser != null) {
                                    Get.offAllNamed(
                                      Routes.HOME,
                                      arguments: updatedUser,
                                    );
                                  }
                                },
                          icon: controller.isSavingData.value
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: BlinkingLoadingIcon(
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save_outlined),
                          label: Text('save_changes'.tr),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionCard(
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
