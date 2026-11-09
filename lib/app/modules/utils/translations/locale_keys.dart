// Chaves de tradução do app.
//
// Regras:
// - O nome da constante é em inglês; o valor é a frase em português, para
//   ficar fácil achar e revisar os textos.
// - Uso: Text(LocaleKeys.cancel.tr).
// - Textos com variáveis usam @nome e trParams, nunca concatenação:
//   LocaleKeys.cityLabel.trParams({'city': cidade}).
// - Toda chave nova precisa existir nos 4 dicionários em languages/
//   (o teste test/translations_test.dart confere isso).
// - Os valores precisam ser únicos: duas constantes com o mesmo texto
//   viram a mesma chave.
abstract class LocaleKeys {
  // ===========================================================================
  // GERAL
  // ===========================================================================
  static const appNameFull = 'Redes Comunicacionais Locais';
  static const appNameMultiline = 'Redes Comunicacionais\nLocais';
  static const appShortName = 'RCL';
  static const cancel = 'Cancelar';
  static const confirm = 'Confirmar';
  static const close = 'Fechar';
  static const continueLabel = 'Continuar';
  static const done = 'Concluir';
  static const send = 'Enviar';
  static const edit = 'Editar';
  static const delete = 'Excluir';
  static const change = 'Alterar';
  static const filter = 'Filtrar';
  static const ok = 'OK';
  static const gotIt = 'Entendi';
  static const later = 'Depois';
  static const update = 'Atualizar';
  static const restart = 'Reiniciar';
  static const loading = 'Carregando...';
  static const tapToSelect = 'Toque para selecionar...';
  static const versionLabel = 'Versão: @version';
  static const unexpectedError = 'Erro inesperado. Tente novamente.';

  // ===========================================================================
  // IDIOMA E TEMA
  // ===========================================================================
  static const language = 'Idioma';
  static const languagePortugueseBrazil = 'Português (Brasil)';
  static const languageEnglishUs = 'Inglês (EUA)';
  static const languageItalian = 'Italiano (Itália)';
  static const languageSpanish = 'Espanhol (Espanha)';
  static const theme = 'Tema';
  static const chooseTheme = 'Escolha o tema';
  static const themeClassic = 'Tema clássico';
  static const themeClassicDescription = 'Interface original';
  static const themeLight = 'Tema branco';
  static const themeLightDescription = 'Interface clara';

  // ===========================================================================
  // MENU E TELA INICIAL
  // ===========================================================================
  static const newsCenter = 'Central da matéria';
  static const communicationCenter = 'Central de comunicação';
  static const connections = 'Conexões';
  static const about = 'Sobre';
  // Console Mesh (aviso antes de abrir) e seletor de cidades
  static const meshConsoleMenu =
      'Console Mesh (testes)';
  static const meshConsoleIntroTitle =
      'O que é o Console Mesh?';
  static const meshConsoleIntroMessage =
      'É uma ferramenta de testes que mostra como as notícias passam de um celular para outro, mesmo sem internet.';
  static const meshConsoleIntroShare =
      'Celulares que estão perto trocam notícias entre si usando Bluetooth e Wi-Fi, sem precisar de internet. Chamamos isso de "rede mesh".';
  static const meshConsoleIntroRadar =
      'No console você liga e desliga essa troca e acompanha, na hora, tudo o que está sendo enviado e recebido.';
  static const meshConsoleIntroSafe =
      'É usado pela equipe do projeto para testes. Pode usar sem medo: ele não apaga as suas matérias.';
  static const openConsole =
      'Abrir console';
  static const notNow =
      'Agora não';
  static const chooseYourCity =
      'Escolha sua cidade';
  static const chooseYourCitySubtitle =
      'Veja as notícias da sua cidade ou de toda a região';
  static const allCitiesSubtitle =
      'Notícias de toda a região';
  static const aboutUs = 'Sobre nós';
  static const whoWeAre = 'Quem somos?';
  static const userGuide = 'Guia do usuário';
  static const faq = 'Perguntas frequentes';
  static const login = 'Entrar';
  static const logout = 'Sair';
  static const admin = 'Admin';
  static const help = 'Ajuda';
  static const guest = 'Convidado';
  static const rclUser = 'Usuário RCL';
  static const filterNews = 'Filtrar notícias';
  static const enterNewsName = 'Digite o nome da notícia';
  static const myDrafts = 'Meus rascunhos';
  static const rejectedNews = 'Matérias rejeitadas';
  static const deletedNews = 'Matérias excluídas';
  static const newsReview = 'Revisão de matérias';
  // Rótulos curtos dos filtros da central (chips da Home editorial)
  static const chipRevision = 'Em revisão';
  static const chipDrafts = 'Rascunhos';
  static const chipRejected = 'Rejeitadas';
  static const chipDeleted = 'Excluídas';
  static const backToNewsCenter = 'Voltar à central da matéria';
  static const back = 'Voltar';
  static const changeCity = 'Trocar cidade';
  static const cityLabel = 'Cidade: @city';
  static const allCities = 'Todas as cidades';
  static const refreshDataError =
      'Não foi possível atualizar os dados. Verifique sua conexão.';

