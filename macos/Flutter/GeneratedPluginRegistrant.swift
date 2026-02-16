//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import shared_preferences_foundation
<<<<<<< HEAD

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  SharedPreferencesPlugin.register(with: registry.registrar(forPlugin: "SharedPreferencesPlugin"))
=======
import sqflite_darwin

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  SharedPreferencesPlugin.register(with: registry.registrar(forPlugin: "SharedPreferencesPlugin"))
  SqflitePlugin.register(with: registry.registrar(forPlugin: "SqflitePlugin"))
>>>>>>> 254912d (Initial commit)
}
