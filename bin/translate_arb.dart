import 'dart:convert';
import 'dart:io';
import 'package:dotenv/dotenv.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  var env = DotEnv(includePlatformEnvironment: true);
  env.load(['assets/.env']); // Load environment variables from the .env file

  final apiKey = env['GOOGLE_TRANSLATE_API_KEY'];
  if (apiKey == null) {
    throw Exception("API key not found");
  }

  final arbFile = File('lib/l10n/intl_en.arb');
  final arbContent = json.decode(await arbFile.readAsString());

  const targetLanguages = ['es', 'fr', 'de', 'it', 'zh', 'zh_Hant']; // Use underscore instead of hyphen

  for (var language in targetLanguages) {
    final translatedContent = await translateArbContent(arbContent, language.replaceAll('_', '-'), apiKey); // Replace underscore with hyphen for translation
    translatedContent['@@locale'] = language; // Set the @@locale key correctly
    final translatedFile = File('lib/l10n/intl_$language.arb');
    await translatedFile.writeAsString(json.encode(translatedContent));
    print('Translated to $language and saved to ${translatedFile.path}');
  }
}

Future<Map<String, dynamic>> translateArbContent(Map<String, dynamic> content, String targetLanguage, String apiKey) async {
  final translatedContent = <String, dynamic>{};
  for (var key in content.keys) {
    if (key.startsWith('@') || key == 'appName') { // Skip meta keys and appName
      translatedContent[key] = content[key];
    } else {
      translatedContent[key] = await translateText(content[key], targetLanguage, apiKey);
    }
  }
  return translatedContent;
}

Future<String> translateText(String text, String targetLanguage, String apiKey) async {
  final url = Uri.parse('https://translation.googleapis.com/language/translate/v2?key=$apiKey');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'q': text,
      'source': 'en',
      'target': targetLanguage,
      'format': 'text'
    }),
  );

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    return jsonResponse['data']['translations'][0]['translatedText'];
  } else {
    throw Exception('Failed to translate text: ${response.body}');
  }
}