  // ===========================================================================
  // BOAS-VINDAS E ATUALIZAÇÕES
  // ===========================================================================
  static const welcomeTitle = 'Boas-vindas!';
  static const welcomeMessage =
      'Preparamos a sua dose diária de informação com fatos reais e zero fake news.';
  static const tapToContinue = 'Toque para continuar';
  static const releaseNotesTitle = 'Novidades da atualização';
  static const updateDownloaded = 'Atualização baixada com sucesso!';
  static const newVersionAvailable = 'Nova versão disponível';
  static const mandatoryUpdateMessage =
      'Uma atualização obrigatória é necessária para continuar utilizando o aplicativo.';
  static const optionalUpdateMessage =
      'Uma nova versão está disponível! Gostaria de atualizar agora?';

  // ===========================================================================
  // LOGIN
  // ===========================================================================
  static const loginWithGoogle = 'Entrar com Google';
  static const loginWithMicrosoft = 'Entrar com Microsoft';
  static const loginWithApple = 'Entrar com Apple';
  static const loginAnonymously = 'Entrar anonimamente';
  static const loginGoogleError =
      'Ocorreu um erro ao tentar fazer login com o Google. Por favor, tente novamente.';
  static const loginMicrosoftError =
      'Ocorreu um erro ao tentar fazer login com a Microsoft. Por favor, tente novamente.';
  static const loginAppleError =
      'Ocorreu um erro ao tentar fazer login com a Apple. Por favor, tente novamente.';

  // ===========================================================================
  // CONEXÕES
  // ===========================================================================
  static const connectionsDescription =
      'Gerencie e acompanhe o status das suas conexões externas.';
  static const internet = 'Internet';
  static const internetDescription =
      'Conectividade geral para os módulos do aplicativo.';
  static const statusActive = 'Ativo';
  static const statusFailed = 'Falha';

  // ===========================================================================
  // CENTRAL DE COMUNICAÇÃO E WEB
  // ===========================================================================
  static const chats = 'Chats';
  static const couldNotOpenChat = 'Não foi possível abrir o chat.';
  static const services = 'Serviços';
  static const pageUnderDevelopment = 'Página em desenvolvimento';
  static const couldNotOpenLink = 'Não foi possível abrir o link';
  static const openingLinkNewTab = 'Abrindo link em nova aba...';

  // ===========================================================================
  // ADMINISTRAÇÃO E PAPÉIS
  // ===========================================================================
  static const manageUsers = 'Gerenciar usuários';
  static const chooseCityToManageEditors =
      'Escolha a cidade para gerenciar os editores e administradores';
  static const registeredUsers = 'Usuários cadastrados';
  static const filterAll = 'Todos';
  static const filterUsers = 'Usuários';
  static const filterEditors = 'Editores';
  static const filterAdmins = 'Admins';
  static const noUserFound = 'Nenhum usuário encontrado';
  static const roleUser = 'Usuário';
  static const roleEditor = 'Editor';
  static const roleAdmin = 'Administrador';
  static const roleUpdatedSuccess = 'Cargo atualizado com sucesso';
  static const roleUpdateError = 'Ocorreu um erro ao atualizar o cargo';
  static const citiesUpdatedSuccess = 'Cidades atualizadas com sucesso';
  static const citiesUpdateError = 'Ocorreu um erro ao atualizar as cidades';
  static const changeOperationCities = 'Alterar cidades de atuação';
  static const operationCities = 'Cidades de atuação';
  static const operationCitiesLabel = 'Cidades de atuação:';
  static const selectCitiesFor = 'Selecione as cidades para:\n@email';
  static const selectAtLeastOneCityForEditor =
      'Selecione pelo menos uma cidade para o editor.';
  static const confirmChange = 'Confirmar alteração';
  static const changeRoleMessage =
      'Alterar papel de @email\nDe: @from\nPara: @to';

