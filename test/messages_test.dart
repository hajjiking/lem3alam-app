import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lem3alam_mobile/gen_l10n/app_localizations.dart';
import 'package:lem3alam_mobile/src/core/networking/api_client.dart';
import 'package:lem3alam_mobile/src/core/networking/api_exception.dart';
import 'package:lem3alam_mobile/src/core/ui/app_theme.dart';
import 'package:lem3alam_mobile/src/features/auth/domain/user.dart';
import 'package:lem3alam_mobile/src/features/auth/presentation/auth_controller.dart';
import 'package:lem3alam_mobile/src/features/auth/presentation/auth_state.dart';
import 'package:lem3alam_mobile/src/features/messages/application/chat_thread_controller.dart';
import 'package:lem3alam_mobile/src/features/messages/application/conversations_controller.dart';
import 'package:lem3alam_mobile/src/features/messages/data/messages_repository.dart';
import 'package:lem3alam_mobile/src/features/messages/presentation/messages_screen.dart';
import 'package:lem3alam_mobile/src/features/messages/presentation/chat_thread_pane.dart';
import 'package:lem3alam_mobile/src/features/messages/presentation/chat_message_bubble.dart';
import 'package:lem3alam_mobile/src/features/messages/presentation/conversation_list_pane.dart';
import 'package:lem3alam_mobile/src/features/dashboard/presentation/widgets/dashboard_bottom_navigation.dart';
import 'package:lem3alam_mobile/src/routing/app_router.dart';
import 'package:lem3alam_mobile/src/presentation/splash/splash_controller.dart';

AuthState _identity([int id = 10, String role = 'client']) => AuthState(
    status: AuthStatus.authenticated,
    user: User(
        id: id,
        name: 'Amina',
        email: 'test@example.com',
        role: role,
        status: 'active',
        city: 'Rabat'));

class _Auth extends AuthController {
  _Auth([this.role = 'client']);
  final String role;
  @override
  AuthState build() => _identity(10, role);
  void change(int id) => state = _identity(id);
}

class _Ready extends SplashController {
  @override
  SplashState build() =>
      const SplashState(isReady: true, targetLocation: '/messages');
}

class _Archives extends ChatArchiveStore {
  final values = <int, Set<String>>{};
  @override
  Future<Set<String>> load(int userId) async => values[userId] ?? {};
  @override
  Future<void> save(int userId, Set<String> ids) async {
    values[userId] = ids;
  }
}

Map<String, dynamic> _conversation(
        {int peer = 20,
        int? task = 19,
        String name = 'Ahmed Benali',
        int unread = 2}) =>
    {
      'contact_id': peer,
      'task_id': task,
      'contact_name': name,
      'contact_role': 'tasker',
      'contact_avatar_url': null,
      'is_online': null,
      'last_message_preview': 'Can we arrange a time for the repair?',
      'last_message_time': DateTime.now().toIso8601String(),
      'unread_count': unread,
      'related_task': task == null
          ? null
          : {
              'id': task,
              'title': 'Repair washing machine',
              'location': 'Rabat, Morocco',
              'budget_min': 120,
              'budget_max': 150
            },
    };
Map<String, dynamic> _message(int id, {bool mine = false, String? text}) => {
      'id': id,
      'sender_id': mine ? 10 : 20,
      'receiver_id': mine ? 20 : 10,
      'task_id': 19,
      'content': text ??
          (mine
              ? 'Tomorrow at 10:00 works for me.'
              : 'Hello! When would you be available?'),
      'created_at':
          DateTime.now().subtract(Duration(minutes: 10 - id)).toIso8601String(),
      'status': mine ? 'read' : 'sent',
    };

class _Api extends ApiClient {
  _Api() : super(Dio());
  List<Map<String, dynamic>> conversations = [
    _conversation(),
    _conversation(peer: 30, task: null, name: 'Sara El Amrani', unread: 1),
    _conversation(peer: 40, task: null, name: 'Youssef R.', unread: 0)
  ];
  List<Map<String, dynamic>> messages = [
    _message(4, mine: true),
    _message(3),
    _message(2, mine: true),
    _message(1)
  ];
  int pageSize = 30;
  final gets = <String>[];
  final posts = <Map<String, dynamic>>[];
  final reads = <int>[];
  Future<void> Function()? onSend;
  Future<void> Function()? onGet;
  @override
  Future<T> getJson<T>(String path,
      {Map<String, dynamic>? queryParameters}) async {
    gets.add(path);
    await onGet?.call();
    if (path.endsWith('/details')) {
      return {'success': true, 'data': _conversation()} as T;
    }
    final before = queryParameters?['before_id'] as int?;
    final items = path == 'conversations'
        ? conversations
        : messages
            .where((m) => before == null || (m['id'] as int) < before)
            .toList();
    final page = queryParameters?['page'] as int? ?? 1;
    final size = path == 'conversations' ? 2 : pageSize;
    return {
      'success': true,
      'data': {
        'data': items.skip((page - 1) * size).take(size).toList(),
        'current_page': page,
        'last_page': items.isEmpty ? 1 : (items.length / size).ceil(),
        'per_page': size,
        'total': items.length
      }
    } as T;
  }

