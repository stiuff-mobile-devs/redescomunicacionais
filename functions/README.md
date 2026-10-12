# Documentação de Endpoints

Este documento detalha todos os endpoints disponíveis no backend (**Firebase Functions v2**).

---

## Visão Geral da Configuração no Flutter

Todas as funções do tipo **Callable (`onCall`)** no Flutter são executadas utilizando o pacote `cloud_functions`. A instância deve sempre apontar para a região configurada no backend:

```dart
import 'package:cloud_functions/cloud_functions.dart';

final FirebaseFunctions functions = FirebaseFunctions.instanceFor(
  region: 'southamerica-east1',
);
```

---

## 1. `healthCheck`

Verifica a disponibilidade e saúde operacional do serviço de Cloud Functions.

* **Tipo:** HTTP REST (`onRequest`)
* **Método:** `GET` / `POST`
* **URL:** `https://southamerica-east1-redescomunicacionais.cloudfunctions.net/healthCheck`
* **Autenticação:** Pública (não requer autenticação nem token)

### Dados de Entrada
Nenhum parâmetro necessário.

### O que faz
Retorna um status HTTP 200 confirmando que as Cloud Functions estão online e respondendo adequadamente.

### Resposta (Response)
* **Status HTTP:** `200 OK`
* **Corpo (JSON):**
```json
{
  "status": "ok",
  "message": "Service is running"
}
```

### Como chamar no Flutter
Como é um endpoint HTTP REST padrão, pode ser chamado utilizando o pacote `http`:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<bool> checkBackendHealth() async {
  final url = Uri.parse(
    'https://southamerica-east1-redescomunicacionais.cloudfunctions.net/healthCheck',
  );

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    print("Status: ${data['status']}"); // "ok"
    return true;
  }
  return false;
}
```

---

## 2. `savePublicKey`

Registra ou rotaciona a chave pública RSA de um usuário, associando-a ao seu e-mail e mantendo o histórico de chaves antigas.

* **Tipo:** Callable (`onCall`)
* **Nome da Função:** `savePublicKey`
* **Autenticação:** Obrigatória. O usuário precisa estar autenticado no Firebase Auth e o e-mail no payload deve coincidir com o e-mail do usuário logado.

### Dados de Entrada (Payload)
Objeto JSON (ou Map no Dart) com as seguintes propriedades:

| Campo | Tipo | Obrigatório | Descrição |
| :--- | :--- |:------------| :--- |
| `id` | `String` | Sim         | Identificador da chave (geralmente o e-mail do remetente) |
| `email` | `String` | Sim         | E-mail do proprietário da chave (deve ser igual ao do usuário autenticado) |
| `publicKey` | `String` | Sim         | Chave pública no formato PEM |
| `cities` | `List<String>` | Não         | Lista de cidades atendidas/associadas pelo usuário |
| `createdAt` | `String` | Sim         | Data de criação em formato ISO 8601 |
| `lastUpdated` | `String` | Sim         | Data da última atualização em formato ISO 8601 |

### O que faz
1. Valida se a requisição possui usuário logado (`request.auth`).
2. Valida se o `email` da chave informada pertence ao usuário logado (`loggedUser.email == data.email`).
3. Busca se já existe uma chave cadastrada para esse e-mail na coleção `public_keys/{email}`.
4. Se já existir uma chave anterior, move a chave antiga para o array `oldPublicKeys` (histórico de rotação).
5. Grava a nova chave e atualiza a coleção `public_keys` no Firestore com `{ merge: true }`.

### Resposta (Response)
```json
{
  "message": "Public key saved successfully."
}
```

### Como chamar no Flutter
```dart
import 'package:cloud_functions/cloud_functions.dart';

