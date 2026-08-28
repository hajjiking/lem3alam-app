// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get paymentsPeriod => 'Payment period';

  @override
  String get paymentsTitle => 'My Payments';

  @override
  String get paymentsSubtitle => 'Track your spending and manage your payments';

  @override
  String get paymentsWallet => 'Wallet Balance';

  @override
  String get paymentsSpent => 'Total Spent';

  @override
  String get paymentsRefunds => 'Refunds';

  @override
  String get paymentsBudget => 'Remaining Budget';

  @override
  String get paymentsUnavailable => 'Unavailable';

  @override
  String get paymentsUnsupported =>
      'Wallet balances, top-ups, saved cards and remaining budgets are not supported by the current payment system. No funds will be added or card details collected here.';

  @override
  String get paymentsRefundNotice =>
      'Refund totals are unavailable because refund amounts and dates are not recorded separately.';

  @override
  String get paymentsAddFunds => 'Add Funds';

  @override
  String get paymentsFundTitle => 'Add funds to your wallet';

  @override
  String get paymentsPosted => 'Tasks Posted';

  @override
  String get paymentsCompleted => 'Completed Tasks';

  @override
  String get paymentsActive => 'In Progress';

  @override
  String get paymentsOverview => 'Spending Overview';

  @override
  String get paymentsCumulative =>
      'Cumulative gross spending from completed payments';

  @override
  String get paymentsCategory => 'Spending by Category';

  @override
  String get paymentsRecent => 'Recent Payments';

  @override
  String get paymentsAll => 'All Payments';

  @override
  String get paymentsEmpty => 'No payments in this period.';

  @override
  String get paymentsMethods => 'Payment Methods';

  @override
  String get paymentsAddCard => 'Add New Card';

  @override
  String get paymentsNoCards => 'Saved cards are not available yet.';

  @override
  String get paymentsLoadError => 'Could not load your payments. Please retry.';

  @override
  String get paymentsPrivate =>
      'Only your MAD payments are shown. Spending includes completed gross payments, not pending amounts or tasker net earnings.';

  @override
  String get paymentsUndated =>
      'Some completed payments have no payment date. They are included only in the all-time total, not in period charts.';

  @override
  String get paymentsPaid => 'Completed';

  @override
  String get paymentsPending => 'Pending';

  @override
  String get paymentsFailed => 'Failed';

  @override
  String get paymentsRefunded => 'Refunded';

  @override
  String get paymentsDisputed => 'Disputed';

  @override
  String get paymentsPaidDate => 'Paid on';

  @override
  String get paymentsCreatedDate => 'Payment created on';

  @override
  String get paymentsOriginal => 'Original payment amount';

  @override
  String get paymentsAmount => 'Payment amount';

  @override
  String get cashFeeAccounting =>
      'Receive the full gross amount in cash. The platform fee reduces your recorded net earnings; this confirmation does not collect the fee from you.';

  @override
  String get cashPaymentsTitle => 'Cash payment confirmation';

  @override
  String get cashPaymentsLoadError =>
      'Could not load cash payments awaiting confirmation.';

  @override
  String get cashConfirm => 'Confirm cash received';

  @override
  String cashConfirmBody(String amount, String task) {
    return 'Have you received $amount in cash for $task? Confirm only after receiving the full payment. This will record it in your earnings.';
  }

  @override
  String get cashConfirmed =>
      'Cash receipt confirmed. Your earnings have been updated.';

  @override
  String get cashPaymentChanged =>
      'This payment changed. Refresh and check the amount before confirming.';

  @override
  String get cashAwaitingReceipt =>
      'The client approved this job. Confirm once you have received the cash. It will not count as paid until you confirm.';

  @override
  String get cashAmountReview =>
      'An agreed final amount or a valid payment record is missing. Contact support to review this payment before confirming.';

  @override
  String get earningsTitle => 'My Earnings';

  @override
  String get earningsSubtitle => 'Track your earnings and performance';

  @override
  String get earningsLastMonth => 'Last Month';

  @override
  String get earningsThisYear => 'This Year';

  @override
  String get earningsTotal => 'Total Earnings';

  @override
  String get earningsGross => 'Gross Earnings';

  @override
  String get earningsFees => 'Platform Fees';

  @override
  String get earningsNet => 'Net Earnings';

  @override
  String get earningsBalance => 'Available Balance';

  @override
  String get earningsBalanceUnavailable =>
      'A withdrawable balance is not available from the payment system yet. Completed or released payments are not a wallet balance.';

  @override
  String earningsComparison(String percent) {
    return '$percent% versus the previous comparable period';
  }

  @override
  String get earningsNoComparison => 'No previous earnings to compare';

  @override
  String earningsCompletedChange(String count) {
    return '$count versus the previous comparable period';
  }

  @override
  String get earningsActiveNow => 'Currently active';

  @override
  String get earningsAllTime => 'All time';

  @override
  String get earningsRating => 'Average Rating';

  @override
  String get earningsJobs => 'Total Jobs';

  @override
  String get earningsOverview => 'Earnings Overview';

  @override
  String get earningsCumulative => 'Cumulative net from completed payments';

  @override
  String get earningsCategory => 'Earnings by Category';

  @override
  String get earningsUncategorized => 'Other services';

  @override
  String get earningsFeeInfo => 'About Platform Fees';

  @override
  String earningsFeeBody(String rate) {
    return 'New payments and estimates use a $rate% platform fee. Historical payments keep their recorded fees; actual rates may differ.';
  }

  @override
  String get earningsEstimateBasis =>
      'Expected amounts use the accepted offer, or the task’s minimum budget when no accepted price is available. Estimates are not earned income.';

  @override
  String get earningsTransactions => 'Recent Transactions';

  @override
  String get earningsGrossLabel => 'Gross';

  @override
  String get earningsFeeLabel => 'Fee';

  @override
  String get earningsNetLabel => 'Net';

  @override
  String get earningsExpected => 'Expected';

  @override
  String get earningsEstimatedFee => 'Est. Fee';

  @override
  String get earningsEstimatedNet => 'Est. Net';

  @override
  String earningsPaidOn(String date) {
    return 'Paid on $date';
  }

  @override
  String earningsEstimatedOn(String date) {
    return 'Active assignment · $date';
  }

  @override
  String get earningsLoadError =>
      'Could not load your earnings. Please retry. Inconsistent payment records must be corrected before totals can be shown.';

  @override
  String get earningsEmpty => 'No completed payments in this period.';

  @override
  String get earningsNoTransactions => 'No transactions for this period.';

  @override
  String get earningsPrivate =>
      'Only your earnings are shown. Totals include completed MAD payments; pending, refunded, failed and disputed payments are excluded.';

  @override
  String get earningsChartData => 'View chart data';

  @override
  String get earningsDetails => 'Transaction details';

  @override
  String get earningsPeriod => 'Earnings period';

  @override
  String earningsReviewCount(String count) {
    return '$count reviews';
  }

  @override
  String messagesSubtitle(String role) {
    String _temp0 = intl.Intl.selectLogic(
      role,
      {
        'tasker': 'Chat with clients and manage your conversations',
        'client': 'Chat with taskers and manage your conversations',
        'other': 'Manage your conversations',
      },
    );
    return '$_temp0';
  }

  @override
  String get messagesSearch => 'Search messages…';

  @override
  String get messagesUnread => 'Unread';

  @override
  String get messagesArchived => 'Archived';

  @override
  String get messagesEmpty => 'No conversations yet.';

  @override
  String get messagesNoMatch => 'No conversations match your filters.';

  @override
  String get messagesSelect => 'Select a conversation to start chatting.';

  @override
  String get messagesLoadError => 'Could not load messages. Please try again.';

  @override
  String get messagesSyncError =>
      'Messages could not refresh. Your previous messages are still shown.';

  @override
  String get messagesType => 'Type a message…';

  @override
  String get messagesSend => 'Send message';

  @override
  String get messagesAttach => 'Add attachment';

  @override
  String get messagesCall => 'Call';

  @override
  String get messagesMore => 'Conversation options';

  @override
  String get messagesBlock => 'Block contact';

  @override
  String get messagesReport => 'Report contact';

  @override
  String get messagesArchive => 'Archive chat';

  @override
  String get messagesUnarchive => 'Unarchive chat';

  @override
  String get messagesLocalArchive =>
      'Archiving only changes the conversation list on this device.';

  @override
  String get messagesToday => 'Today';

  @override
  String get messagesYesterday => 'Yesterday';

  @override
  String get messagesOffline => 'Offline';

  @override
  String get messagesPresenceUnknown => 'Presence unavailable';

  @override
  String get messagesSent => 'Sent';

  @override
  String get messagesDelivered => 'Delivered';

  @override
  String get messagesRead => 'Read';

  @override
  String get messagesOlder => 'Load earlier messages';

  @override
  String get messagesNoThread => 'No messages in this conversation yet.';

  @override
  String get messagesSendError =>
      'Message was not sent. Your draft is kept; check the conversation before retrying.';

  @override
  String get messagesFilters => 'Filter conversations';

  @override
  String get leaveReview => 'Leave a Review';

  @override
  String get reviewSaved => 'Your review has been submitted.';

  @override
  String get reviewAlreadySubmitted => 'You have already reviewed this task.';

  @override
  String get reviewUnavailable =>
      'This task is no longer available to review. Close the form to refresh its review status.';

  @override
  String get reviewTasksLoadError =>
      'Could not load your review details. Please try again.';

  @override
  String get noReviewableTasks =>
      'No completed tasks are waiting for your review.';

  @override
  String get reviewPublicNotice =>
      'Your review will appear on the tasker\'s profile.';

  @override
  String get reviewCommentLength => 'Write between 20 and 500 characters.';

  @override
  String reviewStars(int count) {
    return '$count out of 5 stars';
  }

  @override
  String get completionApprovalTitle => 'Completion approval';

  @override
  String completionApprovalCount(int count) {
    return 'Completion approval ($count)';
  }

  @override
  String get completionApprovalSubtitle =>
      'Review the delivered work, then approve completion or return it for changes.';

  @override
  String get completionApprovalLoadError =>
      'Could not load completion requests. Please try again.';

  @override
  String get noCompletionApprovals => 'No tasks are waiting for your approval.';

  @override
  String get approveCompletion => 'Approve completion';

  @override
  String get returnForChanges => 'Return for changes';

  @override
  String confirmApproveCompletion(String task) {
    return 'Approve completion of “$task” and prepare its payment? Cash is recorded as paid only after the tasker confirms receipt. Previously verified non-cash payments are released; other electronic payments still need processing.';
  }

  @override
  String confirmReturnForChanges(String task) {
    return 'Return “$task” to the tasker for changes? The task will remain in progress.';
  }

  @override
  String get completionApproved => 'Completion approved';

  @override
  String get taskReturnedForChanges => 'Task returned for changes';

  @override
  String get completionRequestChanged =>
      'This completion request has changed. Review the refreshed task before deciding.';

  @override
  String completionRequestedOn(String date) {
    return 'Requested on $date';
  }

  @override
  String get activeAssignmentsTitle => 'Active assignments';

  @override
  String activeAssignmentsCount(int count) {
    return 'Active assignments ($count)';
  }

  @override
  String get activeAssignmentsSubtitle =>
      'Tasks you have been hired for — deliver and request completion.';

  @override
  String get noActiveAssignments =>
      'No active assignments yet. Tasks will appear here when a client hires you.';

  @override
  String get assignmentsLoadError =>
      'Could not load your assignments. Please try again.';

  @override
  String get requestCompletion => 'Request completion';

  @override
  String confirmRequestCompletion(String task) {
    return 'Have you finished “$task”? Send a completion request to the client for approval.';
  }

  @override
  String get awaitingClientApproval => 'Awaiting client approval';

  @override
  String get completionRequestSent =>
      'Completion requested. Awaiting client approval.';

  @override
  String get assignmentNoLongerActive =>
      'This assignment is no longer active. Refresh to see its current status.';

  @override
  String get clientOffersTitle => 'New offers waiting';

  @override
  String clientOffersWaiting(int count) {
    return 'New offers waiting ($count)';
  }

  @override
  String get clientOffersSubtitle =>
      'Review tasker proposals and pick the best fit.';

  @override
  String get clientOffersEmpty =>
      'No new offers yet. Proposals for your tasks will appear here.';

  @override
  String get clientOffersLoadError =>
      'Could not load your offers. Please try again.';

  @override
  String get taskOffers => 'Task proposals';

  @override
  String get rejectOffer => 'Reject';

  @override
  String get offerAccepted => 'Offer accepted';

  @override
  String get offerRejected => 'Offer rejected';

  @override
  String get offerNoLongerAvailable =>
      'This offer is no longer available. Refresh to see the latest proposals.';

  @override
  String confirmAcceptOffer(String name, String task) {
    return 'Accept $name\'s offer for “$task”? This assigns the task to this tasker.';
  }

  @override
  String confirmRejectOffer(String name) {
    return 'Reject $name\'s offer?';
  }

  @override
  String get taskerAvailableTasks => 'All available tasks';

  @override
  String get taskerBrowseInfo =>
      'Browse open tasks from all clients and apply. Posting is available for clients only.';

  @override
  String get taskerViewAndApply => 'View and apply';

  @override
  String get clientTasksTitle => 'My tasks';

  @override
  String get clientTasksScope => 'Only tasks you posted';

  @override
  String get clientTasksEmpty =>
      'You haven’t posted any tasks matching these filters.';

  @override
  String clientTasksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks',
      one: '1 task',
    );
    return '$_temp0';
  }

  @override
  String get taskerNoComparison => 'No previous-period activity';

  @override
  String taskerPeriodChange(String change) {
    return '$change% vs previous period';
  }

  @override
  String get taskerPeriodUnavailable =>
      'Analytics for this period are unavailable. Update the server and refresh.';

  @override
  String get taskerAnalyticsPrivate =>
      'Only your paid earnings and completed work. Changes compare the same elapsed time in the previous period.';

  @override
  String get taskerNoActivity =>
      'You have no recorded earnings or completed tasks in this period.';

  @override
  String get taskerDashboardLoadError => 'Couldn’t load your tasker dashboard';

  @override
  String get taskerDashboardRetryHint =>
      'Check your connection and sign in to your tasker account, then retry.';

  @override
  String get adminLast7Days => 'Last 7 days';

  @override
  String get adminLast30Days => 'Last 30 days';

  @override
  String get adminStarted => 'Started';

  @override
  String get adminNoPeriodActivity =>
      'No recorded task activity in this period.';

  @override
  String get adminNoCategoryActivity => 'No tasks to group by category yet.';

  @override
  String get adminNoRecentActivity => 'No recent tasks yet.';

  @override
  String get adminUnknownValue => 'Unavailable';

  @override
  String get adminPaidVolume => 'Paid volume';

  @override
  String get adminChartData => 'View chart data';

  @override
  String adminAnalyticsDates(String timezone) {
    return 'Daily posted, started and completed events. Dates follow $timezone.';
  }

  @override
  String get clientDashboardReadySubtitle => 'Ready to get things done today?';

  @override
  String get clientDashboardPromoTitle => 'A little help goes a long way';

  @override
  String get clientDashboardPromoSubtitle =>
      'Post a task and find the right professional for your home.';

  @override
  String get clientDashboardLoadError =>
      'We couldn’t load your dashboard. Check your connection and try again.';

  @override
  String get clientDashboardEmpty =>
      'No tasks yet. Post your first task to get started.';

  @override
  String get clientDashboardNoRecentTasks =>
      'No matching tasks among your latest 10. View all to see your full task history.';

  @override
  String get clientDashboardSuccessInfo =>
      'Success rate is shown only when the API provides it. A dash means it is unavailable, not zero.';

  @override
  String get clientDashboardPayments => 'Payments';

  @override
  String get clientDashboardUnknownTime => 'Date unavailable';

  @override
  String get appName => 'lem3alam';

  @override
  String get loading => 'Loading...';

  @override
  String get login => 'Login';

  @override
  String get register => 'Create account';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get requiredField => 'Required';

  @override
  String get passwordTooShort => 'Minimum 8 characters';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get passwordConfirm => 'Confirm password';

  @override
  String get name => 'Name';

  @override
  String get phone => 'Phone';

  @override
  String get city => 'City';

  @override
  String get role => 'Role';

  @override
  String get client => 'Client';

  @override
  String get tasker => 'Tasker';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get logout => 'Logout';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get loginSubtitle => 'Sign in to access your account';

  @override
  String get createAccountTitle => 'Create your account';

  @override
  String get createAccountSubtitle =>
      'Enter your details to create a new account';

  @override
  String get tasks => 'Tasks';

  @override
  String get tasksSubtitle => 'Browse tasks';

  @override
  String get createTask => 'Create task';

  @override
  String get editTask => 'Edit task';

  @override
  String get taskDetails => 'Task details';

  @override
  String get deleteTask => 'Delete task';

  @override
  String get apply => 'Apply';

  @override
  String get applyToTask => 'Apply to task';

  @override
  String get proposal => 'Proposal';

  @override
  String get proposedBudget => 'Proposed budget';

  @override
  String get estimatedDuration => 'Estimated duration';

  @override
  String get submitApplication => 'Submit application';

  @override
  String get applicationSubmitted => 'Application submitted';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirmDeleteTask => 'Are you sure you want to delete this task?';

  @override
  String get retry => 'Retry';

  @override
  String get unableToLoad => 'Unable to load data';

  @override
  String get emptyTasksTitle => 'No tasks';

  @override
  String get emptyTasksSubtitle => 'Create a new task or refresh the page.';

  @override
  String get shortcuts => 'Shortcuts';

  @override
  String get tip => 'Tip';

  @override
  String get tipText => 'Start by creating a task then choose the best offer.';

  @override
  String get remote => 'Remote';

  @override
  String get title => 'Title';

  @override
  String get description => 'Description';

  @override
  String get category => 'Category';

  @override
  String get addressOptional => 'Address (optional)';

  @override
  String get budgetMin => 'Minimum budget';

  @override
  String get budgetMax => 'Maximum budget';

  @override
  String get budgetType => 'Budget type';

  @override
  String get urgency => 'Urgency';

  @override
  String get paymentMethodOptional => 'Payment method (optional)';

  @override
  String get cash => 'Cash';

  @override
  String get card => 'Card';

  @override
  String get online => 'Online';

  @override
  String get save => 'Save';

  @override
  String get fixed => 'Fixed';

  @override
  String get hourly => 'Hourly';

  @override
  String get negotiable => 'Negotiable';

  @override
  String get urgencyLow => 'Low';

  @override
  String get urgencyMedium => 'Medium';

  @override
  String get urgencyHigh => 'High';

  @override
  String get urgencyUrgent => 'Urgent';

  @override
  String get statusOpen => 'Open';

  @override
  String get statusAssigned => 'Assigned';

  @override
  String get statusInProgress => 'In progress';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get lang => 'Language';

  @override
  String get langAr => 'Arabic';

  @override
  String get langEn => 'English';

  @override
  String get langFr => 'French';

  @override
  String get languageAction => 'Language';

  @override
  String get refreshAction => 'Refresh';

  @override
  String get reload => 'Reload';

  @override
  String get popularCategories => 'Popular categories';

  @override
  String get all => 'All';

  @override
  String get categories => 'Categories';

  @override
  String get browseTasksByCategory => 'Browse tasks by category';

  @override
  String get nearbyArtisans => 'Nearby artisans';

  @override
  String get seeTaskersOnMap => 'See taskers on the map';

  @override
  String get nearbyTasks => 'Nearby tasks';

  @override
  String get jobsMatchedToYourLocation => 'Jobs matched to your location';

  @override
  String get myProfile => 'My profile';

  @override
  String get publicTaskerProfile => 'Public tasker profile';

  @override
  String get myReviews => 'My reviews';

  @override
  String get ratingsAndFeedback => 'Ratings & feedback';

  @override
  String get hello => 'Hello';

  @override
  String helloName(Object name) {
    return 'Hello, $name';
  }

  @override
  String get photos => 'Photos';

  @override
  String get add => 'Add';

  @override
  String get addPhotosHelper =>
      'Add up to 5 photos to help taskers understand the job.';

  @override
  String get locationSelected => 'Location selected';

  @override
  String get pickOnMap => 'Pick on map';

  @override
  String get clear => 'Clear';

  @override
  String get cameraCaptureNotAvailableOnWeb =>
      'Camera capture is not available on web';

  @override
  String get maxTaskPhotos => 'You can attach up to 5 photos';

  @override
  String get cameraPermission => 'Camera permission';

  @override
  String get cameraPermissionPermanentlyDenied =>
      'Camera permission is permanently denied. Please enable it in Settings.';

  @override
  String get cameraPermissionRequired =>
      'Camera permission is required to take photos.';

  @override
  String get close => 'Close';

  @override
  String get openSettings => 'Open Settings';

  @override
  String cameraError(Object error) {
    return 'Camera error: $error';
  }

  @override
  String get camera => 'Camera';

  @override
  String get switchCamera => 'Switch camera';

  @override
  String get noCameraFound => 'No camera found on this device.';

  @override
  String get retake => 'Retake';

  @override
  String get usePhoto => 'Use Photo';

  @override
  String get location => 'Location';

  @override
  String get viewProfile => 'View profile';

  @override
  String newHighPriorityNearbyTasksFound(int count) {
    return '$count new high-priority nearby task(s) found.';
  }

  @override
  String get enableNearbyTaskMatching => 'Enable nearby task matching';

  @override
  String get nearbyTasksConsentSubtitle =>
      'We only use your location after you consent, and the feed refreshes at a battery-friendly interval.';

  @override
  String get nearbyTasksConsentBody =>
      'Location is used to find nearby jobs within your chosen radius and improve task relevance based on your tasker profile.';

  @override
  String get allowLocationBasedNearbyTasks =>
      'Allow location-based nearby tasks';

  @override
  String get feedControls => 'Feed controls';

  @override
  String radiusAdjustable(int min, int max) {
    return 'Radius is adjustable from ${min}km to ${max}km.';
  }

  @override
  String lastRefreshedAt(Object time) {
    return 'Last refreshed $time';
  }

  @override
  String radiusLabel(int radius) {
    return 'Radius: $radius km';
  }

  @override
  String get savedOnly => 'Saved only';

  @override
  String get savedStatus => 'Saved';

  @override
  String get locationAccuracyLow =>
      'Location accuracy is currently low. Move to an open area or refresh for better nearby matching.';

  @override
  String get noNearbyTasks => 'No nearby tasks';

  @override
  String get noNearbyTasksSubtitle =>
      'Try increasing the radius or switch back from saved-only mode.';

  @override
  String get locationDisabled => 'Location disabled';

  @override
  String get locationServicesRequired => 'Please enable GPS/location services.';

  @override
  String get locationDisabledNearbyTasksMessage =>
      'Please enable device location services to keep nearby tasks accurate.';

  @override
  String get permissionRequired => 'Permission required';

  @override
  String get permissionBlocked => 'Permission blocked';

  @override
  String get locationPermissionPermanentlyDenied =>
      'Location permission is permanently denied. Enable it in Settings.';

  @override
  String get locationPermissionRequiredNearbyArtisans =>
      'Location permission is required to show nearby artisans.';

  @override
  String get allowLocationAccessNearbyTasks =>
      'Allow location access to load nearby tasks.';

  @override
  String get enablePermissionInSettings =>
      'Location permission was denied permanently. Enable it in app settings.';

  @override
  String get unableToLoadNearbyTasks => 'Unable to load nearby tasks';

  @override
  String get distanceUnavailable => 'Distance n/a';

  @override
  String clientRatingLabel(Object rating) {
    return 'Client $rating';
  }

  @override
  String get applicationSubmittedNearbyTask =>
      'Application submitted for this nearby task.';

  @override
  String get accept => 'Accept';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get goToHome => 'Go to home';

  @override
  String get home => 'Home';

  @override
  String get openLocationSettings => 'Open Location Settings';

  @override
  String get loginRequired => 'Login required';

  @override
  String get couldNotLoadNearbyArtisans => 'Could not load nearby artisans.';

  @override
  String get noLocation => 'No location';

  @override
  String get artisans => 'Artisans';

  @override
  String get noArtisansFoundNearby => 'No artisans found nearby.';

  @override
  String get go => 'Go';

  @override
  String get center => 'Center';

  @override
  String get directions => 'Directions';

  @override
  String distanceAway(Object distance) {
    return '$distance km away';
  }

  @override
  String get couldNotOpenNavigationApp => 'Could not open navigation app.';

  @override
  String get goToFirstPage => 'Go to first page';

  @override
  String get goToPreviousPage => 'Go to previous page';

  @override
  String get goToNextPage => 'Go to next page';

  @override
  String get goToLastPage => 'Go to last page';

  @override
  String get reviews => 'Reviews';

  @override
  String get noReviews => 'No reviews';

  @override
  String get noReviewsMatchFilters => 'No reviews match your filters.';

  @override
  String get allRatings => 'All ratings';

  @override
  String starsCount(int count) {
    return '$count stars';
  }

  @override
  String get oneStar => '1 star';

  @override
  String get rating => 'Rating';

  @override
  String get sort => 'Sort';

  @override
  String get newest => 'Newest';

  @override
  String get oldest => 'Oldest';

  @override
  String get highestRating => 'Highest rating';

  @override
  String get lowestRating => 'Lowest rating';

  @override
  String get fromDate => 'From';

  @override
  String get toDate => 'To';

  @override
  String get clearDates => 'Clear dates';

  @override
  String get anonymous => 'Anonymous';

  @override
  String get taskerProfile => 'Tasker Profile';

  @override
  String get about => 'About';

  @override
  String get noBioProvided => 'No bio provided.';

  @override
  String get seeAll => 'See all';

  @override
  String get greetingMorning => 'Good morning,';

  @override
  String get greetingEvening => 'Good evening,';

  @override
  String get searchTasksHint => 'Search services or tasks...';

  @override
  String get promoTodayTitle => 'Need help with something today?';

  @override
  String get promoTodaySubtitle => 'Book trusted experts in minutes.';

  @override
  String get bookNow => 'Book now';

  @override
  String get recommendedForYou => 'Recommended for you';

  @override
  String get pickedForYourNeeds => 'Based on your activity and location';

  @override
  String get inCategory => 'Selected in this category';

  @override
  String get allTasks => 'All tasks';

  @override
  String tasksAvailableCount(int count) {
    return '$count available';
  }

  @override
  String get nearby => 'Near me';

  @override
  String get needService => 'I need a service';

  @override
  String get needServiceSubtitle => 'Book a professional in minutes.';

  @override
  String get wantWork => 'I want to work';

  @override
  String get wantWorkSubtitle => 'Offer your services and earn.';

  @override
  String get more => 'More';

  @override
  String get personalInformation => 'Personal information';

  @override
  String get personalInformationSubtitle =>
      'We\'ll use this to build your profile.';

  @override
  String get security => 'Security';

  @override
  String get securitySubtitle => 'Use a strong, unique password.';

  @override
  String get noAccountYet => 'Don\'t have an account?';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get passwordHint =>
      'Use 8+ characters with a mix of letters, numbers, and symbols.';

  @override
  String reviewsCount(Object rating, int count) {
    return '$rating · $count reviews';
  }

  @override
  String get noReviewsYet => 'No reviews yet.';

  @override
  String get whatPeopleSayAboutThisTasker =>
      'What people say about this tasker.';

  @override
  String get available => 'Available';

  @override
  String get busy => 'Busy';

  @override
  String get contact => 'Contact';

  @override
  String get bookService => 'Book Service';

  @override
  String serviceRequestForName(Object name) {
    return 'Service request for $name';
  }

  @override
  String bookServiceDescription(Object name) {
    return 'Hi $name, I would like to book a service. Please contact me.';
  }

  @override
  String get noPhoneNumber => 'No phone number';

  @override
  String get serviceArea => 'Service area';

  @override
  String get address => 'Address';

  @override
  String get pricing => 'Pricing';

  @override
  String get verification => 'Verification';

  @override
  String get details => 'Details';

  @override
  String get verified => 'Verified';

  @override
  String get unverified => 'Unverified';

  @override
  String get skills => 'Skills';

  @override
  String get noSkillsListed => 'No skills listed.';

  @override
  String yearsCount(int count) {
    return '$count years';
  }

  @override
  String get availability => 'Availability';

  @override
  String get availableToTakeNewWork => 'Available to take new work';

  @override
  String get currentlyBusy => 'Currently busy';

  @override
  String get social => 'Social';

  @override
  String get noSocialAccounts => 'No social accounts.';

  @override
  String get gallery => 'Gallery';

  @override
  String get noPhotosYet => 'No photos yet.';

  @override
  String get noCategories => 'No categories';

  @override
  String get tryAgainLater => 'Try again later.';

  @override
  String get pickLocation => 'Pick location';

  @override
  String get confirmLocation => 'Confirm location';

  @override
  String get locationPermissionRequiredToPick =>
      'Location permission is required to pick a location.';

  @override
  String get couldNotLoadMap => 'Could not load map.';

  @override
  String get searchUsers => 'Search users';

  @override
  String get searchCity => 'Search city';

  @override
  String get adminWorkspace => 'Admin Workspace';

  @override
  String get overview => 'Overview';

  @override
  String get users => 'Users';

  @override
  String get reports => 'Reports';

  @override
  String get settings => 'Settings';

  @override
  String signedInAs(Object email, Object role) {
    return 'Signed in as $email ($role)';
  }

  @override
  String get usersMetric => 'Users';

  @override
  String get tasksMetric => 'Tasks';

  @override
  String get openDisputes => 'Open disputes';

  @override
  String get revenue => 'Revenue';

  @override
  String get operationalSnapshot => 'Operational snapshot';

  @override
  String get operationalSnapshotSubtitle =>
      'Matches the backend admin datasets already used by the web app.';

  @override
  String get verifiedUsersLoadedPage => 'Verified users on loaded page';

  @override
  String get openReportsLoadedPage => 'Open reports on loaded page';

  @override
  String get mobileAdminParityPhase => 'Mobile admin parity phase';

  @override
  String get overviewModerationReports => 'Overview, moderation, reports';

  @override
  String get unableToLoadAdminOverview => 'Unable to load admin overview';

  @override
  String get checkConnectionOrAdminPermissions =>
      'Check your connection or admin permissions, then try again.';

  @override
  String get userModeration => 'User Moderation';

  @override
  String loadedUsersFromAdminApi(int loaded, int total) {
    return 'Loaded $loaded of $total users from the admin API.';
  }

  @override
  String get noUsersFound => 'No users found';

  @override
  String get tryDifferentSearchOrRefresh =>
      'Try a different search term or refresh the page.';

  @override
  String get unableToLoadUsers => 'Unable to load users';

  @override
  String get adminUsersEndpointFailed =>
      'The admin users endpoint failed to respond.';

  @override
  String get reportsComplaints => 'Reports & Complaints';

  @override
  String loadedReportsFromSharedBackend(int loaded, int total) {
    return 'Loaded $loaded of $total reports from the shared backend.';
  }

  @override
  String get noReportsFound => 'No reports found';

  @override
  String get noUserReportsToModerate =>
      'There are no user reports to moderate right now.';

  @override
  String get unableToLoadReports => 'Unable to load reports';

  @override
  String get adminReportsEndpointFailed =>
      'The admin reports endpoint failed to respond.';

  @override
  String get nearbyTaskSettingsUpdated => 'Nearby task settings updated.';

  @override
  String get nearbyTaskControls => 'Nearby task controls';

  @override
  String get nearbyTaskControlsSubtitle =>
      'Adjust default radius, limits, refresh cadence, and priority alerts for taskers.';

  @override
  String get defaultRadiusKm => 'Default radius (km)';

  @override
  String get minimumRadiusKm => 'Minimum radius (km)';

  @override
  String get maximumRadiusKm => 'Maximum radius (km)';

  @override
  String get refreshIntervalMinutes => 'Refresh interval (minutes)';

  @override
  String get notifyFromUrgency => 'Notify from urgency';

  @override
  String get enableHighPriorityAlerts => 'Enable high-priority alerts';

  @override
  String get saveSettings => 'Save settings';

  @override
  String get unableToLoadSettings => 'Unable to load settings';

  @override
  String get nearbyTaskSettingsEndpointFailed =>
      'The nearby task settings endpoint failed to respond.';

  @override
  String get noDescriptionProvided => 'No description provided.';

  @override
  String get verifyAction => 'Verify';

  @override
  String get ban => 'Ban';

  @override
  String get unban => 'Unban';

  @override
  String get suspend7Days => 'Suspend 7 days';

  @override
  String get unsuspend => 'Unsuspend';

  @override
  String get resolve => 'Resolve';

  @override
  String get mondayShort => 'Mon';

  @override
  String get tuesdayShort => 'Tue';

  @override
  String get wednesdayShort => 'Wed';

  @override
  String get thursdayShort => 'Thu';

  @override
  String get fridayShort => 'Fri';

  @override
  String get saturdayShort => 'Sat';

  @override
  String get sundayShort => 'Sun';

  @override
  String get errNetwork =>
      'Couldn\'t reach the server. Check your internet and try again.';

  @override
  String get errTimeout => 'Connection timed out. Try again.';

  @override
  String get errCancelled => 'Request cancelled.';

  @override
  String get errUnauthorized => 'You need to login to continue.';

  @override
  String get errForbidden => 'You don\'t have permission to do that.';

  @override
  String get errNotFound => 'Resource not found.';

  @override
  String get errServer => 'Server error. Please try later.';

  @override
  String get errUnknown => 'Something went wrong. Please try again.';

  @override
  String get chat => 'Chat';

  @override
  String get readMore => 'Read more';

  @override
  String get readLess => 'Read less';

  @override
  String get services => 'Services';

  @override
  String get topRated => 'Top Rated';

  @override
  String verifiedYears(int count) {
    return '$count+ Years';
  }

  @override
  String get verifiedIdentity => 'Verified';

  @override
  String daysAgo(int count) {
    return '$count days ago';
  }

  @override
  String weeksAgo(int count) {
    return '$count weeks ago';
  }

  @override
  String get writeReview => 'Write a review';

  @override
  String get helpful => 'Helpful';

  @override
  String get notHelpful => 'Not helpful';

  @override
  String showReviewsForRating(int rating) {
    return 'Show $rating★ only';
  }

  @override
  String get sortByNewest => 'Newest first';

  @override
  String get sortByTopRated => 'Top rated first';

  @override
  String get noCommentProvided => 'No comment provided.';

  @override
  String get shareYourExperience => 'Share your experience with this tasker…';

  @override
  String get submitReview => 'Submit review';

  @override
  String get selectRatingFirst => 'Select a rating first';

  @override
  String get notProvided => 'Not provided';

  @override
  String get acceptingNewBookings => 'Accepting new bookings';

  @override
  String get mon => 'Mon';

  @override
  String get tue => 'Tue';

  @override
  String get wed => 'Wed';

  @override
  String get thu => 'Thu';

  @override
  String get fri => 'Fri';

  @override
  String get sat => 'Sat';

  @override
  String get sun => 'Sun';

  @override
  String get unavailable => 'Unavailable';

  @override
  String get socialLinks => 'Social links';

  @override
  String get portfolio => 'Portfolio';

  @override
  String portfolioSubtitle(int count) {
    return '$count works';
  }

  @override
  String get availableTodayHint => 'Available today';

  @override
  String get features => 'What I bring';

  @override
  String get statJobsCompleted => 'Jobs completed';

  @override
  String get statResponseTime => 'Response time';

  @override
  String get statCompletionRate => 'Completion rate';

  @override
  String get slotMorning => 'Morning';

  @override
  String get slotAfternoon => 'Afternoon';

  @override
  String get slotEvening => 'Evening';

  @override
  String dashboardGreeting(Object name) {
    return 'Hello, $name 👋';
  }

  @override
  String get dashboardReadySubtitle => 'Ready to help and earn today?';

  @override
  String get dashboardOnline => 'Online';

  @override
  String get dashboardOffline => 'Offline';

  @override
  String get dashboardMenu => 'Open dashboard menu';

  @override
  String get dashboardNotifications => 'Notifications';

  @override
  String get dashboardProfile => 'Profile';

  @override
  String get dashboardAppearance => 'Appearance';

  @override
  String get dashboardLightMode => 'Light mode';

  @override
  String get dashboardDarkMode => 'Dark mode';

  @override
  String get dashboardActiveTasks => 'Active Tasks';

  @override
  String get dashboardCompleted => 'Completed';

  @override
  String get dashboardTotalEarnings => 'Total Earnings';

  @override
  String get dashboardRating => 'Rating';

  @override
  String get dashboardCurrencyMad => 'MAD';

  @override
  String get dashboardSuccessRate => 'Success Rate';

  @override
  String get dashboardViewDetails => 'View details';

  @override
  String get dashboardRecentTasks => 'Recent Tasks';

  @override
  String get dashboardViewAll => 'View All';

  @override
  String dashboardPendingCount(int count) {
    return 'Pending ($count)';
  }

  @override
  String dashboardAcceptedCount(int count) {
    return 'Accepted ($count)';
  }

  @override
  String get dashboardCompletedFilter => 'Completed';

  @override
  String get dashboardRepairWashingMachine => 'Repair washing machine';

  @override
  String get dashboardFixKitchenFaucet => 'Fix kitchen faucet';

  @override
  String get dashboardInstallLedLights => 'Install LED lights';

  @override
  String get dashboardRabatMorocco => 'Rabat, Morocco';

  @override
  String get dashboardCasablancaMorocco => 'Casablanca, Morocco';

  @override
  String get dashboardMarrakechMorocco => 'Marrakech, Morocco';

  @override
  String get dashboardHomeAppliance => 'Home Appliance';

  @override
  String get dashboardPlumbing => 'Plumbing';

  @override
  String get dashboardElectrical => 'Electrical';

  @override
  String dashboardHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String dashboardDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String get dashboardStatusNew => 'New';

  @override
  String get dashboardStatusPending => 'Pending';

  @override
  String dashboardPrice(Object amount) {
    return '$amount MAD';
  }

  @override
  String get dashboardGrowBusiness => 'Grow Your Business';

  @override
  String get dashboardGrowBusinessSubtitle =>
      'Get more tasks and increase your earnings';

  @override
  String get dashboardBoostProfile => 'Boost Profile';

  @override
  String get dashboardPostTask => 'Post Task';

  @override
  String get dashboardMessages => 'Messages';

  @override
  String get dashboardEarnings => 'Earnings';

  @override
  String get dashboardPerformance => 'Performance';

  @override
  String get dashboardThisWeek => 'This Week';

  @override
  String get dashboardThisMonth => 'This Month';

  @override
  String get dashboardTasksCompleted => 'Tasks Completed';

  @override
  String dashboardChangeVsLastWeek(int change) {
    return '$change% vs last week';
  }

  @override
  String get dashboardNoFilteredTasks => 'No tasks in this category yet.';

  @override
  String dashboardFeatureUnavailable(Object feature) {
    return '$feature is coming soon.';
  }

  @override
  String get adminDefaultName => 'Admin';

  @override
  String adminGreeting(Object name) {
    return 'Hello, $name 👋';
  }

  @override
  String get adminDashboardSubtitle =>
      'Here’s what’s happening on your platform today.';

  @override
  String get adminAnalyticsFallback =>
      'Live analytics are unavailable. Showing the latest dashboard snapshot.';

  @override
  String get adminTotalUsers => 'Total Users';

  @override
  String get adminTotalTasks => 'Total Tasks';

  @override
  String get adminCompletedTasks => 'Completed Tasks';

  @override
  String get adminActiveTaskers => 'Active Taskers';

  @override
  String get adminPendingTasks => 'Pending Tasks';

  @override
  String get adminPendingReviews => 'Pending Reviews';

  @override
  String get adminVsLast7Days => 'vs last 7 days';

  @override
  String get adminTasksOverview => 'Tasks Overview';

  @override
  String get adminPosted => 'Posted';

  @override
  String get adminInProgress => 'In Progress';

  @override
  String get adminTasksByStatus => 'Tasks by Status';

  @override
  String get adminTotal => 'Total';

  @override
  String get adminCancelled => 'Cancelled';

  @override
  String get adminViewAllTasks => 'View All Tasks';

  @override
  String get adminTopCategories => 'Top Categories';

  @override
  String adminTaskBy(Object customerName) {
    return 'by $customerName';
  }

  @override
  String adminMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes ago',
      one: '1 minute ago',
    );
    return '$_temp0';
  }

  @override
  String adminWeekShort(int number) {
    return 'W$number';
  }

  @override
  String get adminHomeRepairs => 'Home Repairs';

  @override
  String get adminCleaning => 'Cleaning';

  @override
  String get adminPainting => 'Painting';

  @override
  String get adminDetailedAnalyticsUnavailable =>
      'Detailed analytics will appear when the admin API provides them. No sample data is displayed.';

  @override
  String get dashboardLiveDataUnavailable =>
      'Dashboard data is not available from the API yet. No sample tasks or statistics are displayed.';
}
