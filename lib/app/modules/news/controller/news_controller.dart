import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart' show Colors, debugPrint;
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:redescomunicacionais/app/modules/dashboard/controller/home_controller.dart';
import 'package:redescomunicacionais/app/modules/news/data/model/news_model.dart';
import 'package:redescomunicacionais/app/modules/news/data/repository/news_repository.dart';
import 'package:redescomunicacionais/app/modules/news/utils/news_states.dart';
import 'package:redescomunicacionais/app/modules/user/controller/user_controller.dart';
import 'package:redescomunicacionais/app/modules/user/data/model/user_model.dart';
import 'package:redescomunicacionais/app/routes/app_routes.dart';

class NewsController extends GetxController {
  final NewsRepository _repository = NewsRepository();
  late UserController userController;
  late UserModel user;

  HomeController get homeController => Get.find<HomeController>();

  var newss = <NewsModel>[].obs;
  RxBool isLoading = false.obs;
  RxnInt selectedCardIndex = RxnInt();

  @override
  onInit() async {
    super.onInit();
    userController = Get.find<UserController>();
    user = await userController.getCurrentUser() ?? UserModel.empty();
    await syncHiveAndFirebase();
    getNewsFromHive();
  }

  // Add news - save to both Hive and Firebase
  Future<void> addNews(
    String title,
    String subtitle,
    List<String> cities,
    List<String> categories,
    String body,
    List<String> urlImages,
    String author,
    String email,
    String createdAt,
    String type,
    String status,
    String videoUrl,
  ) async {
    try {
      isLoading(true);
      NewsModel news = NewsModel(
        id: DateTime.now().toIso8601String(),
        title: title,
        subtitle: subtitle,
        cities: cities,
        categories: categories,
        body: body,
        urlImages: urlImages,
        author: author,
        createdBy: email,
        createdAt: DateTime.now(),
        type: type,
        status: status,
        validatedBy: null,
        validatedAt: null,
        editedBy: null,
        editedAt: null,
        excluedBy: null,
        excluedAt: null,
        editedObservation: null,
        validatedObservation: null,
        excludedObservation: null,
        videoUrl: videoUrl,
      );

      try {
        await _repository.saveNewsToHive(news);
      } catch (e) {
        debugPrint("Erro ao salvar notícia no Hive: $e");
      }

      try {
        await _repository.saveNewsToFirebase(news);
      } catch (e) {
        debugPrint("Erro ao salvar notícia no Firebase: $e");
      }

      newss.insert(0, news);
    } catch (e) {
      rethrow;
    } finally {
      isLoading(false);
    }
  }

  // Get news from Firebase only
  Future<void> getNewsFromFirebase() async {
    try {
      isLoading(true);
      newss.value = await _repository.getNewsFromFirebase();
      newss.sort((a, b) => DateTime.parse(b.createdAt.toString())
          .compareTo(DateTime.parse(a.createdAt.toString())));
    } catch (e) {
      /*Get.snackbar('Erro', 'Não foi possível carregar as notícias.',
          snackPosition: SnackPosition.BOTTOM);*/
    } finally {
      isLoading(false);
    }
  }

