import 'package:flutter/widgets.dart';

import '../../core/networking/api_exception.dart';
import 'l10n.dart';

String localizeApiException(BuildContext context, ApiException e) {
  final l10n = context.l10n;
  switch (e.message) {
    case 'err_network':
      return l10n.errNetwork;
    case 'err_timeout':
      return l10n.errTimeout;
    case 'err_cancelled':
      return l10n.errCancelled;
    case 'err_unauthorized':
      return l10n.errUnauthorized;
    case 'err_forbidden':
      return l10n.errForbidden;
    case 'err_not_found':
      return l10n.errNotFound;
    case 'err_server':
      return l10n.errServer;
    case 'err_unknown':
      return l10n.errUnknown;
    default:
      return e.message;
  }
}

