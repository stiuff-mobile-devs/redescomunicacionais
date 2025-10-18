import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/news/utils/news_states.dart';
import 'package:redescomunicacionais/app/modules/news/controller/news_controller.dart';
import 'package:redescomunicacionais/app/modules/news/data/model/news_model.dart';
import 'package:intl/intl.dart';
import 'package:redescomunicacionais/app/utils/theme/color_pallete.dart'; // Para formatar datas

class NewsWindowsPage extends GetView<NewsController> {
  const NewsWindowsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.darkBlueToBlackGradient(),
        ),
        child: Obx(
          () {
            if (controller.isLoading.value) {
              const Center(child: CircularProgressIndicator());
            }

            if (controller.newss.isEmpty) {
              return const Center(
                  child: Text(
                "Nenhuma Matéria encontrada",
                selectionColor: Colors.white,
              ));
            }
            // Filtra notícias com imagens válidas e status "publicado"
            final validNews = controller.getValidNews();

            if (validNews.isEmpty) {
              return const Center(
                child: Text(
                  "Nenhuma Matéria encontrada",
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              );
            }

            return GestureDetector(
              // Detecta toque fora dos cards para fechar o menu
              behavior: HitTestBehavior.translucent,
              onTap: () {
                controller.selectedCardIndex.value = null;
              },
              child: ListView(
                children: [
                  const SizedBox(height: 16.0), // Espaço superior

                  // Cards horizontais
                  _buildHorizontalCards(validNews),

                  const SizedBox(height: 16.0),

                  // Lista vertical de notícias
                  ..._buildNewsList(validNews),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHorizontalCards(List<dynamic> validNews) {
    return SizedBox(
      height: 120.0,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: validNews.map<Widget>((news) {
            final NewsModel n = news as NewsModel;
            return GestureDetector(
              onTap: () => controller.openNews(n),
              child: Card(
                color: Colors.grey[900],
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: SizedBox(
                  width: 120.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8.0)),
                        child: _buildSafeImage(n.urlImages[0], 70.0),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          n.title,
                          style: const TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  List<Widget> _buildNewsList(List<dynamic> validNews) {
    return validNews.asMap().entries.map<Widget>(
      (entry) {
        final index = entry.key;
        final news = entry.value as NewsModel;

        return Obx(() {
          final isSelected = controller.isSelected(index);

          return Column(
            children: [
              // Barra de ações (aparece apenas quando o card está selecionado)
              if (isSelected)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 8.0),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12.0),
                      topRight: Radius.circular(12.0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Ícone de editar (lápis)
                      GestureDetector(
                        onTap: () {
                          if (controller.canEdit(news)) {
                            controller.openEditNews(news);
                          } else {
                            _showAccessDeniedDialog(Get.context!);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      // Ícone de excluir (lixeira)
                      GestureDetector(
                        onTap: () {
                          hideNewsPopup(news.id, NewsStates.deletado,
                              controller.user.email, news.createdBy, news.type);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Card da notícia
              GestureDetector(
                onTap: () => controller.openNews(news),
                onLongPress: () => controller.toggleSelected(index),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: isSelected
                          ? Radius.zero
                          : const Radius.circular(12.0),
                      topRight: isSelected
                          ? Radius.zero
                          : const Radius.circular(12.0),
                      bottomLeft: const Radius.circular(12.0),
                      bottomRight: const Radius.circular(12.0),
                    ),
                    border: isSelected
                        ? Border.all(color: Colors.blue, width: 2.0)
                        : null,
                  ),
                  margin: EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    bottom: 8.0,
                    top: isSelected ? 0.0 : 8.0,
                  ),
                  child: Card(
                    color: Colors.black,
                    margin: EdgeInsets.zero,
                    elevation: isSelected ? 8.0 : 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: isSelected
                            ? Radius.zero
                            : const Radius.circular(12.0),
                        topRight: isSelected
                            ? Radius.zero
                            : const Radius.circular(12.0),
                        bottomLeft: const Radius.circular(12.0),
                        bottomRight: const Radius.circular(12.0),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Imagem da notícia
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: isSelected
                                ? Radius.zero
                                : const Radius.circular(12.0),
                            topRight: isSelected
                                ? Radius.zero
                                : const Radius.circular(12.0),
                          ),
                          child: _buildSafeImage(news.urlImages[0], 200.0),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Título da notícia
                              Text(
                                news.title,
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8.0),
                              // Subtítulo ou descrição curta
                              Text(
                                news.subtitle ?? '',
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.grey,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8.0),
                              // Data formatada
                              Text(
                                _getFormattedDate(news.createdAt.toString()),
                                style: const TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        });
      },
    ).toList();
  }

  Future<void> hideNewsPopup(String newsId, String status, String userEmail,
      String authorEmail, String type) async {
    await Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey[900],
        title:
            Text("Excluir $type", style: const TextStyle(color: Colors.white)),
        content: Text(
          "Tem certeza que deseja excluir esta $type?",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancelar", style: TextStyle(color: Colors.blue)),
          ),
          TextButton(
            onPressed: () async {
              Get.back(); // Fecha o diálogo
              try {
                String result = await controller.hideNews(
                    newsId, status, userEmail, authorEmail, type);
                if (result == "sucess" || result == "success") {
                  // Recarrega as notícias
                  controller.getNewsFromFirebase();
                }
              } catch (_) {}
            },
            child: const Text("Excluir", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  void _showAccessDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text("Acesso Negado",
              style: TextStyle(color: Colors.white)),
          content: const Text(
            "Você não pode editar esta notícia porque não é o autor. Apenas o autor original pode fazer alterações.",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK", style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  // Função para calcular e formatar a data
  String _getFormattedDate(String dataCriacao) {
    try {
      final creationDate = DateTime.parse(dataCriacao);
      final now = DateTime.now();
      final difference = now.difference(creationDate);

      if (difference.inSeconds < 60) {
        return '${difference.inSeconds} segundos atrás';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} minutos atrás';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} horas atrás';
      } else {
        return DateFormat('dd/MM/yyyy').format(creationDate);
      }
    } catch (e) {
      return dataCriacao;
    }
  }

  // Função para construir imagem segura com tratamento de erro
  Widget _buildSafeImage(String base64String, double height) {
    try {
      return Image.memory(
        base64Decode(base64String),
        fit: BoxFit.cover,
        width: double.infinity,
        height: height,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: height,
            color: Colors.grey[800],
            child: const Icon(
              Icons.image_not_supported,
              color: Colors.grey,
              size: 40,
            ),
          );
        },
      );
    } catch (e) {
      return Container(
        width: double.infinity,
        height: height,
        color: Colors.grey[800],
        child: const Icon(
          Icons.image_not_supported,
          color: Colors.grey,
          size: 40,
        ),
      );
    }
  }
}
