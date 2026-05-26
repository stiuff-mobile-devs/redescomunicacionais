import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/connections/controller/connections_controller.dart';
import 'package:redescomunicacionais/app/utils/theme/color_pallete.dart';

class ConnectionsPage extends GetView<ConnectionsController> {
  const ConnectionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 8,
        foregroundColor: Colors.white,
        title: const Text('Conexões'),
        actions: [
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppColors.appBarTopGradient()),
        ),
      ),

      body: Obx(
        () => Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: AppColors.darkBlueToBlackGradient(),
          ),
          child: controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : _buildConnectionsContent(),
        ),
      ),
    );
  }

  Widget _buildConnectionsContent() {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        children: [
          _buildConnectionsHeader(),
          const SizedBox(height: 16),
          _buildInternetConnectionCard(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildConnectionsHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: const Text(
        'Gerencie e acompanhe o status das suas conexões externas.',
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          height: 1.35,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInternetConnectionCard() {
    return Obx(
      () => _buildConnectionCard(
        title: 'Internet',
        description: 'Conectividade geral para os módulos do aplicativo.',
        icon: Icons.wifi_rounded,
        accentColor: Colors.cyan.shade300,
        isConnected: controller.isInternetConnected.value,
      ),
    );
  }


  Widget _buildConnectionCard({
    required String title,
    required String description,
    required IconData icon,
    required Color accentColor,
    required bool isConnected,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withValues(alpha: 0.08),
        border: Border.all(color: accentColor.withValues(alpha: 0.65), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accentColor, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.82),
                    fontSize: 13,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _buildStatusBadge(
            isConnected: isConnected,
            accentColor: accentColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge({
    required bool isConnected,
    required Color accentColor,
  }) {
    final Color badgeColor = isConnected ? accentColor : Colors.redAccent;
    final String label = isConnected ? 'Ativo' : 'Falha';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: badgeColor.withValues(alpha: 0.7)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: badgeColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}