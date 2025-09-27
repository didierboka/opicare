import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:opicare/core/constants/api_url.dart';

void main() async {
  print('Test des nouveaux headers avec opisms.net...');
  
  try {
    final client = http.Client();
    final response = await client.post(
      Uri.parse('https://opisms.net/opisms-aws/vaccin/majrdv'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'Opicare-Mobile-App/1.0',
        'Connection': 'keep-alive',
        'Cache-Control': 'no-cache',
        'Accept-Encoding': 'gzip, deflate',
      },
      body: jsonEncode({
        "calId": "19897594",
        "usrId": "21",
        "ctrregion": "11",
        "ctrdist": "86",
        "ctrId": "25",
        "patId": "216",
        "vacId": "84",
        "dtRap": "2013-12-12",
        "dtPre": "2013-12-12",
        "lot": "127VFC044Z",
        "imgCarnet": ApiUrl.base64Default
      }),
    ).timeout(const Duration(seconds: 30));
    
    client.close();
    print('✅ Réponse reçue: ${response.statusCode}');
    print('📄 Contenu: ${response.body}');
  } on TimeoutException catch (e) {
    print('❌ TimeoutException: $e');
  } on http.ClientException catch (e) {
    print('❌ ClientException: $e');
  } catch (e) {
    print('❌ Autre erreur: $e');
  }
}