  // ===========================================================================
  // PERFIL DO USUÁRIO
  // ===========================================================================
  static const profile = 'Meu perfil';
  static const yourData = 'Seus dados';
  static const updateDisplayName = 'Atualize seu nome de exibição';
  static const name = 'Nome';
  static const enterYourName = 'Digite seu nome';
  static const saveChanges = 'Salvar alterações';
  static const memberSince = 'Membro desde @date';
  static const favoriteCity = 'Cidade favorita';
  static const favoriteCityInfo =
      'As notícias desta cidade aparecem na tela inicial.';
  static const noCitySelected = 'Nenhuma cidade escolhida';
  static const operationCitiesInfo =
      'Cidades em que você pode publicar. Quem define é o administrador.';
  static const noOperationCities = 'Nenhuma cidade definida';
  static const dangerZone = 'Zona de perigo';
  static const deleteAccount = 'Excluir conta';
  static const deleteAccountWarning =
      'Excluir a conta remove o acesso e os dados vinculados.';
  static const confirmDeletion = 'Confirmar exclusão';
  static const confirmDeleteAccountMessage =
      'Tem certeza que deseja excluir sua conta? Essa ação não tem volta e todos os dados serão perdidos.';
  static const invalidName = 'Informe um nome válido.';
  static const nameUpdatedSuccess = 'Nome atualizado com sucesso.';
  static const nameUpdateError = 'Não foi possível atualizar o nome.';
  static const accountDeletedSuccess = 'Sua conta foi excluída com sucesso.';
  static const accountDeleteError = 'Não foi possível excluir a conta.';
  static const loginAgain = 'Sua sessão expirou. Faça login novamente.';
  static const loginAgainBeforeDelete =
      'Por segurança, faça login novamente antes de excluir sua conta.';

  // ===========================================================================
  // CENTRAL DA MATÉRIA
  // ===========================================================================
  static const createNewNews = 'Criar nova matéria';
  static const createNewNewsSubtitle = 'Comece a criar uma nova matéria';
  static const reviewNews = 'Revisar matérias';
  static const reviewNewsSubtitle = 'Fila de avaliação e aprovação editorial';
  static const viewDrafts = 'Ver seus rascunhos';
  static const viewDraftsSubtitle = 'Acesse suas matérias salvas como rascunhos';
  static const viewRejected = 'Ver suas matérias rejeitadas';
  static const viewRejectedSubtitle = 'Acompanhe o que voltou para ajustes';
  static const viewDeleted = 'Ver suas matérias excluídas';
  static const viewDeletedSubtitle = 'Confira o histórico de exclusões';
  static const editorialPanel = 'Painel editorial';
  static const editorialPanelSubtitle =
      'Crie e organize as matérias em um único lugar.';

  // ===========================================================================
  // CRIAR E EDITAR MATÉRIA
  // ===========================================================================
  static const addNews = 'Adicionar matéria';
  static const editNews = 'Editar matéria';
  static const title = 'Título';
  static const titleRequired = 'O título é obrigatório.';
  static const subtitleOptional = 'Subtítulo (opcional)';
  static const newsBodyHint = 'Digite o corpo da matéria...';
  static const collaboratorsOptional = 'Colaboradores (opcional)';
  static const tapToAddCollaborators = 'Toque para adicionar colaboradores...';
  static const addCollaborators = 'Adicionar colaboradores';
  static const typeNameManually = 'Digitar nome manualmente...';
  static const projectEditors = 'Editores do projeto:';
  static const nameNotProvided = 'Nome não informado';
  static const selectCategories = 'Selecione as categorias';
  static const selectAtLeastOneCategory = 'Selecione pelo menos uma categoria.';
  static const selectCity = 'Selecione a cidade';
  static const selectAtLeastOneCity = 'Selecione pelo menos uma cidade.';
  static const selectType = 'Selecione o tipo';
  static const selectAtLeastOneType = 'Selecione pelo menos um tipo.';
  static const youtubeUrlOptional = 'URL do YouTube (opcional)';
  static const youtubeUrlPlaceholder = 'https://www.youtube.com/watch?v=...';
  static const pasteYoutubeLinkHere = 'Cole aqui um link do vídeo do YouTube';
  static const addImage = 'Adicionar imagem';
  static const changeImage = 'Alterar imagem';
  static const imageRequirements =
      'Imagens com grande tamanho serão comprimidas, o que pode causar perda de qualidade e lentidão no carregamento. Para uma melhor visualização, recomenda-se o uso de imagens com orientação paisagem.';
  static const publishNews = 'Publicar matéria';
  static const saveDraft = 'Salvar rascunho';
  static const updateNews = 'Atualizar e publicar matéria';
  static const fillRequiredFields =
      'Por favor, preencha todos os campos obrigatórios.';
  static const draftSavedSuccess = 'Rascunho salvo com sucesso!';
  static const newsSentForReview = 'Matéria enviada para análise com sucesso!';
  static const newsUpdatedSuccess = 'Matéria atualizada com sucesso!';
  static const newsUpdateError = 'Não foi possível atualizar a matéria.';
  static const saveDraftError = 'Erro ao salvar rascunho';
  static const publishNewsError = 'Erro ao publicar matéria';

