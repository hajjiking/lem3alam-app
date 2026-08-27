// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get leaveReview => 'اترك تقييماً';

  @override
  String get reviewSaved => 'تم إرسال تقييمك.';

  @override
  String get reviewAlreadySubmitted => 'سبق لك تقييم هذه المهمة.';

  @override
  String get reviewUnavailable =>
      'لم تعد هذه المهمة متاحة للتقييم. أغلق النموذج لتحديث حالة التقييم.';

  @override
  String get reviewTasksLoadError => 'تعذر تحميل تفاصيل تقييمك. حاول مجدداً.';

  @override
  String get noReviewableTasks => 'لا توجد مهام مكتملة بانتظار تقييمك.';

  @override
  String get reviewPublicNotice => 'سيظهر تقييمك في الملف الشخصي لمقدم الخدمة.';

  @override
  String get reviewCommentLength => 'اكتب ما بين 20 و500 حرف.';

  @override
  String reviewStars(int count) {
    return '$count من 5 نجوم';
  }

  @override
  String get completionApprovalTitle => 'الموافقة على إكمال المهام';

  @override
  String completionApprovalCount(int count) {
    return 'الموافقة على إكمال المهام ($count)';
  }

  @override
  String get completionApprovalSubtitle =>
      'راجع العمل المنجز ثم وافق على إكماله أو أعده لإجراء تعديلات.';

  @override
  String get completionApprovalLoadError =>
      'تعذر تحميل طلبات إكمال المهام. حاول مجدداً.';

  @override
  String get noCompletionApprovals => 'لا توجد مهام بانتظار موافقتك.';

  @override
  String get approveCompletion => 'الموافقة على الإكمال';

  @override
  String get returnForChanges => 'إعادة للتعديل';

  @override
  String confirmApproveCompletion(String task) {
    return 'هل توافق على إكمال «$task»؟ سيتم تحديد المهمة كمكتملة دون تحرير أي دفعة مالية.';
  }

  @override
  String confirmReturnForChanges(String task) {
    return 'هل تريد إعادة «$task» إلى مقدم الخدمة لإجراء تعديلات؟ ستبقى المهمة قيد التنفيذ.';
  }

  @override
  String get completionApproved => 'تمت الموافقة على الإكمال';

  @override
  String get taskReturnedForChanges => 'تمت إعادة المهمة للتعديل';

  @override
  String get completionRequestChanged =>
      'تغير طلب الإكمال. راجع المهمة المحدّثة قبل اتخاذ القرار.';

  @override
  String completionRequestedOn(String date) {
    return 'تاريخ الطلب: $date';
  }

  @override
  String get activeAssignmentsTitle => 'المهام المسندة إليك';

  @override
  String activeAssignmentsCount(int count) {
    return 'المهام المسندة إليك ($count)';
  }

  @override
  String get activeAssignmentsSubtitle =>
      'المهام التي تم توظيفك لإنجازها — أنجز العمل وأرسل طلب إكماله.';

  @override
  String get noActiveAssignments =>
      'لا توجد مهام مسندة إليك حالياً. ستظهر هنا عندما يختارك العميل.';

  @override
  String get assignmentsLoadError =>
      'تعذر تحميل المهام المسندة إليك. حاول مجدداً.';

  @override
  String get requestCompletion => 'طلب إكمال المهمة';

  @override
  String confirmRequestCompletion(String task) {
    return 'هل أنجزت «$task»؟ أرسل طلب إكمال المهمة للعميل للموافقة عليه.';
  }

  @override
  String get awaitingClientApproval => 'بانتظار موافقة العميل';

  @override
  String get completionRequestSent =>
      'تم إرسال طلب الإكمال. بانتظار موافقة العميل.';

  @override
  String get assignmentNoLongerActive =>
      'لم تعد هذه المهمة نشطة. حدّث الصفحة لمعرفة حالتها.';

  @override
  String get clientOffersTitle => 'عروض جديدة بانتظارك';

  @override
  String clientOffersWaiting(int count) {
    return 'عروض جديدة بانتظارك ($count)';
  }

  @override
  String get clientOffersSubtitle => 'قارن عروض مقدمي الخدمات واختر الأنسب.';

  @override
  String get clientOffersEmpty =>
      'لا توجد عروض جديدة بعد. ستظهر هنا العروض المقدمة لمهامك.';

  @override
  String get clientOffersLoadError => 'تعذر تحميل عروضك. حاول مجدداً.';

  @override
  String get taskOffers => 'العروض المقدمة للمهمة';

  @override
  String get rejectOffer => 'رفض';

  @override
  String get offerAccepted => 'تم قبول العرض';

  @override
  String get offerRejected => 'تم رفض العرض';

  @override
  String get offerNoLongerAvailable =>
      'لم يعد هذا العرض متاحاً. حدّث الصفحة لعرض أحدث العروض.';

  @override
  String confirmAcceptOffer(String name, String task) {
    return 'هل تقبل عرض $name للمهمة «$task»؟ سيتم إسناد المهمة إليه.';
  }

  @override
  String confirmRejectOffer(String name) {
    return 'هل تريد رفض عرض $name؟';
  }

  @override
  String get taskerAvailableTasks => 'جميع المهام المتاحة';

  @override
  String get taskerBrowseInfo =>
      'تصفح المهام المفتوحة من جميع العملاء وتقدم إليها. نشر المهام متاح للعملاء فقط.';

  @override
  String get taskerViewAndApply => 'عرض المهمة والتقدم إليها';

  @override
  String get clientTasksTitle => 'مهامي';

  @override
  String get clientTasksScope => 'المهام التي نشرتها فقط';

  @override
  String get clientTasksEmpty => 'لم تنشر أي مهام تطابق هذه الفلاتر.';

  @override
  String clientTasksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مهمة',
      many: '$count مهمة',
      few: '$count مهام',
      two: 'مهمتان',
      one: 'مهمة واحدة',
      zero: 'لا توجد مهام',
    );
    return '$_temp0';
  }

  @override
  String get taskerNoComparison => 'لا يوجد نشاط في الفترة السابقة';

  @override
  String taskerPeriodChange(String change) {
    return '$change٪ مقارنة بالفترة السابقة';
  }

  @override
  String get taskerPeriodUnavailable =>
      'إحصاءات هذه الفترة غير متاحة. حدّث الخادم ثم أعد التحميل.';

  @override
  String get taskerAnalyticsPrivate =>
      'أرباحك المدفوعة ومهامك المكتملة فقط. تتم المقارنة بالمدة المنقضية نفسها من الفترة السابقة.';

  @override
  String get taskerNoActivity =>
      'لا توجد أرباح أو مهام مكتملة مسجلة لك خلال هذه الفترة.';

  @override
  String get taskerDashboardLoadError => 'تعذر تحميل لوحة تحكم المهني';

  @override
  String get taskerDashboardRetryHint =>
      'تحقق من اتصالك وسجّل الدخول إلى حسابك كمهني، ثم أعد المحاولة.';

  @override
  String get adminLast7Days => 'آخر 7 أيام';

  @override
  String get adminLast30Days => 'آخر 30 يوماً';

  @override
  String get adminStarted => 'بدأت';

  @override
  String get adminNoPeriodActivity =>
      'لا يوجد نشاط مسجل للمهام خلال هذه الفترة.';

  @override
  String get adminNoCategoryActivity => 'لا توجد مهام لتصنيفها حسب الفئة بعد.';

  @override
  String get adminNoRecentActivity => 'لا توجد مهام حديثة بعد.';

  @override
  String get adminUnknownValue => 'غير متاح';

  @override
  String get adminPaidVolume => 'المبالغ المدفوعة';

  @override
  String get adminChartData => 'عرض بيانات الرسم';

  @override
  String adminAnalyticsDates(String timezone) {
    return 'المهام المنشورة والمبدوءة والمكتملة يومياً. المنطقة الزمنية: $timezone.';
  }

  @override
  String get clientDashboardReadySubtitle => 'مستعد لإنجاز مهامك اليوم؟';

  @override
  String get clientDashboardPromoTitle => 'مساعدة بسيطة تصنع الفرق';

  @override
  String get clientDashboardPromoSubtitle =>
      'انشر مهمة واعثر على المهني المناسب لمنزلك.';

  @override
  String get clientDashboardLoadError =>
      'تعذر تحميل لوحة التحكم. تحقق من اتصالك وحاول مرة أخرى.';

  @override
  String get clientDashboardEmpty =>
      'لا توجد مهام بعد. انشر مهمتك الأولى للبدء.';

  @override
  String get clientDashboardNoRecentTasks =>
      'لا توجد مهام مطابقة ضمن آخر 10 مهام. اعرض الكل للاطلاع على السجل الكامل.';

  @override
  String get clientDashboardSuccessInfo =>
      'تظهر نسبة النجاح فقط عندما توفرها الواجهة البرمجية. تعني الشرطة أن القيمة غير متاحة وليست صفراً.';

  @override
  String get clientDashboardPayments => 'المدفوعات';

  @override
  String get clientDashboardUnknownTime => 'التاريخ غير متاح';

  @override
  String get appName => 'لمعلم';

  @override
  String get loading => 'تحميل...';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get register => 'إنشاء حساب';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get requiredField => 'مطلوب';

  @override
  String get passwordTooShort => 'الحد الأدنى 8 أحرف';

  @override
  String get passwordMismatch => 'غير متطابق';

  @override
  String get passwordConfirm => 'تأكيد كلمة المرور';

  @override
  String get name => 'الاسم';

  @override
  String get phone => 'الهاتف';

  @override
  String get city => 'المدينة';

  @override
  String get role => 'الدور';

  @override
  String get client => 'عميل';

  @override
  String get tasker => 'محترف';

  @override
  String get dashboard => 'لوحة التحكم';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get welcomeBack => 'مرحباً بعودتك';

  @override
  String get loginSubtitle => 'سجّل دخولك للوصول إلى حسابك';

  @override
  String get createAccountTitle => 'أنشئ حسابك';

  @override
  String get createAccountSubtitle => 'أدخل بياناتك لإنشاء حساب جديد';

  @override
  String get tasks => 'المهام';

  @override
  String get tasksSubtitle => 'تصفح المهام';

  @override
  String get createTask => 'إنشاء مهمة';

  @override
  String get editTask => 'تعديل مهمة';

  @override
  String get taskDetails => 'تفاصيل المهمة';

  @override
  String get deleteTask => 'حذف المهمة';

  @override
  String get apply => 'تقديم عرض';

  @override
  String get applyToTask => 'تقديم عرض للمهمة';

  @override
  String get proposal => 'العرض';

  @override
  String get proposedBudget => 'الميزانية المقترحة';

  @override
  String get estimatedDuration => 'المدة المتوقعة';

  @override
  String get submitApplication => 'إرسال العرض';

  @override
  String get applicationSubmitted => 'تم إرسال العرض';

  @override
  String get delete => 'حذف';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirmDeleteTask => 'هل أنت متأكد من حذف هذه المهمة؟';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get unableToLoad => 'تعذر تحميل البيانات';

  @override
  String get emptyTasksTitle => 'لا توجد مهام';

  @override
  String get emptyTasksSubtitle => 'أنشئ مهمة جديدة أو حدّث الصفحة.';

  @override
  String get shortcuts => 'الاختصارات';

  @override
  String get tip => 'نصيحة';

  @override
  String get tipText => 'ابدأ بإنشاء مهمة ثم اختر أفضل عرض.';

  @override
  String get remote => 'عن بعد';

  @override
  String get title => 'العنوان';

  @override
  String get description => 'الوصف';

  @override
  String get category => 'الفئة';

  @override
  String get addressOptional => 'العنوان التفصيلي (اختياري)';

  @override
  String get budgetMin => 'الحد الأدنى';

  @override
  String get budgetMax => 'الحد الأقصى';

  @override
  String get budgetType => 'نوع الميزانية';

  @override
  String get urgency => 'درجة الاستعجال';

  @override
  String get paymentMethodOptional => 'طريقة الدفع (اختياري)';

  @override
  String get cash => 'نقداً';

  @override
  String get card => 'بطاقة';

  @override
  String get online => 'أونلاين';

  @override
  String get save => 'حفظ';

  @override
  String get fixed => 'ثابت';

  @override
  String get hourly => 'بالساعة';

  @override
  String get negotiable => 'قابل للتفاوض';

  @override
  String get urgencyLow => 'منخفض';

  @override
  String get urgencyMedium => 'متوسط';

  @override
  String get urgencyHigh => 'مرتفع';

  @override
  String get urgencyUrgent => 'عاجل';

  @override
  String get statusOpen => 'مفتوحة';

  @override
  String get statusAssigned => 'مُعيّنة';

  @override
  String get statusInProgress => 'قيد التنفيذ';

  @override
  String get statusCompleted => 'مكتملة';

  @override
  String get statusCancelled => 'ملغاة';

  @override
  String get lang => 'اللغة';

  @override
  String get langAr => 'العربية';

  @override
  String get langEn => 'الإنجليزية';

  @override
  String get langFr => 'الفرنسية';

  @override
  String get languageAction => 'اللغة';

  @override
  String get refreshAction => 'تحديث';

  @override
  String get reload => 'إعادة التحميل';

  @override
  String get popularCategories => 'الفئات الشائعة';

  @override
  String get all => 'الكل';

  @override
  String get categories => 'الفئات';

  @override
  String get browseTasksByCategory => 'تصفح المهام حسب الفئة';

  @override
  String get nearbyArtisans => 'المهنيون القريبون';

  @override
  String get seeTaskersOnMap => 'عرض المهنيين على الخريطة';

  @override
  String get nearbyTasks => 'المهام القريبة';

  @override
  String get jobsMatchedToYourLocation => 'مهام مناسبة لموقعك';

  @override
  String get myProfile => 'ملفي الشخصي';

  @override
  String get publicTaskerProfile => 'الملف العام للمهني';

  @override
  String get myReviews => 'تقييماتي';

  @override
  String get ratingsAndFeedback => 'التقييمات والملاحظات';

  @override
  String get hello => 'مرحباً';

  @override
  String helloName(Object name) {
    return 'مرحباً، $name';
  }

  @override
  String get photos => 'الصور';

  @override
  String get add => 'إضافة';

  @override
  String get addPhotosHelper =>
      'أضف حتى 5 صور لمساعدة المهنيين على فهم المهمة.';

  @override
  String get locationSelected => 'تم اختيار الموقع';

  @override
  String get pickOnMap => 'اختيار من الخريطة';

  @override
  String get clear => 'مسح';

  @override
  String get cameraCaptureNotAvailableOnWeb =>
      'التقاط الصور بالكاميرا غير متاح على الويب';

  @override
  String get maxTaskPhotos => 'يمكنك إرفاق حتى 5 صور';

  @override
  String get cameraPermission => 'إذن الكاميرا';

  @override
  String get cameraPermissionPermanentlyDenied =>
      'تم رفض إذن الكاميرا نهائياً. يرجى تفعيله من الإعدادات.';

  @override
  String get cameraPermissionRequired => 'إذن الكاميرا مطلوب لالتقاط الصور.';

  @override
  String get close => 'إغلاق';

  @override
  String get openSettings => 'فتح الإعدادات';

  @override
  String cameraError(Object error) {
    return 'خطأ في الكاميرا: $error';
  }

  @override
  String get camera => 'الكاميرا';

  @override
  String get switchCamera => 'تبديل الكاميرا';

  @override
  String get noCameraFound => 'لم يتم العثور على كاميرا على هذا الجهاز.';

  @override
  String get retake => 'إعادة الالتقاط';

  @override
  String get usePhoto => 'استخدام الصورة';

  @override
  String get location => 'الموقع';

  @override
  String get viewProfile => 'عرض الملف الشخصي';

  @override
  String newHighPriorityNearbyTasksFound(int count) {
    return 'تم العثور على $count مهمة قريبة جديدة ذات أولوية عالية.';
  }

  @override
  String get enableNearbyTaskMatching => 'تفعيل مطابقة المهام القريبة';

  @override
  String get nearbyTasksConsentSubtitle =>
      'لن نستخدم موقعك إلا بعد موافقتك، ويتم تحديث القائمة بفاصل زمني مناسب للبطارية.';

  @override
  String get nearbyTasksConsentBody =>
      'يتم استخدام الموقع للعثور على وظائف قريبة ضمن النطاق الذي تختاره وتحسين ملاءمة المهام حسب ملفك المهني.';

  @override
  String get allowLocationBasedNearbyTasks =>
      'السماح بالمهام القريبة المعتمدة على الموقع';

  @override
  String get feedControls => 'عناصر التحكم في القائمة';

  @override
  String radiusAdjustable(int min, int max) {
    return 'يمكن تعديل النطاق من $minكم إلى $maxكم.';
  }

  @override
  String lastRefreshedAt(Object time) {
    return 'آخر تحديث $time';
  }

  @override
  String radiusLabel(int radius) {
    return 'النطاق: $radius كم';
  }

  @override
  String get savedOnly => 'المحفوظة فقط';

  @override
  String get savedStatus => 'محفوظة';

  @override
  String get locationAccuracyLow =>
      'دقة الموقع منخفضة حالياً. انتقل إلى مكان مفتوح أو حدّث لتحسين المطابقة القريبة.';

  @override
  String get noNearbyTasks => 'لا توجد مهام قريبة';

  @override
  String get noNearbyTasksSubtitle =>
      'جرّب زيادة النطاق أو إلغاء وضع المحفوظة فقط.';

  @override
  String get locationDisabled => 'الموقع معطل';

  @override
  String get locationServicesRequired => 'يرجى تفعيل خدمات GPS/الموقع.';

  @override
  String get locationDisabledNearbyTasksMessage =>
      'يرجى تفعيل خدمات الموقع للحفاظ على دقة المهام القريبة.';

  @override
  String get permissionRequired => 'الإذن مطلوب';

  @override
  String get permissionBlocked => 'الإذن محظور';

  @override
  String get locationPermissionPermanentlyDenied =>
      'تم رفض إذن الموقع نهائياً. فعّله من الإعدادات.';

  @override
  String get locationPermissionRequiredNearbyArtisans =>
      'إذن الموقع مطلوب لعرض المهنيين القريبين.';

  @override
  String get allowLocationAccessNearbyTasks =>
      'اسمح بالوصول إلى الموقع لتحميل المهام القريبة.';

  @override
  String get enablePermissionInSettings =>
      'تم رفض إذن الموقع نهائياً. فعّله من إعدادات التطبيق.';

  @override
  String get unableToLoadNearbyTasks => 'تعذر تحميل المهام القريبة';

  @override
  String get distanceUnavailable => 'المسافة غير متاحة';

  @override
  String clientRatingLabel(Object rating) {
    return 'تقييم العميل $rating';
  }

  @override
  String get applicationSubmittedNearbyTask =>
      'تم إرسال طلب لهذه المهمة القريبة.';

  @override
  String get accept => 'قبول';

  @override
  String get dismiss => 'تجاهل';

  @override
  String get goToHome => 'العودة إلى الرئيسية';

  @override
  String get home => 'الرئيسية';

  @override
  String get openLocationSettings => 'فتح إعدادات الموقع';

  @override
  String get loginRequired => 'تسجيل الدخول مطلوب';

  @override
  String get couldNotLoadNearbyArtisans => 'تعذر تحميل المهنيين القريبين.';

  @override
  String get noLocation => 'لا يوجد موقع';

  @override
  String get artisans => 'المهنيون';

  @override
  String get noArtisansFoundNearby => 'لم يتم العثور على مهنيين قريبين.';

  @override
  String get go => 'اذهب';

  @override
  String get center => 'توسيط';

  @override
  String get directions => 'الاتجاهات';

  @override
  String distanceAway(Object distance) {
    return 'يبعد $distance كم';
  }

  @override
  String get couldNotOpenNavigationApp => 'تعذر فتح تطبيق الملاحة.';

  @override
  String get goToFirstPage => 'الانتقال إلى الصفحة الأولى';

  @override
  String get goToPreviousPage => 'الانتقال إلى الصفحة السابقة';

  @override
  String get goToNextPage => 'الانتقال إلى الصفحة التالية';

  @override
  String get goToLastPage => 'الانتقال إلى الصفحة الأخيرة';

  @override
  String get reviews => 'التقييمات';

  @override
  String get noReviews => 'لا توجد تقييمات';

  @override
  String get noReviewsMatchFilters => 'لا توجد تقييمات تطابق عوامل التصفية.';

  @override
  String get allRatings => 'كل التقييمات';

  @override
  String starsCount(int count) {
    return '$count نجوم';
  }

  @override
  String get oneStar => 'نجمة واحدة';

  @override
  String get rating => 'التقييم';

  @override
  String get sort => 'الترتيب';

  @override
  String get newest => 'الأحدث';

  @override
  String get oldest => 'الأقدم';

  @override
  String get highestRating => 'الأعلى تقييماً';

  @override
  String get lowestRating => 'الأقل تقييماً';

  @override
  String get fromDate => 'من';

  @override
  String get toDate => 'إلى';

  @override
  String get clearDates => 'مسح التواريخ';

  @override
  String get anonymous => 'مجهول';

  @override
  String get taskerProfile => 'ملف المهني';

  @override
  String get about => 'نبذة';

  @override
  String get noBioProvided => 'لا توجد نبذة.';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get greetingMorning => 'صباح الخير،';

  @override
  String get greetingEvening => 'مساء الخير،';

  @override
  String get searchTasksHint => 'ابحث عن خدمة أو مهمة...';

  @override
  String get promoTodayTitle => 'تحتاج مساعدة في شيء ما اليوم؟';

  @override
  String get promoTodaySubtitle => 'احجز خبراء موثوقين خلال دقائق.';

  @override
  String get bookNow => 'احجز الآن';

  @override
  String get recommendedForYou => 'مقترحة لك';

  @override
  String get pickedForYourNeeds => 'بناءً على نشاطك وموقعك الجغرافي';

  @override
  String get inCategory => 'مختارة في هذا القسم';

  @override
  String get allTasks => 'كل المهام';

  @override
  String tasksAvailableCount(int count) {
    return '$count متاحة';
  }

  @override
  String get nearby => 'قريب مني';

  @override
  String get needService => 'أحتاج خدمة';

  @override
  String get needServiceSubtitle => 'احجز محترفاً خلال دقائق.';

  @override
  String get wantWork => 'أريد العمل';

  @override
  String get wantWorkSubtitle => 'قدم خدماتك واربح.';

  @override
  String get more => 'المزيد';

  @override
  String get personalInformation => 'المعلومات الشخصية';

  @override
  String get personalInformationSubtitle => 'سنستخدمها لإنشاء ملفك الشخصي.';

  @override
  String get security => 'الأمان';

  @override
  String get securitySubtitle => 'استخدم كلمة مرور قوية وفريدة.';

  @override
  String get noAccountYet => 'ليس لديك حساب؟';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get passwordHint =>
      'استخدم 8 أحرف على الأقل مع مزيج من الحروف والأرقام والرموز.';

  @override
  String reviewsCount(Object rating, int count) {
    return '$rating · $count تقييم';
  }

  @override
  String get noReviewsYet => 'لا توجد تقييمات بعد.';

  @override
  String get whatPeopleSayAboutThisTasker => 'ماذا يقول الناس عن هذا المهني.';

  @override
  String get available => 'متاح';

  @override
  String get busy => 'مشغول';

  @override
  String get contact => 'تواصل';

  @override
  String get bookService => 'احجز الخدمة';

  @override
  String serviceRequestForName(Object name) {
    return 'طلب خدمة لـ $name';
  }

  @override
  String bookServiceDescription(Object name) {
    return 'مرحباً $name، أود حجز خدمة. يرجى التواصل معي.';
  }

  @override
  String get noPhoneNumber => 'لا يوجد رقم هاتف';

  @override
  String get serviceArea => 'منطقة الخدمة';

  @override
  String get address => 'العنوان';

  @override
  String get pricing => 'التسعير';

  @override
  String get verification => 'التحقق';

  @override
  String get details => 'التفاصيل';

  @override
  String get verified => 'موثّق';

  @override
  String get unverified => 'غير موثّق';

  @override
  String get skills => 'المهارات';

  @override
  String get noSkillsListed => 'لا توجد مهارات مدرجة.';

  @override
  String yearsCount(int count) {
    return '$count سنوات';
  }

  @override
  String get availability => 'التوفر';

  @override
  String get availableToTakeNewWork => 'متاح لاستقبال أعمال جديدة';

  @override
  String get currentlyBusy => 'مشغول حالياً';

  @override
  String get social => 'الحسابات الاجتماعية';

  @override
  String get noSocialAccounts => 'لا توجد حسابات اجتماعية.';

  @override
  String get gallery => 'المعرض';

  @override
  String get noPhotosYet => 'لا توجد صور بعد.';

  @override
  String get noCategories => 'لا توجد فئات';

  @override
  String get tryAgainLater => 'حاول مرة أخرى لاحقاً.';

  @override
  String get pickLocation => 'اختيار الموقع';

  @override
  String get confirmLocation => 'تأكيد الموقع';

  @override
  String get locationPermissionRequiredToPick =>
      'إذن الموقع مطلوب لاختيار موقع.';

  @override
  String get couldNotLoadMap => 'تعذر تحميل الخريطة.';

  @override
  String get searchUsers => 'البحث عن المستخدمين';

  @override
  String get searchCity => 'ابحث عن مدينة';

  @override
  String get adminWorkspace => 'مساحة الإدارة';

  @override
  String get overview => 'نظرة عامة';

  @override
  String get users => 'المستخدمون';

  @override
  String get reports => 'البلاغات';

  @override
  String get settings => 'الإعدادات';

  @override
  String signedInAs(Object email, Object role) {
    return 'تم تسجيل الدخول باسم $email ($role)';
  }

  @override
  String get usersMetric => 'المستخدمون';

  @override
  String get tasksMetric => 'المهام';

  @override
  String get openDisputes => 'النزاعات المفتوحة';

  @override
  String get revenue => 'الإيرادات';

  @override
  String get operationalSnapshot => 'لقطة تشغيلية';

  @override
  String get operationalSnapshotSubtitle => 'مطابقة لبيانات الإدارة في الويب.';

  @override
  String get verifiedUsersLoadedPage =>
      'المستخدمون الموثقون في الصفحة المحمّلة';

  @override
  String get openReportsLoadedPage => 'البلاغات المفتوحة في الصفحة المحمّلة';

  @override
  String get mobileAdminParityPhase => 'مرحلة التطابق الإداري على الجوال';

  @override
  String get overviewModerationReports => 'نظرة عامة، إشراف، بلاغات';

  @override
  String get unableToLoadAdminOverview => 'تعذر تحميل نظرة الإدارة العامة';

  @override
  String get checkConnectionOrAdminPermissions =>
      'تحقق من الاتصال أو صلاحيات الإدارة ثم حاول مرة أخرى.';

  @override
  String get userModeration => 'إدارة المستخدمين';

  @override
  String loadedUsersFromAdminApi(int loaded, int total) {
    return 'تم تحميل $loaded من أصل $total مستخدم من واجهة الإدارة.';
  }

  @override
  String get noUsersFound => 'لم يتم العثور على مستخدمين';

  @override
  String get tryDifferentSearchOrRefresh =>
      'جرّب كلمة بحث أخرى أو حدّث الصفحة.';

  @override
  String get unableToLoadUsers => 'تعذر تحميل المستخدمين';

  @override
  String get adminUsersEndpointFailed =>
      'فشلت نقطة نهاية مستخدمي الإدارة في الاستجابة.';

  @override
  String get reportsComplaints => 'البلاغات والشكايات';

  @override
  String loadedReportsFromSharedBackend(int loaded, int total) {
    return 'تم تحميل $loaded من أصل $total بلاغ من الواجهة الخلفية المشتركة.';
  }

  @override
  String get noReportsFound => 'لا توجد بلاغات';

  @override
  String get noUserReportsToModerate =>
      'لا توجد بلاغات مستخدمين تحتاج إلى إشراف حالياً.';

  @override
  String get unableToLoadReports => 'تعذر تحميل البلاغات';

  @override
  String get adminReportsEndpointFailed =>
      'فشلت نقطة نهاية بلاغات الإدارة في الاستجابة.';

  @override
  String get nearbyTaskSettingsUpdated => 'تم تحديث إعدادات المهام القريبة.';

  @override
  String get nearbyTaskControls => 'إعدادات المهام القريبة';

  @override
  String get nearbyTaskControlsSubtitle =>
      'اضبط النطاق الافتراضي والحدود وفاصل التحديث والتنبيهات للمهنيين.';

  @override
  String get defaultRadiusKm => 'النطاق الافتراضي (كم)';

  @override
  String get minimumRadiusKm => 'الحد الأدنى للنطاق (كم)';

  @override
  String get maximumRadiusKm => 'الحد الأقصى للنطاق (كم)';

  @override
  String get refreshIntervalMinutes => 'فاصل التحديث (دقائق)';

  @override
  String get notifyFromUrgency => 'الإشعار بدءاً من درجة الاستعجال';

  @override
  String get enableHighPriorityAlerts => 'تفعيل تنبيهات الأولوية العالية';

  @override
  String get saveSettings => 'حفظ الإعدادات';

  @override
  String get unableToLoadSettings => 'تعذر تحميل الإعدادات';

  @override
  String get nearbyTaskSettingsEndpointFailed =>
      'فشلت نقطة نهاية إعدادات المهام القريبة في الاستجابة.';

  @override
  String get noDescriptionProvided => 'لا يوجد وصف.';

  @override
  String get verifyAction => 'توثيق';

  @override
  String get ban => 'حظر';

  @override
  String get unban => 'إلغاء الحظر';

  @override
  String get suspend7Days => 'تعليق 7 أيام';

  @override
  String get unsuspend => 'إلغاء التعليق';

  @override
  String get resolve => 'حل';

  @override
  String get mondayShort => 'الإث';

  @override
  String get tuesdayShort => 'الثل';

  @override
  String get wednesdayShort => 'الأر';

  @override
  String get thursdayShort => 'الخ';

  @override
  String get fridayShort => 'الجم';

  @override
  String get saturdayShort => 'السب';

  @override
  String get sundayShort => 'الأحد';

  @override
  String get errNetwork =>
      'تعذر الاتصال بالخادم. تحقق من الإنترنت وحاول مرة أخرى.';

  @override
  String get errTimeout => 'انتهت مهلة الاتصال. حاول مرة أخرى.';

  @override
  String get errCancelled => 'تم إلغاء الطلب.';

  @override
  String get errUnauthorized => 'يجب تسجيل الدخول للمتابعة.';

  @override
  String get errForbidden => 'ليس لديك صلاحية لتنفيذ هذا الإجراء.';

  @override
  String get errNotFound => 'المورد غير موجود.';

  @override
  String get errServer => 'حدث خطأ في الخادم. حاول لاحقاً.';

  @override
  String get errUnknown => 'حدث خطأ غير متوقع. حاول مرة أخرى.';

  @override
  String get chat => 'محادثة';

  @override
  String get readMore => 'اقرأ المزيد';

  @override
  String get readLess => 'إخفاء';

  @override
  String get services => 'الخدمات';

  @override
  String get topRated => 'الأعلى تقييماً';

  @override
  String verifiedYears(int count) {
    return '$count+ سنوات';
  }

  @override
  String get verifiedIdentity => 'موثّق';

  @override
  String daysAgo(int count) {
    return 'قبل $count أيام';
  }

  @override
  String weeksAgo(int count) {
    return 'قبل $count أسابيع';
  }

  @override
  String get writeReview => 'اكتب مراجعة';

  @override
  String get helpful => 'مفيد';

  @override
  String get notHelpful => 'غير مفيد';

  @override
  String showReviewsForRating(int rating) {
    return 'إظهار $rating نجوم فقط';
  }

  @override
  String get sortByNewest => 'الأحدث أولاً';

  @override
  String get sortByTopRated => 'الأعلى تقييماً أولاً';

  @override
  String get noCommentProvided => 'لا يوجد تعليق.';

  @override
  String get shareYourExperience => 'شارك تجربتك مع هذا الحرفي…';

  @override
  String get submitReview => 'إرسال المراجعة';

  @override
  String get selectRatingFirst => 'اختر تقييماً أولاً';

  @override
  String get notProvided => 'غير متوفر';

  @override
  String get acceptingNewBookings => 'يقبل حجوزات جديدة';

  @override
  String get mon => 'اث';

  @override
  String get tue => 'ثل';

  @override
  String get wed => 'أر';

  @override
  String get thu => 'خم';

  @override
  String get fri => 'جم';

  @override
  String get sat => 'سب';

  @override
  String get sun => 'أح';

  @override
  String get unavailable => 'غير متاح';

  @override
  String get socialLinks => 'روابط التواصل';

  @override
  String get portfolio => 'الأعمال';

  @override
  String portfolioSubtitle(int count) {
    return '$count عمل';
  }

  @override
  String get availableTodayHint => 'متاح اليوم';

  @override
  String get features => 'ما أقدمه';

  @override
  String get statJobsCompleted => 'المهام المنجزة';

  @override
  String get statResponseTime => 'وقت الاستجابة';

  @override
  String get statCompletionRate => 'نسبة الإنجاز';

  @override
  String get slotMorning => 'صباحاً';

  @override
  String get slotAfternoon => 'ظهراً';

  @override
  String get slotEvening => 'مساءً';

  @override
  String dashboardGreeting(Object name) {
    return 'مرحباً، $name 👋';
  }

  @override
  String get dashboardReadySubtitle => 'هل أنت مستعد للمساعدة والربح اليوم؟';

  @override
  String get dashboardOnline => 'متصل';

  @override
  String get dashboardOffline => 'غير متصل';

  @override
  String get dashboardMenu => 'فتح قائمة لوحة التحكم';

  @override
  String get dashboardNotifications => 'الإشعارات';

  @override
  String get dashboardProfile => 'الملف الشخصي';

  @override
  String get dashboardAppearance => 'المظهر';

  @override
  String get dashboardLightMode => 'الوضع الفاتح';

  @override
  String get dashboardDarkMode => 'الوضع الداكن';

  @override
  String get dashboardActiveTasks => 'المهام النشطة';

  @override
  String get dashboardCompleted => 'المكتملة';

  @override
  String get dashboardTotalEarnings => 'إجمالي الأرباح';

  @override
  String get dashboardRating => 'التقييم';

  @override
  String get dashboardCurrencyMad => 'درهم';

  @override
  String get dashboardSuccessRate => 'نسبة النجاح';

  @override
  String get dashboardViewDetails => 'عرض التفاصيل';

  @override
  String get dashboardRecentTasks => 'المهام الأخيرة';

  @override
  String get dashboardViewAll => 'عرض الكل';

  @override
  String dashboardPendingCount(int count) {
    return 'قيد الانتظار ($count)';
  }

  @override
  String dashboardAcceptedCount(int count) {
    return 'المقبولة ($count)';
  }

  @override
  String get dashboardCompletedFilter => 'المكتملة';

  @override
  String get dashboardRepairWashingMachine => 'إصلاح غسالة الملابس';

  @override
  String get dashboardFixKitchenFaucet => 'إصلاح صنبور المطبخ';

  @override
  String get dashboardInstallLedLights => 'تركيب مصابيح LED';

  @override
  String get dashboardRabatMorocco => 'الرباط، المغرب';

  @override
  String get dashboardCasablancaMorocco => 'الدار البيضاء، المغرب';

  @override
  String get dashboardMarrakechMorocco => 'مراكش، المغرب';

  @override
  String get dashboardHomeAppliance => 'أجهزة منزلية';

  @override
  String get dashboardPlumbing => 'السباكة';

  @override
  String get dashboardElectrical => 'الكهرباء';

  @override
  String dashboardHoursAgo(int count) {
    return 'قبل $count ساعة';
  }

  @override
  String dashboardDaysAgo(int count) {
    return 'قبل $count يوم';
  }

  @override
  String get dashboardStatusNew => 'جديد';

  @override
  String get dashboardStatusPending => 'قيد الانتظار';

  @override
  String dashboardPrice(Object amount) {
    return '$amount درهم';
  }

  @override
  String get dashboardGrowBusiness => 'طوّر نشاطك';

  @override
  String get dashboardGrowBusinessSubtitle => 'احصل على مهام أكثر وزِد أرباحك';

  @override
  String get dashboardBoostProfile => 'عزّز ملفك';

  @override
  String get dashboardPostTask => 'انشر مهمة';

  @override
  String get dashboardMessages => 'الرسائل';

  @override
  String get dashboardEarnings => 'الأرباح';

  @override
  String get dashboardPerformance => 'الأداء';

  @override
  String get dashboardThisWeek => 'هذا الأسبوع';

  @override
  String get dashboardThisMonth => 'هذا الشهر';

  @override
  String get dashboardTasksCompleted => 'المهام المنجزة';

  @override
  String dashboardChangeVsLastWeek(int change) {
    return '$change٪ مقارنة بالأسبوع الماضي';
  }

  @override
  String get dashboardNoFilteredTasks => 'لا توجد مهام في هذه الفئة بعد.';

  @override
  String dashboardFeatureUnavailable(Object feature) {
    return 'ميزة $feature ستتوفر قريباً.';
  }

  @override
  String get adminDefaultName => 'المشرف';

  @override
  String adminGreeting(Object name) {
    return 'مرحباً، $name 👋';
  }

  @override
  String get adminDashboardSubtitle => 'إليك ما يحدث على منصتك اليوم.';

  @override
  String get adminAnalyticsFallback =>
      'الإحصاءات المباشرة غير متاحة. يتم عرض أحدث لقطة للوحة التحكم.';

  @override
  String get adminTotalUsers => 'إجمالي المستخدمين';

  @override
  String get adminTotalTasks => 'إجمالي المهام';

  @override
  String get adminCompletedTasks => 'المهام المكتملة';

  @override
  String get adminActiveTaskers => 'المهنيون النشطون';

  @override
  String get adminPendingTasks => 'المهام المعلقة';

  @override
  String get adminPendingReviews => 'التقييمات المعلقة';

  @override
  String get adminVsLast7Days => 'مقارنة بآخر 7 أيام';

  @override
  String get adminTasksOverview => 'نظرة عامة على المهام';

  @override
  String get adminPosted => 'منشورة';

  @override
  String get adminInProgress => 'قيد التنفيذ';

  @override
  String get adminTasksByStatus => 'المهام حسب الحالة';

  @override
  String get adminTotal => 'الإجمالي';

  @override
  String get adminCancelled => 'ملغاة';

  @override
  String get adminViewAllTasks => 'عرض كل المهام';

  @override
  String get adminTopCategories => 'أهم الفئات';

  @override
  String adminTaskBy(Object customerName) {
    return 'بواسطة $customerName';
  }

  @override
  String adminMinutesAgo(int count) {
    return 'قبل $count دقيقة';
  }

  @override
  String adminWeekShort(int number) {
    return 'أ$number';
  }

  @override
  String get adminHomeRepairs => 'إصلاحات منزلية';

  @override
  String get adminCleaning => 'التنظيف';

  @override
  String get adminPainting => 'الصباغة';

  @override
  String get adminDetailedAnalyticsUnavailable =>
      'ستظهر التحليلات التفصيلية عندما توفرها واجهة برمجة الإدارة. لا يتم عرض أي بيانات تجريبية.';

  @override
  String get dashboardLiveDataUnavailable =>
      'بيانات لوحة التحكم غير متاحة من الواجهة البرمجية بعد. لا يتم عرض مهام أو إحصاءات تجريبية.';
}
