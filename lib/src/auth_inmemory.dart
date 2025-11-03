// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';

import 'package:auth_client/auth_client.dart';
import 'package:core/core.dart';
import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

/// {@template auth_inmemory}
/// An in-memory implementation of the [AuthClient] interface for
/// demonstration and testing purposes.
///
/// This client simulates authentication flows without requiring a backend,
/// managing user and token states purely in memory.
/// {@endtemplate}

/// {@nodoc}
class AuthInmemory implements AuthClient {
  /// {@macro auth_inmemory}
  AuthInmemory({
    this.initialUser,
    this.initialToken,
    Logger? logger,
    List<String>? privilegedEmails,
  })  : _logger = logger ?? Logger('AuthInmemory'),
        _privilegedEmails = privilegedEmails ??
            const ['admin@example.com', 'publisher@example.com'] {
    _logger.fine(
      'Initializing with initialUser: $initialUser, '
      'initialToken: $initialToken, '
      'privilegedEmails: $_privilegedEmails',
    );
    _currentUser = initialUser;
    _currentToken = initialToken;
    // To mimic a "hot" stream like a real auth client, we immediately
    // emit the initial state. We use a Future to schedule this for the next
    // event-loop microtask, ensuring that subscribers (like AppBloc) have
    // time to listen before the first event is sent.
    Future(() => _authStateController.add(_currentUser));
    _logger
      ..finer(
        'Scheduled initial user ($_currentUser) to be added to authStateController.',
      )
      ..fine('AuthInmemory initialization complete.');
  }
  final Logger _logger;
  final Uuid _uuid = const Uuid();

  /// The initial user to set for demonstration purposes.
  final User? initialUser;

  /// The initial token to set for demonstration purposes.
  final String? initialToken;

  /// The list of privileged emails that are allowed to access the dashboard.
  final Set<String> _privilegedEmails;

  final StreamController<User?> _authStateController =
      StreamController<User?>.broadcast();

  User? _currentUser;
  String? _currentToken;
  final Map<String, String> _pendingCodes = {};

  @override
  Stream<User?> get authStateChanges {
    _logger.finer('authStateChanges getter called.');
    return _authStateController.stream;
  }

  /// Returns the current authentication token.
  ///
  /// This is a custom getter for the in-memory client to allow the
  /// repository to retrieve the token after successful authentication.
  String? get currentToken {
    _logger.finer('currentToken getter called. Returning $_currentToken');
    return _currentToken;
  }

  @override
  Future<User?> getCurrentUser() async {
    _logger.fine('getCurrentUser called.');
    await Future<void>.delayed(const Duration(milliseconds: 100));
    _logger.fine('getCurrentUser returning $_currentUser');
    return _currentUser;
  }

  @override
  Future<void> requestSignInCode(
    String email, {
    bool isDashboardLogin = false,
  }) async {
    _logger.fine(
      'requestSignInCode called for email: $email, '
      'isDashboardLogin: $isDashboardLogin',
    );
    if (!email.contains('@') || !email.contains('.')) {
      _logger.warning(
        'Invalid email format for $email. Throwing InvalidInputException.',
      );
      throw const InvalidInputException('Invalid email format.');
    }

    if (isDashboardLogin && !_privilegedEmails.contains(email)) {
      _logger.warning(
        'Dashboard login requested for non-privileged email $email. '
        'Throwing UnauthorizedException.',
      );
      throw const UnauthorizedException(
        'This email does not have dashboard access.',
      );
    }

    _pendingCodes[email] = '123456'; // Hardcoded for demo
    _logger.info(
      'Generated code 123456 for $email. Pending codes: $_pendingCodes',
    );
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _logger.fine('requestSignInCode completed for email: $email');
  }

  @override
  Future<AuthSuccessResponse> verifySignInCode(
    String email,
    String code, {
    bool isDashboardLogin = false,
  }) async {
    _logger.fine(
      'verifySignInCode called for email: $email, code: $code, '
      '$code, isDashboardLogin: $isDashboardLogin',
    );
    if (!email.contains('@') || !email.contains('.')) {
      _logger.warning(
        'Invalid email format for $email. Throwing InvalidInputException.',
      );
      throw const InvalidInputException('Invalid email format.');
    }

    if (isDashboardLogin && !_privilegedEmails.contains(email)) {
      _logger.warning(
        'Dashboard login verification for non-privileged email $email. '
        'Throwing NotFoundException.',
      );
      throw const NotFoundException('User not found for dashboard access.');
    }

    if (code != _pendingCodes[email]) {
      _logger.warning(
        'Invalid or expired code for $email. Expected: '
        '${_pendingCodes[email]}, Got: $code. Throwing AuthenticationException.',
      );
      throw const AuthenticationException('Invalid or expired code.');
    }

    final user = User(
      id: _uuid.v4(),
      email: email,
      appRole: isDashboardLogin
          ? AppUserRole.premiumUser
          : AppUserRole.standardUser,
      dashboardRole: switch (email) {
        'admin@example.com' when isDashboardLogin => DashboardUserRole.admin,
        'publisher@example.com' when isDashboardLogin => DashboardUserRole.publisher,
        _ => DashboardUserRole.none,
      },
      createdAt: DateTime.now(),
      feedDecoratorStatus:
          Map<FeedDecoratorType, UserFeedDecoratorStatus>.fromEntries(
            FeedDecoratorType.values.map(
              (type) => MapEntry(
                type,
                const UserFeedDecoratorStatus(isCompleted: false),
              ),
            ),
          ),
    );
    _currentUser = user;
    _currentToken = _uuid.v4();
    _authStateController.add(_currentUser);
    _pendingCodes.remove(email);

    _logger
      ..info(
        'User $email verified. New user: $_currentUser, token: $_currentToken',
      )
      ..finer('Pending codes after verification: $_pendingCodes');
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _logger.fine('verifySignInCode completed for email: $email');
    return AuthSuccessResponse(user: user, token: _currentToken!);
  }

  @override
  Future<AuthSuccessResponse> signInAnonymously() async {
    _logger.fine('signInAnonymously called.');
    final user = User(
      id: _uuid.v4(),
      email: 'anonymous@example.com',
      appRole: AppUserRole.guestUser,
      dashboardRole: DashboardUserRole.none,
      createdAt: DateTime.now(),
      feedDecoratorStatus:
          Map<FeedDecoratorType, UserFeedDecoratorStatus>.fromEntries(
            FeedDecoratorType.values.map(
              (type) => MapEntry(
                type,
                const UserFeedDecoratorStatus(isCompleted: false),
              ),
            ),
          ),
    );
    _currentUser = user;
    _currentToken = _uuid.v4();
    _authStateController.add(_currentUser);

    _logger.info(
      'Signed in anonymously. User: $_currentUser, token: $_currentToken',
    );
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _logger.fine('signInAnonymously completed.');
    return AuthSuccessResponse(user: user, token: _currentToken!);
  }

  @override
  Future<void> signOut() async {
    _logger.fine('signOut called.');
    _currentUser = null;
    _currentToken = null;
    _authStateController.add(null);
    _pendingCodes.clear();

    _logger
      ..info(
        'User signed out. Current user: $_currentUser, token: $_currentToken',
      )
      ..finer('Pending codes after sign out: $_pendingCodes');
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _logger.fine('signOut completed.');
  }
}