  // ===========================================================================
  // GUIA DE PUBLICAÇÃO (termos)
  // ===========================================================================
  static const publicationGuideTitle = 'Guia rápido de publicação – RCL';
  static const confirmPublication = 'Confirmar publicação';
  static const termsNewsClarity = '1. Clareza da notícia';
  static const termsArticleClarity = '1. Clareza do artigo';
  static const termsInfoQuality = '2. Qualidade da informação';
  static const termsEthics = '3. Ética e respeito';
  static const termsImages = '4. Imagens e vídeos';
  static const termsTransparency = '5. Transparência';
  static const termShortTitle = 'O título está curto e direto';
  static const termSimpleText = 'O texto está simples, sem palavras difíceis';
  static const termNewsStructure =
      'O texto tem princípio (o fato), desenvolvimento (explicação do fato) e fim (desfecho e indicação autorizada de telefones e emails úteis, se for o caso)';
  static const termFactsChecked =
      'Conferi os fatos e minhas fontes são confiáveis';
  static const termSourcesIndicated =
      'Indiquei claramente a origem das informações e imagens';
  static const termNoRumors =
      'Não publiquei nada baseado apenas em boatos ou redes sociais';
  static const termNoPrejudice =
      'O texto da matéria não contém preconceito, violência nem ofensa';
  static const termPrivacy = 'Protegi a privacidade de crianças e vítimas';
  static const termNoManipulation =
      'Não alterei imagens, áudios ou vídeos de forma enganosa';
  static const termNoAi =
      'Não gerei imagens nem vídeos por inteligência artificial';
  static const termNoCopy =
      'Não copiei esta notícia nem partes dela de outra fonte';
  static const termMediaRights =
      'Fiz as fotos e vídeos ou tenho autorização para usar fotos e vídeos feitos por outras pessoas';
  static const termNoSensationalism =
      'A imagem não é sensacionalista nem constrangedora (estas não devem nunca ser publicadas)';
  static const termImageCredits =
      'Ao final da matéria, identifiquei local, data e fonte das imagens';
  static const termSigned = 'Assinei a matéria com meu nome ou perfil';
  static const termGrammarReview = 'Fiz a revisão gramatical do texto';
  static const termOpinionStructure =
      'O texto tem princípio, meio e fim, ou seja, desenvolve um argumento completo';
  static const termRespectPeople =
      'Se me refiro a pessoas, faço isso de forma respeitosa';
  static const termOpinionFactsChecked =
      'Se uso fatos e dados para embasar meu artigo, declaro que conferi todos eles e que não contém erros nem são fake news';
  static const termOpinionGrounded = 'Minha opinião no texto tem fundamento';
  static const termOwnOpinion =
      'Assumo a opinião e o posicionamento que estou publicando';

