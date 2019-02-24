package com.artemchep.flutter.gpg

import android.content.Intent
import android.util.Log
import com.google.android.gms.auth.api.Auth
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInAccount
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import com.google.android.gms.games.Games
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.suspendCancellableCoroutine
import java.util.concurrent.CopyOnWriteArrayList
import kotlin.coroutines.resume
import io.flutter.plugin.common.MethodChannel

/**
 * @author Artem Chepurnoy
 */
class PlayGamesPlugin(
    val registrar: PluginRegistry.Registrar
) : MethodCallHandler {

    companion object {
        private const val TAG = "PlayGamesPlugin"

        private const val COMMAND_IS_SUPPORTED = "isSupported"

        fun registerWith(registrar: PluginRegistry.Registrar) {
            val channel = MethodChannel(registrar.messenger(), "com.artemchep.flutter/google_play_games")
            channel.setMethodCallHandler(PlayGamesPlugin(registrar))
        }
    }

    override fun onMethodCall(method: MethodCall, result: Result) {
        when (method.method) {
            COMMAND_IS_SUPPORTED -> result.success(false)
            else -> result.notImplemented()
        }
    }

}