  @override
  Future<T> postJson<T>(String path,
      {Object? data, Map<String, dynamic>? queryParameters}) async {
    expect(path, 'messages');
    final payload = data! as Map<String, dynamic>;
    posts.add(payload);
    await onSend?.call();
    final m = _message(5, mine: true, text: payload['content'] as String)
      ..['status'] = 'sent';
    messages.insert(0, m);
    return {'success': true, 'data': m} as T;
  }

  @override
  Future<T> putJson<T>(String path,
      {Object? data, Map<String, dynamic>? queryParameters}) async {
    expect(path, 'conversations/20/read');
    reads.add((data! as Map<String, dynamic>)['through_id'] as int);
    conversations[0]['unread_count'] = 0;
    return {
      'success': true,
      'data': {'read': true}
    } as T;
  }
}

MessagesRepository _repo(_Api api,
        {AuthState Function()? auth, Future<void> Function()? expire}) =>
    MessagesRepository(api, auth ?? _identity, expire ?? () async {});
final _capture = GlobalKey();
Future<void> _pump(WidgetTester tester, _Api api,
    {bool wide = false,
    String language = 'en',
    bool dark = false,
    bool selected = false}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(wide ? 1100 : 360, wide ? 950 : 800);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  final router = GoRouter(
      initialLocation: selected ? '/messages/20?task_id=19' : '/messages',
      routes: [
        GoRoute(
            path: '/messages',
            name: AppRouteNames.messages,
            builder: (_, __) => const MessagesScreen(),
            routes: [
              GoRoute(
                  path: ':peerId',
                  name: AppRouteNames.messageThread,
                  builder: (_, state) => MessagesScreen(selected: (
                        contactId: int.parse(state.pathParameters['peerId']!),
                        taskId: int.tryParse(
                            state.uri.queryParameters['task_id'] ?? '')
                      ))),
            ]),
      ]);
  addTearDown(router.dispose);
  await tester.pumpWidget(ProviderScope(
      overrides: [
        authControllerProvider.overrideWith(_Auth.new),
        messagesRepositoryProvider.overrideWithValue(_repo(api)),
        chatArchiveStoreProvider.overrideWithValue(_Archives())
      ],
      child: MaterialApp.router(
          routerConfig: router,
          locale: Locale(language),
          theme: dark ? AppTheme.dark() : AppTheme.light(),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          builder: (context, child) => RepaintBoundary(
              key: _capture,
              child: Scaffold(
                  body: child,
                  bottomNavigationBar: Consumer(
                      builder: (context, ref, _) => DashboardBottomNavigation(
                          selectedIndex: 3,
                          homeLabel: 'Home',
                          tasksLabel: 'Tasks',
                          messagesLabel: 'Messages',
                          earningsLabel: 'Payments',
                          profileLabel: 'Profile',
                          postTaskLabel: 'Post Task',
                          unreadMessageCount: ref
                                  .watch(conversationsControllerProvider)
                                  .asData
                                  ?.value
                                  .unreadCount ??
                              0,
                          onSelected: (_) {})))))));
  await tester.pumpAndSettle();
}