  // ===========================================================================
  // VISUALIZAÇÃO E REVISÃO DE MATÉRIAS
  // ===========================================================================
  static const infoOf = 'Informações da @type';
  static const contentOf = 'Conteúdo da @type';
  static const author = 'Autor';
  static const date = 'Data';
  static const city = 'Cidade';
  static const type = 'Tipo';
  static const reviewer = 'Revisor';
  static const category = 'Categoria';
  static const categories = 'Categorias';
  static const allCategories = 'Todas as categorias';
  static const collaborators = 'Colaboradores';
  static const noNewsAvailable = 'Não há notícias disponíveis';
  static const loadMoreNews = 'Carregar mais matérias';
  static const review = 'Revisar';
  static const observations = 'Observações';
  static const noObservationAvailable = 'Nenhuma observação disponível';
  static const deleteType = 'Excluir @type';
  static const confirmDeleteType = 'Tem certeza que deseja excluir esta @type?';
  static const chooseActionForNews = 'Escolha uma ação para esta matéria:';
  static const accept = 'Aceitar';
  static const reject = 'Recusar';
  static const reasonToAccept = 'Motivo para aceitar';
  static const reasonToReject = 'Motivo para recusar';
  static const writeReason = 'Escreva o motivo:';
  static const writeReasonHere = 'Escreva o motivo aqui';
  static const secondsAgo = '@count segundos atrás';
  static const minutesAgo = '@count minutos atrás';
  static const hoursAgo = '@count horas atrás';
  static const cannotReviewOwnNews =
      'Você não pode revisar sua própria matéria.';
  static const onlyAuthorCanDelete =
      'Apenas o autor pode excluir esta matéria.';
  static const typeDeletedSuccess = '@type excluída com sucesso!';
  static const typeDeleteError =
      'Não foi possível excluir esta @type no momento.';
  static const newsApprovedSuccess = 'Matéria aprovada com sucesso!';
  static const newsRejectedSuccess = 'Matéria rejeitada com sucesso!';
  static const newsReviewError = 'Não foi possível revisar a matéria.';

  // ===========================================================================
  // CATEGORIAS E TIPOS
  // Estes valores SÃO os dados gravados nas matérias (Hive, Firebase, mesh e
  // assinatura). NÃO altere o texto daqui: para mudar o que aparece em
  // português, altere só o valor no pt_br_translation.dart.
  // ===========================================================================
  static const categoryPolitics = 'Política';
  static const categorySecurity = 'Segurança';
  static const categoryEducation = 'Educação';
  static const categoryHealth = 'Saúde';
  static const categoryTransport = 'Transporte público e trânsito';
  static const categoryEconomy = 'Economia';
  static const categoryJobs = 'Emprego e oportunidades';
  static const categoryCulture = 'Cultura';
  static const categoryTourism = 'Turismo e lazer';
  static const categorySports = 'Esportes';
  static const categoryEnvironment = 'Meio Ambiente';
  static const categoryInfrastructure = 'Infraestrutura da cidade';
  static const categoryHousing = 'Habitação';
  static const categoryTechnology = 'Tecnologia';
  static const categoryCommunity = 'Ação comunitária';
  static const typeNews = 'Notícia';
  static const typeOpinion = 'Opinião';

  // ===========================================================================
  // IMAGEM, VÍDEO E LOCALIZAÇÃO
  // ===========================================================================
  static const noImageSelected = 'Nenhuma imagem selecionada.';
  static const processingImage =
      'Processando sua imagem... Isso pode levar alguns segundos.';
  static const cropImageTitle = 'Editar imagem';
  static const errorProcessingImage = 'Erro ao processar a imagem.';
  static const imageTooLarge = 'A imagem ainda é muito grande!';
  static const imageSelectedSuccess = 'Imagem selecionada com sucesso!';
  static const invalidYoutubeUrl = 'URL do YouTube inválida';
  static const watchOnYoutube = 'Assistir no YouTube';
  static const locationRequestTitle = 'Solicitação de localização';
  static const locationPermissionDescriptionAndroid =
      'O aplicativo gostaria de acessar sua localização para fornecer melhores informações sobre sua área. Se concorda, selecione \'Confirmar\'. Caso contrário, selecione \'Continuar sem localização\'.';
  static const locationPermissionDescriptionIos =
      'Usamos sua localização para mostrar notícias mais próximas de você.';
  static const allowLocation = 'Permitir localização';
  static const continueWithoutLocation = 'Continuar sem localização';
  static const locationNotProvided = 'Localização não fornecida';
  static const cityNotFound = 'Cidade não encontrada';
  static const errorUpdatingLocation = 'Erro ao atualizar localização';
  static const checkingLocationMessage =
      'Aguarde enquanto verificamos sua localização';
}
