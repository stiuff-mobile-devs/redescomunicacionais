import 'package:redescomunicacionais/app/modules/utils/translations/locale_keys.dart';

// Inglês (EUA)
final Map<String, String> enUsTranslation = {
  // ===== Geral =====
  LocaleKeys.appNameFull: 'Local Communication Networks',
  LocaleKeys.appNameMultiline: 'Local Communication\nNetworks',
  LocaleKeys.appShortName: 'RCL',
  LocaleKeys.cancel: 'Cancel',
  LocaleKeys.confirm: 'Confirm',
  LocaleKeys.close: 'Close',
  LocaleKeys.continueLabel: 'Continue',
  LocaleKeys.done: 'Done',
  LocaleKeys.send: 'Send',
  LocaleKeys.edit: 'Edit',
  LocaleKeys.delete: 'Delete',
  LocaleKeys.change: 'Change',
  LocaleKeys.filter: 'Filter',
  LocaleKeys.ok: 'OK',
  LocaleKeys.gotIt: 'Got it',
  LocaleKeys.later: 'Later',
  LocaleKeys.update: 'Update',
  LocaleKeys.restart: 'Restart',
  LocaleKeys.loading: 'Loading...',
  LocaleKeys.tapToSelect: 'Tap to select...',
  LocaleKeys.versionLabel: 'Version: @version',
  LocaleKeys.unexpectedError: 'Unexpected error. Please try again.',
  // ===== Idioma e tema =====
  LocaleKeys.language: 'Language',
  LocaleKeys.languagePortugueseBrazil: 'Portuguese (Brazil)',
  LocaleKeys.languageEnglishUs: 'English (US)',
  LocaleKeys.languageItalian: 'Italian (Italy)',
  LocaleKeys.languageSpanish: 'Spanish (Spain)',
  LocaleKeys.theme: 'Theme',
  LocaleKeys.chooseTheme: 'Choose the theme',
  LocaleKeys.themeClassic: 'Classic theme',
  LocaleKeys.themeClassicDescription: 'Original interface',
  LocaleKeys.themeLight: 'White theme',
  LocaleKeys.themeLightDescription: 'Light interface',

  // ===== Menu e tela inicial =====
  LocaleKeys.newsCenter: 'News center',
  LocaleKeys.communicationCenter: 'Communication center',
  LocaleKeys.connections: 'Connections',
  LocaleKeys.about: 'About',
  LocaleKeys.meshConsoleMenu:
      'Mesh Console (tests)',
  LocaleKeys.meshConsoleIntroTitle:
      'What is the Mesh Console?',
  LocaleKeys.meshConsoleIntroMessage:
      'It is a testing tool that shows how news travels from one phone to another, even without internet.',
  LocaleKeys.meshConsoleIntroShare:
      'Phones that are close to each other share news using Bluetooth and Wi-Fi, without needing internet. We call this a "mesh network".',
  LocaleKeys.meshConsoleIntroRadar:
      'In the console you turn this sharing on and off and follow, in real time, everything being sent and received.',
  LocaleKeys.meshConsoleIntroSafe:
      'It is used by the project team for testing. Feel free to use it: it does not delete your articles.',
  LocaleKeys.openConsole:
      'Open console',
  LocaleKeys.notNow:
      'Not now',
  LocaleKeys.chooseYourCity:
      'Choose your city',
  LocaleKeys.chooseYourCitySubtitle:
      'See the news from your city or from the whole region',
  LocaleKeys.allCitiesSubtitle:
      'News from the whole region',
  LocaleKeys.aboutUs: 'About us',
  LocaleKeys.whoWeAre: 'Who are we?',
  LocaleKeys.userGuide: 'User guide',
  LocaleKeys.faq: 'Frequently asked questions',
  LocaleKeys.login: 'Sign in',
  LocaleKeys.logout: 'Sign out',
  LocaleKeys.admin: 'Admin',
  LocaleKeys.help: 'Help',
  LocaleKeys.guest: 'Guest',
  LocaleKeys.rclUser: 'RCL user',
  LocaleKeys.filterNews: 'Filter news',
  LocaleKeys.enterNewsName: 'Enter the news title',
  LocaleKeys.myDrafts: 'My drafts',
  LocaleKeys.rejectedNews: 'Rejected articles',
  LocaleKeys.deletedNews: 'Deleted articles',
  LocaleKeys.newsReview: 'Article review',
  LocaleKeys.chipRevision: 'In review',
  LocaleKeys.chipDrafts: 'Drafts',
  LocaleKeys.chipRejected: 'Rejected',
  LocaleKeys.chipDeleted: 'Deleted',
  LocaleKeys.backToNewsCenter: 'Back to news center',
  LocaleKeys.back: 'Back',
  LocaleKeys.changeCity: 'Change city',
  LocaleKeys.cityLabel: 'City: @city',
  LocaleKeys.allCities: 'All cities',
  LocaleKeys.refreshDataError:
      'Could not update the data. Check your connection.',

  // ===== Boas-vindas e atualizações =====
  LocaleKeys.welcomeTitle: 'Welcome!',
  LocaleKeys.welcomeMessage:
      'We prepared your daily dose of information with real facts and zero fake news.',
  LocaleKeys.tapToContinue: 'Tap to continue',
  LocaleKeys.releaseNotesTitle: "What's new in this update",
  LocaleKeys.updateDownloaded: 'Update downloaded successfully!',
  LocaleKeys.newVersionAvailable: 'New version available',
  LocaleKeys.mandatoryUpdateMessage:
      'A required update is needed to keep using the app.',
  LocaleKeys.optionalUpdateMessage:
      'A new version is available! Would you like to update now?',
  // ===== Login =====
  LocaleKeys.loginWithGoogle: 'Sign in with Google',
  LocaleKeys.loginWithMicrosoft: 'Sign in with Microsoft',
  LocaleKeys.loginWithApple: 'Sign in with Apple',
  LocaleKeys.loginAnonymously: 'Sign in anonymously',
  LocaleKeys.loginGoogleError:
      'An error occurred while signing in with Google. Please try again.',
  LocaleKeys.loginMicrosoftError:
      'An error occurred while signing in with Microsoft. Please try again.',
  LocaleKeys.loginAppleError:
      'An error occurred while signing in with Apple. Please try again.',

  // ===== Conexões =====
  LocaleKeys.connectionsDescription:
      'Manage and track the status of your external connections.',
  LocaleKeys.internet: 'Internet',
  LocaleKeys.internetDescription: 'General connectivity for the app modules.',
  LocaleKeys.statusActive: 'Active',
  LocaleKeys.statusFailed: 'Failed',

  // ===== Central de comunicação e web =====
  LocaleKeys.chats: 'Chats',
  LocaleKeys.couldNotOpenChat: 'Could not open the chat.',
  LocaleKeys.services: 'Services',
  LocaleKeys.pageUnderDevelopment: 'Page under development',
  LocaleKeys.couldNotOpenLink: 'Could not open the link',
  LocaleKeys.openingLinkNewTab: 'Opening link in a new tab...',

  // ===== Administração e papéis =====
  LocaleKeys.manageUsers: 'Manage users',
  LocaleKeys.chooseCityToManageEditors:
      'Choose the city to manage editors and administrators',
  LocaleKeys.registeredUsers: 'Registered users',
  LocaleKeys.filterAll: 'All',
  LocaleKeys.filterUsers: 'Users',
  LocaleKeys.filterEditors: 'Editors',
  LocaleKeys.filterAdmins: 'Admins',
  LocaleKeys.noUserFound: 'No users found',
  LocaleKeys.roleUser: 'User',
  LocaleKeys.roleEditor: 'Editor',
  LocaleKeys.roleAdmin: 'Administrator',
  LocaleKeys.roleUpdatedSuccess: 'Role updated successfully',
  LocaleKeys.roleUpdateError: 'An error occurred while updating the role',
  LocaleKeys.citiesUpdatedSuccess: 'Cities updated successfully',
  LocaleKeys.citiesUpdateError: 'An error occurred while updating the cities',
  LocaleKeys.changeOperationCities: 'Change operating cities',
  LocaleKeys.operationCities: 'Operating cities',
  LocaleKeys.operationCitiesLabel: 'Operating cities:',
  LocaleKeys.selectCitiesFor: 'Select the cities for:\n@email',
  LocaleKeys.selectAtLeastOneCityForEditor:
      'Select at least one city for the editor.',
  LocaleKeys.confirmChange: 'Confirm change',
  LocaleKeys.changeRoleMessage: 'Change role of @email\nFrom: @from\nTo: @to',

  // ===== Perfil do usuário =====
  LocaleKeys.profile: 'My profile',
  LocaleKeys.yourData: 'Your data',
  LocaleKeys.updateDisplayName: 'Update your display name',
  LocaleKeys.name: 'Name',
  LocaleKeys.enterYourName: 'Enter your name',
  LocaleKeys.saveChanges: 'Save changes',
  LocaleKeys.memberSince: 'Member since @date',
  LocaleKeys.favoriteCity: 'Favorite city',
  LocaleKeys.favoriteCityInfo: 'News from this city appear on the home screen.',
  LocaleKeys.noCitySelected: 'No city selected',
  LocaleKeys.operationCitiesInfo:
      'Cities where you can publish. They are set by the administrator.',
  LocaleKeys.noOperationCities: 'No city set',
  LocaleKeys.dangerZone: 'Danger zone',
  LocaleKeys.deleteAccount: 'Delete account',
  LocaleKeys.deleteAccountWarning:
      'Deleting the account removes access and linked data.',
  LocaleKeys.confirmDeletion: 'Confirm deletion',
  LocaleKeys.confirmDeleteAccountMessage:
      'Are you sure you want to delete your account? This action cannot be undone and all data will be lost.',
  LocaleKeys.invalidName: 'Please enter a valid name.',
  LocaleKeys.nameUpdatedSuccess: 'Name updated successfully.',
  LocaleKeys.nameUpdateError: 'Could not update the name.',
  LocaleKeys.accountDeletedSuccess: 'Your account was deleted successfully.',
  LocaleKeys.accountDeleteError: 'Could not delete the account.',
  LocaleKeys.loginAgain: 'Your session has expired. Please sign in again.',
  LocaleKeys.loginAgainBeforeDelete:
      'For security, please sign in again before deleting your account.',

  // ===== Central da matéria =====
  LocaleKeys.createNewNews: 'Create new article',
  LocaleKeys.createNewNewsSubtitle: 'Start creating a new article',
  LocaleKeys.reviewNews: 'Review articles',
  LocaleKeys.reviewNewsSubtitle: 'Editorial review and approval queue',
  LocaleKeys.viewDrafts: 'View your drafts',
  LocaleKeys.viewDraftsSubtitle: 'Access your articles saved as drafts',
  LocaleKeys.viewRejected: 'View your rejected articles',
  LocaleKeys.viewRejectedSubtitle: 'See what was sent back for changes',
  LocaleKeys.viewDeleted: 'View your deleted articles',
  LocaleKeys.viewDeletedSubtitle: 'Check the deletion history',
  LocaleKeys.editorialPanel: 'Editorial panel',
  LocaleKeys.editorialPanelSubtitle:
      'Create and organize articles in a single place.',

  // ===== Criar e editar matéria =====
  LocaleKeys.addNews: 'Add article',
  LocaleKeys.editNews: 'Edit article',
  LocaleKeys.title: 'Title',
  LocaleKeys.titleRequired: 'The title is required.',
  LocaleKeys.subtitleOptional: 'Subtitle (optional)',
  LocaleKeys.newsBodyHint: 'Type the article body...',
  LocaleKeys.collaboratorsOptional: 'Collaborators (optional)',
  LocaleKeys.tapToAddCollaborators: 'Tap to add collaborators...',
  LocaleKeys.addCollaborators: 'Add collaborators',
  LocaleKeys.typeNameManually: 'Type a name manually...',
  LocaleKeys.projectEditors: 'Project editors:',
  LocaleKeys.nameNotProvided: 'Name not provided',
  LocaleKeys.selectCategories: 'Select the categories',
  LocaleKeys.selectAtLeastOneCategory: 'Select at least one category.',
  LocaleKeys.selectCity: 'Select the city',
  LocaleKeys.selectAtLeastOneCity: 'Select at least one city.',
  LocaleKeys.selectType: 'Select the type',
  LocaleKeys.selectAtLeastOneType: 'Select at least one type.',
  LocaleKeys.youtubeUrlOptional: 'YouTube URL (optional)',
  LocaleKeys.youtubeUrlPlaceholder: 'https://www.youtube.com/watch?v=...',
  LocaleKeys.pasteYoutubeLinkHere: 'Paste a YouTube video link here',
  LocaleKeys.addImage: 'Add image',
  LocaleKeys.changeImage: 'Change image',
  LocaleKeys.imageRequirements:
      'Large images will be compressed, which may reduce quality and slow down loading. For better display, landscape images are recommended.',
  LocaleKeys.publishNews: 'Publish article',
  LocaleKeys.saveDraft: 'Save draft',
  LocaleKeys.updateNews: 'Update and publish article',
  LocaleKeys.fillRequiredFields: 'Please fill in all required fields.',
  LocaleKeys.draftSavedSuccess: 'Draft saved successfully!',
  LocaleKeys.newsSentForReview: 'Article sent for review successfully!',
  LocaleKeys.newsUpdatedSuccess: 'Article updated successfully!',
  LocaleKeys.newsUpdateError: 'Could not update the article.',
  LocaleKeys.saveDraftError: 'Error saving the draft',
  LocaleKeys.publishNewsError: 'Error publishing the article',

  // ===== Guia de publicação =====
  LocaleKeys.publicationGuideTitle: 'Quick publishing guide – RCL',
  LocaleKeys.confirmPublication: 'Confirm publication',
  LocaleKeys.termsNewsClarity: '1. Clarity of the news',
  LocaleKeys.termsArticleClarity: '1. Clarity of the article',
  LocaleKeys.termsInfoQuality: '2. Quality of information',
  LocaleKeys.termsEthics: '3. Ethics and respect',
  LocaleKeys.termsImages: '4. Images and videos',
  LocaleKeys.termsTransparency: '5. Transparency',
  LocaleKeys.termShortTitle: 'The title is short and direct',
  LocaleKeys.termSimpleText: 'The text is simple, without difficult words',
  LocaleKeys.termNewsStructure:
      'The text has a beginning (the fact), a middle (explanation of the fact) and an end (outcome and authorized useful phone numbers and emails, if applicable)',
  LocaleKeys.termFactsChecked: 'I checked the facts and my sources are reliable',
  LocaleKeys.termSourcesIndicated:
      'I clearly stated where the information and images came from',
  LocaleKeys.termNoRumors:
      'I did not publish anything based only on rumors or social media',
  LocaleKeys.termNoPrejudice:
      'The article contains no prejudice, violence or offense',
  LocaleKeys.termPrivacy: 'I protected the privacy of children and victims',
  LocaleKeys.termNoManipulation:
      'I did not alter images, audio or videos in a misleading way',
  LocaleKeys.termNoAi: 'I did not generate images or videos with artificial intelligence',
  LocaleKeys.termNoCopy: 'I did not copy this news or parts of it from another source',
  LocaleKeys.termMediaRights:
      'I took the photos and videos or I have permission to use photos and videos taken by other people',
  LocaleKeys.termNoSensationalism:
      'The image is not sensationalist or embarrassing (such images must never be published)',
  LocaleKeys.termImageCredits:
      'At the end of the article, I identified the place, date and source of the images',
  LocaleKeys.termSigned: 'I signed the article with my name or profile',
  LocaleKeys.termGrammarReview: 'I proofread the text',
  LocaleKeys.termOpinionStructure:
      'The text has a beginning, middle and end, that is, it develops a complete argument',
  LocaleKeys.termRespectPeople:
      'If I mention people, I do it respectfully',
  LocaleKeys.termOpinionFactsChecked:
      'If I use facts and data to support my article, I declare that I checked all of them and that they contain no errors and are not fake news',
  LocaleKeys.termOpinionGrounded: 'My opinion in the text is well-founded',
  LocaleKeys.termOwnOpinion:
      'I take responsibility for the opinion and position I am publishing',

  // ===== Visualização e revisão de matérias =====
  LocaleKeys.infoOf: '@type information',
  LocaleKeys.contentOf: '@type content',
  LocaleKeys.author: 'Author',
  LocaleKeys.date: 'Date',
  LocaleKeys.city: 'City',
  LocaleKeys.type: 'Type',
  LocaleKeys.reviewer: 'Reviewer',
  LocaleKeys.category: 'Category',
  LocaleKeys.categories: 'Categories',
  LocaleKeys.allCategories: 'All categories',
  LocaleKeys.collaborators: 'Collaborators',
  LocaleKeys.noNewsAvailable: 'No news available',
  LocaleKeys.loadMoreNews: 'Load more articles',
  LocaleKeys.review: 'Review',
  LocaleKeys.observations: 'Notes',
  LocaleKeys.noObservationAvailable: 'No notes available',
  LocaleKeys.deleteType: 'Delete @type',
  LocaleKeys.confirmDeleteType: 'Are you sure you want to delete this @type?',
  LocaleKeys.chooseActionForNews: 'Choose an action for this article:',
  LocaleKeys.accept: 'Accept',
  LocaleKeys.reject: 'Reject',
  LocaleKeys.reasonToAccept: 'Reason for accepting',
  LocaleKeys.reasonToReject: 'Reason for rejecting',
  LocaleKeys.writeReason: 'Write the reason:',
  LocaleKeys.writeReasonHere: 'Write the reason here',
  LocaleKeys.secondsAgo: '@count seconds ago',
  LocaleKeys.minutesAgo: '@count minutes ago',
  LocaleKeys.hoursAgo: '@count hours ago',
  LocaleKeys.cannotReviewOwnNews: 'You cannot review your own article.',
  LocaleKeys.onlyAuthorCanDelete: 'Only the author can delete this article.',
  LocaleKeys.typeDeletedSuccess: '@type deleted successfully!',
  LocaleKeys.typeDeleteError: 'Could not delete this @type right now.',
  LocaleKeys.newsApprovedSuccess: 'Article approved successfully!',
  LocaleKeys.newsRejectedSuccess: 'Article rejected successfully!',
  LocaleKeys.newsReviewError: 'Could not review the article.',

  // ===== Categorias e tipos =====
  LocaleKeys.categoryPolitics: 'Politics',
  LocaleKeys.categorySecurity: 'Security',
  LocaleKeys.categoryEducation: 'Education',
  LocaleKeys.categoryHealth: 'Health',
  LocaleKeys.categoryTransport: 'Public transport and traffic',
  LocaleKeys.categoryEconomy: 'Economy',
  LocaleKeys.categoryJobs: 'Jobs and opportunities',
  LocaleKeys.categoryCulture: 'Culture',
  LocaleKeys.categoryTourism: 'Tourism and leisure',
  LocaleKeys.categorySports: 'Sports',
  LocaleKeys.categoryEnvironment: 'Environment',
  LocaleKeys.categoryInfrastructure: 'City infrastructure',
  LocaleKeys.categoryHousing: 'Housing',
  LocaleKeys.categoryTechnology: 'Technology',
  LocaleKeys.categoryCommunity: 'Community action',
  LocaleKeys.typeNews: 'News',
  LocaleKeys.typeOpinion: 'Opinion',

  // ===== Imagem, vídeo e localização =====
  LocaleKeys.noImageSelected: 'No image selected.',
  LocaleKeys.processingImage:
      'Processing your image... This may take a few seconds.',
  LocaleKeys.cropImageTitle: 'Edit image',
  LocaleKeys.errorProcessingImage: 'Error processing the image.',
  LocaleKeys.imageTooLarge: 'The image is still too large!',
  LocaleKeys.imageSelectedSuccess: 'Image selected successfully!',
  LocaleKeys.invalidYoutubeUrl: 'Invalid YouTube URL',
  LocaleKeys.watchOnYoutube: 'Watch on YouTube',
  LocaleKeys.locationRequestTitle: 'Location request',
  LocaleKeys.locationPermissionDescriptionAndroid:
      "The app would like to access your location to provide better information about your area. If you agree, select 'Confirm'. Otherwise, select 'Continue without location'.",
  LocaleKeys.locationPermissionDescriptionIos:
      'We use your location to show news closer to you.',
  LocaleKeys.allowLocation: 'Allow location',
  LocaleKeys.continueWithoutLocation: 'Continue without location',
  LocaleKeys.locationNotProvided: 'Location not provided',
  LocaleKeys.cityNotFound: 'City not found',
  LocaleKeys.errorUpdatingLocation: 'Error updating location',
  LocaleKeys.checkingLocationMessage: 'Please wait while we check your location',
};
