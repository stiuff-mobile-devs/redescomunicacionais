import 'package:redescomunicacionais/app/modules/utils/translations/locale_keys.dart';

// Espanhol (Espanha)
final Map<String, String> esEsTranslation = {
  // ===== Geral =====
  LocaleKeys.appNameFull: 'Redes Comunicacionales Locales',
  LocaleKeys.appNameMultiline: 'Redes Comunicacionales\nLocales',
  LocaleKeys.appShortName: 'RCL',
  LocaleKeys.cancel: 'Cancelar',
  LocaleKeys.confirm: 'Confirmar',
  LocaleKeys.close: 'Cerrar',
  LocaleKeys.continueLabel: 'Continuar',
  LocaleKeys.done: 'Listo',
  LocaleKeys.send: 'Enviar',
  LocaleKeys.edit: 'Editar',
  LocaleKeys.delete: 'Eliminar',
  LocaleKeys.change: 'Cambiar',
  LocaleKeys.filter: 'Filtrar',
  LocaleKeys.ok: 'OK',
  LocaleKeys.gotIt: 'Entendido',
  LocaleKeys.later: 'Más tarde',
  LocaleKeys.update: 'Actualizar',
  LocaleKeys.restart: 'Reiniciar',
  LocaleKeys.loading: 'Cargando...',
  LocaleKeys.tapToSelect: 'Toca para seleccionar...',
  LocaleKeys.versionLabel: 'Versión: @version',
  LocaleKeys.unexpectedError: 'Error inesperado. Inténtalo de nuevo.',
  // ===== Idioma e tema =====
  LocaleKeys.language: 'Idioma',
  LocaleKeys.languagePortugueseBrazil: 'Portugués (Brasil)',
  LocaleKeys.languageEnglishUs: 'Inglés (EE. UU.)',
  LocaleKeys.languageItalian: 'Italiano (Italia)',
  LocaleKeys.languageSpanish: 'Español (España)',
  LocaleKeys.theme: 'Tema',
  LocaleKeys.chooseTheme: 'Elige el tema',
  LocaleKeys.themeClassic: 'Tema clásico',
  LocaleKeys.themeClassicDescription: 'Interfaz original',
  LocaleKeys.themeLight: 'Tema blanco',
  LocaleKeys.themeLightDescription: 'Interfaz clara',

  // ===== Menu e tela inicial =====
  LocaleKeys.newsCenter: 'Central de noticias',
  LocaleKeys.communicationCenter: 'Central de comunicación',
  LocaleKeys.connections: 'Conexiones',
  LocaleKeys.about: 'Acerca de',
  LocaleKeys.aboutUs: 'Sobre nosotros',
  LocaleKeys.whoWeAre: '¿Quiénes somos?',
  LocaleKeys.userGuide: 'Guía del usuario',
  LocaleKeys.faq: 'Preguntas frecuentes',
  LocaleKeys.login: 'Iniciar sesión',
  LocaleKeys.logout: 'Cerrar sesión',
  LocaleKeys.admin: 'Admin',
  LocaleKeys.help: 'Ayuda',
  LocaleKeys.guest: 'Invitado',
  LocaleKeys.rclUser: 'Usuario RCL',
  LocaleKeys.filterNews: 'Filtrar noticias',
  LocaleKeys.enterNewsName: 'Escribe el título de la noticia',
  LocaleKeys.myDrafts: 'Mis borradores',
  LocaleKeys.rejectedNews: 'Artículos rechazados',
  LocaleKeys.deletedNews: 'Artículos eliminados',
  LocaleKeys.newsReview: 'Revisión de artículos',
  LocaleKeys.chooseCityToViewNews: 'Elige la ciudad para ver los artículos',
  LocaleKeys.viewAllCities: 'Ver todas las ciudades',
  LocaleKeys.changeCity: 'Cambiar ciudad',
  LocaleKeys.cityLabel: 'Ciudad: @city',
  LocaleKeys.allCities: 'Todas las ciudades',
  LocaleKeys.refreshDataError:
      'No se pudieron actualizar los datos. Comprueba tu conexión.',

  // ===== Boas-vindas e atualizações =====
  LocaleKeys.welcomeTitle: '¡Bienvenido!',
  LocaleKeys.welcomeMessage:
      'Preparamos tu dosis diaria de información con hechos reales y cero noticias falsas.',
  LocaleKeys.tapToContinue: 'Toca para continuar',
  LocaleKeys.releaseNotesTitle: 'Novedades de la actualización',
  LocaleKeys.updateDownloaded: '¡Actualización descargada con éxito!',
  LocaleKeys.newVersionAvailable: 'Nueva versión disponible',
  LocaleKeys.mandatoryUpdateMessage:
      'Se necesita una actualización obligatoria para seguir usando la aplicación.',
  LocaleKeys.optionalUpdateMessage:
      '¡Hay una nueva versión disponible! ¿Quieres actualizar ahora?',
  // ===== Login =====
  LocaleKeys.loginWithGoogle: 'Iniciar sesión con Google',
  LocaleKeys.loginWithMicrosoft: 'Iniciar sesión con Microsoft',
  LocaleKeys.loginWithApple: 'Iniciar sesión con Apple',
  LocaleKeys.loginAnonymously: 'Entrar de forma anónima',
  LocaleKeys.loginGoogleError:
      'Ocurrió un error al iniciar sesión con Google. Por favor, inténtalo de nuevo.',
  LocaleKeys.loginMicrosoftError:
      'Ocurrió un error al iniciar sesión con Microsoft. Por favor, inténtalo de nuevo.',
  LocaleKeys.loginAppleError:
      'Ocurrió un error al iniciar sesión con Apple. Por favor, inténtalo de nuevo.',

  // ===== Conexões =====
  LocaleKeys.connectionsDescription:
      'Gestiona y sigue el estado de tus conexiones externas.',
  LocaleKeys.internet: 'Internet',
  LocaleKeys.internetDescription:
      'Conectividad general para los módulos de la aplicación.',
  LocaleKeys.statusActive: 'Activo',
  LocaleKeys.statusFailed: 'Fallo',

  // ===== Central de comunicação e web =====
  LocaleKeys.chats: 'Chats',
  LocaleKeys.couldNotOpenChat: 'No se pudo abrir el chat.',
  LocaleKeys.services: 'Servicios',
  LocaleKeys.pageUnderDevelopment: 'Página en desarrollo',
  LocaleKeys.couldNotOpenLink: 'No se pudo abrir el enlace',
  LocaleKeys.openingLinkNewTab: 'Abriendo el enlace en una nueva pestaña...',

  // ===== Administração e papéis =====
  LocaleKeys.manageUsers: 'Gestionar usuarios',
  LocaleKeys.chooseCityToManageEditors:
      'Elige la ciudad para gestionar los editores y administradores',
  LocaleKeys.registeredUsers: 'Usuarios registrados',
  LocaleKeys.filterAll: 'Todos',
  LocaleKeys.filterUsers: 'Usuarios',
  LocaleKeys.filterEditors: 'Editores',
  LocaleKeys.filterAdmins: 'Admins',
  LocaleKeys.noUserFound: 'No se encontró ningún usuario',
  LocaleKeys.roleUser: 'Usuario',
  LocaleKeys.roleEditor: 'Editor',
  LocaleKeys.roleAdmin: 'Administrador',
  LocaleKeys.roleUpdatedSuccess: 'Cargo actualizado con éxito',
  LocaleKeys.roleUpdateError: 'Ocurrió un error al actualizar el cargo',
  LocaleKeys.citiesUpdatedSuccess: 'Ciudades actualizadas con éxito',
  LocaleKeys.citiesUpdateError: 'Ocurrió un error al actualizar las ciudades',
  LocaleKeys.changeOperationCities: 'Cambiar ciudades de actuación',
  LocaleKeys.operationCities: 'Ciudades de actuación',
  LocaleKeys.operationCitiesLabel: 'Ciudades de actuación:',
  LocaleKeys.selectCitiesFor: 'Selecciona las ciudades para:\n@email',
  LocaleKeys.selectAtLeastOneCityForEditor:
      'Selecciona al menos una ciudad para el editor.',
  LocaleKeys.confirmChange: 'Confirmar cambio',
  LocaleKeys.changeRoleMessage: 'Cambiar el rol de @email\nDe: @from\nA: @to',

  // ===== Perfil do usuário =====
  LocaleKeys.profile: 'Mi perfil',
  LocaleKeys.yourData: 'Tus datos',
  LocaleKeys.updateDisplayName: 'Actualiza tu nombre visible',
  LocaleKeys.name: 'Nombre',
  LocaleKeys.enterYourName: 'Escribe tu nombre',
  LocaleKeys.saveChanges: 'Guardar cambios',
  LocaleKeys.memberSince: 'Miembro desde @date',
  LocaleKeys.favoriteCity: 'Ciudad favorita',
  LocaleKeys.favoriteCityInfo:
      'Las noticias de esta ciudad aparecen en la pantalla de inicio.',
  LocaleKeys.noCitySelected: 'Ninguna ciudad elegida',
  LocaleKeys.operationCitiesInfo:
      'Ciudades en las que puedes publicar. Las define el administrador.',
  LocaleKeys.noOperationCities: 'Ninguna ciudad definida',
  LocaleKeys.dangerZone: 'Zona de peligro',
  LocaleKeys.deleteAccount: 'Eliminar cuenta',
  LocaleKeys.deleteAccountWarning:
      'Eliminar la cuenta quita el acceso y los datos vinculados.',
  LocaleKeys.confirmDeletion: 'Confirmar eliminación',
  LocaleKeys.confirmDeleteAccountMessage:
      '¿Seguro que quieres eliminar tu cuenta? Esta acción no se puede deshacer y se perderán todos los datos.',
  LocaleKeys.invalidName: 'Introduce un nombre válido.',
  LocaleKeys.nameUpdatedSuccess: 'Nombre actualizado con éxito.',
  LocaleKeys.nameUpdateError: 'No se pudo actualizar el nombre.',
  LocaleKeys.accountDeletedSuccess: 'Tu cuenta se eliminó con éxito.',
  LocaleKeys.accountDeleteError: 'No se pudo eliminar la cuenta.',
  LocaleKeys.loginAgain: 'Tu sesión ha caducado. Inicia sesión de nuevo.',
  LocaleKeys.loginAgainBeforeDelete:
      'Por seguridad, inicia sesión de nuevo antes de eliminar tu cuenta.',

  // ===== Central da matéria =====
  LocaleKeys.createNewNews: 'Crear nuevo artículo',
  LocaleKeys.createNewNewsSubtitle: 'Empieza a crear un nuevo artículo',
  LocaleKeys.reviewNews: 'Revisar artículos',
  LocaleKeys.reviewNewsSubtitle: 'Cola de evaluación y aprobación editorial',
  LocaleKeys.viewDrafts: 'Ver tus borradores',
  LocaleKeys.viewDraftsSubtitle: 'Accede a tus artículos guardados como borradores',
  LocaleKeys.viewRejected: 'Ver tus artículos rechazados',
  LocaleKeys.viewRejectedSubtitle: 'Sigue lo que volvió para ajustes',
  LocaleKeys.viewDeleted: 'Ver tus artículos eliminados',
  LocaleKeys.viewDeletedSubtitle: 'Consulta el historial de eliminaciones',
  LocaleKeys.editorialPanel: 'Panel editorial',
  LocaleKeys.editorialPanelSubtitle:
      'Crea y organiza los artículos en un solo lugar.',

  // ===== Criar e editar matéria =====
  LocaleKeys.addNews: 'Añadir artículo',
  LocaleKeys.editNews: 'Editar artículo',
  LocaleKeys.title: 'Título',
  LocaleKeys.titleRequired: 'El título es obligatorio.',
  LocaleKeys.subtitleOptional: 'Subtítulo (opcional)',
  LocaleKeys.newsBodyHint: 'Escribe el cuerpo del artículo...',
  LocaleKeys.collaboratorsOptional: 'Colaboradores (opcional)',
  LocaleKeys.tapToAddCollaborators: 'Toca para añadir colaboradores...',
  LocaleKeys.addCollaborators: 'Añadir colaboradores',
  LocaleKeys.typeNameManually: 'Escribir nombre manualmente...',
  LocaleKeys.projectEditors: 'Editores del proyecto:',
  LocaleKeys.nameNotProvided: 'Nombre no informado',
  LocaleKeys.selectCategories: 'Selecciona las categorías',
  LocaleKeys.selectAtLeastOneCategory: 'Selecciona al menos una categoría.',
  LocaleKeys.selectCity: 'Selecciona la ciudad',
  LocaleKeys.selectAtLeastOneCity: 'Selecciona al menos una ciudad.',
  LocaleKeys.selectType: 'Selecciona el tipo',
  LocaleKeys.selectAtLeastOneType: 'Selecciona al menos un tipo.',
  LocaleKeys.youtubeUrlOptional: 'URL de YouTube (opcional)',
  LocaleKeys.youtubeUrlPlaceholder: 'https://www.youtube.com/watch?v=...',
  LocaleKeys.pasteYoutubeLinkHere: 'Pega aquí un enlace de video de YouTube',
  LocaleKeys.addImage: 'Añadir imagen',
  LocaleKeys.changeImage: 'Cambiar imagen',
  LocaleKeys.imageRequirements:
      'Las imágenes grandes se comprimirán, lo que puede causar pérdida de calidad y lentitud al cargar. Para una mejor visualización, se recomienda usar imágenes en orientación horizontal.',
  LocaleKeys.publishNews: 'Publicar artículo',
  LocaleKeys.saveDraft: 'Guardar borrador',
  LocaleKeys.updateNews: 'Actualizar y publicar artículo',
  LocaleKeys.fillRequiredFields:
      'Por favor, completa todos los campos obligatorios.',
  LocaleKeys.draftSavedSuccess: '¡Borrador guardado con éxito!',
  LocaleKeys.newsSentForReview: '¡Artículo enviado a revisión con éxito!',
  LocaleKeys.newsUpdatedSuccess: '¡Artículo actualizado con éxito!',
  LocaleKeys.newsUpdateError: 'No se pudo actualizar el artículo.',
  LocaleKeys.saveDraftError: 'Error al guardar el borrador',
  LocaleKeys.publishNewsError: 'Error al publicar el artículo',

  // ===== Guia de publicação =====
  LocaleKeys.publicationGuideTitle: 'Guía rápida de publicación – RCL',
  LocaleKeys.confirmPublication: 'Confirmar publicación',
  LocaleKeys.termsNewsClarity: '1. Claridad de la noticia',
  LocaleKeys.termsArticleClarity: '1. Claridad del artículo',
  LocaleKeys.termsInfoQuality: '2. Calidad de la información',
  LocaleKeys.termsEthics: '3. Ética y respeto',
  LocaleKeys.termsImages: '4. Imágenes y videos',
  LocaleKeys.termsTransparency: '5. Transparencia',
  LocaleKeys.termShortTitle: 'El título es corto y directo',
  LocaleKeys.termSimpleText: 'El texto es sencillo, sin palabras difíciles',
  LocaleKeys.termNewsStructure:
      'El texto tiene inicio (el hecho), desarrollo (explicación del hecho) y final (desenlace e indicación autorizada de teléfonos y correos útiles, si corresponde)',
  LocaleKeys.termFactsChecked:
      'Verifiqué los hechos y mis fuentes son confiables',
  LocaleKeys.termSourcesIndicated:
      'Indiqué claramente el origen de la información y de las imágenes',
  LocaleKeys.termNoRumors:
      'No publiqué nada basado solo en rumores o redes sociales',
  LocaleKeys.termNoPrejudice:
      'El texto del artículo no contiene prejuicios, violencia ni ofensas',
  LocaleKeys.termPrivacy: 'Protegí la privacidad de niños y víctimas',
  LocaleKeys.termNoManipulation:
      'No alteré imágenes, audios ni videos de forma engañosa',
  LocaleKeys.termNoAi:
      'No generé imágenes ni videos con inteligencia artificial',
  LocaleKeys.termNoCopy:
      'No copié esta noticia ni partes de ella de otra fuente',
  LocaleKeys.termMediaRights:
      'Hice las fotos y videos o tengo autorización para usar fotos y videos hechos por otras personas',
  LocaleKeys.termNoSensationalism:
      'La imagen no es sensacionalista ni humillante (estas nunca deben publicarse)',
  LocaleKeys.termImageCredits:
      'Al final del artículo, identifiqué el lugar, la fecha y la fuente de las imágenes',
  LocaleKeys.termSigned: 'Firmé el artículo con mi nombre o perfil',
  LocaleKeys.termGrammarReview: 'Hice la revisión gramatical del texto',
  LocaleKeys.termOpinionStructure:
      'El texto tiene inicio, desarrollo y final, es decir, desarrolla un argumento completo',
  LocaleKeys.termRespectPeople:
      'Si me refiero a personas, lo hago de forma respetuosa',
  LocaleKeys.termOpinionFactsChecked:
      'Si uso hechos y datos para respaldar mi artículo, declaro que los verifiqué todos y que no contienen errores ni son noticias falsas',
  LocaleKeys.termOpinionGrounded: 'Mi opinión en el texto tiene fundamento',
  LocaleKeys.termOwnOpinion:
      'Asumo la opinión y la postura que estoy publicando',

  // ===== Visualização e revisão de matérias =====
  LocaleKeys.infoOf: 'Información de @type',
  LocaleKeys.contentOf: 'Contenido de @type',
  LocaleKeys.author: 'Autor',
  LocaleKeys.date: 'Fecha',
  LocaleKeys.city: 'Ciudad',
  LocaleKeys.type: 'Tipo',
  LocaleKeys.reviewer: 'Revisor',
  LocaleKeys.category: 'Categoría',
  LocaleKeys.categories: 'Categorías',
  LocaleKeys.allCategories: 'Todas las categorías',
  LocaleKeys.collaborators: 'Colaboradores',
  LocaleKeys.noNewsAvailable: 'No hay noticias disponibles',
  LocaleKeys.loadMoreNews: 'Cargar más artículos',
  LocaleKeys.review: 'Revisar',
  LocaleKeys.observations: 'Observaciones',
  LocaleKeys.noObservationAvailable: 'Ninguna observación disponible',
  LocaleKeys.deleteType: 'Eliminar @type',
  LocaleKeys.confirmDeleteType: '¿Seguro que quieres eliminar esta @type?',
  LocaleKeys.chooseActionForNews: 'Elige una acción para este artículo:',
  LocaleKeys.accept: 'Aceptar',
  LocaleKeys.reject: 'Rechazar',
  LocaleKeys.reasonToAccept: 'Motivo para aceptar',
  LocaleKeys.reasonToReject: 'Motivo para rechazar',
  LocaleKeys.writeReason: 'Escribe el motivo:',
  LocaleKeys.writeReasonHere: 'Escribe el motivo aquí',
  LocaleKeys.secondsAgo: 'hace @count segundos',
  LocaleKeys.minutesAgo: 'hace @count minutos',
  LocaleKeys.hoursAgo: 'hace @count horas',
  LocaleKeys.cannotReviewOwnNews: 'No puedes revisar tu propio artículo.',
  LocaleKeys.onlyAuthorCanDelete: 'Solo el autor puede eliminar este artículo.',
  LocaleKeys.typeDeletedSuccess: '¡@type eliminada con éxito!',
  LocaleKeys.typeDeleteError: 'No se pudo eliminar esta @type en este momento.',
  LocaleKeys.newsApprovedSuccess: '¡Artículo aprobado con éxito!',
  LocaleKeys.newsRejectedSuccess: '¡Artículo rechazado con éxito!',
  LocaleKeys.newsReviewError: 'No se pudo revisar el artículo.',

  // ===== Categorias e tipos =====
  LocaleKeys.categoryPolitics: 'Política',
  LocaleKeys.categorySecurity: 'Seguridad',
  LocaleKeys.categoryEducation: 'Educación',
  LocaleKeys.categoryHealth: 'Salud',
  LocaleKeys.categoryTransport: 'Transporte público y tráfico',
  LocaleKeys.categoryEconomy: 'Economía',
  LocaleKeys.categoryJobs: 'Empleo y oportunidades',
  LocaleKeys.categoryCulture: 'Cultura',
  LocaleKeys.categoryTourism: 'Turismo y ocio',
  LocaleKeys.categorySports: 'Deportes',
  LocaleKeys.categoryEnvironment: 'Medio ambiente',
  LocaleKeys.categoryInfrastructure: 'Infraestructura de la ciudad',
  LocaleKeys.categoryHousing: 'Vivienda',
  LocaleKeys.categoryTechnology: 'Tecnología',
  LocaleKeys.categoryCommunity: 'Acción comunitaria',
  LocaleKeys.typeNews: 'Noticia',
  LocaleKeys.typeOpinion: 'Opinión',

  // ===== Imagem, vídeo e localização =====
  LocaleKeys.noImageSelected: 'Ninguna imagen seleccionada.',
  LocaleKeys.processingImage:
      'Procesando tu imagen... Esto puede tardar unos segundos.',
  LocaleKeys.cropImageTitle: 'Editar imagen',
  LocaleKeys.errorProcessingImage: 'Error al procesar la imagen.',
  LocaleKeys.imageTooLarge: '¡La imagen sigue siendo demasiado grande!',
  LocaleKeys.imageSelectedSuccess: '¡Imagen seleccionada con éxito!',
  LocaleKeys.invalidYoutubeUrl: 'URL de YouTube no válida',
  LocaleKeys.watchOnYoutube: 'Ver en YouTube',
  LocaleKeys.locationRequestTitle: 'Solicitud de ubicación',
  LocaleKeys.locationPermissionDescriptionAndroid:
      "La aplicación quiere acceder a tu ubicación para ofrecer mejor información sobre tu zona. Si estás de acuerdo, selecciona 'Confirmar'. De lo contrario, selecciona 'Continuar sin ubicación'.",
  LocaleKeys.locationPermissionDescriptionIos:
      'Usamos tu ubicación para mostrar noticias más cercanas a ti.',
  LocaleKeys.allowLocation: 'Permitir ubicación',
  LocaleKeys.continueWithoutLocation: 'Continuar sin ubicación',
  LocaleKeys.locationNotProvided: 'Ubicación no proporcionada',
  LocaleKeys.cityNotFound: 'Ciudad no encontrada',
  LocaleKeys.errorUpdatingLocation: 'Error al actualizar la ubicación',
  LocaleKeys.checkingLocationMessage:
      'Espera mientras verificamos tu ubicación',
};
