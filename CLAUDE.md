# CLAUDE.md

Responda sempre em **português (PT-BR)**.

## Visão geral

**Redes Comunicacionais Locais (RCL)** — app Flutter (Android, iOS e Web) para produção e circulação colaborativa de notícias locais em cidades com menos de 10 mil habitantes no interior do RJ, onde a internet é instável. Projeto de TCC (UFF).

As notícias são assinadas digitalmente (RSA) e circulam offline entre dispositivos por uma rede mesh epidêmica (Nearby Connections), além de serem sincronizadas com o Firebase quando há internet. **Assuma sempre que o dispositivo pode estar offline.**

- Flutter (sempre na última versão estável) / Dart `^3.5.4` / Java 21, gerência de estado e rotas com **GetX** ([padrão GetX Pattern](https://kauemurakami.github.io/getx_pattern/))
- Firebase: Auth (Google e Apple), Firestore, Storage, Remote Config, Cloud Functions
- Persistência local: **Hive** (modelos), **GetStorage** (preferências simples) e **flutter_secure_storage** (chave privada)
- Backend: `functions/` — Firebase Functions v2 em **TypeScript** (Node 22), região `southamerica-east1`
- Repositório: https://github.com/Redes-Comunicacionais-Locais/redescomunicacionais

## Comandos

```bash
flutter pub get
flutter analyze
flutter run
dart run build_runner build --delete-conflicting-outputs   # regenera os *.g.dart do Hive

# Cloud Functions
cd functions && npm run build        # tsc
cd functions && npm run serve        # emulador local
```

## Arquitetura do app (`lib/app/`)

```
config/      constantes de configuração (secrets.dart)
data/        bindings compartilhados
routes/      app_routes.dart (nomes) + app_pages.dart (GetPage + bindings)
services/    serviços globais (Hive, localização, atualização, release notes...)
modules/     uma pasta por funcionalidade
modules/utils/   módulo de utilitários compartilhados (não é uma tela)
```

`modules/utils/` reúne tudo o que é reutilizável (não crie mais pastas `utils` dentro dos outros módulos):

- `popups/` — `AppPopups` (snackbars, diálogos, bottom sheets, carregamento)
- `app_bar/` — `AppBars` (AppBar padrão com degradê) e `AppTone` (tom de cor de cada tela)
- `translations/` — `LocaleKeys`, dicionários e `AppTranslation`
- `theme/`, `components/`, `widgets/`, `responsive_utils.dart`
- `news/` (categorias, tipos, status, cidades, `NewsLabels`, `NewsListMode`), `user/` (`UserRoles`), `dashboard/` (`menu_drawer`)

Cada módulo em `modules/<nome>/` segue o padrão:

- `bindings/` — `Bindings` que registram controllers/repositórios com `Get.lazyPut`/`Get.put`
- `controller/` — `GetxController` com estado reativo (`.obs`, `Obx`)
- `ui/` — páginas e widgets
- `data/model`, `data/provider`, `data/repository` — quando o módulo acessa dados (provider fala com Firebase/Functions, repository orquestra)

Ao criar uma tela nova: adicionar a constante em `Routes`, registrar o `GetPage` com seu binding em `AppPages` e navegar com `Get.toNamed(Routes.X)`.

## Regras de negócio das matérias

**Papéis** (`role`): `admin`, `editor`, `user` (+ `guest` no app). Hoje são lidos da **coleção `roles` do Firestore** (não de custom claims); veja "Usuários e papéis no Firestore". Constantes em `modules/utils/user/userRoles.dart`; validação no backend em `functions/src/service/auth.service.ts`. Editor/admin criam, submetem, aprovam, rejeitam e excluem matérias.

**Ciclo de vida** (confira os nomes exatos dos status no `NewsModel`):

| Ação | Status resultante | Efeitos |
|---|---|---|
| Salvar rascunho | Rascunho | Só no Hive. **Não** gera pacote, não vai para a API nem para a mesh |
| Enviar para revisão | Em revisão | Assina, cria `NewsPackageModel` com `isUploaded = false` |
| Aceitar | Aprovado | Atualiza `lastUpdated`, reassina, entra na sincronização |
| Rejeitar | Rejeitado | Atualiza `lastUpdated`, reassina, entra na sincronização |
| Excluir | Deletado (**soft delete**) | Nunca apagar fisicamente: o status precisa se propagar pela mesh |
| Editar matéria já submetida | Volta obrigatoriamente para Em revisão | Novo `lastUpdated`, reassina, `isUploaded = false` |

Regra geral: **toda alteração de conteúdo/status exige novo `lastUpdated` e nova assinatura**, senão a mudança não vence nos outros aparelhos.

**Pacote de matéria** (`NewsPackageModel`): `id` (UUID), `news` (NewsModel, imagens em Base64), `signature`, `email` (assinador), `lastUpdated`, `isUploaded`.

**Sincronização híbrida** (todas as ações, exceto rascunho):
- Mesh: o pacote fica sempre disponível para o `NearbyService`, online ou offline.
- Nuvem: se online, envia à API (`uploadNewsPackage`), que valida a assinatura e faz merge na coleção `news`; com sucesso, marca `isUploaded = true` no Hive. Se offline, mantém `isUploaded = false`.
- Conflitos: **Last Write Wins** pelo `lastUpdated`.
- Ações que **exigem internet**: aprovar, rejeitar, excluir, alterar matéria em análise e gerar par de chaves. Rascunhos funcionam offline.

**Feed de notícias publicadas:** paginação em lotes de **10** (carga inicial, "carregar mais" e pull-to-refresh), com cache no Hive.

**Central da matéria e filtros da Home:** as listas (em revisão, rascunhos, rejeitadas, excluídas) **reutilizam a Home**, só trocando o filtro `NewsListMode` (`modules/utils/news/news_list_mode.dart`, que define título, ícone e tom de cada modo).
- O feed público é a Home normal (`NewsListMode.published`), **sem** controles de modo.
- A central abre uma **segunda Home empilhada** com `Get.toNamed(Routes.HOME, arguments: {'editorial': true}, preventDuplicates: false)`, e o modo fica em `HomeController.editorialMode`. A `HomePage` lê o argumento pela própria rota (`ModalRoute.of(context)`), então a Home do feed nunca muda de modo.
- Na Home editorial: seta de voltar (volta à central), chips para trocar de filtro e nada de drawer, busca ou FAB. O `NewsWidgets` recebe o modo por parâmetro (`mode`); não use flags globais.

## Segurança e chaves (`modules/mesh/services/keys_service.dart`)

- RSA 2048 com pointycastle (`FortunaRandom`), assinatura RSA + SHA-256 em Base64 (`toSign`/`toCheck`). PEM com cabeçalhos próprios `NEIGHBOR_NEWS`; `importPublicKey` rejeita chaves sem esse cabeçalho.
- **Chave privada**: só no `flutter_secure_storage`. Nunca logar, enviar à rede, salvar no Hive/GetStorage ou incluir em pacotes.
- **Geração só online**: ao logar, se não há chave privada, gera o par apenas com acesso à API. A privada só é persistida **depois** que a pública for registrada com sucesso (`savePublicKey`).
- **Rotação**: a chave antiga vai para `oldPublicKeys`. A verificação de matérias deve testar a chave ativa **e** as antigas. `revocationInfo` invalida chaves comprometidas.
- **Autoridade certificadora**: a API assina o `PublicKeyPackage` com sua chave privada (só no backend). A chave pública da API é embutida no app; todo pacote de chaves recebido pela mesh é validado com ela, e o `timestamp` do pacote impede replay (sempre fica o mais recente).
- Chaves públicas são registradas via API, nunca escritas direto no Firestore.

## Mesh (`modules/mesh/services/nearby_service.dart`)

`NearbyService` é um `GetxService` (vive fora da UI) usando `nearby_connections` com estratégia `P2P_CLUSTER`.

- `startEpidemicMesh` pede permissões (Bluetooth, localização) e ativa anúncio + descoberta; conexões são aceitas automaticamente e são simétricas.
- **Handshake**: troca apenas metadados (IDs + `lastUpdated` das notícias e timestamp do pacote de chaves). Só depois pede/envia o que falta ou o que está desatualizado (LWW).
- **Transporte**: payload de bytes para mensagens pequenas (**limite de 32 KB**); matérias completas (até ~1 MB com imagens) e pacotes de chaves vão como **arquivo temporário**, que deve ser apagado após a leitura.
- `_processIncomingJson` trata: handshake, pedidos de matéria/chaves, recebimento de matéria e recebimento de chaves.
- Matéria com assinatura inválida/desconhecida: **não é exibida**, mas o pacote bruto é salvo e continua sendo repassado (nó de retransmissão).
- Alterações no formato dos pacotes precisam ser compatíveis entre app e Functions (`functions/src/model/`) e com versões antigas do app em circulação na mesh.

**Ainda não implementado** (não presuma que existe; só implemente se pedido): worker em segundo plano para reenviar pacotes com `isUploaded = false`, restrição de editor por `cities` e flag "Importância da Imagem" (prioridade de envio de imagens na mesh — regra ainda em discussão).

## Firebase e API

**Princípio de arquitetura: o app conversa só com as Cloud Functions, e só as Functions conversam com o Firebase (Firestore/Storage).**
- Toda leitura/escrita de dados nova deve ser feita por um endpoint em `functions/src/`, nunca com `FirebaseFirestore`/`FirebaseStorage` direto no app. O app usa o Firebase apenas para autenticação (Firebase Auth) e para chamar as Functions.
- Ao alterar um fluxo que ainda acessa o Firestore direto no app, migre-o para uma Function em vez de ampliar o acesso direto.
- **Ainda falta migrar** (acesso direto ao Firestore no app hoje): em `user_provider.dart`, `public_keys`; em `news_provider.dart`, leitura de notícias; e `release_notes_service.dart` (`app_updates`).

- **Cloud Functions** (`functions/src/`): `controller/` (endpoints `onCall`/`onRequest`), `service/`, `repository/` e `model/`. Endpoints: `healthCheck`, `savePublicKey`, `getPublicKeysPackage`, `uploadNewsPackage`, `setUserRole`, `syncUserProfile`, `updateUserProfile`, `deleteUserAccount`, `listUsers`. Documentação completa em [functions/README.md](functions/README.md) — mantenha-a atualizada ao alterar/criar endpoints.
- No Flutter, chamar as functions sempre com `FirebaseFunctions.instanceFor(region: 'southamerica-east1')`. As chamadas ficam nos providers/serviços (`news_provider.dart`, `user_provider.dart`, `mesh/services/package_service.dart`).

### Usuários e papéis no Firestore

**Estado atual (produção):** duas coleções com o mesmo ID (o `uid` do Firebase Auth):
- `users/{uid}`: dados pessoais. Leitura/escrita pelo próprio usuário ou por admin.
- `roles/{uid}`: campo `role`. Leitura pelo próprio usuário; criação/alteração só por admin; exclusão pelo próprio usuário ou admin.
- As regras usam `getRole()`, que lê `roles/{uid}`, para liberar escrita em `news`, `news_test` e `public_keys`.

**Em teste: coleção unificada `users_v2/{uid}`** (mesmos campos do `UserModel`, via `toFirebase()`). Coexiste com `users` e `roles`, que **não devem ser alteradas nem removidas** durante o teste.
- **Gravação dupla (só nas Functions)**: o app não acessa `users`, `roles` nem `users_v2`; tudo passa pelas Functions, que **leem de `users` e `roles`** e gravam cada alteração também em `users_v2`, na mesma transação/batch.
  - `syncUserProfile` (login): cria `users` + `users_v2` para usuário novo (`role: 'user'`) e cria `users_v2` para usuário antigo copiando de `users` + `roles` (papel real). Sem API, o app usa o usuário do Hive.
  - `updateUserProfile`: grava só `name`, `urlImage`, `selectedAppCity` nas duas coleções.
  - `deleteUserAccount`: apaga `users`, `roles` e `users_v2` e a conta no Auth.
  - `setUserRole`: grava `users`, `roles` e `users_v2`. `listUsers`: lê `users` (só admin, verificado em `roles`).
- A validação de admin **nas Functions**: `setUserRole` usa a custom claim `token.role` (`getAdminUser`); `listUsers` usa a coleção `roles` (`getAdminUserFromRoles`, mesmo critério das regras do Firestore).
- O `firestore.rules` não está versionado neste repositório (é publicado pelo console).
- Campos: `id` (= uid), `name`, `email`, `urlImage`, `role` (`admin` | `editor` | `user`), `createdAt`, `roleUpdatedAt`, `roleUpdatedBy` (uid do admin), `lastUpdated`, `operationsCities`, `selectedAppCity`. O `UserModel` **não tem mais `status`** (índices Hive 8–11 obsoletos).
- **Campos do admin**: `role`, `roleUpdatedAt`, `roleUpdatedBy`, `operationsCities`. **Imutáveis**: `id`, `createdAt`.
- **Leitura**: o próprio usuário ou admin.
- **Criação**: só o próprio usuário, com `id == uid`, `role: 'user'` e os campos do admin ausentes ou nulos.
- **Atualização pelo usuário**: qualquer campo, **exceto** os campos do admin e os imutáveis (checado com `diff().affectedKeys()`, que também barra adicionar ou remover esses campos).
- **Atualização pelo admin**: **somente** os campos do admin (+ `lastUpdated`), **somente** de outros usuários (o admin não altera o próprio papel, para não ficar sem admin). Ao mudar `role`, `roleUpdatedBy` deve ser o uid do admin.
- **Atualizações do próprio usuário devem usar `update()` só com os campos de perfil** (`toFirebaseProfile()`), nunca `set(toFirebase())`: enviar `roleUpdatedBy: null` num documento que não tem esse campo conta como alteração e a regra nega.
- **Exclusão**: só o próprio usuário. Excluir o documento não apaga a conta no Firebase Auth.
- Admin na coleção nova é verificado por `isAdminV2()`, que lê `users_v2/{uid}` (independente de `roles`).
- O primeiro admin é criado **manualmente pelo console** (o console e o Admin SDK ignoram as regras).
- Nunca permita que o usuário grave `role` (ou outros campos do admin) no próprio documento: isso permitiria se promover a admin.

**Plano de virada** (só após validar os testes):
1. Migrar `users` + `roles` para `users_v2` com script usando o Admin SDK.
2. Fazer `getRole()` ler de `users_v2`.
3. Atualizar a Function `setUserRole`, o `user_provider.dart` e o restante do app para ler/gravar em `users_v2`.
4. Remover as regras de `users` e `roles` e, por último, os dados antigos.

**Pendências em aberto:** avaliar migrar os papéis para custom claims (`request.auth.token.role`), o que eliminaria os `get()` nas regras.

### Hive

Adapters registrados e boxes abertos em `services/hive_service.dart`. `typeId`s em uso — **não reutilizar nem alterar**:

| typeId | Modelo |
|---|---|
| 0 | `UserModel` |
| 1 | `NewsModel` |
| 2 | `NewsPackageModel` |
| 3 | `PublicKeyPackage` |
| 4 | `PublicKeyModel` |
| 12 | `RevocationInfo` |

Ao mudar um modelo Hive, não reaproveite `@HiveField` removidos e rode o `build_runner`. Nunca edite os arquivos `*.g.dart` manualmente.

## Convenções

- Código (classes, variáveis, métodos) em inglês; comentários em português.
- Arquivos em `snake_case`; classes em `PascalCase`.
- **Commits** em português, minúsculos, com prefixo:
  - `feat:` nova funcionalidade · `update:` alterar funcionalidade existente · `fix:` corrigir · `del:` remover
  - Ex.: `feat: feedback visual no botao de publicar`
- **Branches**: nome curto (até ~20 caracteres), descritivo, sem nome de desenvolvedor nem siglas obscuras. Ex.: `fix-modo-desenvolvedor`.
  - Fluxo: branch pessoal → `testing` (testes internos) → `develop` (beta) → `main` (produção, só código validado). Apague a branch pessoal após o merge em `testing`.
- **Versionamento**: SemVer (`MAIOR.MENOR.PATCH`) no `pubspec.yaml`. Mudança incompatível em modelo Hive, formato de pacote ou API = MAIOR; nova funcionalidade compatível = MENOR; correção = PATCH.
- Textos voltados ao público (leigo, de todas as idades): linguagem simples e direta, sem jargões técnicos.

## Regras obrigatórias

1. **Rode `flutter analyze`** após alterar código Dart e corrija os problemas introduzidos.
2. **Não faça commit nem push** sem pedido explícito. Nunca trabalhe direto em `main` ou `develop`.
3. **Textos visíveis ao usuário** nunca ficam fixos no código: use o GetX com as chaves tipadas de `modules/utils/translations/locale_keys.dart`.
   - Cada chave é uma constante com nome em inglês e **valor = a frase em português** (ex.: `static const newsApprovedSuccess = 'Matéria aprovada com sucesso!';`). Os valores precisam ser únicos.
   - Uso: `LocaleKeys.cancel.tr`. Nunca use `'texto'.tr` com string solta.
   - Frases com variáveis usam `@nome` + `trParams` (ex.: `LocaleKeys.cityLabel.trParams({'city': c})`), **nunca concatenação** (a ordem das palavras muda entre idiomas).
   - Ao criar uma chave, adicione-a em `LocaleKeys` e nos **4** dicionários de `modules/utils/translations/languages/` (`pt_br`, `en_us`, `es_es`, `it_it`), no mesmo bloco. O `test/translations_test.dart` confere chaves, valores vazios e `@parâmetros`: rode `flutter test test/translations_test.dart`.
   - **Categorias e tipos** são gravados nas matérias em português (dados da mesh e da assinatura): não altere esses valores em `LocaleKeys`. Para exibir, use `NewsLabels.category()`/`NewsLabels.type()` (`modules/utils/news/news_labels.dart`); papéis usam `UserRoles.label()`.
   - Datas visíveis usam `AppTranslation.formatDate()`. O idioma escolhido é salvo no GetStorage por `AppTranslation.changeLocale()`. O padrão/fallback é `pt_BR`.
   - Erros mostrados ao usuário usam mensagens traduzidas; o detalhe técnico (`$e`) vai só para o `debugPrint`. Para uma mensagem específica, lance `FriendlyException(LocaleKeys.x)` (`modules/utils/components/friendly_exception.dart`).
   - Fora da tradução: o Console Mesh (tela de desenvolvedor), nomes de cidades e dos grupos de chat.
4. **Pop-ups só pelo `AppPopups`** (`modules/utils/popups/app_popups.dart`). Nunca use `showDialog`, `Get.dialog`, `Get.snackbar`, `Get.bottomSheet`, `showModalBottomSheet` ou `ScaffoldMessenger` direto nas telas.
   - Mensagem rápida: `AppPopups.success/error/warning/info(texto)` (snackbar flutuante embaixo, com ícone).
   - Confirmação: `await AppPopups.confirm(...)` → `bool` (`destructive: true` para excluir).
   - Texto: `AppPopups.input(...)`; lista de opções: `AppPopups.choose<T>(...)`; conteúdo livre: `AppPopups.sheet(...)` ou `AppPopups.custom(widget)` usando `AppSheet`/`AppSheetButton` por dentro.
   - Aviso simples centralizado: `AppPopups.alert(...)`; carregamento bloqueante: `AppPopups.showLoading()`/`hideLoading()`.
   - Dentro das folhas, feche com `Navigator.of(context).pop(valor)`.
5. **AppBars só pelo `AppBars.build`** (`modules/utils/app_bar/app_bars.dart`). Nunca use `AppBar(...)` direto nas telas.
   - A cor vem de um `AppTone` (`brand`, `success`, `info`, `warning`, `danger`, `deleted`), nunca de uma cor solta: o degradê vai do azul da marca até a cor do tom, nos temas claro e escuro, e a cor do texto/ícones é calculada para manter o contraste.
   - A seta de voltar e o ícone do menu (quando há drawer) são automáticos; passe `leading` só para comportamentos especiais (ex.: WebView). Filtros/abas vão em `bottom`.
   - Para um tom novo, adicione-o em `AppTone` (e reaproveite a cor em outros destaques da tela, como os cards da central).
6. **Não quebre a segurança**: nunca exponha a chave privada, nunca desative a verificação de assinatura nem aceite pacotes de chaves sem validar com a chave pública da API.
7. **Não quebre a compatibilidade da mesh**: mudanças em `NewsPackageModel`, `PublicKeyPackage` ou no handshake devem continuar legíveis por versões antigas do app e pelas Functions.
