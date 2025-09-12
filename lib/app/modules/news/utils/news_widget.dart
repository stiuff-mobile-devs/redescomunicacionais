import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:redescomunicacionais/app/modules/news/utils/news_states.dart';
import 'package:redescomunicacionais/app/modules/user/data/model/user_model.dart';
import 'package:redescomunicacionais/app/routes/app_routes.dart';
import 'package:redescomunicacionais/app/modules/news/controller/news_controller.dart';
import 'package:intl/intl.dart'; // Para formatar datas

class NewsWidget extends StatefulWidget {
  NewsWidget({super.key});

  @override
  State<NewsWidget> createState() => _NewsWidgetState();
}

class _NewsWidgetState extends State<NewsWidget> {
  final NewsController newsController = Get.find<NewsController>();
  late String userEmail;
  int? selectedCardIndex;

  @override
  void initState() {
    super.initState();

    // Verifica o tipo dos argumentos e extrai o email
    final arguments = Get.arguments;
    if (arguments is UserModel) {
      userEmail = arguments.email;
    } else if (arguments is Map<String, dynamic>) {
      userEmail = arguments['email'] ?? '';
    } else {
      userEmail = '';
    }

    // Busca as notícias apenas uma vez quando o widget é inicializado
    newsController.getNewsFromFirebase();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (newsController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (newsController.newss.isEmpty) {
        return const Center(
            child: Text(
          "Nenhuma Matéria encontrada",
          selectionColor: Colors.white,
        ));
      }

      // Filtra notícias com imagens válidas e status "publicado"
      final validNews = newsController.newss.where((news) {
        // Verifica se o status é "publicado"
        if (news.status != "publicado") return false;

        // Verifica se tem imagens
        if (news.urlImages.isEmpty) return false;

        // Verifica se a imagem base64 é válida
        try {
          base64Decode(news.urlImages[0]);
          return true;
        } catch (e) {
          return false;
        }
      }).toList();

      if (validNews.isEmpty) {
        return const Center(
          child: Text(
            "Nenhuma matéria com imagem válida encontrada",
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        );
      }

      return GestureDetector(
        // Detecta toque fora dos cards para fechar o menu
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (selectedCardIndex != null) {
            setState(() {
              selectedCardIndex = null;
            });
          }
        },
        child: ListView(
          children: [
            const SizedBox(height: 16.0), // Espaço superior

            // Cards horizontais
            SizedBox(
              height: 120.0, // Altura dos cards horizontais
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: validNews.map((news) {
                    return GestureDetector(
                      onTap: () {
                        Get.toNamed(
                          Routes.NEWS_PAGE,
                          arguments: {
                            "titulo": news.title,
                            "subtitulo": news.subtitle,
                            "cidade": news.cities.isNotEmpty
                                ? news.cities.join(', ')
                                : '',
                            "categoria": news.categories.isNotEmpty
                                ? news.categories.join(', ')
                                : '',
                            "corpo": news.body,
                            "imgurl": news.urlImages.isNotEmpty
                                ? news.urlImages[0]
                                : '',
                            "autor": news.author,
                            "dataCriacao": news.createdAt.toString(),
                            "type": news.type,
                            "videoUrl": news.videoUrl,
                          },
                        );
                      },
                      child: Card(
                        color: Colors.grey[900],
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: SizedBox(
                          width: 120.0, // Largura de cada card horizontal
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(8.0)),
                                child: _buildSafeImage(news.urlImages[0], 70.0),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  news.title,
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
            ),

            const SizedBox(
                height:
                    16.0), // Espaço entre os cards horizontais e a lista vertical

            // Lista vertical de notícias
            ...validNews.asMap().entries.map((entry) {
              final index = entry.key;
              final news = entry.value;
              final isSelected = selectedCardIndex == index;

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
                              _showDevelopmentPopup("Editar");
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
                                  userEmail, news.createdBy, news.type);
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
                    onTap: () {
                      // Sempre navega para a página da notícia
                      Get.toNamed(
                        Routes.NEWS_PAGE,
                        arguments: {
                          "titulo": news.title,
                          "subtitulo": news.subtitle,
                          "cidade": news.cities.isNotEmpty
                              ? news.cities.join(', ')
                              : '',
                          "categoria": news.categories.isNotEmpty
                              ? news.categories.join(', ')
                              : '',
                          "corpo": news.body,
                          "imgurl": news.urlImages.isNotEmpty
                              ? news.urlImages[0]
                              : '',
                          "autor": news.author,
                          "dataCriacao": news.createdAt.toString(),
                          "type": news.type,
                          "videoUrl": news.videoUrl,
                        },
                      );
                    },
                    onLongPress: () {
                      // Seleciona/deseleciona o card no long press
                      setState(() {
                        if (selectedCardIndex == index) {
                          selectedCardIndex = null;
                        } else {
                          selectedCardIndex = index;
                        }
                      });
                    },
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
                                    _getFormattedDate(
                                        news.createdAt.toString()),
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
            }).toList(),
          ],
        ),
      );
    });
  }

  void hideNewsPopup(String newsId, String status, String userEmail,
      String authorEmail, String type) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            "Excluir $type",
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            "Tem certeza que deseja excluir esta $type?",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "Cancelar",
                style: TextStyle(color: Colors.blue),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Fecha o dialog primeiro

                try {
                  String result = await newsController.hideNews(
                      newsId, status, userEmail, authorEmail, type);

                  // Se foi sucesso, atualiza a lista
                  if (result == "sucess") {
                    setState(() {
                      selectedCardIndex = null; // Remove seleção
                    });
                    newsController
                        .getNewsFromFirebase(); // Recarrega as notícias
                  }

                  // ignore: empty_catches
                } catch (e) {}
              },
              child: const Text(
                "Excluir",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  // Método para mostrar popup de função em desenvolvimento
  void _showDevelopmentPopup(String action) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            action,
            style: const TextStyle(color: Colors.white),
          ),
          content: const Text(
            "Função em desenvolvimento",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "OK",
                style: TextStyle(color: Colors.blue),
              ),
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
