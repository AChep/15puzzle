package com.artemchep.flutter

import com.artemchep.flutter.gpg.PlayGamesPlugin
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugins.GeneratedPluginRegistrant

fun registerWith(registry: PluginRegistry) {
    registerPlayGamesWith(registry)
}

fun registerPlayGamesWith(registry: PluginRegistry) {
    val key = PlayGamesPlugin::class.java.canonicalName
    if (!registry.hasPlugin(key)) {
        PlayGamesPlugin.registerWith(registry.registrarFor(key))
    }
}