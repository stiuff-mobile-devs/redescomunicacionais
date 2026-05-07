import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:redescomunicacionais/app/modules/news/data/model/news_model.dart';
import 'package:redescomunicacionais/app/modules/news/utils/news_states.dart';

class NewsProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionPath = "news";

Future<void> saveNewsToFirebase(NewsModel news) async {
  try {
    await _firestore
        .collection(collectionPath)
        .doc(news.id) 
        .set(
          news.toMap(), 
          SetOptions(merge: true), 
        );
  } on FirebaseException catch (e) {
    throw Exception("Erro no Firebase (${e.code}): ${e.message}");
  } catch (e) {
    throw Exception("Erro desconhecido ao salvar: $e");
  }
}

 Future<void> saveNewsToHive(NewsModel news) async {
  try {
    // Verifiqua se a box já está aberta para evitar lentidão
    var box = Hive.isBoxOpen(collectionPath) 
        ? Hive.box<NewsModel>(collectionPath) 
        : await Hive.openBox<NewsModel>(collectionPath);

    //  salva ou atualiza se o ID já existir
    await box.put(news.id, news);
    
  } catch (e) {
    throw Exception("Erro ao salvar no Hive local: $e");
  }
}

Future<List<NewsModel>> getNewsFromHive() async {
  try {
    final box = Hive.isBoxOpen(collectionPath)
        ? Hive.box<NewsModel>(collectionPath)
        : await Hive.openBox<NewsModel>(collectionPath);

    List<NewsModel> list = box.values.toList().cast<NewsModel>();

    list.sort((a, b) {
      final dateA = a.lastUpdated ?? a.createdAt;
      final dateB = b.lastUpdated ?? b.createdAt;
      
      // INVERTIDO AQUI: dateA comparando com dateB
      return dateA.compareTo(dateB); 
    });

    return list;
  } catch (e) {
    throw Exception("Erro ao buscar no Hive: $e");
  }
}

  Future<List<NewsModel>> getNewsFromFirebase() async {
  try {
    // Adicionamos o orderBy aqui!
    QuerySnapshot querySnapshot = await _firestore
        .collection(collectionPath)
        .orderBy('createdAt', descending: true) // Ordena por createdAt do mais recente para o mais antigo
        .get();

    return querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return NewsModel.fromMap(data);
    }).toList();
  } catch (e) {
    throw Exception("Erro ao buscar as matérias: $e");
  }
}

  Future<String> hideNews(String newsId, String status, String userEmail) async {
  final now = DateTime.now();
  bool updatedFirebase = false;
  bool updatedHive = false;

  //  Tenta atualizar o Firebase (Pode falhar se estiver offline)
  try {
    await _firestore.collection(collectionPath).doc(newsId).update({
      'status': status,
      'excludedAt': Timestamp.fromDate(now),
      'excludedBy': userEmail,
      'lastUpdated': Timestamp.fromDate(now),
    });
    updatedFirebase = true;
  } catch (e) {
    debugPrint("Firebase falhou no hideNews (provavelmente offline): $e");
  }

  // 2. Tenta atualizar o Hive (Garante que o usuário veja a mudança na hora)
  try {
    if (Hive.isBoxOpen(collectionPath)) {
      var box = Hive.box<NewsModel>(collectionPath);
      var news = box.get(newsId);
      if (news != null) {
        news.status = status;
        news.excludedAt = now;
        news.excludedBy = userEmail;
        news.lastUpdated = now;
        await box.put(newsId, news);
        updatedHive = true;
      }
    }
  } catch (e) {
    debugPrint("Erro crítico ao atualizar Hive local: $e");
  }

  // 3. Lógica de retorno para o Controller
  if (updatedFirebase || updatedHive) {
    // Se pelo menos um funcionou, retornamos sucesso.
    // O seu sistema de sincronização futura cuidará do resto.
    return 'success'; 
  } else {
    return 'error';
  }
}

  Future<void> updateNews(
      String newsId, Map<String, dynamic> updatedData) async {
    try {
      await FirebaseFirestore.instance
          .collection('news')
          .doc(newsId)
          .update(updatedData);
    } catch (e) {
      throw Exception("Erro ao atualizar notícia no Firebase: $e");
    }
  }

 Future<void> reviewNews({
  required String newsId,
  required bool isApproved,
  required String reason,
  required String validator,
  required String validatorName,
  required String newsType,
}) async {
  final now = DateTime.now();
  final isDeleted = newsType == NewsStates.deletado;
  final status = isApproved ? NewsStates.publicado : NewsStates.rejeitado;

  // 1. Montamos o mapa de atualização (Padrão Timestamp para Firebase)
  final Map<String, dynamic> updates = {
    'status': isDeleted ? NewsStates.deletado : status,
    'type': newsType,
    'lastUpdated': Timestamp.fromDate(now),
  };

  if (isApproved) {
    updates['validatedAt'] = Timestamp.fromDate(now);
    updates['validatedObservation'] = reason;
    updates['validatedBy'] = validator;
    updates['validatedByName'] = validatorName;
  } else {
    if (isDeleted) {
      updates['excludedAt'] = Timestamp.fromDate(now);
      updates['excludedBy'] = validator;
      updates['excludedObservation'] = reason;
    } else {
      updates['rejectedAt'] = Timestamp.fromDate(now);
      updates['rejectedBy'] = validator;
      updates['rejectedObservation'] = reason;
    }
  }

  // --- BLOCO 1: FIREBASE ---
  try {
    await _firestore.collection(collectionPath).doc(newsId).update(updates);
  } catch (e) {
    debugPrint("Firebase falhou na revisão (Offline?): $e");
  }

  // --- BLOCO 2: HIVE ---
  try {
    if (Hive.isBoxOpen(collectionPath)) {
      var box = Hive.box<NewsModel>(collectionPath);
      var news = box.get(newsId);
      
      if (news != null) {
        // Atualizamos o objeto local com as mesmas informações
        news.status = updates['status'];
        news.type = updates['type'];
        news.lastUpdated = now;

        if (isApproved) {
          news.validatedAt = now;
          news.validatedObservation = reason;
          news.validatedBy = validator;
          news.validatedByName = validatorName;
        } else {
          if (isDeleted) {
            news.excludedAt = now; // Seguindo seu campo 'excluedAt'
            news.excludedBy = validator;
            news.excludedObservation = reason;
          } else {
            news.rejectedAt = now;
            news.rejectedBy = validator;
            news.rejectedObservation = reason;
          }
        }
        
        await box.put(newsId, news);
      }
    }
  } catch (e) {
    debugPrint("Erro ao atualizar revisão no Hive: $e");
    // Se ambos falharem
    throw Exception("Falha total ao salvar revisão.");
  }
}
  
  Future<void> syncHiveAndFirebase() async {
  try {
    List<NewsModel> firebaseNewsList = await getNewsFromFirebase();
    List<NewsModel> hiveNewsList = await getNewsFromHive();

    Map<String, NewsModel> firebaseMap = {for (var news in firebaseNewsList) news.id: news};
    Map<String, NewsModel> hiveMap = {for (var news in hiveNewsList) news.id: news};

    Set<String> allIds = {...firebaseMap.keys, ...hiveMap.keys};

    for (String id in allIds) {
      // Usando try-catch individual para não travar o loop inteiro se um ID der erro
      try {
        NewsModel? fbNews = firebaseMap[id];
        NewsModel? hiveNews = hiveMap[id];

        if (fbNews != null && hiveNews == null) {
          // Existe apenas no Firebase: baixar para o celular
          await saveNewsToHive(fbNews);
          
        } else if (fbNews == null && hiveNews != null) {
          // Existe apenas no celular: subir para a nuvem
          await saveNewsToFirebase(hiveNews);
          
        } else if (fbNews != null && hiveNews != null) {
          // Existe nos dois: Verificar quem ganha
          
          final fbDate = fbNews.lastUpdated;
          final hiveDate = hiveNews.lastUpdated;

          if (fbDate != null && hiveDate != null) {
            if (fbDate.isAfter(hiveDate)) {
              // Firebase é mais novo -> Atualiza só o Hive
              await saveNewsToHive(fbNews);
            } else if (hiveDate.isAfter(fbDate)) {
              // Hive é mais novo -> Atualiza só o Firebase
              await saveNewsToFirebase(hiveNews);
            }
            // Se forem iguais, não faz nada! Economiza processamento.
            
          } else if (fbDate != null) {
            // Só Firebase tem data -> Atualiza Hive
            await saveNewsToHive(fbNews);
          } else if (hiveDate != null) {
            // Só Hive tem data -> Atualiza Firebase
            await saveNewsToFirebase(hiveNews);
          } else {
            // Nenhum tem data: força o do Firebase como padrão e adiciona data
            NewsModel updatedNews = _copyNewsWithLastUpdated(fbNews);
            await saveNewsToFirebase(updatedNews);
            await saveNewsToHive(updatedNews);
          }
        }
      } catch (e) {
        debugPrint("Erro ao sincronizar a notícia ID $id: $e");
        // Continua para o próximo ID mesmo se este falhar
      }
    }
  } catch (e) {
    throw Exception("Erro fatal ao sincronizar Hive e Firebase: $e");
  }
}

  // Método auxiliar para criar uma cópia de NewsModel com lastUpdated atualizado
 NewsModel _copyNewsWithLastUpdated(NewsModel news) {
    return news.copyWith(lastUpdated: DateTime.now());
  }
}
