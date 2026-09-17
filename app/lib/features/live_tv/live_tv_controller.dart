import '../../core/domain/live_channel.dart';
import '../../core/domain/models.dart';
import '../../core/domain/programme.dart';
import '../../core/providers/live_provider.dart';

class LiveTvController {
  LiveTvController(this.providers);
  final List<LiveTvProvider> providers;

  Future<List<LiveChannel>> channels() async {
    final result = <String, LiveChannel>{};
    for (final provider in providers) {
      try {
        for (final channel in await provider.channels()) {
          result.putIfAbsent('${channel.name.toLowerCase()}|${channel.group ?? ''}', () => channel);
        }
      } catch (_) {}
    }
    return result.values.toList(growable: false);
  }

  Future<List<Programme>> guide(String channelId, DateTime from, DateTime to) async {
    final guide = <Programme>[];
    for (final provider in providers) {
      try { guide.addAll(await provider.programmes(channelId, from, to)); } catch (_) {}
    }
    guide.sort((a, b) => a.startsAt.compareTo(b.startsAt));
    return guide;
  }

  Future<List<StreamSource>> streams(LiveChannel channel) async {
    final streams = <StreamSource>[];
    for (final provider in providers) {
      try { streams.addAll(await provider.streams(channel)); } catch (_) {}
    }
    return streams;
  }
}