Future<void> registerPublicKey({
  required String userEmail,
  required String pemPublicKey,
  List<String> cities = const [],
}) async {
  try {
    final functions = FirebaseFunctions.instanceFor(region: 'southamerica-east1');
    final callable = functions.httpsCallable('savePublicKey');

    final payload = {
      'id': userEmail,
      'email': userEmail,
      'publicKey': pemPublicKey,
      'cities': cities,
      'createdAt': DateTime.now().toIso8601String(),
      'lastUpdated': DateTime.now().toIso8601String(),
    };

    final result = await callable.call(payload);
  } on FirebaseFunctionsException catch (e) {
    debugPrint("Erro [${e.code}]: ${e.message}");
  }
}
```

---

## 3. `getPublicKeysPackage`

Retorna um pacote assinado digitalmente pelo servidor contendo **todas as chaves públicas** cadastradas no sistema. Esse pacote é utilizado pela rede mesh para verificar assinaturas offline de notícias.

* **Tipo:** Callable (`onCall`)
* **Nome da Função:** `getPublicKeysPackage`
* **Autenticação:** Pública (não requer autenticação nem token)
* **Segurança:** Utiliza o segredo interno `API_PRIVATE_KEY` para assinar o pacote.

### Dados de Entrada (Payload)
Nenhum dado é necessário. Pode ser enviado vazio `{}`.

### O que faz
1. Lê a chave privada do servidor através do Google Cloud Secret Manager (`API_PRIVATE_KEY`).
2. Busca todas as chaves públicas cadastradas na coleção `public_keys` do Firestore.
3. Gera uma assinatura digital criptográfica de todo o lote de chaves.
4. Retorna o pacote contendo a lista de chaves, carimbo de data/hora e a assinatura digital do servidor.

### Resposta (Response)
```json
{
  "publicKeys": [
    {
      "id": "editor@email.com",
      "email": "editor@email.com",
      "publicKey": "-----BEGIN PUBLIC KEY-----\n...",
      "cities": ["cidade-a", "cidade-b"],
      "oldPublicKeys": [
        "-----BEGIN PUBLIC KEY-----\n...",
        "-----BEGIN PUBLIC KEY-----\n..."
      ],
      "createdAt": "2026-01-01T10:00:00.000Z",
      "lastUpdated": "2026-01-01T10:00:00.000Z"
    },
    {
      ...
    }
  ],
  "sender": "INTERNAL_API",
  "timestamp": "2026-10-12T12:00:00.000Z",
  "signature": "MEQCIE3yB9..."
}
```

### Como chamar no Flutter
```dart
import 'package:cloud_functions/cloud_functions.dart';

Future<Map<String, dynamic>?> fetchPublicKeysPackage() async {
  try {
    final functions = FirebaseFunctions.instanceFor(region: 'southamerica-east1');
    final callable = functions.httpsCallable('getPublicKeysPackage');

    final result = await callable.call();
    
    final Map<String, dynamic> package = Map<String, dynamic>.from(result.data);
    print("Total de chaves recebidas: ${(package['publicKeys'] as List).length}");
    print("Assinatura do pacote: ${package['signature']}");
    
    return package;
  } on FirebaseFunctionsException catch (e) {
    print("Erro ao buscar pacote de chaves: ${e.code} - ${e.message}");
    return null;
  }
}
```

---

## 4. `uploadNewsPackage`

Recebe um pacote de notícia assinado digitalmente, valida sua autenticidade criptográfica contra a chave pública do autor/editor e persiste a notícia e o pacote no Firestore.

* **Tipo:** Callable (`onCall`)
* **Nome da Função:** `uploadNewsPackage`
* **Autenticação:** Obrigatória. O usuário precisa estar autenticado no Firebase Auth e ser um editor. O pacote deve conter uma assinatura válida correspondente à chave pública do `sender`.

### Dados de Entrada (Payload)
Objeto com a estrutura de um `NewsPackage`:

```json
{
  "id": "uuid-do-pacote",
  "sender": "autor@email.com",
  "signature": "assinatura-rsa-base64",
  "isUploaded": false,
  "lastUpdated": "2026-10-12T10:00:00.000Z",
  "news": {
    "id": "uuid-da-noticia",
    "title": "Título da Notícia",
    "subtitle": "Subtítulo opcional",
    "body": "Conteúdo textual da notícia...",
    "cities": ["cidade-1"],
    "categories": ["geral"],
    "urlImages": ["https://.../foto.jpg"],
    "videoUrl": null,
    "type": "noticia",
    "status": "publicado",
    "author": "Nome do Autor",
    "createdBy": "autor@email.com",
    "createdAt": "2026-10-12T09:00:00.000Z",
    "lastUpdated": "2026-10-12T10:00:00.000Z"
  }
}
```

### O que faz
1. Busca a chave pública do remetente (`sender`) na coleção `public_keys`.
2. Verifica se a assinatura digital (`signature`) confere com os dados da notícia utilizando a chave pública atual do remetente.
3. Se a chave atual falhar, tenta validar contra as chaves antigas (`oldPublicKeys`) do histórico.
4. Se a assinatura for inválida, lança erro `permission-denied: Invalid news package signature`.
5. Se for válida, marca `isUploaded = true`.
6. **Primeiro**: salva ou atualiza a notícia na coleção raiz `news/{news.id}` (`merge: true`).
7. **Em seguida**: salva o pacote assinado na subcoleção `news/{news.id}/packages/{package.id}` (`merge: true`).

### Resposta (Response)
```json
{
  "message": "News package successfully synced."
}
```

### Como chamar no Flutter
```dart
import 'package:cloud_functions/cloud_functions.dart';