  // Get news from Hive only
  Future<void> getNewsFromHive() async {
    try {
      isLoading(true);
      newss.value = await _repository.getNewsFromHive();
      newss.sort((a, b) => DateTime.parse(b.createdAt.toString())
          .compareTo(DateTime.parse(a.createdAt.toString())));
    } catch (e) {
      debugPrint("Erro ao carregar as notícias do Hive: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<String> hideNews(String newsId, String status, String userEmail,
      String authorEmail, String type) async {
    if (userEmail == authorEmail) {
      String result = "";
      try {
        isLoading(true);

        result = await _repository.hideNews(newsId, status, userEmail);

        if (result == "success") {
          newss.removeWhere(
              (news) => news.id == newsId); // Remove da lista local (interface)
          Get.snackbar(
            'Sucesso',
            '$type excluída com sucesso!',
            snackPosition: SnackPosition.BOTTOM,
            colorText: Colors.white,
            backgroundColor: Colors.green,
          );
        }
      } catch (e) {
        Get.snackbar(
          'Erro',
          'Não foi possível excluir essa $type.',
          snackPosition: SnackPosition.BOTTOM,
          colorText: Colors.white,
          backgroundColor: Colors.red,
        );
      } finally {
        isLoading(false);
      }
      return result;
    } else {
      Get.snackbar(
        'Erro',
        'Você não tem permissão para excluir esta $type.',
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.white,
        backgroundColor: Colors.red,
      );
      return "Você não tem permissão para excluir esta $type.";
    }
  }

  List<dynamic> getValidNews() {
    return newss.where((news) {
      if (news.status != NewsStates.publicado) return false;
      try {
        if (news.urlImages[0] != "") {
          base64Decode(news.urlImages[0]);
        }
        return true;
      } catch (_) {
        return false;
      }
    }).toList();
  }

  List<dynamic> getInAnalysis() {
    return newss.where((news) {
      if (news.status != NewsStates.emAnalise) return false;
      try {
        if (news.urlImages[0] != "") {
          base64Decode(news.urlImages[0]);
        }
        return true;
      } catch (_) {
        return false;
      }
    }).toList();
  }

  // Prepara o map de argumentos usado nas rotas de detalhe
  Map<String, dynamic> toNewsArguments(NewsModel news) {
    return {
      "titulo": news.title,
      "subtitulo": news.subtitle,
      "cidade": news.cities.isNotEmpty ? news.cities.join(', ') : '',
      "categoria": news.categories.isNotEmpty ? news.categories.join(', ') : '',
      "corpo": news.body,
      "imgurl": news.urlImages.isNotEmpty ? news.urlImages[0] : '',
      "autor": news.author,
      "dataCriacao": news.createdAt.toString(),
      "type": news.type,
      "videoUrl": news.videoUrl,
      "validatedBy": news.validatedBy ?? '',
      "validatedByName": news.validatedByName ?? '',
    };
  }

  // Abre a página de detalhe
  void openNews(NewsModel news) {
    Get.toNamed(Routes.NEWS_PAGE, arguments: toNewsArguments(news));
  }

  // Abre a página de edição (usada quando o usuário pode editar)
  void openEditNews(NewsModel news) {
    Get.toNamed(Routes.EDIT_NEWS, arguments: {
      "newsId": news.id,
      "titulo": news.title,
      "subtitulo": news.subtitle,
      "cidade": news.cities,
      "categoria": news.categories,
      "corpo": news.body,
      "imgurl": news.urlImages.isNotEmpty ? news.urlImages[0] : '',
      "autor": news.author,
      "dataCriacao": news.createdAt.toString(),
      "type": news.type,
      "status": news.status,
    });
  }

  // Verifica se o usuário atual é o autor (p/ habilitar editar/excluir)
  bool canEdit(NewsModel news) {
    return user.email == news.createdBy;
  }

  // Controla seleção de cards (toggle)
  void toggleSelected(int index) {
    if (selectedCardIndex.value == index) {
      selectedCardIndex.value = null;
    } else {
      selectedCardIndex.value = index;
    }
  }

  bool isSelected(int index) => selectedCardIndex.value == index;

  /// Sincroniza Hive <-> Firebase
  Future<void> syncHiveAndFirebase() async {
    try {
      isLoading(true);

      // Busca dados
      final List<NewsModel> firebaseList =
          await _repository.getNewsFromFirebase();
      final List<NewsModel> hiveList = await _repository.getNewsFromHive();

      // Cria maps para acesso rápido por ID
      final Map<String, NewsModel> fbMap = {
        for (var n in firebaseList) n.id: n,
      };
      final Map<String, NewsModel> hiveMap = {
        for (var n in hiveList) n.id: n,
      };

      final Set<String> allIds = {...fbMap.keys, ...hiveMap.keys};

      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final WriteBatch batch = firestore.batch();
      final CollectionReference collRef = firestore.collection('news');

      var hiveBox = await Hive.openBox<NewsModel>('news');

      for (final id in allIds) {
        final fb = fbMap[id];
        final hv = hiveMap[id];

        if (fb != null && hv == null) {
          // existe só no firebase -> salva no Hive
          try {
            await hiveBox.put(id, fb);
          } catch (e) {
            debugPrint("Erro ao salvar no Hive (from Firebase): $e");
          }
        } else if (hv != null && fb == null) {
          // existe só no hive -> envia para Firebase (batch)
          final docRef = collRef.doc(id);
          batch.set(docRef, hv.toMap());
        } else if (fb != null && hv != null) {
          // existe nos dois -> comparar última modificação
          final DateTime? fbLast = _lastModifiedFromModel(fb);
          final DateTime? hvLast = _lastModifiedFromModel(hv);

          if ((hvLast ?? DateTime.fromMillisecondsSinceEpoch(0))
              .isAfter(fbLast ?? DateTime.fromMillisecondsSinceEpoch(0))) {
            // Hive mais novo -> envia para Firebase
            final docRef = collRef.doc(id);
            batch.set(docRef, hv.toMap());
          } else if ((fbLast ?? DateTime.fromMillisecondsSinceEpoch(0))
              .isAfter(hvLast ?? DateTime.fromMillisecondsSinceEpoch(0))) {
            // Firebase mais novo -> atualiza Hive
            try {
              await hiveBox.put(id, fb);
            } catch (e) {
              debugPrint("Erro ao atualizar Hive (from Firebase): $e");
            }
          } // se iguais, nada a fazer
        }
      }

      // Commit batch se houver operações
      try {
        await batch.commit();
      } catch (e) {
        debugPrint("Erro ao commitar batch no Firestore: $e");
      }

      // Atualiza lista local do controller com os dados mais recentes (re-fetch do Hive)
      try {
        newss.value = await _repository.getNewsFromHive();
        newss.sort((a, b) => DateTime.parse(b.createdAt.toString())
            .compareTo(DateTime.parse(a.createdAt.toString())));
      } catch (e) {
        debugPrint("Erro ao recarregar notícias após sync: $e");
      }
    } catch (e) {
      debugPrint("Erro na sincronização: $e");
    } finally {
      isLoading(false);
    }
  }

  // helper para extrair última modificação de um NewsModel
  DateTime? _lastModifiedFromModel(NewsModel n) {
    DateTime? parseDynamic(dynamic d) {
      if (d == null) return null;
      if (d is DateTime) return d;
      if (d is String) {
        try {
          return DateTime.tryParse(d);
        } catch (_) {
          return null;
        }
      }
      return null;
    }

    final List<DateTime?> candidates = [
      parseDynamic(n.createdAt),
      parseDynamic(n.editedAt),
      parseDynamic(n.validatedAt),
      parseDynamic(n.excluedAt),
    ];
    candidates.removeWhere((c) => c == null);
    if (candidates.isEmpty) return null;
    candidates.sort((a, b) => a!.compareTo(b!));
    return candidates.last;
  }

  // Mapeamento city -> asset path (adicione as imagens em assets/ e registre no pubspec.yaml)
  final Map<String, String> _cityImageAssets = {
    'São Sebastião do Alto': 'assets/images/cidades/saosebastiaodoalto.jpg',
    'Macuco': 'assets/images/cidades/macuco.jpg',
    'Rio das Flores': 'assets/images/cidades/riodasflores.jpg',
    'Comendador Levy Gasparian': 'assets/images/cidades/levygasparian.jpg',
    'Laje do Muriaé': 'assets/images/cidades/lajedomuriae.jpg',
    'São José de Ubá': 'assets/images/cidades/saojosedeuba.jpg',
    // add more or a 'default' entry
    'default': 'assets/images/default_city.jpg',
  };

  // Retorna o path do asset JPG para a cidade dada
  String getCityImageAsset(String? city) {
    final key = (city == null || city.isEmpty) ? 'default' : city;
    return _cityImageAssets[key] ?? _cityImageAssets['default']!;
  }

  reviewNews(String newsId, bool isApproved, String reason, String validator,
      String creator, String validatorName) async {
    try {
      isLoading(true);
      if (validator == creator) {
        Get.snackbar(
          'Erro',
          'Você não pode revisar sua própria matéria.',
          snackPosition: SnackPosition.BOTTOM,
          colorText: Colors.white,
          backgroundColor: Colors.red,
        );
        return;
      }
      await _repository.reviewNews(
          newsId, isApproved, reason, validator, validatorName);
      // Atualiza lista local
      await getNewsFromFirebase();
      homeController.forceRecreate();
      Get.snackbar(
        'Sucesso',
        isApproved
            ? 'Matéria aprovada com sucesso!'
            : 'Matéria rejeitada com sucesso!',
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.white,
        backgroundColor: Colors.green,
      );
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Não foi possível revisar a matéria.',
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.white,
        backgroundColor: Colors.red,
      );
    } finally {
      isLoading(false);
    }
  }
}
