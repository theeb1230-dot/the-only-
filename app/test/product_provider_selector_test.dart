import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_only/core/domain/models.dart';
import 'package:the_only/core/providers/product_provider_selector.dart';
import 'package:the_only/core/providers/provider.dart';
import 'package:the_only/core/providers/provider_health_store.dart';

class P implements MediaProvider {
  P(this.id); @override final String id;
  @override Future<List<MediaItem>> search(String query) async=>const [];
  @override Future<ProviderResult> sourcesFor(MediaItem item) async=>ProviderResult(providerId:id,sources:const []);
}
void main(){
 test('product selector enforces enabled priority then health',() async {
  SharedPreferences.setMockInitialValues({'the_only.provider.off.enabled':false,'the_only.provider.priority.priority':9});
  final prefs=await SharedPreferences.getInstance(); final health=ProviderHealthStore();
  health.record('healthy',success:true,latencyMs:10); health.record('weak',success:false,latencyMs:10);
  final ordered=ProductProviderSelector(health:health,preferences:prefs).order([P('weak'),P('off'),P('healthy'),P('priority')]);
  expect(ordered.map((e)=>e.id).toList(),['priority','healthy','weak']);
 });
}