Future<void> sendNewsPackage(Map<String, dynamic> newsPackageMap) async {
  try {
    final functions = FirebaseFunctions.instanceFor(region: 'southamerica-east1');
    final callable = functions.httpsCallable('uploadNewsPackage');

    final result = await callable.call(newsPackageMap);
    print("Sucesso: ${result.data['message']}");
  } on FirebaseFunctionsException catch (e) {
    if (e.code == 'permission-denied') {
      print("Assinatura digital do pacote inválida!");
    } else {
      print("Erro ao sincronizar notícia: ${e.code} - ${e.message}");
    }
  }
}
```

---

## 5. `setUserRole`

Altera o papel de acesso (`role`) de um usuário para `user`, `editor` ou `admin`. Esta ação altera imediatamente as **Custom Claims** do Firebase Auth e o documento do usuário no Firestore.

* **Tipo:** Callable (`onCall`)
* **Nome da Função:** `setUserRole`
* **Autenticação:** **Apenas Administradores**. O usuário que faz a chamada precisa ter a claim `role: 'admin'`.

### Dados de Entrada (Payload)

| Campo | Tipo | Obrigatório | Valores Aceitos | Descrição |
| :--- | :--- | :--- | :--- | :--- |
| `targetUid` | `String` | Sim | String não vazia | UID do usuário no Firebase Auth |
| `role` | `String` | Sim | `'user'`, `'editor'`, `'admin'` | Novo papel a ser concedido |
| `operationsCities` | `Map<String, String>` | Não | Objeto chave/valor | Mapa de cidades de atuação (código -> nome da cidade) |

Exemplo de JSON:
```json
{
  "targetUid": "u7d8K2j9L1s0...",
  "role": "editor",
  "operationsCities": {
    "1": "São Sebastião do Alto"
  }
}
```

### O que faz
1. Valida se o usuário que chamou a função está autenticado.
2. Valida se o solicitante possui permissão de `admin` via Custom Claims do token (através de `getAdminUser`). Se não for admin, lança `permission-denied`.
3. Valida se `targetUid` e `role` são válidos.
4. Atualiza as **Custom Claims** do usuário de destino via Firebase Admin SDK (`setCustomUserClaims`).
5. Atualiza o papel, as cidades de atuação (`operationsCities`, se informadas) e os metadados de auditoria (`roleUpdatedAt`, `roleUpdatedBy`, `lastUpdated`) no documento do usuário em `users/{targetUid}`.

### Resposta (Response)
```json
{
  "message": "User role successfully updated to 'editor'."
}
```

### Como chamar no Flutter
```dart
import 'package:cloud_functions/cloud_functions.dart';

Future<void> changeRole({
  required String targetUserId,
  required String newRole, // 'user', 'editor', ou 'admin'
  Map<String, String>? operationsCities,
}) async {
  try {
    final functions = FirebaseFunctions.instanceFor(region: 'southamerica-east1');
    final callable = functions.httpsCallable('setUserRole');

    final Map<String, dynamic> payload = {
      'targetUid': targetUserId,
      'role': newRole,
    };

    if (operationsCities != null) {
      payload['operationsCities'] = operationsCities;
    }

    final result = await callable.call(payload);

    print("Sucesso: ${result.data['message']}");
  } on FirebaseFunctionsException catch (e) {
    if (e.code == 'permission-denied') {
      print("Acesso negado: Você não é administrador.");
    } else {
      print("Erro [${e.code}]: ${e.message}");
    }
  }
}
```

---

## Tabela Resumo dos Endpoints

| Endpoint | Tipo | Autenticação Requerida | Papel Mínimo            | Entrada Principal | Resposta Principal |
| :--- | :--- |:-----------------------|:------------------------| :--- | :--- |
| `healthCheck` | `onRequest` | Nenhuma                | Público                 | Nenhuma | `{ status: "ok" }` |
| `savePublicKey` | `onCall` | Sim                    | Qualquer usuário logado | Dados da chave pública (`PublicKey`) | `{ message: "Public key saved successfully." }` |
| `getPublicKeysPackage` | `onCall` | Não                    | Público                 | Vazio | `{ publicKeys: [...], signature: "..." }` |
| `uploadNewsPackage` | `onCall` | Sim                    | Editor                  | Pacote de notícia (`NewsPackage`) | `{ message: "News package successfully synced." }` |
| `setUserRole` | `onCall` | Sim                    | Admin                   | `{ targetUid, role, operationsCities? }` | `{ message: "User role successfully updated to '...'" }` |
