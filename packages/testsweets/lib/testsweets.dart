library testsweets;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:testsweets/widget_inspector.dart';

/// Uploads the automation Keys in the given list to the user project with the given
/// [projectId].
///
/// Call this function from your `main.dart` script. The automation keys can be found
/// in the "app_automation_keys.dart" file generated by the testsweets_generator.
///
/// Error messages are printed to the console.
///
/// Returns `true` on success, `false` on failure.
///
/// Example usage:
/// ```
/// import 'package:testsweets/testsweets.dart' as testSweets;
/// import 'app_automation_keys.dart' as appKeys;
///
/// void main() {
///   testSweets.syncAutomationKeys(projectId: 'YOUR_PROJECT_ID', apiKey: 'YOUR_PROJECT_API_KEY', automationKeys: appKeys.APP_AUTOMATION_KEYS);
///   runApp(MyApp());
/// }
/// ```
///
/// You must replace `YOUR_PROJECT_ID` and `YOUR_PROJECT_API_KEY` with the project id and api key of your project, respectively.
/// These can be found in the project config tab in the test sweets application.
Future<bool> syncAutomationKeys(
    {String projectId,
    String apiKey,
    List<Map<String, String>> automationKeys}) {
  return _uploadAutomationKeys(
      projectId: projectId, apiKey: apiKey, automationKeys: automationKeys);
}

Future<bool> _uploadAutomationKeys(
    {String projectId,
    String apiKey,
    List<Map<String, String>> automationKeys}) async {
  const endpoint =
      'https://us-central1-testsweets-38348.cloudfunctions.net/saveAutomationKeys';
  print(
      '\u001b[36mTestSweets: POSTING automation keys to ${endpoint}. Keys: ${automationKeys}\u001b[0m');
  var response = await http.post(
    endpoint,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'apiKey': apiKey,
      'projectId': projectId,
      'automationKeys': automationKeys,
    }),
  );
  if (response.statusCode != 200) {
    print(
        '\u001b[31mTestSweets: FAILED to POST keys with statusCode ${response.statusCode}. Error: ${response.body}\u001b[0m');
    return false;
  } else {
    print(
        '\u001b[36mTestSweets: Successfully uploaded automation keys.\u001b[0m');
    return true;
  }
}

class TestSweets {
  /// Creates an tranparent overlay which can be turned on 
  /// to inspect widgets and their key names
  static Widget builder(BuildContext context, Widget child,
      {bool enabled = true}) {
    return enabled && kDebugMode ? WidgetInspectorView(child: child) : child;
  }
}
