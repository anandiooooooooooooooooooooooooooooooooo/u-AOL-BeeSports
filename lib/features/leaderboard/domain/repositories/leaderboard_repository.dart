import 'package:beesports/features/leaderboard/domain/entities/leaderboard_entry_entity.dart';
import 'package:beesports/shared/models/sport_type.dart';

abstract class LeaderboardRepository {
  Future<List<LeaderboardEntryEntity>> getLeaderboard(
    SportType sport, {
    String? campus,
  });

  Future<LeaderboardEntryEntity?> getPlayerRanking(
    String userId,
    SportType sport,
  );
}
