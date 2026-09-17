import '../domain/live_channel.dart';
import '../domain/programme.dart';
import '../domain/models.dart';

abstract interface class LiveTvProvider {
  String get id;
  Future<List<LiveChannel>> channels();
  Future<List<Programme>> programmes(String channelId, DateTime from, DateTime to);
  Future<List<StreamSource>> streams(LiveChannel channel);
}
