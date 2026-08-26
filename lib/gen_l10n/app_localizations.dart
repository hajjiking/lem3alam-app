import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'lem3alam'**
  String get appName;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredField;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Minimum 8 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// No description provided for @passwordConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get passwordConfirm;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @client.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get client;

  /// No description provided for @tasker.
  ///
  /// In en, this message translates to:
  /// **'Tasker'**
  String get tasker;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to access your account'**
  String get loginSubtitle;

  /// No description provided for @createAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get createAccountTitle;

  /// No description provided for @createAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your details to create a new account'**
  String get createAccountSubtitle;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// No description provided for @tasksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse tasks'**
  String get tasksSubtitle;

  /// No description provided for @createTask.
  ///
  /// In en, this message translates to:
  /// **'Create task'**
  String get createTask;

  /// No description provided for @editTask.
  ///
  /// In en, this message translates to:
  /// **'Edit task'**
  String get editTask;

  /// No description provided for @taskDetails.
  ///
  /// In en, this message translates to:
  /// **'Task details'**
  String get taskDetails;

  /// No description provided for @deleteTask.
  ///
  /// In en, this message translates to:
  /// **'Delete task'**
  String get deleteTask;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @applyToTask.
  ///
  /// In en, this message translates to:
  /// **'Apply to task'**
  String get applyToTask;

  /// No description provided for @proposal.
  ///
  /// In en, this message translates to:
  /// **'Proposal'**
  String get proposal;

  /// No description provided for @proposedBudget.
  ///
  /// In en, this message translates to:
  /// **'Proposed budget'**
  String get proposedBudget;

  /// No description provided for @estimatedDuration.
  ///
  /// In en, this message translates to:
  /// **'Estimated duration'**
  String get estimatedDuration;

  /// No description provided for @submitApplication.
  ///
  /// In en, this message translates to:
  /// **'Submit application'**
  String get submitApplication;

  /// No description provided for @applicationSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Application submitted'**
  String get applicationSubmitted;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirmDeleteTask.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this task?'**
  String get confirmDeleteTask;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @unableToLoad.
  ///
  /// In en, this message translates to:
  /// **'Unable to load data'**
  String get unableToLoad;

  /// No description provided for @emptyTasksTitle.
  ///
  /// In en, this message translates to:
  /// **'No tasks'**
  String get emptyTasksTitle;

  /// No description provided for @emptyTasksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a new task or refresh the page.'**
  String get emptyTasksSubtitle;

  /// No description provided for @shortcuts.
  ///
  /// In en, this message translates to:
  /// **'Shortcuts'**
  String get shortcuts;

  /// No description provided for @tip.
  ///
  /// In en, this message translates to:
  /// **'Tip'**
  String get tip;

  /// No description provided for @tipText.
  ///
  /// In en, this message translates to:
  /// **'Start by creating a task then choose the best offer.'**
  String get tipText;

  /// No description provided for @remote.
  ///
  /// In en, this message translates to:
  /// **'Remote'**
  String get remote;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @addressOptional.
  ///
  /// In en, this message translates to:
  /// **'Address (optional)'**
  String get addressOptional;

  /// No description provided for @budgetMin.
  ///
  /// In en, this message translates to:
  /// **'Minimum budget'**
  String get budgetMin;

  /// No description provided for @budgetMax.
  ///
  /// In en, this message translates to:
  /// **'Maximum budget'**
  String get budgetMax;

  /// No description provided for @budgetType.
  ///
  /// In en, this message translates to:
  /// **'Budget type'**
  String get budgetType;

  /// No description provided for @urgency.
  ///
  /// In en, this message translates to:
  /// **'Urgency'**
  String get urgency;

  /// No description provided for @paymentMethodOptional.
  ///
  /// In en, this message translates to:
  /// **'Payment method (optional)'**
  String get paymentMethodOptional;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @card.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get card;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @fixed.
  ///
  /// In en, this message translates to:
  /// **'Fixed'**
  String get fixed;

  /// No description provided for @hourly.
  ///
  /// In en, this message translates to:
  /// **'Hourly'**
  String get hourly;

  /// No description provided for @negotiable.
  ///
  /// In en, this message translates to:
  /// **'Negotiable'**
  String get negotiable;

  /// No description provided for @urgencyLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get urgencyLow;

  /// No description provided for @urgencyMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get urgencyMedium;

  /// No description provided for @urgencyHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get urgencyHigh;

  /// No description provided for @urgencyUrgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get urgencyUrgent;

  /// No description provided for @statusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get statusOpen;

  /// No description provided for @statusAssigned.
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get statusAssigned;

  /// No description provided for @statusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get statusInProgress;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @lang.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get lang;

  /// No description provided for @langAr.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get langAr;

  /// No description provided for @langEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEn;

  /// No description provided for @langFr.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get langFr;

  /// No description provided for @languageAction.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageAction;

  /// No description provided for @refreshAction.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refreshAction;

  /// No description provided for @reload.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get reload;

  /// No description provided for @popularCategories.
  ///
  /// In en, this message translates to:
  /// **'Popular categories'**
  String get popularCategories;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @browseTasksByCategory.
  ///
  /// In en, this message translates to:
  /// **'Browse tasks by category'**
  String get browseTasksByCategory;

  /// No description provided for @nearbyArtisans.
  ///
  /// In en, this message translates to:
  /// **'Nearby artisans'**
  String get nearbyArtisans;

  /// No description provided for @seeTaskersOnMap.
  ///
  /// In en, this message translates to:
  /// **'See taskers on the map'**
  String get seeTaskersOnMap;

  /// No description provided for @nearbyTasks.
  ///
  /// In en, this message translates to:
  /// **'Nearby tasks'**
  String get nearbyTasks;

  /// No description provided for @jobsMatchedToYourLocation.
  ///
  /// In en, this message translates to:
  /// **'Jobs matched to your location'**
  String get jobsMatchedToYourLocation;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My profile'**
  String get myProfile;

  /// No description provided for @publicTaskerProfile.
  ///
  /// In en, this message translates to:
  /// **'Public tasker profile'**
  String get publicTaskerProfile;

  /// No description provided for @myReviews.
  ///
  /// In en, this message translates to:
  /// **'My reviews'**
  String get myReviews;

  /// No description provided for @ratingsAndFeedback.
  ///
  /// In en, this message translates to:
  /// **'Ratings & feedback'**
  String get ratingsAndFeedback;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// No description provided for @helloName.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String helloName(Object name);

  /// No description provided for @photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @addPhotosHelper.
  ///
  /// In en, this message translates to:
  /// **'Add up to 5 photos to help taskers understand the job.'**
  String get addPhotosHelper;

  /// No description provided for @locationSelected.
  ///
  /// In en, this message translates to:
  /// **'Location selected'**
  String get locationSelected;

  /// No description provided for @pickOnMap.
  ///
  /// In en, this message translates to:
  /// **'Pick on map'**
  String get pickOnMap;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @cameraCaptureNotAvailableOnWeb.
  ///
  /// In en, this message translates to:
  /// **'Camera capture is not available on web'**
  String get cameraCaptureNotAvailableOnWeb;

  /// No description provided for @maxTaskPhotos.
  ///
  /// In en, this message translates to:
  /// **'You can attach up to 5 photos'**
  String get maxTaskPhotos;

  /// No description provided for @cameraPermission.
  ///
  /// In en, this message translates to:
  /// **'Camera permission'**
  String get cameraPermission;

  /// No description provided for @cameraPermissionPermanentlyDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is permanently denied. Please enable it in Settings.'**
  String get cameraPermissionPermanentlyDenied;

  /// No description provided for @cameraPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required to take photos.'**
  String get cameraPermissionRequired;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @cameraError.
  ///
  /// In en, this message translates to:
  /// **'Camera error: {error}'**
  String cameraError(Object error);

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @switchCamera.
  ///
  /// In en, this message translates to:
  /// **'Switch camera'**
  String get switchCamera;

  /// No description provided for @noCameraFound.
  ///
  /// In en, this message translates to:
  /// **'No camera found on this device.'**
  String get noCameraFound;

  /// No description provided for @retake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get retake;

  /// No description provided for @usePhoto.
  ///
  /// In en, this message translates to:
  /// **'Use Photo'**
  String get usePhoto;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @viewProfile.
  ///
  /// In en, this message translates to:
  /// **'View profile'**
  String get viewProfile;

  /// No description provided for @newHighPriorityNearbyTasksFound.
  ///
  /// In en, this message translates to:
  /// **'{count} new high-priority nearby task(s) found.'**
  String newHighPriorityNearbyTasksFound(int count);

  /// No description provided for @enableNearbyTaskMatching.
  ///
  /// In en, this message translates to:
  /// **'Enable nearby task matching'**
  String get enableNearbyTaskMatching;

  /// No description provided for @nearbyTasksConsentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We only use your location after you consent, and the feed refreshes at a battery-friendly interval.'**
  String get nearbyTasksConsentSubtitle;

  /// No description provided for @nearbyTasksConsentBody.
  ///
  /// In en, this message translates to:
  /// **'Location is used to find nearby jobs within your chosen radius and improve task relevance based on your tasker profile.'**
  String get nearbyTasksConsentBody;

  /// No description provided for @allowLocationBasedNearbyTasks.
  ///
  /// In en, this message translates to:
  /// **'Allow location-based nearby tasks'**
  String get allowLocationBasedNearbyTasks;

  /// No description provided for @feedControls.
  ///
  /// In en, this message translates to:
  /// **'Feed controls'**
  String get feedControls;

  /// No description provided for @radiusAdjustable.
  ///
  /// In en, this message translates to:
  /// **'Radius is adjustable from {min}km to {max}km.'**
  String radiusAdjustable(int min, int max);

  /// No description provided for @lastRefreshedAt.
  ///
  /// In en, this message translates to:
  /// **'Last refreshed {time}'**
  String lastRefreshedAt(Object time);

  /// No description provided for @radiusLabel.
  ///
  /// In en, this message translates to:
  /// **'Radius: {radius} km'**
  String radiusLabel(int radius);

  /// No description provided for @savedOnly.
  ///
  /// In en, this message translates to:
  /// **'Saved only'**
  String get savedOnly;

  /// No description provided for @savedStatus.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get savedStatus;

  /// No description provided for @locationAccuracyLow.
  ///
  /// In en, this message translates to:
  /// **'Location accuracy is currently low. Move to an open area or refresh for better nearby matching.'**
  String get locationAccuracyLow;

  /// No description provided for @noNearbyTasks.
  ///
  /// In en, this message translates to:
  /// **'No nearby tasks'**
  String get noNearbyTasks;

  /// No description provided for @noNearbyTasksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try increasing the radius or switch back from saved-only mode.'**
  String get noNearbyTasksSubtitle;

  /// No description provided for @locationDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location disabled'**
  String get locationDisabled;

  /// No description provided for @locationServicesRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enable GPS/location services.'**
  String get locationServicesRequired;

  /// No description provided for @locationDisabledNearbyTasksMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enable device location services to keep nearby tasks accurate.'**
  String get locationDisabledNearbyTasksMessage;

  /// No description provided for @permissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Permission required'**
  String get permissionRequired;

  /// No description provided for @permissionBlocked.
  ///
  /// In en, this message translates to:
  /// **'Permission blocked'**
  String get permissionBlocked;

  /// No description provided for @locationPermissionPermanentlyDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission is permanently denied. Enable it in Settings.'**
  String get locationPermissionPermanentlyDenied;

  /// No description provided for @locationPermissionRequiredNearbyArtisans.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required to show nearby artisans.'**
  String get locationPermissionRequiredNearbyArtisans;

  /// No description provided for @allowLocationAccessNearbyTasks.
  ///
  /// In en, this message translates to:
  /// **'Allow location access to load nearby tasks.'**
  String get allowLocationAccessNearbyTasks;

  /// No description provided for @enablePermissionInSettings.
  ///
  /// In en, this message translates to:
  /// **'Location permission was denied permanently. Enable it in app settings.'**
  String get enablePermissionInSettings;

  /// No description provided for @unableToLoadNearbyTasks.
  ///
  /// In en, this message translates to:
  /// **'Unable to load nearby tasks'**
  String get unableToLoadNearbyTasks;

  /// No description provided for @distanceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Distance n/a'**
  String get distanceUnavailable;

  /// No description provided for @clientRatingLabel.
  ///
  /// In en, this message translates to:
  /// **'Client {rating}'**
  String clientRatingLabel(Object rating);

  /// No description provided for @applicationSubmittedNearbyTask.
  ///
  /// In en, this message translates to:
  /// **'Application submitted for this nearby task.'**
  String get applicationSubmittedNearbyTask;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @goToHome.
  ///
  /// In en, this message translates to:
  /// **'Go to home'**
  String get goToHome;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @openLocationSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Location Settings'**
  String get openLocationSettings;

  /// No description provided for @loginRequired.
  ///
  /// In en, this message translates to:
  /// **'Login required'**
  String get loginRequired;

  /// No description provided for @couldNotLoadNearbyArtisans.
  ///
  /// In en, this message translates to:
  /// **'Could not load nearby artisans.'**
  String get couldNotLoadNearbyArtisans;

  /// No description provided for @noLocation.
  ///
  /// In en, this message translates to:
  /// **'No location'**
  String get noLocation;

  /// No description provided for @artisans.
  ///
  /// In en, this message translates to:
  /// **'Artisans'**
  String get artisans;

  /// No description provided for @noArtisansFoundNearby.
  ///
  /// In en, this message translates to:
  /// **'No artisans found nearby.'**
  String get noArtisansFoundNearby;

  /// No description provided for @go.
  ///
  /// In en, this message translates to:
  /// **'Go'**
  String get go;

  /// No description provided for @center.
  ///
  /// In en, this message translates to:
  /// **'Center'**
  String get center;

  /// No description provided for @directions.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get directions;

  /// No description provided for @distanceAway.
  ///
  /// In en, this message translates to:
  /// **'{distance} km away'**
  String distanceAway(Object distance);

  /// No description provided for @couldNotOpenNavigationApp.
  ///
  /// In en, this message translates to:
  /// **'Could not open navigation app.'**
  String get couldNotOpenNavigationApp;

  /// No description provided for @goToFirstPage.
  ///
  /// In en, this message translates to:
  /// **'Go to first page'**
  String get goToFirstPage;

  /// No description provided for @goToPreviousPage.
  ///
  /// In en, this message translates to:
  /// **'Go to previous page'**
  String get goToPreviousPage;

  /// No description provided for @goToNextPage.
  ///
  /// In en, this message translates to:
  /// **'Go to next page'**
  String get goToNextPage;

  /// No description provided for @goToLastPage.
  ///
  /// In en, this message translates to:
  /// **'Go to last page'**
  String get goToLastPage;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @noReviews.
  ///
  /// In en, this message translates to:
  /// **'No reviews'**
  String get noReviews;

  /// No description provided for @noReviewsMatchFilters.
  ///
  /// In en, this message translates to:
  /// **'No reviews match your filters.'**
  String get noReviewsMatchFilters;

  /// No description provided for @allRatings.
  ///
  /// In en, this message translates to:
  /// **'All ratings'**
  String get allRatings;

  /// No description provided for @starsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} stars'**
  String starsCount(int count);

  /// No description provided for @oneStar.
  ///
  /// In en, this message translates to:
  /// **'1 star'**
  String get oneStar;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @newest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get newest;

  /// No description provided for @oldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest'**
  String get oldest;

  /// No description provided for @highestRating.
  ///
  /// In en, this message translates to:
  /// **'Highest rating'**
  String get highestRating;

  /// No description provided for @lowestRating.
  ///
  /// In en, this message translates to:
  /// **'Lowest rating'**
  String get lowestRating;

  /// No description provided for @fromDate.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get fromDate;

  /// No description provided for @toDate.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get toDate;

  /// No description provided for @clearDates.
  ///
  /// In en, this message translates to:
  /// **'Clear dates'**
  String get clearDates;

  /// No description provided for @anonymous.
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get anonymous;

  /// No description provided for @taskerProfile.
  ///
  /// In en, this message translates to:
  /// **'Tasker Profile'**
  String get taskerProfile;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @noBioProvided.
  ///
  /// In en, this message translates to:
  /// **'No bio provided.'**
  String get noBioProvided;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning,'**
  String get greetingMorning;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening,'**
  String get greetingEvening;

  /// No description provided for @searchTasksHint.
  ///
  /// In en, this message translates to:
  /// **'Search services or tasks...'**
  String get searchTasksHint;

  /// No description provided for @promoTodayTitle.
  ///
  /// In en, this message translates to:
  /// **'Need help with something today?'**
  String get promoTodayTitle;

  /// No description provided for @promoTodaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Book trusted experts in minutes.'**
  String get promoTodaySubtitle;

  /// No description provided for @bookNow.
  ///
  /// In en, this message translates to:
  /// **'Book now'**
  String get bookNow;

  /// No description provided for @recommendedForYou.
  ///
  /// In en, this message translates to:
  /// **'Recommended for you'**
  String get recommendedForYou;

  /// No description provided for @pickedForYourNeeds.
  ///
  /// In en, this message translates to:
  /// **'Based on your activity and location'**
  String get pickedForYourNeeds;

  /// No description provided for @inCategory.
  ///
  /// In en, this message translates to:
  /// **'Selected in this category'**
  String get inCategory;

  /// No description provided for @allTasks.
  ///
  /// In en, this message translates to:
  /// **'All tasks'**
  String get allTasks;

  /// No description provided for @tasksAvailableCount.
  ///
  /// In en, this message translates to:
  /// **'{count} available'**
  String tasksAvailableCount(int count);

  /// No description provided for @nearby.
  ///
  /// In en, this message translates to:
  /// **'Near me'**
  String get nearby;

  /// No description provided for @needService.
  ///
  /// In en, this message translates to:
  /// **'I need a service'**
  String get needService;

  /// No description provided for @needServiceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Book a professional in minutes.'**
  String get needServiceSubtitle;

  /// No description provided for @wantWork.
  ///
  /// In en, this message translates to:
  /// **'I want to work'**
  String get wantWork;

  /// No description provided for @wantWorkSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Offer your services and earn.'**
  String get wantWorkSubtitle;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get personalInformation;

  /// No description provided for @personalInformationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll use this to build your profile.'**
  String get personalInformationSubtitle;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @securitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use a strong, unique password.'**
  String get securitySubtitle;

  /// No description provided for @noAccountYet.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccountYet;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Use 8+ characters with a mix of letters, numbers, and symbols.'**
  String get passwordHint;

  /// No description provided for @reviewsCount.
  ///
  /// In en, this message translates to:
  /// **'{rating} · {count} reviews'**
  String reviewsCount(Object rating, int count);

  /// No description provided for @noReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet.'**
  String get noReviewsYet;

  /// No description provided for @whatPeopleSayAboutThisTasker.
  ///
  /// In en, this message translates to:
  /// **'What people say about this tasker.'**
  String get whatPeopleSayAboutThisTasker;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @busy.
  ///
  /// In en, this message translates to:
  /// **'Busy'**
  String get busy;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @bookService.
  ///
  /// In en, this message translates to:
  /// **'Book Service'**
  String get bookService;

  /// No description provided for @serviceRequestForName.
  ///
  /// In en, this message translates to:
  /// **'Service request for {name}'**
  String serviceRequestForName(Object name);

  /// No description provided for @bookServiceDescription.
  ///
  /// In en, this message translates to:
  /// **'Hi {name}, I would like to book a service. Please contact me.'**
  String bookServiceDescription(Object name);

  /// No description provided for @noPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'No phone number'**
  String get noPhoneNumber;

  /// No description provided for @serviceArea.
  ///
  /// In en, this message translates to:
  /// **'Service area'**
  String get serviceArea;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @pricing.
  ///
  /// In en, this message translates to:
  /// **'Pricing'**
  String get pricing;

  /// No description provided for @verification.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get verification;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @unverified.
  ///
  /// In en, this message translates to:
  /// **'Unverified'**
  String get unverified;

  /// No description provided for @skills.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get skills;

  /// No description provided for @noSkillsListed.
  ///
  /// In en, this message translates to:
  /// **'No skills listed.'**
  String get noSkillsListed;

  /// No description provided for @yearsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} years'**
  String yearsCount(int count);

  /// No description provided for @availability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get availability;

  /// No description provided for @availableToTakeNewWork.
  ///
  /// In en, this message translates to:
  /// **'Available to take new work'**
  String get availableToTakeNewWork;

  /// No description provided for @currentlyBusy.
  ///
  /// In en, this message translates to:
  /// **'Currently busy'**
  String get currentlyBusy;

  /// No description provided for @social.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get social;

  /// No description provided for @noSocialAccounts.
  ///
  /// In en, this message translates to:
  /// **'No social accounts.'**
  String get noSocialAccounts;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @noPhotosYet.
  ///
  /// In en, this message translates to:
  /// **'No photos yet.'**
  String get noPhotosYet;

  /// No description provided for @noCategories.
  ///
  /// In en, this message translates to:
  /// **'No categories'**
  String get noCategories;

  /// No description provided for @tryAgainLater.
  ///
  /// In en, this message translates to:
  /// **'Try again later.'**
  String get tryAgainLater;

  /// No description provided for @pickLocation.
  ///
  /// In en, this message translates to:
  /// **'Pick location'**
  String get pickLocation;

  /// No description provided for @confirmLocation.
  ///
  /// In en, this message translates to:
  /// **'Confirm location'**
  String get confirmLocation;

  /// No description provided for @locationPermissionRequiredToPick.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required to pick a location.'**
  String get locationPermissionRequiredToPick;

  /// No description provided for @couldNotLoadMap.
  ///
  /// In en, this message translates to:
  /// **'Could not load map.'**
  String get couldNotLoadMap;

  /// No description provided for @searchUsers.
  ///
  /// In en, this message translates to:
  /// **'Search users'**
  String get searchUsers;

  /// No description provided for @searchCity.
  ///
  /// In en, this message translates to:
  /// **'Search city'**
  String get searchCity;

  /// No description provided for @adminWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Admin Workspace'**
  String get adminWorkspace;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @signedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {email} ({role})'**
  String signedInAs(Object email, Object role);

  /// No description provided for @usersMetric.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get usersMetric;

  /// No description provided for @tasksMetric.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasksMetric;

  /// No description provided for @openDisputes.
  ///
  /// In en, this message translates to:
  /// **'Open disputes'**
  String get openDisputes;

  /// No description provided for @revenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get revenue;

  /// No description provided for @operationalSnapshot.
  ///
  /// In en, this message translates to:
  /// **'Operational snapshot'**
  String get operationalSnapshot;

  /// No description provided for @operationalSnapshotSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Matches the backend admin datasets already used by the web app.'**
  String get operationalSnapshotSubtitle;

  /// No description provided for @verifiedUsersLoadedPage.
  ///
  /// In en, this message translates to:
  /// **'Verified users on loaded page'**
  String get verifiedUsersLoadedPage;

  /// No description provided for @openReportsLoadedPage.
  ///
  /// In en, this message translates to:
  /// **'Open reports on loaded page'**
  String get openReportsLoadedPage;

  /// No description provided for @mobileAdminParityPhase.
  ///
  /// In en, this message translates to:
  /// **'Mobile admin parity phase'**
  String get mobileAdminParityPhase;

  /// No description provided for @overviewModerationReports.
  ///
  /// In en, this message translates to:
  /// **'Overview, moderation, reports'**
  String get overviewModerationReports;

  /// No description provided for @unableToLoadAdminOverview.
  ///
  /// In en, this message translates to:
  /// **'Unable to load admin overview'**
  String get unableToLoadAdminOverview;

  /// No description provided for @checkConnectionOrAdminPermissions.
  ///
  /// In en, this message translates to:
  /// **'Check your connection or admin permissions, then try again.'**
  String get checkConnectionOrAdminPermissions;

  /// No description provided for @userModeration.
  ///
  /// In en, this message translates to:
  /// **'User Moderation'**
  String get userModeration;

  /// No description provided for @loadedUsersFromAdminApi.
  ///
  /// In en, this message translates to:
  /// **'Loaded {loaded} of {total} users from the admin API.'**
  String loadedUsersFromAdminApi(int loaded, int total);

  /// No description provided for @noUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get noUsersFound;

  /// No description provided for @tryDifferentSearchOrRefresh.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term or refresh the page.'**
  String get tryDifferentSearchOrRefresh;

  /// No description provided for @unableToLoadUsers.
  ///
  /// In en, this message translates to:
  /// **'Unable to load users'**
  String get unableToLoadUsers;

  /// No description provided for @adminUsersEndpointFailed.
  ///
  /// In en, this message translates to:
  /// **'The admin users endpoint failed to respond.'**
  String get adminUsersEndpointFailed;

  /// No description provided for @reportsComplaints.
  ///
  /// In en, this message translates to:
  /// **'Reports & Complaints'**
  String get reportsComplaints;

  /// No description provided for @loadedReportsFromSharedBackend.
  ///
  /// In en, this message translates to:
  /// **'Loaded {loaded} of {total} reports from the shared backend.'**
  String loadedReportsFromSharedBackend(int loaded, int total);

  /// No description provided for @noReportsFound.
  ///
  /// In en, this message translates to:
  /// **'No reports found'**
  String get noReportsFound;

  /// No description provided for @noUserReportsToModerate.
  ///
  /// In en, this message translates to:
  /// **'There are no user reports to moderate right now.'**
  String get noUserReportsToModerate;

  /// No description provided for @unableToLoadReports.
  ///
  /// In en, this message translates to:
  /// **'Unable to load reports'**
  String get unableToLoadReports;

  /// No description provided for @adminReportsEndpointFailed.
  ///
  /// In en, this message translates to:
  /// **'The admin reports endpoint failed to respond.'**
  String get adminReportsEndpointFailed;

  /// No description provided for @nearbyTaskSettingsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Nearby task settings updated.'**
  String get nearbyTaskSettingsUpdated;

  /// No description provided for @nearbyTaskControls.
  ///
  /// In en, this message translates to:
  /// **'Nearby task controls'**
  String get nearbyTaskControls;

  /// No description provided for @nearbyTaskControlsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Adjust default radius, limits, refresh cadence, and priority alerts for taskers.'**
  String get nearbyTaskControlsSubtitle;

  /// No description provided for @defaultRadiusKm.
  ///
  /// In en, this message translates to:
  /// **'Default radius (km)'**
  String get defaultRadiusKm;

  /// No description provided for @minimumRadiusKm.
  ///
  /// In en, this message translates to:
  /// **'Minimum radius (km)'**
  String get minimumRadiusKm;

  /// No description provided for @maximumRadiusKm.
  ///
  /// In en, this message translates to:
  /// **'Maximum radius (km)'**
  String get maximumRadiusKm;

  /// No description provided for @refreshIntervalMinutes.
  ///
  /// In en, this message translates to:
  /// **'Refresh interval (minutes)'**
  String get refreshIntervalMinutes;

  /// No description provided for @notifyFromUrgency.
  ///
  /// In en, this message translates to:
  /// **'Notify from urgency'**
  String get notifyFromUrgency;

  /// No description provided for @enableHighPriorityAlerts.
  ///
  /// In en, this message translates to:
  /// **'Enable high-priority alerts'**
  String get enableHighPriorityAlerts;

  /// No description provided for @saveSettings.
  ///
  /// In en, this message translates to:
  /// **'Save settings'**
  String get saveSettings;

  /// No description provided for @unableToLoadSettings.
  ///
  /// In en, this message translates to:
  /// **'Unable to load settings'**
  String get unableToLoadSettings;

  /// No description provided for @nearbyTaskSettingsEndpointFailed.
  ///
  /// In en, this message translates to:
  /// **'The nearby task settings endpoint failed to respond.'**
  String get nearbyTaskSettingsEndpointFailed;

  /// No description provided for @noDescriptionProvided.
  ///
  /// In en, this message translates to:
  /// **'No description provided.'**
  String get noDescriptionProvided;

  /// No description provided for @verifyAction.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyAction;

  /// No description provided for @ban.
  ///
  /// In en, this message translates to:
  /// **'Ban'**
  String get ban;

  /// No description provided for @unban.
  ///
  /// In en, this message translates to:
  /// **'Unban'**
  String get unban;

  /// No description provided for @suspend7Days.
  ///
  /// In en, this message translates to:
  /// **'Suspend 7 days'**
  String get suspend7Days;

  /// No description provided for @unsuspend.
  ///
  /// In en, this message translates to:
  /// **'Unsuspend'**
  String get unsuspend;

  /// No description provided for @resolve.
  ///
  /// In en, this message translates to:
  /// **'Resolve'**
  String get resolve;

  /// No description provided for @mondayShort.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get mondayShort;

  /// No description provided for @tuesdayShort.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tuesdayShort;

  /// No description provided for @wednesdayShort.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wednesdayShort;

  /// No description provided for @thursdayShort.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thursdayShort;

  /// No description provided for @fridayShort.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get fridayShort;

  /// No description provided for @saturdayShort.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get saturdayShort;

  /// No description provided for @sundayShort.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sundayShort;

  /// No description provided for @errNetwork.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach the server. Check your internet and try again.'**
  String get errNetwork;

  /// No description provided for @errTimeout.
  ///
  /// In en, this message translates to:
  /// **'Connection timed out. Try again.'**
  String get errTimeout;

  /// No description provided for @errCancelled.
  ///
  /// In en, this message translates to:
  /// **'Request cancelled.'**
  String get errCancelled;

  /// No description provided for @errUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'You need to login to continue.'**
  String get errUnauthorized;

  /// No description provided for @errForbidden.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to do that.'**
  String get errForbidden;

  /// No description provided for @errNotFound.
  ///
  /// In en, this message translates to:
  /// **'Resource not found.'**
  String get errNotFound;

  /// No description provided for @errServer.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try later.'**
  String get errServer;

  /// No description provided for @errUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errUnknown;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get readMore;

  /// No description provided for @readLess.
  ///
  /// In en, this message translates to:
  /// **'Read less'**
  String get readLess;

  /// No description provided for @services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services;

  /// No description provided for @topRated.
  ///
  /// In en, this message translates to:
  /// **'Top Rated'**
  String get topRated;

  /// No description provided for @verifiedYears.
  ///
  /// In en, this message translates to:
  /// **'{count}+ Years'**
  String verifiedYears(int count);

  /// No description provided for @verifiedIdentity.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verifiedIdentity;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String daysAgo(int count);

  /// No description provided for @weeksAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} weeks ago'**
  String weeksAgo(int count);

  /// No description provided for @writeReview.
  ///
  /// In en, this message translates to:
  /// **'Write a review'**
  String get writeReview;

  /// No description provided for @helpful.
  ///
  /// In en, this message translates to:
  /// **'Helpful'**
  String get helpful;

  /// No description provided for @notHelpful.
  ///
  /// In en, this message translates to:
  /// **'Not helpful'**
  String get notHelpful;

  /// No description provided for @showReviewsForRating.
  ///
  /// In en, this message translates to:
  /// **'Show {rating}★ only'**
  String showReviewsForRating(int rating);

  /// No description provided for @sortByNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get sortByNewest;

  /// No description provided for @sortByTopRated.
  ///
  /// In en, this message translates to:
  /// **'Top rated first'**
  String get sortByTopRated;

  /// No description provided for @noCommentProvided.
  ///
  /// In en, this message translates to:
  /// **'No comment provided.'**
  String get noCommentProvided;

  /// No description provided for @shareYourExperience.
  ///
  /// In en, this message translates to:
  /// **'Share your experience with this tasker…'**
  String get shareYourExperience;

  /// No description provided for @submitReview.
  ///
  /// In en, this message translates to:
  /// **'Submit review'**
  String get submitReview;

  /// No description provided for @selectRatingFirst.
  ///
  /// In en, this message translates to:
  /// **'Select a rating first'**
  String get selectRatingFirst;

  /// No description provided for @notProvided.
  ///
  /// In en, this message translates to:
  /// **'Not provided'**
  String get notProvided;

  /// No description provided for @acceptingNewBookings.
  ///
  /// In en, this message translates to:
  /// **'Accepting new bookings'**
  String get acceptingNewBookings;

  /// No description provided for @mon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get mon;

  /// No description provided for @tue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tue;

  /// No description provided for @wed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wed;

  /// No description provided for @thu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thu;

  /// No description provided for @fri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get fri;

  /// No description provided for @sat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get sat;

  /// No description provided for @sun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sun;

  /// No description provided for @unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get unavailable;

  /// No description provided for @socialLinks.
  ///
  /// In en, this message translates to:
  /// **'Social links'**
  String get socialLinks;

  /// No description provided for @portfolio.
  ///
  /// In en, this message translates to:
  /// **'Portfolio'**
  String get portfolio;

  /// No description provided for @portfolioSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} works'**
  String portfolioSubtitle(int count);

  /// No description provided for @availableTodayHint.
  ///
  /// In en, this message translates to:
  /// **'Available today'**
  String get availableTodayHint;

  /// No description provided for @features.
  ///
  /// In en, this message translates to:
  /// **'What I bring'**
  String get features;

  /// No description provided for @statJobsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Jobs completed'**
  String get statJobsCompleted;

  /// No description provided for @statResponseTime.
  ///
  /// In en, this message translates to:
  /// **'Response time'**
  String get statResponseTime;

  /// No description provided for @statCompletionRate.
  ///
  /// In en, this message translates to:
  /// **'Completion rate'**
  String get statCompletionRate;

  /// No description provided for @slotMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get slotMorning;

  /// No description provided for @slotAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get slotAfternoon;

  /// No description provided for @slotEvening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get slotEvening;

  /// No description provided for @dashboardGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name} 👋'**
  String dashboardGreeting(Object name);

  /// No description provided for @dashboardReadySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to help and earn today?'**
  String get dashboardReadySubtitle;

  /// No description provided for @dashboardOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get dashboardOnline;

  /// No description provided for @dashboardOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get dashboardOffline;

  /// No description provided for @dashboardMenu.
  ///
  /// In en, this message translates to:
  /// **'Open dashboard menu'**
  String get dashboardMenu;

  /// No description provided for @dashboardNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get dashboardNotifications;

  /// No description provided for @dashboardProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get dashboardProfile;

  /// No description provided for @dashboardAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get dashboardAppearance;

  /// No description provided for @dashboardLightMode.
  ///
  /// In en, this message translates to:
  /// **'Light mode'**
  String get dashboardLightMode;

  /// No description provided for @dashboardDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get dashboardDarkMode;

  /// No description provided for @dashboardActiveTasks.
  ///
  /// In en, this message translates to:
  /// **'Active Tasks'**
  String get dashboardActiveTasks;

  /// No description provided for @dashboardCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get dashboardCompleted;

  /// No description provided for @dashboardTotalEarnings.
  ///
  /// In en, this message translates to:
  /// **'Total Earnings'**
  String get dashboardTotalEarnings;

  /// No description provided for @dashboardRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get dashboardRating;

  /// No description provided for @dashboardCurrencyMad.
  ///
  /// In en, this message translates to:
  /// **'MAD'**
  String get dashboardCurrencyMad;

  /// No description provided for @dashboardSuccessRate.
  ///
  /// In en, this message translates to:
  /// **'Success Rate'**
  String get dashboardSuccessRate;

  /// No description provided for @dashboardViewDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get dashboardViewDetails;

  /// No description provided for @dashboardRecentTasks.
  ///
  /// In en, this message translates to:
  /// **'Recent Tasks'**
  String get dashboardRecentTasks;

  /// No description provided for @dashboardViewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get dashboardViewAll;

  /// No description provided for @dashboardPendingCount.
  ///
  /// In en, this message translates to:
  /// **'Pending ({count})'**
  String dashboardPendingCount(int count);

  /// No description provided for @dashboardAcceptedCount.
  ///
  /// In en, this message translates to:
  /// **'Accepted ({count})'**
  String dashboardAcceptedCount(int count);

  /// No description provided for @dashboardCompletedFilter.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get dashboardCompletedFilter;

  /// No description provided for @dashboardRepairWashingMachine.
  ///
  /// In en, this message translates to:
  /// **'Repair washing machine'**
  String get dashboardRepairWashingMachine;

  /// No description provided for @dashboardFixKitchenFaucet.
  ///
  /// In en, this message translates to:
  /// **'Fix kitchen faucet'**
  String get dashboardFixKitchenFaucet;

  /// No description provided for @dashboardInstallLedLights.
  ///
  /// In en, this message translates to:
  /// **'Install LED lights'**
  String get dashboardInstallLedLights;

  /// No description provided for @dashboardRabatMorocco.
  ///
  /// In en, this message translates to:
  /// **'Rabat, Morocco'**
  String get dashboardRabatMorocco;

  /// No description provided for @dashboardCasablancaMorocco.
  ///
  /// In en, this message translates to:
  /// **'Casablanca, Morocco'**
  String get dashboardCasablancaMorocco;

  /// No description provided for @dashboardMarrakechMorocco.
  ///
  /// In en, this message translates to:
  /// **'Marrakech, Morocco'**
  String get dashboardMarrakechMorocco;

  /// No description provided for @dashboardHomeAppliance.
  ///
  /// In en, this message translates to:
  /// **'Home Appliance'**
  String get dashboardHomeAppliance;

  /// No description provided for @dashboardPlumbing.
  ///
  /// In en, this message translates to:
  /// **'Plumbing'**
  String get dashboardPlumbing;

  /// No description provided for @dashboardElectrical.
  ///
  /// In en, this message translates to:
  /// **'Electrical'**
  String get dashboardElectrical;

  /// No description provided for @dashboardHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour ago} other{{count} hours ago}}'**
  String dashboardHoursAgo(int count);

  /// No description provided for @dashboardDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day ago} other{{count} days ago}}'**
  String dashboardDaysAgo(int count);

  /// No description provided for @dashboardStatusNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get dashboardStatusNew;

  /// No description provided for @dashboardStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get dashboardStatusPending;

  /// No description provided for @dashboardPrice.
  ///
  /// In en, this message translates to:
  /// **'{amount} MAD'**
  String dashboardPrice(Object amount);

  /// No description provided for @dashboardGrowBusiness.
  ///
  /// In en, this message translates to:
  /// **'Grow Your Business'**
  String get dashboardGrowBusiness;

  /// No description provided for @dashboardGrowBusinessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get more tasks and increase your earnings'**
  String get dashboardGrowBusinessSubtitle;

  /// No description provided for @dashboardBoostProfile.
  ///
  /// In en, this message translates to:
  /// **'Boost Profile'**
  String get dashboardBoostProfile;

  /// No description provided for @dashboardPostTask.
  ///
  /// In en, this message translates to:
  /// **'Post Task'**
  String get dashboardPostTask;

  /// No description provided for @dashboardMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get dashboardMessages;

  /// No description provided for @dashboardEarnings.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get dashboardEarnings;

  /// No description provided for @dashboardPerformance.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get dashboardPerformance;

  /// No description provided for @dashboardThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get dashboardThisWeek;

  /// No description provided for @dashboardThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get dashboardThisMonth;

  /// No description provided for @dashboardTasksCompleted.
  ///
  /// In en, this message translates to:
  /// **'Tasks Completed'**
  String get dashboardTasksCompleted;

  /// No description provided for @dashboardChangeVsLastWeek.
  ///
  /// In en, this message translates to:
  /// **'{change}% vs last week'**
  String dashboardChangeVsLastWeek(int change);

  /// No description provided for @dashboardNoFilteredTasks.
  ///
  /// In en, this message translates to:
  /// **'No tasks in this category yet.'**
  String get dashboardNoFilteredTasks;

  /// No description provided for @dashboardFeatureUnavailable.
  ///
  /// In en, this message translates to:
  /// **'{feature} is coming soon.'**
  String dashboardFeatureUnavailable(Object feature);

  /// No description provided for @adminDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get adminDefaultName;

  /// No description provided for @adminGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name} 👋'**
  String adminGreeting(Object name);

  /// No description provided for @adminDashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Here’s what’s happening on your platform today.'**
  String get adminDashboardSubtitle;

  /// No description provided for @adminAnalyticsFallback.
  ///
  /// In en, this message translates to:
  /// **'Live analytics are unavailable. Showing the latest dashboard snapshot.'**
  String get adminAnalyticsFallback;

  /// No description provided for @adminTotalUsers.
  ///
  /// In en, this message translates to:
  /// **'Total Users'**
  String get adminTotalUsers;

  /// No description provided for @adminTotalTasks.
  ///
  /// In en, this message translates to:
  /// **'Total Tasks'**
  String get adminTotalTasks;

  /// No description provided for @adminCompletedTasks.
  ///
  /// In en, this message translates to:
  /// **'Completed Tasks'**
  String get adminCompletedTasks;

  /// No description provided for @adminActiveTaskers.
  ///
  /// In en, this message translates to:
  /// **'Active Taskers'**
  String get adminActiveTaskers;

  /// No description provided for @adminPendingTasks.
  ///
  /// In en, this message translates to:
  /// **'Pending Tasks'**
  String get adminPendingTasks;

  /// No description provided for @adminPendingReviews.
  ///
  /// In en, this message translates to:
  /// **'Pending Reviews'**
  String get adminPendingReviews;

  /// No description provided for @adminVsLast7Days.
  ///
  /// In en, this message translates to:
  /// **'vs last 7 days'**
  String get adminVsLast7Days;

  /// No description provided for @adminTasksOverview.
  ///
  /// In en, this message translates to:
  /// **'Tasks Overview'**
  String get adminTasksOverview;

  /// No description provided for @adminPosted.
  ///
  /// In en, this message translates to:
  /// **'Posted'**
  String get adminPosted;

  /// No description provided for @adminInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get adminInProgress;

  /// No description provided for @adminTasksByStatus.
  ///
  /// In en, this message translates to:
  /// **'Tasks by Status'**
  String get adminTasksByStatus;

  /// No description provided for @adminTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get adminTotal;

  /// No description provided for @adminCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get adminCancelled;

  /// No description provided for @adminViewAllTasks.
  ///
  /// In en, this message translates to:
  /// **'View All Tasks'**
  String get adminViewAllTasks;

  /// No description provided for @adminTopCategories.
  ///
  /// In en, this message translates to:
  /// **'Top Categories'**
  String get adminTopCategories;

  /// No description provided for @adminTaskBy.
  ///
  /// In en, this message translates to:
  /// **'by {customerName}'**
  String adminTaskBy(Object customerName);

  /// No description provided for @adminMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 minute ago} other{{count} minutes ago}}'**
  String adminMinutesAgo(int count);

  /// No description provided for @adminWeekShort.
  ///
  /// In en, this message translates to:
  /// **'W{number}'**
  String adminWeekShort(int number);

  /// No description provided for @adminHomeRepairs.
  ///
  /// In en, this message translates to:
  /// **'Home Repairs'**
  String get adminHomeRepairs;

  /// No description provided for @adminCleaning.
  ///
  /// In en, this message translates to:
  /// **'Cleaning'**
  String get adminCleaning;

  /// No description provided for @adminPainting.
  ///
  /// In en, this message translates to:
  /// **'Painting'**
  String get adminPainting;

  /// No description provided for @adminDetailedAnalyticsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Detailed analytics will appear when the admin API provides them. No sample data is displayed.'**
  String get adminDetailedAnalyticsUnavailable;

  /// No description provided for @dashboardLiveDataUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Dashboard data is not available from the API yet. No sample tasks or statistics are displayed.'**
  String get dashboardLiveDataUnavailable;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
