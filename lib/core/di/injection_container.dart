import 'package:beesports/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:beesports/features/auth/domain/repositories/auth_repository.dart';
import 'package:beesports/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:beesports/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:beesports/features/chat/domain/repositories/chat_repository.dart';
import 'package:beesports/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:beesports/features/leaderboard/data/repositories/leaderboard_repository_impl.dart';
import 'package:beesports/features/leaderboard/domain/repositories/leaderboard_repository.dart';
import 'package:beesports/features/leaderboard/presentation/bloc/leaderboard_bloc.dart';
import 'package:beesports/features/lobby/data/repositories/lobby_repository_impl.dart';
import 'package:beesports/features/lobby/domain/repositories/lobby_repository.dart';
import 'package:beesports/features/lobby/presentation/bloc/create_lobby_bloc.dart';
import 'package:beesports/features/lobby/presentation/bloc/lobby_detail_bloc.dart';
import 'package:beesports/features/lobby/presentation/bloc/lobby_list_bloc.dart';
import 'package:beesports/features/match/data/repositories/match_repository_impl.dart';
import 'package:beesports/features/match/domain/repositories/match_repository.dart';
import 'package:beesports/features/match/presentation/bloc/match_bloc.dart';
import 'package:beesports/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:beesports/features/notifications/domain/repositories/notification_repository.dart';
import 'package:beesports/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:beesports/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:beesports/features/profile/domain/repositories/profile_repository.dart';
import 'package:beesports/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:beesports/features/social/data/repositories/social_repository_impl.dart';
import 'package:beesports/features/social/domain/repositories/social_repository.dart';
import 'package:beesports/features/social/presentation/bloc/social_bloc.dart';
import 'package:beesports/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:beesports/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:beesports/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  sl.registerLazySingleton<SupabaseClient>(
    () => Supabase.instance.client,
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<SupabaseClient>()),
  );

  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl<SupabaseClient>()),
  );

  sl.registerLazySingleton<LobbyRepository>(
    () => LobbyRepositoryImpl(sl<SupabaseClient>()),
  );

  sl.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(sl<SupabaseClient>()),
  );

  sl.registerLazySingleton<MatchRepository>(
    () => MatchRepositoryImpl(sl<SupabaseClient>()),
  );

  sl.registerLazySingleton<LeaderboardRepository>(
    () => LeaderboardRepositoryImpl(sl<SupabaseClient>()),
  );

  sl.registerFactory<AuthBloc>(
    () => AuthBloc(sl<AuthRepository>()),
  );

  sl.registerFactory<ProfileBloc>(
    () => ProfileBloc(sl<ProfileRepository>()),
  );

  sl.registerFactory<LobbyListBloc>(
    () => LobbyListBloc(sl<LobbyRepository>()),
  );

  sl.registerFactory<LobbyDetailBloc>(
    () => LobbyDetailBloc(sl<LobbyRepository>()),
  );

  sl.registerFactory<CreateLobbyBloc>(
    () => CreateLobbyBloc(sl<LobbyRepository>()),
  );

  sl.registerFactory<WalletBloc>(
    () => WalletBloc(sl<WalletRepository>()),
  );

  sl.registerFactory<MatchBloc>(
    () => MatchBloc(sl<MatchRepository>()),
  );

  sl.registerFactory<LeaderboardBloc>(
    () => LeaderboardBloc(sl<LeaderboardRepository>()),
  );

  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(sl<SupabaseClient>()),
  );

  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(sl<SupabaseClient>()),
  );

  sl.registerFactory<ChatBloc>(
    () => ChatBloc(sl<ChatRepository>()),
  );

  sl.registerFactory<NotificationBloc>(
    () => NotificationBloc(sl<NotificationRepository>()),
  );

  sl.registerLazySingleton<SocialRepository>(
    () => SocialRepositoryImpl(sl<SupabaseClient>()),
  );

  sl.registerFactory<SocialBloc>(
    () => SocialBloc(sl<SocialRepository>()),
  );
}
