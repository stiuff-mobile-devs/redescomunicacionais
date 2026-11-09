import 'package:redescomunicacionais/app/modules/utils/translations/locale_keys.dart';

// Português (Brasil) - idioma padrão e de fallback.
// A chave já é a frase em português; o valor pode ser ajustado aqui sem
// mudar a chave.
final Map<String, String> ptBrTranslation = {
  // ===== Geral =====
  LocaleKeys.appNameFull: 'Redes Comunicacionais Locais',
  LocaleKeys.appNameMultiline: 'Redes Comunicacionais\nLocais',
  LocaleKeys.appShortName: 'RCL',
  LocaleKeys.cancel: 'Cancelar',
  LocaleKeys.confirm: 'Confirmar',
  LocaleKeys.close: 'Fechar',
  LocaleKeys.continueLabel: 'Continuar',
  LocaleKeys.done: 'Concluir',
  LocaleKeys.send: 'Enviar',
  LocaleKeys.edit: 'Editar',
  LocaleKeys.delete: 'Excluir',
  LocaleKeys.change: 'Alterar',
  LocaleKeys.filter: 'Filtrar',
  LocaleKeys.ok: 'OK',
  LocaleKeys.gotIt: 'Entendi',
  LocaleKeys.later: 'Depois',
  LocaleKeys.update: 'Atualizar',
  LocaleKeys.restart: 'Reiniciar',
  LocaleKeys.loading: 'Carregando...',
  LocaleKeys.tapToSelect: 'Toque para selecionar...',
  LocaleKeys.versionLabel: 'Versão: @version',
  LocaleKeys.unexpectedError: 'Erro inesperado. Tente novamente.',
  // ===== Idioma e tema =====
  LocaleKeys.language: 'Idioma',
  LocaleKeys.languagePortugueseBrazil: 'Português (Brasil)',
  LocaleKeys.languageEnglishUs: 'Inglês (EUA)',
  LocaleKeys.languageItalian: 'Italiano (Itália)',
  LocaleKeys.languageSpanish: 'Espanhol (Espanha)',
  LocaleKeys.theme: 'Tema',
  LocaleKeys.chooseTheme: 'Escolha o tema',
  LocaleKeys.themeClassic: 'Tema clássico',
  LocaleKeys.themeClassicDescription: 'Interface original',
  LocaleKeys.themeLight: 'Tema branco',
  LocaleKeys.themeLightDescription: 'Interface clara',

  // ===== Menu e tela inicial =====
  LocaleKeys.newsCenter: 'Central da matéria',
  LocaleKeys.communicationCenter: 'Central de comunicação',
  LocaleKeys.connections: 'Conexões',
  LocaleKeys.about: 'Sobre',
  LocaleKeys.aboutUs: 'Sobre nós',
  LocaleKeys.whoWeAre: 'Quem somos?',
  LocaleKeys.userGuide: 'Guia do usuário',
  LocaleKeys.faq: 'Perguntas frequentes',
  LocaleKeys.login: 'Entrar',
  LocaleKeys.logout: 'Sair',
  LocaleKeys.admin: 'Admin',
  LocaleKeys.help: 'Ajuda',
  LocaleKeys.guest: 'Convidado',
  LocaleKeys.rclUser: 'Usuário RCL',
  LocaleKeys.filterNews: 'Filtrar notícias',
  LocaleKeys.enterNewsName: 'Digite o nome da notícia',
  LocaleKeys.myDrafts: 'Meus rascunhos',
  LocaleKeys.rejectedNews: 'Matérias rejeitadas',
  LocaleKeys.deletedNews: 'Matérias excluídas',
  LocaleKeys.newsReview: 'Revisão de matérias',
  LocaleKeys.chipRevision: 'Em revisão',
  LocaleKeys.chipDrafts: 'Rascunhos',
  LocaleKeys.chipRejected: 'Rejeitadas',
  LocaleKeys.chipDeleted: 'Excluídas',
  LocaleKeys.backToNewsCenter: 'Voltar à central da matéria',
  LocaleKeys.back: 'Voltar',
  LocaleKeys.chooseCityToViewNews:
      'Escolha a cidade para visualizar as matérias',
  LocaleKeys.viewAllCities: 'Visualizar todas as cidades',
  LocaleKeys.changeCity: 'Trocar cidade',
  LocaleKeys.cityLabel: 'Cidade: @city',
  LocaleKeys.allCities: 'Todas as cidades',
  LocaleKeys.refreshDataError:
      'Não foi possível atualizar os dados. Verifique sua conexão.',

  // ===== Boas-vindas e atualizações =====
  LocaleKeys.welcomeTitle: 'Boas-vindas!',
  LocaleKeys.welcomeMessage:
      'Preparamos a sua dose diária de informação com fatos reais e zero fake news.',
  LocaleKeys.tapToContinue: 'Toque para continuar',
  LocaleKeys.releaseNotesTitle: 'Novidades da atualização',
  LocaleKeys.updateDownloaded: 'Atualização baixada com sucesso!',
  LocaleKeys.newVersionAvailable: 'Nova versão disponível',
  LocaleKeys.mandatoryUpdateMessage:
      'Uma atualização obrigatória é necessária para continuar utilizando o aplicativo.',
  LocaleKeys.optionalUpdateMessage:
      'Uma nova versão está disponível! Gostaria de atualizar agora?',
  // ===== Login =====
  LocaleKeys.loginWithGoogle: 'Entrar com Google',
  LocaleKeys.loginWithMicrosoft: 'Entrar com Microsoft',
  LocaleKeys.loginWithApple: 'Entrar com Apple',
  LocaleKeys.loginAnonymously: 'Entrar anonimamente',
  LocaleKeys.loginGoogleError:
      'Ocorreu um erro ao tentar fazer login com o Google. Por favor, tente novamente.',
  LocaleKeys.loginMicrosoftError:
      'Ocorreu um erro ao tentar fazer login com a Microsoft. Por favor, tente novamente.',
  LocaleKeys.loginAppleError:
      'Ocorreu um erro ao tentar fazer login com a Apple. Por favor, tente novamente.',

  // ===== Conexões =====
  LocaleKeys.connectionsDescription:
      'Gerencie e acompanhe o status das suas conexões externas.',
  LocaleKeys.internet: 'Internet',
  LocaleKeys.internetDescription:
      'Conectividade geral para os módulos do aplicativo.',
  LocaleKeys.statusActive: 'Ativo',
  LocaleKeys.statusFailed: 'Falha',

  // ===== Central de comunicação e web =====
  LocaleKeys.chats: 'Chats',
  LocaleKeys.couldNotOpenChat: 'Não foi possível abrir o chat.',
  LocaleKeys.services: 'Serviços',
  LocaleKeys.pageUnderDevelopment: 'Página em desenvolvimento',
  LocaleKeys.couldNotOpenLink: 'Não foi possível abrir o link',
  LocaleKeys.openingLinkNewTab: 'Abrindo link em nova aba...',

  // ===== Administração e papéis =====
  LocaleKeys.manageUsers: 'Gerenciar usuários',
  LocaleKeys.chooseCityToManageEditors:
      'Escolha a cidade para gerenciar os editores e administradores',
  LocaleKeys.registeredUsers: 'Usuários cadastrados',
  LocaleKeys.filterAll: 'Todos',
  LocaleKeys.filterUsers: 'Usuários',
  LocaleKeys.filterEditors: 'Editores',
  LocaleKeys.filterAdmins: 'Admins',
  LocaleKeys.noUserFound: 'Nenhum usuário encontrado',
  LocaleKeys.roleUser: 'Usuário',
  LocaleKeys.roleEditor: 'Editor',
  LocaleKeys.roleAdmin: 'Administrador',
  LocaleKeys.roleUpdatedSuccess: 'Cargo atualizado com sucesso',
  LocaleKeys.roleUpdateError: 'Ocorreu um erro ao atualizar o cargo',
  LocaleKeys.citiesUpdatedSuccess: 'Cidades atualizadas com sucesso',
  LocaleKeys.citiesUpdateError: 'Ocorreu um erro ao atualizar as cidades',
  LocaleKeys.changeOperationCities: 'Alterar cidades de atuação',
  LocaleKeys.operationCities: 'Cidades de atuação',
  LocaleKeys.operationCitiesLabel: 'Cidades de atuação:',
  LocaleKeys.selectCitiesFor: 'Selecione as cidades para:\n@email',
  LocaleKeys.selectAtLeastOneCityForEditor:
      'Selecione pelo menos uma cidade para o editor.',
  LocaleKeys.confirmChange: 'Confirmar alteração',
  LocaleKeys.changeRoleMessage: 'Alterar papel de @email\nDe: @from\nPara: @to',

  // ===== Perfil do usuário =====
  LocaleKeys.profile: 'Meu perfil',
  LocaleKeys.yourData: 'Seus dados',
  LocaleKeys.updateDisplayName: 'Atualize seu nome de exibição',
  LocaleKeys.name: 'Nome',
  LocaleKeys.enterYourName: 'Digite seu nome',
  LocaleKeys.saveChanges: 'Salvar alterações',
  LocaleKeys.memberSince: 'Membro desde @date',
  LocaleKeys.favoriteCity: 'Cidade favorita',
  LocaleKeys.favoriteCityInfo:
      'As notícias desta cidade aparecem na tela inicial.',
  LocaleKeys.noCitySelected: 'Nenhuma cidade escolhida',
  LocaleKeys.operationCitiesInfo:
      'Cidades em que você pode publicar. Quem define é o administrador.',
  LocaleKeys.noOperationCities: 'Nenhuma cidade definida',
  LocaleKeys.dangerZone: 'Zona de perigo',
  LocaleKeys.deleteAccount: 'Excluir conta',
  LocaleKeys.deleteAccountWarning:
      'Excluir a conta remove o acesso e os dados vinculados.',
  LocaleKeys.confirmDeletion: 'Confirmar exclusão',
  LocaleKeys.confirmDeleteAccountMessage:
      'Tem certeza que deseja excluir sua conta? Essa ação não tem volta e todos os dados serão perdidos.',
  LocaleKeys.invalidName: 'Informe um nome válido.',
  LocaleKeys.nameUpdatedSuccess: 'Nome atualizado com sucesso.',
  LocaleKeys.nameUpdateError: 'Não foi possível atualizar o nome.',
  LocaleKeys.accountDeletedSuccess: 'Sua conta foi excluída com sucesso.',
  LocaleKeys.accountDeleteError: 'Não foi possível excluir a conta.',
  LocaleKeys.loginAgain: 'Sua sessão expirou. Faça login novamente.',
  LocaleKeys.loginAgainBeforeDelete:
      'Por segurança, faça login novamente antes de excluir sua conta.',

  // ===== Central da matéria =====
  LocaleKeys.createNewNews: 'Criar nova matéria',
  LocaleKeys.createNewNewsSubtitle: 'Comece a criar uma nova matéria',
  LocaleKeys.reviewNews: 'Revisar matérias',
  LocaleKeys.reviewNewsSubtitle: 'Fila de avaliação e aprovação editorial',
  LocaleKeys.viewDrafts: 'Ver seus rascunhos',
  LocaleKeys.viewDraftsSubtitle: 'Acesse suas matérias salvas como rascunhos',
  LocaleKeys.viewRejected: 'Ver suas matérias rejeitadas',
  LocaleKeys.viewRejectedSubtitle: 'Acompanhe o que voltou para ajustes',
  LocaleKeys.viewDeleted: 'Ver suas matérias excluídas',
  LocaleKeys.viewDeletedSubtitle: 'Confira o histórico de exclusões',
  LocaleKeys.editorialPanel: 'Painel editorial',
  LocaleKeys.editorialPanelSubtitle:
      'Crie e organize as matérias em um único lugar.',

  // ===== Criar e editar matéria =====
  LocaleKeys.addNews: 'Adicionar matéria',
  LocaleKeys.editNews: 'Editar matéria',
  LocaleKeys.title: 'Título',
  LocaleKeys.titleRequired: 'O título é obrigatório.',
  LocaleKeys.subtitleOptional: 'Subtítulo (opcional)',
  LocaleKeys.newsBodyHint: 'Digite o corpo da matéria...',
  LocaleKeys.collaboratorsOptional: 'Colaboradores (opcional)',
  LocaleKeys.tapToAddCollaborators: 'Toque para adicionar colaboradores...',
  LocaleKeys.addCollaborators: 'Adicionar colaboradores',
  LocaleKeys.typeNameManually: 'Digitar nome manualmente...',
  LocaleKeys.projectEditors: 'Editores do projeto:',
  LocaleKeys.nameNotProvided: 'Nome não informado',
  LocaleKeys.selectCategories: 'Selecione as categorias',
  LocaleKeys.selectAtLeastOneCategory: 'Selecione pelo menos uma categoria.',
  LocaleKeys.selectCity: 'Selecione a cidade',
  LocaleKeys.selectAtLeastOneCity: 'Selecione pelo menos uma cidade.',
  LocaleKeys.selectType: 'Selecione o tipo',
  LocaleKeys.selectAtLeastOneType: 'Selecione pelo menos um tipo.',
  LocaleKeys.youtubeUrlOptional: 'URL do YouTube (opcional)',
  LocaleKeys.youtubeUrlPlaceholder: 'https://www.youtube.com/watch?v=...',
  LocaleKeys.pasteYoutubeLinkHere: 'Cole aqui um link do vídeo do YouTube',
  LocaleKeys.addImage: 'Adicionar imagem',
  LocaleKeys.changeImage: 'Alterar imagem',
  LocaleKeys.imageRequirements:
      'Imagens com grande tamanho serão comprimidas, o que pode causar perda de qualidade e lentidão no carregamento. Para uma melhor visualização, recomenda-se o uso de imagens com orientação paisagem.',
  LocaleKeys.publishNews: 'Publicar matéria',
  LocaleKeys.saveDraft: 'Salvar rascunho',
  LocaleKeys.updateNews: 'Atualizar e publicar matéria',
  LocaleKeys.fillRequiredFields:
      'Por favor, preencha todos os campos obrigatórios.',
  LocaleKeys.draftSavedSuccess: 'Rascunho salvo com sucesso!',
  LocaleKeys.newsSentForReview: 'Matéria enviada para análise com sucesso!',
  LocaleKeys.newsUpdatedSuccess: 'Matéria atualizada com sucesso!',
  LocaleKeys.newsUpdateError: 'Não foi possível atualizar a matéria.',
  LocaleKeys.saveDraftError: 'Erro ao salvar rascunho',
  LocaleKeys.publishNewsError: 'Erro ao publicar matéria',

  // ===== Guia de publicação =====
  LocaleKeys.publicationGuideTitle: 'Guia rápido de publicação – RCL',
  LocaleKeys.confirmPublication: 'Confirmar publicação',
  LocaleKeys.termsNewsClarity: '1. Clareza da notícia',
  LocaleKeys.termsArticleClarity: '1. Clareza do artigo',
  LocaleKeys.termsInfoQuality: '2. Qualidade da informação',
  LocaleKeys.termsEthics: '3. Ética e respeito',
  LocaleKeys.termsImages: '4. Imagens e vídeos',
  LocaleKeys.termsTransparency: '5. Transparência',
  LocaleKeys.termShortTitle: 'O título está curto e direto',
  LocaleKeys.termSimpleText: 'O texto está simples, sem palavras difíceis',
  LocaleKeys.termNewsStructure:
      'O texto tem princípio (o fato), desenvolvimento (explicação do fato) e fim (desfecho e indicação autorizada de telefones e emails úteis, se for o caso)',
  LocaleKeys.termFactsChecked: 'Conferi os fatos e minhas fontes são confiáveis',
  LocaleKeys.termSourcesIndicated:
      'Indiquei claramente a origem das informações e imagens',
  LocaleKeys.termNoRumors:
      'Não publiquei nada baseado apenas em boatos ou redes sociais',
  LocaleKeys.termNoPrejudice:
      'O texto da matéria não contém preconceito, violência nem ofensa',
  LocaleKeys.termPrivacy: 'Protegi a privacidade de crianças e vítimas',
  LocaleKeys.termNoManipulation:
      'Não alterei imagens, áudios ou vídeos de forma enganosa',
  LocaleKeys.termNoAi: 'Não gerei imagens nem vídeos por inteligência artificial',
  LocaleKeys.termNoCopy: 'Não copiei esta notícia nem partes dela de outra fonte',
  LocaleKeys.termMediaRights:
      'Fiz as fotos e vídeos ou tenho autorização para usar fotos e vídeos feitos por outras pessoas',
  LocaleKeys.termNoSensationalism:
      'A imagem não é sensacionalista nem constrangedora (estas não devem nunca ser publicadas)',
  LocaleKeys.termImageCredits:
      'Ao final da matéria, identifiquei local, data e fonte das imagens',
  LocaleKeys.termSigned: 'Assinei a matéria com meu nome ou perfil',
  LocaleKeys.termGrammarReview: 'Fiz a revisão gramatical do texto',
  LocaleKeys.termOpinionStructure:
      'O texto tem princípio, meio e fim, ou seja, desenvolve um argumento completo',
  LocaleKeys.termRespectPeople:
      'Se me refiro a pessoas, faço isso de forma respeitosa',
  LocaleKeys.termOpinionFactsChecked:
      'Se uso fatos e dados para embasar meu artigo, declaro que conferi todos eles e que não contém erros nem são fake news',
  LocaleKeys.termOpinionGrounded: 'Minha opinião no texto tem fundamento',
  LocaleKeys.termOwnOpinion:
      'Assumo a opinião e o posicionamento que estou publicando',

  // ===== Visualização e revisão de matérias =====
  LocaleKeys.infoOf: 'Informações da @type',
  LocaleKeys.contentOf: 'Conteúdo da @type',
  LocaleKeys.author: 'Autor',
  LocaleKeys.date: 'Data',
  LocaleKeys.city: 'Cidade',
  LocaleKeys.type: 'Tipo',
  LocaleKeys.reviewer: 'Revisor',
  LocaleKeys.category: 'Categoria',
  LocaleKeys.categories: 'Categorias',
  LocaleKeys.allCategories: 'Todas as categorias',
  LocaleKeys.collaborators: 'Colaboradores',
  LocaleKeys.noNewsAvailable: 'Não há notícias disponíveis',
  LocaleKeys.loadMoreNews: 'Carregar mais matérias',
  LocaleKeys.review: 'Revisar',
  LocaleKeys.observations: 'Observações',
  LocaleKeys.noObservationAvailable: 'Nenhuma observação disponível',
  LocaleKeys.deleteType: 'Excluir @type',
  LocaleKeys.confirmDeleteType: 'Tem certeza que deseja excluir esta @type?',
  LocaleKeys.chooseActionForNews: 'Escolha uma ação para esta matéria:',
  LocaleKeys.accept: 'Aceitar',
  LocaleKeys.reject: 'Recusar',
  LocaleKeys.reasonToAccept: 'Motivo para aceitar',
  LocaleKeys.reasonToReject: 'Motivo para recusar',
  LocaleKeys.writeReason: 'Escreva o motivo:',
  LocaleKeys.writeReasonHere: 'Escreva o motivo aqui',
  LocaleKeys.secondsAgo: '@count segundos atrás',
  LocaleKeys.minutesAgo: '@count minutos atrás',
  LocaleKeys.hoursAgo: '@count horas atrás',
  LocaleKeys.cannotReviewOwnNews: 'Você não pode revisar sua própria matéria.',
  LocaleKeys.onlyAuthorCanDelete: 'Apenas o autor pode excluir esta matéria.',
  LocaleKeys.typeDeletedSuccess: '@type excluída com sucesso!',
  LocaleKeys.typeDeleteError: 'Não foi possível excluir esta @type no momento.',
  LocaleKeys.newsApprovedSuccess: 'Matéria aprovada com sucesso!',
  LocaleKeys.newsRejectedSuccess: 'Matéria rejeitada com sucesso!',
  LocaleKeys.newsReviewError: 'Não foi possível revisar a matéria.',

  // ===== Categorias e tipos =====
  LocaleKeys.categoryPolitics: 'Política',
  LocaleKeys.categorySecurity: 'Segurança',
  LocaleKeys.categoryEducation: 'Educação',
  LocaleKeys.categoryHealth: 'Saúde',
  LocaleKeys.categoryTransport: 'Transporte público e trânsito',
  LocaleKeys.categoryEconomy: 'Economia',
  LocaleKeys.categoryJobs: 'Emprego e oportunidades',
  LocaleKeys.categoryCulture: 'Cultura',
  LocaleKeys.categoryTourism: 'Turismo e lazer',
  LocaleKeys.categorySports: 'Esportes',
  LocaleKeys.categoryEnvironment: 'Meio ambiente',
  LocaleKeys.categoryInfrastructure: 'Infraestrutura da cidade',
  LocaleKeys.categoryHousing: 'Habitação',
  LocaleKeys.categoryTechnology: 'Tecnologia',
  LocaleKeys.categoryCommunity: 'Ação comunitária',
  LocaleKeys.typeNews: 'Notícia',
  LocaleKeys.typeOpinion: 'Opinião',

  // ===== Imagem, vídeo e localização =====
  LocaleKeys.noImageSelected: 'Nenhuma imagem selecionada.',
  LocaleKeys.processingImage:
      'Processando sua imagem... Isso pode levar alguns segundos.',
  LocaleKeys.cropImageTitle: 'Editar imagem',
  LocaleKeys.errorProcessingImage: 'Erro ao processar a imagem.',
  LocaleKeys.imageTooLarge: 'A imagem ainda é muito grande!',
  LocaleKeys.imageSelectedSuccess: 'Imagem selecionada com sucesso!',
  LocaleKeys.invalidYoutubeUrl: 'URL do YouTube inválida',
  LocaleKeys.watchOnYoutube: 'Assistir no YouTube',
  LocaleKeys.locationRequestTitle: 'Solicitação de localização',
  LocaleKeys.locationPermissionDescriptionAndroid:
      'O aplicativo gostaria de acessar sua localização para fornecer melhores informações sobre sua área. Se concorda, selecione \'Confirmar\'. Caso contrário, selecione \'Continuar sem localização\'.',
  LocaleKeys.locationPermissionDescriptionIos:
      'Usamos sua localização para mostrar notícias mais próximas de você.',
  LocaleKeys.allowLocation: 'Permitir localização',
  LocaleKeys.continueWithoutLocation: 'Continuar sem localização',
  LocaleKeys.locationNotProvided: 'Localização não fornecida',
  LocaleKeys.cityNotFound: 'Cidade não encontrada',
  LocaleKeys.errorUpdatingLocation: 'Erro ao atualizar localização',
  LocaleKeys.checkingLocationMessage:
      'Aguarde enquanto verificamos sua localização',
};
