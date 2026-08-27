// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get activeAssignmentsTitle => 'Missions en cours';

  @override
  String activeAssignmentsCount(int count) {
    return 'Missions en cours ($count)';
  }

  @override
  String get activeAssignmentsSubtitle =>
      'Les tâches qui vous sont confiées — réalisez-les et demandez leur validation.';

  @override
  String get noActiveAssignments =>
      'Aucune mission en cours. Vos tâches apparaîtront ici lorsqu’un client vous engagera.';

  @override
  String get assignmentsLoadError =>
      'Impossible de charger vos missions. Réessayez.';

  @override
  String get requestCompletion => 'Demander la validation';

  @override
  String confirmRequestCompletion(String task) {
    return 'Avez-vous terminé « $task » ? Envoyez une demande de validation au client.';
  }

  @override
  String get awaitingClientApproval => 'En attente de validation du client';

  @override
  String get completionRequestSent =>
      'Demande envoyée. En attente de validation du client.';

  @override
  String get assignmentNoLongerActive =>
      'Cette mission n’est plus active. Actualisez pour voir son statut.';

  @override
  String get clientOffersTitle => 'Nouvelles offres en attente';

  @override
  String clientOffersWaiting(int count) {
    return 'Nouvelles offres en attente ($count)';
  }

  @override
  String get clientOffersSubtitle =>
      'Comparez les propositions et choisissez le meilleur prestataire.';

  @override
  String get clientOffersEmpty =>
      'Aucune nouvelle offre. Les propositions pour vos tâches apparaîtront ici.';

  @override
  String get clientOffersLoadError =>
      'Impossible de charger vos offres. Réessayez.';

  @override
  String get taskOffers => 'Propositions pour cette tâche';

  @override
  String get rejectOffer => 'Refuser';

  @override
  String get offerAccepted => 'Offre acceptée';

  @override
  String get offerRejected => 'Offre refusée';

  @override
  String get offerNoLongerAvailable =>
      'Cette offre n’est plus disponible. Actualisez les propositions.';

  @override
  String confirmAcceptOffer(String name, String task) {
    return 'Accepter l’offre de $name pour « $task » ? La tâche lui sera attribuée.';
  }

  @override
  String confirmRejectOffer(String name) {
    return 'Refuser l’offre de $name ?';
  }

  @override
  String get taskerAvailableTasks => 'Toutes les tâches disponibles';

  @override
  String get taskerBrowseInfo =>
      'Parcourez les tâches ouvertes de tous les clients et postulez. Seuls les clients peuvent publier des tâches.';

  @override
  String get taskerViewAndApply => 'Voir et postuler';

  @override
  String get clientTasksTitle => 'Mes tâches';

  @override
  String get clientTasksScope => 'Uniquement les tâches que vous avez publiées';

  @override
  String get clientTasksEmpty =>
      'Vous n’avez publié aucune tâche correspondant à ces filtres.';

  @override
  String clientTasksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tâches',
      one: '1 tâche',
    );
    return '$_temp0';
  }

  @override
  String get taskerNoComparison => 'Aucune activité sur la période précédente';

  @override
  String taskerPeriodChange(String change) {
    return '$change % par rapport à la période précédente';
  }

  @override
  String get taskerPeriodUnavailable =>
      'Les statistiques de cette période sont indisponibles. Mettez à jour le serveur et actualisez.';

  @override
  String get taskerAnalyticsPrivate =>
      'Uniquement vos revenus payés et vos tâches terminées. La comparaison porte sur la même durée de la période précédente.';

  @override
  String get taskerNoActivity =>
      'Vous n’avez aucun revenu ni tâche terminée enregistré sur cette période.';

  @override
  String get taskerDashboardLoadError =>
      'Impossible de charger votre tableau de bord';

  @override
  String get taskerDashboardRetryHint =>
      'Vérifiez votre connexion et connectez-vous à votre compte prestataire, puis réessayez.';

  @override
  String get adminLast7Days => '7 derniers jours';

  @override
  String get adminLast30Days => '30 derniers jours';

  @override
  String get adminStarted => 'Démarrées';

  @override
  String get adminNoPeriodActivity =>
      'Aucune activité de tâche enregistrée sur cette période.';

  @override
  String get adminNoCategoryActivity =>
      'Aucune tâche à regrouper par catégorie.';

  @override
  String get adminNoRecentActivity => 'Aucune tâche récente.';

  @override
  String get adminUnknownValue => 'Indisponible';

  @override
  String get adminPaidVolume => 'Montant payé';

  @override
  String get adminChartData => 'Voir les données du graphique';

  @override
  String adminAnalyticsDates(String timezone) {
    return 'Tâches publiées, démarrées et terminées par jour. Fuseau horaire : $timezone.';
  }

  @override
  String get clientDashboardReadySubtitle =>
      'Prêt à avancer dans vos projets aujourd’hui ?';

  @override
  String get clientDashboardPromoTitle => 'Un coup de main fait la différence';

  @override
  String get clientDashboardPromoSubtitle =>
      'Publiez une tâche et trouvez le bon professionnel pour votre maison.';

  @override
  String get clientDashboardLoadError =>
      'Impossible de charger votre tableau de bord. Vérifiez votre connexion et réessayez.';

  @override
  String get clientDashboardEmpty =>
      'Aucune tâche pour le moment. Publiez votre première tâche pour commencer.';

  @override
  String get clientDashboardNoRecentTasks =>
      'Aucune tâche correspondante parmi vos 10 dernières. Affichez tout pour consulter votre historique.';

  @override
  String get clientDashboardSuccessInfo =>
      'Le taux de réussite s’affiche uniquement si l’API le fournit. Un tiret indique une valeur indisponible, pas zéro.';

  @override
  String get clientDashboardPayments => 'Paiements';

  @override
  String get clientDashboardUnknownTime => 'Date indisponible';

  @override
  String get appName => 'lem3alam';

  @override
  String get loading => 'Chargement...';

  @override
  String get login => 'Connexion';

  @override
  String get register => 'Créer un compte';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get requiredField => 'Obligatoire';

  @override
  String get passwordTooShort => 'Minimum 8 caractères';

  @override
  String get passwordMismatch => 'Les mots de passe ne correspondent pas';

  @override
  String get passwordConfirm => 'Confirmer le mot de passe';

  @override
  String get name => 'Nom';

  @override
  String get phone => 'Téléphone';

  @override
  String get city => 'Ville';

  @override
  String get role => 'Rôle';

  @override
  String get client => 'Client';

  @override
  String get tasker => 'Prestataire';

  @override
  String get dashboard => 'Tableau de bord';

  @override
  String get logout => 'Déconnexion';

  @override
  String get welcomeBack => 'Bon retour';

  @override
  String get loginSubtitle => 'Connectez-vous pour accéder à votre compte';

  @override
  String get createAccountTitle => 'Créez votre compte';

  @override
  String get createAccountSubtitle =>
      'Saisissez vos informations pour créer un compte';

  @override
  String get tasks => 'Tâches';

  @override
  String get tasksSubtitle => 'Parcourir les tâches';

  @override
  String get createTask => 'Créer une tâche';

  @override
  String get editTask => 'Modifier la tâche';

  @override
  String get taskDetails => 'Détails de la tâche';

  @override
  String get deleteTask => 'Supprimer la tâche';

  @override
  String get apply => 'Postuler';

  @override
  String get applyToTask => 'Postuler à la tâche';

  @override
  String get proposal => 'Proposition';

  @override
  String get proposedBudget => 'Budget proposé';

  @override
  String get estimatedDuration => 'Durée estimée';

  @override
  String get submitApplication => 'Envoyer la proposition';

  @override
  String get applicationSubmitted => 'Proposition envoyée';

  @override
  String get delete => 'Supprimer';

  @override
  String get cancel => 'Annuler';

  @override
  String get confirmDeleteTask =>
      'Êtes-vous sûr de vouloir supprimer cette tâche ?';

  @override
  String get retry => 'Réessayer';

  @override
  String get unableToLoad => 'Impossible de charger les données';

  @override
  String get emptyTasksTitle => 'Aucune tâche';

  @override
  String get emptyTasksSubtitle =>
      'Créez une nouvelle tâche ou actualisez la page.';

  @override
  String get shortcuts => 'Raccourcis';

  @override
  String get tip => 'Astuce';

  @override
  String get tipText =>
      'Commencez par créer une tâche puis choisissez la meilleure offre.';

  @override
  String get remote => 'À distance';

  @override
  String get title => 'Titre';

  @override
  String get description => 'Description';

  @override
  String get category => 'Catégorie';

  @override
  String get addressOptional => 'Adresse (optionnel)';

  @override
  String get budgetMin => 'Budget minimum';

  @override
  String get budgetMax => 'Budget maximum';

  @override
  String get budgetType => 'Type de budget';

  @override
  String get urgency => 'Urgence';

  @override
  String get paymentMethodOptional => 'Mode de paiement (optionnel)';

  @override
  String get cash => 'Espèces';

  @override
  String get card => 'Carte';

  @override
  String get online => 'En ligne';

  @override
  String get save => 'Enregistrer';

  @override
  String get fixed => 'Fixe';

  @override
  String get hourly => 'Horaire';

  @override
  String get negotiable => 'Négociable';

  @override
  String get urgencyLow => 'Faible';

  @override
  String get urgencyMedium => 'Moyenne';

  @override
  String get urgencyHigh => 'Élevée';

  @override
  String get urgencyUrgent => 'Urgente';

  @override
  String get statusOpen => 'Ouverte';

  @override
  String get statusAssigned => 'Assignée';

  @override
  String get statusInProgress => 'En cours';

  @override
  String get statusCompleted => 'Terminée';

  @override
  String get statusCancelled => 'Annulée';

  @override
  String get lang => 'Langue';

  @override
  String get langAr => 'Arabe';

  @override
  String get langEn => 'Anglais';

  @override
  String get langFr => 'Français';

  @override
  String get languageAction => 'Langue';

  @override
  String get refreshAction => 'Actualiser';

  @override
  String get reload => 'Recharger';

  @override
  String get popularCategories => 'Catégories populaires';

  @override
  String get all => 'Toutes';

  @override
  String get categories => 'Catégories';

  @override
  String get browseTasksByCategory => 'Parcourir les tâches par catégorie';

  @override
  String get nearbyArtisans => 'Artisans à proximité';

  @override
  String get seeTaskersOnMap => 'Voir les prestataires sur la carte';

  @override
  String get nearbyTasks => 'Tâches à proximité';

  @override
  String get jobsMatchedToYourLocation => 'Tâches adaptées à votre position';

  @override
  String get myProfile => 'Mon profil';

  @override
  String get publicTaskerProfile => 'Profil public du prestataire';

  @override
  String get myReviews => 'Mes avis';

  @override
  String get ratingsAndFeedback => 'Notes et retours';

  @override
  String get hello => 'Bonjour';

  @override
  String helloName(Object name) {
    return 'Bonjour, $name';
  }

  @override
  String get photos => 'Photos';

  @override
  String get add => 'Ajouter';

  @override
  String get addPhotosHelper =>
      'Ajoutez jusqu\'à 5 photos pour aider les prestataires à comprendre la mission.';

  @override
  String get locationSelected => 'Position sélectionnée';

  @override
  String get pickOnMap => 'Choisir sur la carte';

  @override
  String get clear => 'Effacer';

  @override
  String get cameraCaptureNotAvailableOnWeb =>
      'La capture photo n\'est pas disponible sur le web';

  @override
  String get maxTaskPhotos => 'Vous pouvez joindre jusqu\'à 5 photos';

  @override
  String get cameraPermission => 'Autorisation caméra';

  @override
  String get cameraPermissionPermanentlyDenied =>
      'L\'autorisation caméra est refusée de façon permanente. Veuillez l\'activer dans les réglages.';

  @override
  String get cameraPermissionRequired =>
      'L\'autorisation caméra est nécessaire pour prendre des photos.';

  @override
  String get close => 'Fermer';

  @override
  String get openSettings => 'Ouvrir les réglages';

  @override
  String cameraError(Object error) {
    return 'Erreur caméra : $error';
  }

  @override
  String get camera => 'Caméra';

  @override
  String get switchCamera => 'Changer de caméra';

  @override
  String get noCameraFound => 'Aucune caméra trouvée sur cet appareil.';

  @override
  String get retake => 'Reprendre';

  @override
  String get usePhoto => 'Utiliser la photo';

  @override
  String get location => 'Position';

  @override
  String get viewProfile => 'Voir le profil';

  @override
  String newHighPriorityNearbyTasksFound(int count) {
    return '$count nouvelle(s) tâche(s) proche(s) à haute priorité trouvée(s).';
  }

  @override
  String get enableNearbyTaskMatching =>
      'Activer la détection des tâches à proximité';

  @override
  String get nearbyTasksConsentSubtitle =>
      'Nous utilisons votre position uniquement après votre consentement, et le flux se rafraîchit à un rythme respectueux de la batterie.';

  @override
  String get nearbyTasksConsentBody =>
      'La position sert à trouver des missions proches dans le rayon choisi et à améliorer la pertinence selon votre profil de prestataire.';

  @override
  String get allowLocationBasedNearbyTasks =>
      'Autoriser les tâches proches basées sur la position';

  @override
  String get feedControls => 'Contrôles du flux';

  @override
  String radiusAdjustable(int min, int max) {
    return 'Le rayon peut être ajusté de $min km à $max km.';
  }

  @override
  String lastRefreshedAt(Object time) {
    return 'Dernière actualisation $time';
  }

  @override
  String radiusLabel(int radius) {
    return 'Rayon : $radius km';
  }

  @override
  String get savedOnly => 'Enregistrées uniquement';

  @override
  String get savedStatus => 'Enregistrée';

  @override
  String get locationAccuracyLow =>
      'La précision de la position est actuellement faible. Déplacez-vous dans un endroit dégagé ou actualisez pour de meilleurs résultats.';

  @override
  String get noNearbyTasks => 'Aucune tâche à proximité';

  @override
  String get noNearbyTasksSubtitle =>
      'Essayez d\'augmenter le rayon ou de désactiver le mode enregistrées uniquement.';

  @override
  String get locationDisabled => 'Localisation désactivée';

  @override
  String get locationServicesRequired =>
      'Veuillez activer les services GPS/localisation.';

  @override
  String get locationDisabledNearbyTasksMessage =>
      'Veuillez activer les services de localisation pour garder les tâches proches précises.';

  @override
  String get permissionRequired => 'Autorisation requise';

  @override
  String get permissionBlocked => 'Autorisation bloquée';

  @override
  String get locationPermissionPermanentlyDenied =>
      'L\'autorisation de localisation est refusée définitivement. Activez-la dans les réglages.';

  @override
  String get locationPermissionRequiredNearbyArtisans =>
      'L\'autorisation de localisation est requise pour afficher les artisans proches.';

  @override
  String get allowLocationAccessNearbyTasks =>
      'Autorisez l\'accès à la position pour charger les tâches proches.';

  @override
  String get enablePermissionInSettings =>
      'L\'autorisation de localisation a été refusée définitivement. Activez-la dans les réglages de l\'application.';

  @override
  String get unableToLoadNearbyTasks =>
      'Impossible de charger les tâches proches';

  @override
  String get distanceUnavailable => 'Distance indisponible';

  @override
  String clientRatingLabel(Object rating) {
    return 'Client $rating';
  }

  @override
  String get applicationSubmittedNearbyTask =>
      'Candidature envoyée pour cette tâche proche.';

  @override
  String get accept => 'Accepter';

  @override
  String get dismiss => 'Ignorer';

  @override
  String get goToHome => 'Aller à l\'accueil';

  @override
  String get home => 'Accueil';

  @override
  String get openLocationSettings => 'Ouvrir les réglages de localisation';

  @override
  String get loginRequired => 'Connexion requise';

  @override
  String get couldNotLoadNearbyArtisans =>
      'Impossible de charger les artisans proches.';

  @override
  String get noLocation => 'Aucune position';

  @override
  String get artisans => 'Artisans';

  @override
  String get noArtisansFoundNearby => 'Aucun artisan trouvé à proximité.';

  @override
  String get go => 'Aller';

  @override
  String get center => 'Centrer';

  @override
  String get directions => 'Itinéraire';

  @override
  String distanceAway(Object distance) {
    return 'À $distance km';
  }

  @override
  String get couldNotOpenNavigationApp =>
      'Impossible d\'ouvrir l\'application de navigation.';

  @override
  String get goToFirstPage => 'Aller à la première page';

  @override
  String get goToPreviousPage => 'Aller à la page précédente';

  @override
  String get goToNextPage => 'Aller à la page suivante';

  @override
  String get goToLastPage => 'Aller à la dernière page';

  @override
  String get reviews => 'Avis';

  @override
  String get noReviews => 'Aucun avis';

  @override
  String get noReviewsMatchFilters => 'Aucun avis ne correspond à vos filtres.';

  @override
  String get allRatings => 'Toutes les notes';

  @override
  String starsCount(int count) {
    return '$count étoiles';
  }

  @override
  String get oneStar => '1 étoile';

  @override
  String get rating => 'Note';

  @override
  String get sort => 'Tri';

  @override
  String get newest => 'Plus récents';

  @override
  String get oldest => 'Plus anciens';

  @override
  String get highestRating => 'Meilleure note';

  @override
  String get lowestRating => 'Note la plus basse';

  @override
  String get fromDate => 'Du';

  @override
  String get toDate => 'Au';

  @override
  String get clearDates => 'Effacer les dates';

  @override
  String get anonymous => 'Anonyme';

  @override
  String get taskerProfile => 'Profil du prestataire';

  @override
  String get about => 'À propos';

  @override
  String get noBioProvided => 'Aucune biographie fournie.';

  @override
  String get seeAll => 'Voir tout';

  @override
  String get greetingMorning => 'Bonjour,';

  @override
  String get greetingEvening => 'Bonsoir,';

  @override
  String get searchTasksHint => 'Rechercher un service ou une tâche...';

  @override
  String get promoTodayTitle => 'Besoin d\'aide aujourd\'hui ?';

  @override
  String get promoTodaySubtitle =>
      'Réservez un expert de confiance en quelques minutes.';

  @override
  String get bookNow => 'Réserver maintenant';

  @override
  String get recommendedForYou => 'Recommandé pour vous';

  @override
  String get pickedForYourNeeds =>
      'Basé sur votre activité et votre localisation';

  @override
  String get inCategory => 'Sélectionné dans cette catégorie';

  @override
  String get allTasks => 'Toutes les tâches';

  @override
  String tasksAvailableCount(int count) {
    return '$count disponibles';
  }

  @override
  String get nearby => 'Proche de moi';

  @override
  String get needService => 'Je cherche un service';

  @override
  String get needServiceSubtitle =>
      'Réservez un professionnel en quelques minutes.';

  @override
  String get wantWork => 'Je veux travailler';

  @override
  String get wantWorkSubtitle =>
      'Proposez vos services et gagnez de l\'argent.';

  @override
  String get more => 'Plus';

  @override
  String get personalInformation => 'Informations personnelles';

  @override
  String get personalInformationSubtitle =>
      'Nous utiliserons ces informations pour créer votre profil.';

  @override
  String get security => 'Sécurité';

  @override
  String get securitySubtitle => 'Utilisez un mot de passe fort et unique.';

  @override
  String get noAccountYet => 'Vous n\'avez pas de compte ?';

  @override
  String get alreadyHaveAccount => 'Vous avez déjà un compte ?';

  @override
  String get passwordHint =>
      'Utilisez 8 caractères minimum, avec des lettres, chiffres et symboles.';

  @override
  String reviewsCount(Object rating, int count) {
    return '$rating · $count avis';
  }

  @override
  String get noReviewsYet => 'Aucun avis pour le moment.';

  @override
  String get whatPeopleSayAboutThisTasker =>
      'Ce que les gens disent de ce prestataire.';

  @override
  String get available => 'Disponible';

  @override
  String get busy => 'Occupé';

  @override
  String get contact => 'Contacter';

  @override
  String get bookService => 'Réserver un service';

  @override
  String serviceRequestForName(Object name) {
    return 'Demande de service pour $name';
  }

  @override
  String bookServiceDescription(Object name) {
    return 'Bonjour $name, je souhaite réserver un service. Merci de me contacter.';
  }

  @override
  String get noPhoneNumber => 'Aucun numéro de téléphone';

  @override
  String get serviceArea => 'Zone de service';

  @override
  String get address => 'Adresse';

  @override
  String get pricing => 'Tarification';

  @override
  String get verification => 'Vérification';

  @override
  String get details => 'Détails';

  @override
  String get verified => 'Vérifié';

  @override
  String get unverified => 'Non vérifié';

  @override
  String get skills => 'Compétences';

  @override
  String get noSkillsListed => 'Aucune compétence renseignée.';

  @override
  String yearsCount(int count) {
    return '$count ans';
  }

  @override
  String get availability => 'Disponibilité';

  @override
  String get availableToTakeNewWork => 'Disponible pour de nouveaux travaux';

  @override
  String get currentlyBusy => 'Actuellement occupé';

  @override
  String get social => 'Réseaux sociaux';

  @override
  String get noSocialAccounts => 'Aucun compte social.';

  @override
  String get gallery => 'Galerie';

  @override
  String get noPhotosYet => 'Aucune photo pour le moment.';

  @override
  String get noCategories => 'Aucune catégorie';

  @override
  String get tryAgainLater => 'Réessayez plus tard.';

  @override
  String get pickLocation => 'Choisir l\'emplacement';

  @override
  String get confirmLocation => 'Confirmer l\'emplacement';

  @override
  String get locationPermissionRequiredToPick =>
      'L\'autorisation de localisation est requise pour choisir un emplacement.';

  @override
  String get couldNotLoadMap => 'Impossible de charger la carte.';

  @override
  String get searchUsers => 'Rechercher des utilisateurs';

  @override
  String get searchCity => 'Rechercher une ville';

  @override
  String get adminWorkspace => 'Espace administrateur';

  @override
  String get overview => 'Vue d\'ensemble';

  @override
  String get users => 'Utilisateurs';

  @override
  String get reports => 'Signalements';

  @override
  String get settings => 'Paramètres';

  @override
  String signedInAs(Object email, Object role) {
    return 'Connecté en tant que $email ($role)';
  }

  @override
  String get usersMetric => 'Utilisateurs';

  @override
  String get tasksMetric => 'Tâches';

  @override
  String get openDisputes => 'Litiges ouverts';

  @override
  String get revenue => 'Revenus';

  @override
  String get operationalSnapshot => 'Aperçu opérationnel';

  @override
  String get operationalSnapshotSubtitle =>
      'Correspond aux données admin déjà utilisées par la version web.';

  @override
  String get verifiedUsersLoadedPage =>
      'Utilisateurs vérifiés sur la page chargée';

  @override
  String get openReportsLoadedPage =>
      'Signalements ouverts sur la page chargée';

  @override
  String get mobileAdminParityPhase => 'Phase de parité admin mobile';

  @override
  String get overviewModerationReports =>
      'Vue d\'ensemble, modération, signalements';

  @override
  String get unableToLoadAdminOverview =>
      'Impossible de charger l\'aperçu administrateur';

  @override
  String get checkConnectionOrAdminPermissions =>
      'Vérifiez votre connexion ou vos droits administrateur, puis réessayez.';

  @override
  String get userModeration => 'Modération des utilisateurs';

  @override
  String loadedUsersFromAdminApi(int loaded, int total) {
    return '$loaded utilisateurs chargés sur $total depuis l\'API admin.';
  }

  @override
  String get noUsersFound => 'Aucun utilisateur trouvé';

  @override
  String get tryDifferentSearchOrRefresh =>
      'Essayez un autre terme de recherche ou actualisez la page.';

  @override
  String get unableToLoadUsers => 'Impossible de charger les utilisateurs';

  @override
  String get adminUsersEndpointFailed =>
      'Le point d\'accès admin des utilisateurs n\'a pas répondu.';

  @override
  String get reportsComplaints => 'Signalements et réclamations';

  @override
  String loadedReportsFromSharedBackend(int loaded, int total) {
    return '$loaded signalements chargés sur $total depuis le backend partagé.';
  }

  @override
  String get noReportsFound => 'Aucun signalement trouvé';

  @override
  String get noUserReportsToModerate =>
      'Il n\'y a actuellement aucun signalement utilisateur à modérer.';

  @override
  String get unableToLoadReports => 'Impossible de charger les signalements';

  @override
  String get adminReportsEndpointFailed =>
      'Le point d\'accès admin des signalements n\'a pas répondu.';

  @override
  String get nearbyTaskSettingsUpdated =>
      'Les paramètres des tâches proches ont été mis à jour.';

  @override
  String get nearbyTaskControls => 'Contrôles des tâches proches';

  @override
  String get nearbyTaskControlsSubtitle =>
      'Ajustez le rayon par défaut, les limites, la fréquence de rafraîchissement et les alertes prioritaires pour les prestataires.';

  @override
  String get defaultRadiusKm => 'Rayon par défaut (km)';

  @override
  String get minimumRadiusKm => 'Rayon minimum (km)';

  @override
  String get maximumRadiusKm => 'Rayon maximum (km)';

  @override
  String get refreshIntervalMinutes => 'Intervalle d\'actualisation (minutes)';

  @override
  String get notifyFromUrgency => 'Notifier à partir de l\'urgence';

  @override
  String get enableHighPriorityAlerts => 'Activer les alertes haute priorité';

  @override
  String get saveSettings => 'Enregistrer les paramètres';

  @override
  String get unableToLoadSettings => 'Impossible de charger les paramètres';

  @override
  String get nearbyTaskSettingsEndpointFailed =>
      'Le point d\'accès des paramètres des tâches proches n\'a pas répondu.';

  @override
  String get noDescriptionProvided => 'Aucune description fournie.';

  @override
  String get verifyAction => 'Vérifier';

  @override
  String get ban => 'Bannir';

  @override
  String get unban => 'Débannir';

  @override
  String get suspend7Days => 'Suspendre 7 jours';

  @override
  String get unsuspend => 'Lever la suspension';

  @override
  String get resolve => 'Résoudre';

  @override
  String get mondayShort => 'Lun';

  @override
  String get tuesdayShort => 'Mar';

  @override
  String get wednesdayShort => 'Mer';

  @override
  String get thursdayShort => 'Jeu';

  @override
  String get fridayShort => 'Ven';

  @override
  String get saturdayShort => 'Sam';

  @override
  String get sundayShort => 'Dim';

  @override
  String get errNetwork =>
      'Impossible de joindre le serveur. Vérifiez votre connexion et réessayez.';

  @override
  String get errTimeout => 'Délai de connexion dépassé. Réessayez.';

  @override
  String get errCancelled => 'Requête annulée.';

  @override
  String get errUnauthorized => 'Vous devez vous connecter pour continuer.';

  @override
  String get errForbidden => 'Vous n\'avez pas la permission.';

  @override
  String get errNotFound => 'Ressource introuvable.';

  @override
  String get errServer => 'Erreur serveur. Réessayez plus tard.';

  @override
  String get errUnknown => 'Une erreur est survenue. Réessayez.';

  @override
  String get chat => 'Discuter';

  @override
  String get readMore => 'Lire la suite';

  @override
  String get readLess => 'Réduire';

  @override
  String get services => 'Services';

  @override
  String get topRated => 'Top noté';

  @override
  String verifiedYears(int count) {
    return '$count+ ans';
  }

  @override
  String get verifiedIdentity => 'Vérifié';

  @override
  String daysAgo(int count) {
    return 'Il y a $count jours';
  }

  @override
  String weeksAgo(int count) {
    return 'Il y a $count semaines';
  }

  @override
  String get writeReview => 'Écrire un avis';

  @override
  String get helpful => 'Utile';

  @override
  String get notHelpful => 'Pas utile';

  @override
  String showReviewsForRating(int rating) {
    return 'Afficher $rating★ seulement';
  }

  @override
  String get sortByNewest => 'Plus récents';

  @override
  String get sortByTopRated => 'Mieux notés';

  @override
  String get noCommentProvided => 'Aucun commentaire fourni.';

  @override
  String get shareYourExperience =>
      'Partagez votre expérience avec ce prestataire…';

  @override
  String get submitReview => 'Envoyer l\'avis';

  @override
  String get selectRatingFirst => 'Sélectionnez d\'abord une note';

  @override
  String get notProvided => 'Non renseigné';

  @override
  String get acceptingNewBookings => 'Accepte de nouvelles réservations';

  @override
  String get mon => 'Lun';

  @override
  String get tue => 'Mar';

  @override
  String get wed => 'Mer';

  @override
  String get thu => 'Jeu';

  @override
  String get fri => 'Ven';

  @override
  String get sat => 'Sam';

  @override
  String get sun => 'Dim';

  @override
  String get unavailable => 'Indisponible';

  @override
  String get socialLinks => 'Réseaux sociaux';

  @override
  String get portfolio => 'Portfolio';

  @override
  String portfolioSubtitle(int count) {
    return '$count réalisations';
  }

  @override
  String get availableTodayHint => 'Disponible aujourd\'hui';

  @override
  String get features => 'Mes atouts';

  @override
  String get statJobsCompleted => 'Tâches effectuées';

  @override
  String get statResponseTime => 'Temps de réponse';

  @override
  String get statCompletionRate => 'Taux de réussite';

  @override
  String get slotMorning => 'Matin';

  @override
  String get slotAfternoon => 'Après-midi';

  @override
  String get slotEvening => 'Soir';

  @override
  String dashboardGreeting(Object name) {
    return 'Bonjour, $name 👋';
  }

  @override
  String get dashboardReadySubtitle => 'Prêt à aider et à gagner aujourd’hui ?';

  @override
  String get dashboardOnline => 'En ligne';

  @override
  String get dashboardOffline => 'Hors ligne';

  @override
  String get dashboardMenu => 'Ouvrir le menu du tableau de bord';

  @override
  String get dashboardNotifications => 'Notifications';

  @override
  String get dashboardProfile => 'Profil';

  @override
  String get dashboardAppearance => 'Apparence';

  @override
  String get dashboardLightMode => 'Mode clair';

  @override
  String get dashboardDarkMode => 'Mode sombre';

  @override
  String get dashboardActiveTasks => 'Tâches actives';

  @override
  String get dashboardCompleted => 'Terminées';

  @override
  String get dashboardTotalEarnings => 'Revenus totaux';

  @override
  String get dashboardRating => 'Note';

  @override
  String get dashboardCurrencyMad => 'MAD';

  @override
  String get dashboardSuccessRate => 'Taux de réussite';

  @override
  String get dashboardViewDetails => 'Voir les détails';

  @override
  String get dashboardRecentTasks => 'Tâches récentes';

  @override
  String get dashboardViewAll => 'Tout voir';

  @override
  String dashboardPendingCount(int count) {
    return 'En attente ($count)';
  }

  @override
  String dashboardAcceptedCount(int count) {
    return 'Acceptées ($count)';
  }

  @override
  String get dashboardCompletedFilter => 'Terminées';

  @override
  String get dashboardRepairWashingMachine => 'Réparer une machine à laver';

  @override
  String get dashboardFixKitchenFaucet => 'Réparer le robinet de cuisine';

  @override
  String get dashboardInstallLedLights => 'Installer des éclairages LED';

  @override
  String get dashboardRabatMorocco => 'Rabat, Maroc';

  @override
  String get dashboardCasablancaMorocco => 'Casablanca, Maroc';

  @override
  String get dashboardMarrakechMorocco => 'Marrakech, Maroc';

  @override
  String get dashboardHomeAppliance => 'Électroménager';

  @override
  String get dashboardPlumbing => 'Plomberie';

  @override
  String get dashboardElectrical => 'Électricité';

  @override
  String dashboardHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Il y a $count heures',
      one: 'Il y a 1 heure',
    );
    return '$_temp0';
  }

  @override
  String dashboardDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Il y a $count jours',
      one: 'Il y a 1 jour',
    );
    return '$_temp0';
  }

  @override
  String get dashboardStatusNew => 'Nouveau';

  @override
  String get dashboardStatusPending => 'En attente';

  @override
  String dashboardPrice(Object amount) {
    return '$amount MAD';
  }

  @override
  String get dashboardGrowBusiness => 'Développez votre activité';

  @override
  String get dashboardGrowBusinessSubtitle =>
      'Recevez plus de tâches et augmentez vos revenus';

  @override
  String get dashboardBoostProfile => 'Booster le profil';

  @override
  String get dashboardPostTask => 'Publier';

  @override
  String get dashboardMessages => 'Messages';

  @override
  String get dashboardEarnings => 'Revenus';

  @override
  String get dashboardPerformance => 'Performance';

  @override
  String get dashboardThisWeek => 'Cette semaine';

  @override
  String get dashboardThisMonth => 'Ce mois-ci';

  @override
  String get dashboardTasksCompleted => 'Tâches terminées';

  @override
  String dashboardChangeVsLastWeek(int change) {
    return '$change % par rapport à la semaine dernière';
  }

  @override
  String get dashboardNoFilteredTasks =>
      'Aucune tâche dans cette catégorie pour le moment.';

  @override
  String dashboardFeatureUnavailable(Object feature) {
    return 'La fonctionnalité $feature arrive bientôt.';
  }

  @override
  String get adminDefaultName => 'Admin';

  @override
  String adminGreeting(Object name) {
    return 'Bonjour, $name 👋';
  }

  @override
  String get adminDashboardSubtitle =>
      'Voici ce qui se passe aujourd’hui sur votre plateforme.';

  @override
  String get adminAnalyticsFallback =>
      'Les statistiques en direct sont indisponibles. Le dernier aperçu est affiché.';

  @override
  String get adminTotalUsers => 'Utilisateurs';

  @override
  String get adminTotalTasks => 'Total des tâches';

  @override
  String get adminCompletedTasks => 'Tâches terminées';

  @override
  String get adminActiveTaskers => 'Prestataires actifs';

  @override
  String get adminPendingTasks => 'Tâches en attente';

  @override
  String get adminPendingReviews => 'Avis en attente';

  @override
  String get adminVsLast7Days => 'sur les 7 derniers jours';

  @override
  String get adminTasksOverview => 'Aperçu des tâches';

  @override
  String get adminPosted => 'Publiées';

  @override
  String get adminInProgress => 'En cours';

  @override
  String get adminTasksByStatus => 'Tâches par statut';

  @override
  String get adminTotal => 'Total';

  @override
  String get adminCancelled => 'Annulées';

  @override
  String get adminViewAllTasks => 'Voir toutes les tâches';

  @override
  String get adminTopCategories => 'Meilleures catégories';

  @override
  String adminTaskBy(Object customerName) {
    return 'par $customerName';
  }

  @override
  String adminMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes',
      one: '1 minute',
    );
    return 'il y a $_temp0';
  }

  @override
  String adminWeekShort(int number) {
    return 'S$number';
  }

  @override
  String get adminHomeRepairs => 'Réparations maison';

  @override
  String get adminCleaning => 'Nettoyage';

  @override
  String get adminPainting => 'Peinture';

  @override
  String get adminDetailedAnalyticsUnavailable =>
      'Les analyses détaillées apparaîtront lorsque l’API d’administration les fournira. Aucune donnée d’exemple n’est affichée.';

  @override
  String get dashboardLiveDataUnavailable =>
      'Les données du tableau de bord ne sont pas encore disponibles via l’API. Aucune tâche ni statistique d’exemple n’est affichée.';
}