Future<void> _capturePng(WidgetTester tester, String name) async {
  if (!const bool.fromEnvironment('MESSAGES_SCREENSHOTS')) return;
  final boundary =
      _capture.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    await Directory('build/messages-previews').create(recursive: true);
    await File('build/messages-previews/$name.png')
        .writeAsBytes(data!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    if (const bool.fromEnvironment('MESSAGES_SCREENSHOTS')) {
      await (FontLoader('Cairo')
            ..addFont(rootBundle.load('assets/fonts/Cairo.ttf')))
          .load();
      await (FontLoader('MaterialIcons')
            ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
          .load();
    }
  });
  for (final role in ['client', 'tasker']) {
    testWidgets(
        '$role uses the real Messages branch and correct navigation variant',
        (tester) async {
      final container = ProviderContainer(overrides: [
        authControllerProvider.overrideWith(() => _Auth(role)),
        splashControllerProvider.overrideWith(_Ready.new),
        messagesRepositoryProvider.overrideWithValue(_repo(_Api())),
        chatArchiveStoreProvider.overrideWithValue(_Archives()),
      ]);
      addTearDown(container.dispose);
      final router = container.read(goRouterProvider);
      router.goNamed(AppRouteNames.messages);
      await tester.pumpWidget(UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
              routerConfig: router,
              theme: AppTheme.light(),
              locale: const Locale('en'),
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates:
                  AppLocalizations.localizationsDelegates)));
      await tester.pumpAndSettle();
      expect(find.byType(MessagesScreen), findsOneWidget);
      final nav = tester.widget<DashboardBottomNavigation>(
          find.byType(DashboardBottomNavigation));
      expect(nav.selectedIndex, role == 'client' ? 3 : 2);
      expect(nav.postTaskLabel != null, role == 'client');
      expect(nav.unreadMessageCount, 3);
      expect(
          find.text(role == 'client'
              ? 'Chat with taskers and manage your conversations'
              : 'Chat with clients and manage your conversations'),
          findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  test('polling bridges a multi-page burst without losing history', () async {
    final api = _Api()..pageSize = 2;
    final container = ProviderContainer(overrides: [
      authControllerProvider.overrideWith(_Auth.new),
      messagesRepositoryProvider.overrideWithValue(_repo(api)),
      chatArchiveStoreProvider.overrideWithValue(_Archives())
    ]);
    addTearDown(container.dispose);
    final provider = chatThreadControllerProvider((contactId: 20, taskId: 19));
    container.listen(provider, (_, __) {});
    await container.read(provider.future);
    final controller = container.read(provider.notifier);
    await controller.refresh(older: true);
    api.messages.insertAll(0, [for (var id = 10; id >= 5; id--) _message(id)]);
    await controller.refresh();
    expect(container.read(provider).requireValue.messages.map((m) => m.id),
        [10, 9, 8, 7, 6, 5, 4, 3, 2, 1]);
  });
  testWidgets('compact keyboard keeps composer visible', (tester) async {
    await _pump(tester, _Api(), language: 'ar', dark: true, selected: true);
    tester.view.viewInsets = const FakeViewPadding(bottom: 320);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const ValueKey('message-composer')), 'رسالة جديدة');
    await tester.pump();
    expect(tester.getBottomRight(find.byKey(const ValueKey('message-send'))).dy,
        lessThan(480));
    expect(tester.takeException(), isNull);
  });
  test('repository paginates inbox and sends only authenticated pair data',
      () async {
    final api = _Api();
    expect(await _repo(api).conversations(), hasLength(3));
    expect(api.gets, ['conversations', 'conversations']);
    final sent = await _repo(api)
        .send((contactId: 20, taskId: 19), '  Original message  ');
    expect(sent.text, 'Original message');
    expect(api.posts.single,
        {'receiver_id': 20, 'task_id': 19, 'content': 'Original message'});
  });
  test('repository blocks foreign pair/task responses and stale account data',
      () async {
    final api = _Api();
    await expectLater(_repo(api).thread((contactId: 30, taskId: 19)),
        throwsA(isA<ApiException>()));
    await expectLater(_repo(api).thread((contactId: 20, taskId: null)),
        throwsA(isA<ApiException>()));
    var identity = _identity();
    api.onGet = () async {
      identity = _identity(11);
    };
    await expectLater(_repo(api, auth: () => identity).conversations(),
        throwsA(isA<ApiException>()));
    identity = _identity();
    var expired = false;
    api.onGet = () async {
      identity = _identity(11);
      throw const ApiException(statusCode: 401, message: 'err_unauthorized');
    };
    await expectLater(
        _repo(api,
            auth: () => identity,
            expire: () async {
              expired = true;
            }).conversations(),
        throwsA(isA<ApiException>()));
    expect(expired, false);
  });
  test(
      'controller loads older history, merges new messages and guards double send',
      () async {
    final api = _Api()..pageSize = 2;
    final pending = Completer<void>();
    api.onSend = () => pending.future;
    final container = ProviderContainer(overrides: [
      authControllerProvider.overrideWith(_Auth.new),
      messagesRepositoryProvider.overrideWithValue(_repo(api)),
      chatArchiveStoreProvider.overrideWithValue(_Archives())
    ]);
    addTearDown(container.dispose);
    const key = (contactId: 20, taskId: 19);
    final provider = chatThreadControllerProvider(key);
    container.listen(provider, (_, __) {});
    expect((await container.read(provider.future)).messages, hasLength(2));
    final controller = container.read(provider.notifier);
    await controller.refresh(older: true);
    expect(container.read(provider).requireValue.messages, hasLength(4));
    final sending = controller.send('Hello');
    expect(await controller.send('Hello'), false);
    pending.complete();
    expect(await sending, true);
    await controller.refresh();
    expect(container.read(provider).requireValue.messages.map((m) => m.id),
        [5, 4, 3, 2, 1]);
    expect(api.posts, hasLength(1));
  });
  test('archive preferences and conversation data reset on account change',
      () async {
    final api = _Api();
    final archive = _Archives();
    late ProviderContainer container;
    container = ProviderContainer(overrides: [
      authControllerProvider.overrideWith(_Auth.new),
      messagesRepositoryProvider.overrideWith(
          (ref) => _repo(api, auth: () => ref.read(authControllerProvider))),
      chatArchiveStoreProvider.overrideWithValue(archive)
    ]);
    addTearDown(container.dispose);
    await container.read(conversationsControllerProvider.future);
    await container
        .read(conversationsControllerProvider.notifier)
        .archive('19:20');
    expect(container.read(conversationsControllerProvider).requireValue.visible,
        hasLength(2));
    (container.read(authControllerProvider.notifier) as _Auth).change(11);
    expect(container.read(conversationsControllerProvider).asData, isNull);
    expect(
        (await container.read(conversationsControllerProvider.future)).archived,
        isEmpty);
    expect(archive.values[10], {'19:20'});
  });
  testWidgets(
      'phone opens a full chat route and back returns to searchable inbox',
      (tester) async {
    final api = _Api();
    await _pump(tester, api);
    expect(find.byType(ChatThreadPane), findsNothing);
    expect(find.text('Ahmed Benali'), findsOneWidget);
    await tester.enterText(
        find.byKey(const ValueKey('message-search-10')), 'Sara');
    await tester.pumpAndSettle();
    expect(find.text('Ahmed Benali'), findsNothing);
    expect(find.text('Sara El Amrani'), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('message-search-10')), '');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ahmed Benali'));
    await tester.pumpAndSettle();
    expect(find.byType(ChatThreadPane), findsOneWidget);
    expect(find.byType(ConversationListPane), findsNothing);
    expect(api.reads, [4]);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(ConversationListPane), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('send fails visibly, keeps draft and succeeds on explicit retry',
      (tester) async {
    final api = _Api()
      ..onSend = () async {
        throw const ApiException(statusCode: 500, message: 'err_server');
      };
    await _pump(tester, api, selected: true);
    expect(
        tester
            .widget<IconButton>(find.byKey(const ValueKey('message-send')))
            .onPressed,
        isNull);
    await tester.enterText(
        find.byKey(const ValueKey('message-composer')), 'My real feedback');
    await tester.pump();
    await tester.tap(find.byTooltip('Send message'));
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey('message-composer')))
            .controller!
            .text,
        'My real feedback');
    api.onSend = null;
    await tester.tap(find.byTooltip('Send message'));
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey('message-composer')))
            .controller!
            .text,
        '');
    expect(find.text('My real feedback'), findsOneWidget);
    expect(api.posts, hasLength(2));
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'closing a focused pending composer does not pop inbox or use disposed state',
      (tester) async {
    final api = _Api();
    final pending = Completer<void>();
    api.onSend = () => pending.future;
    await _pump(tester, api);
    await tester.tap(find.text('Ahmed Benali'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('message-composer')),
        'Message while leaving');
    await tester.pump();
    await tester.tap(find.byTooltip('Send message'));
    await tester.pump();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    pending.complete();
    await tester.pumpAndSettle();
    expect(find.byType(ConversationListPane), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  for (final language in ['en', 'fr', 'ar']) {
    for (final wide in [false, true]) {
      testWidgets('$language ${wide ? 'split' : 'phone'} layout and theme',
          (tester) async {
        await _pump(tester, _Api(),
            wide: wide,
            language: language,
            dark: language == 'ar',
            selected: true);
        expect(find.byType(ChatThreadPane), findsOneWidget);
        expect(find.byType(ConversationListPane),
            wide ? findsOneWidget : findsNothing);
        final bubble = find.byType(ChatMessageBubble).first;
        final align = tester.widget<Align>(
            find.descendant(of: bubble, matching: find.byType(Align)).first);
        expect(align.alignment, AlignmentDirectional.centerEnd);
        expect(Directionality.of(tester.element(bubble)),
            language == 'ar' ? TextDirection.rtl : TextDirection.ltr);
        expect(tester.takeException(), isNull);
        await _capturePng(tester, '$language-${wide ? 'wide' : 'phone'}');
      });
    }
  }
}
