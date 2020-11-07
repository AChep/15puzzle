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
) : MethodCallHandler,
    ActivityResultListener {

    companion object {
        private const val TAG = "PlayGamesPlugin"

        private const val RC_SIGN_IN = 10001
        private const val RC_LEADERBOARD_UI = 10002
        private const val RC_ACHIEVEMENT_UI = 10003

        private const val COMMAND_IS_SUPPORTED = "isSupported"
        private const val COMMAND_SIGN_IN = "signIn"
        private const val COMMAND_LEADERBOARD_UI = "showLeaderboard"
        private const val COMMAND_LEADERBOARD_SUBMIT_SCORE = "submitScore"

        private const val ERROR_SIGN_IN = "ERROR_SIGN_IN"
        private const val ERROR_INVALID_ARGS = "ERROR_INVALID_ARGS"

        fun registerWith(registrar: PluginRegistry.Registrar) {
            val channel = MethodChannel(registrar.messenger(), "com.artemchep.flutter/google_play_games")
            channel.setMethodCallHandler(PlayGamesPlugin(registrar))
        }
    }

    /**
     * Thread-safe list of activity result
     * listeners.
     */
    private val onActivityResultListeners = CopyOnWriteArrayList<OnActivityResultListener>()

    override fun onMethodCall(method: MethodCall, result: Result) {
        when (method.method) {
            COMMAND_IS_SUPPORTED -> result.success(true)
            COMMAND_SIGN_IN -> {
                GlobalScope.launch(Dispatchers.Main) {
                    val account: GoogleSignInAccount
                    try {
                        account = signIn()
                    } catch (e: Exception) {
                        result.error(ERROR_SIGN_IN, null, null)
                        return@launch
                    }

                    val accountInfo = mapOf(
                        "id" to account.id,
                        "idToken" to account.idToken,
                        "displayName" to account.displayName,
                        "familyName" to account.familyName,
                        "givenName" to account.givenName,
                        "email" to account.email,
                        "serverAuthCode" to account.serverAuthCode
                    )

                    result.success(accountInfo)
                }
            }
            COMMAND_LEADERBOARD_UI -> {
                GlobalScope.launch(Dispatchers.Main) {
                    val account: GoogleSignInAccount
                    try {
                        account = signIn()
                    } catch (e: Exception) {
                        result.error(ERROR_SIGN_IN, null, null)
                        return@launch
                    }

                    val key = method.argument<String>("id")
                        ?: run {
                            result.error(ERROR_INVALID_ARGS, null, null)
                            return@launch
                        }

                    val activity = registrar.activity()
                    val leaderboard = Games.getLeaderboardsClient(activity, account)

                    leaderboard
                        .getLeaderboardIntent(key)
                        .addOnSuccessListener { intent ->
                            activity.startActivityForResult(intent, RC_LEADERBOARD_UI)
                            result.success(null)
                        }
                        .addOnFailureListener {
                            result.error(ERROR_SIGN_IN, null, null)
                        }
                }
            }
            COMMAND_LEADERBOARD_SUBMIT_SCORE -> {
                GlobalScope.launch(Dispatchers.Main) {
                    val account: GoogleSignInAccount
                    try {
                        account = signIn()
                    } catch (e: Exception) {
                        result.error(ERROR_SIGN_IN, null, null)
                        return@launch
                    }

                    val key = method.argument<String>("id")
                        ?: run {
                            result.error(ERROR_INVALID_ARGS, null, null)
                            return@launch
                        }
                    val score = method.argumentLong("score")
                        ?: run {
                            result.error(ERROR_INVALID_ARGS, null, null)
                            return@launch
                        }

                    val activity = registrar.activity()
                    val leaderboard = Games.getLeaderboardsClient(activity, account)

                    // Submit score
                    leaderboard.submitScore(key, score)
                }
            }
            else -> result.notImplemented()
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        for (listener in onActivityResultListeners) {
            val result = listener.onActivityResult(requestCode, resultCode, data)
            if (result) {
                return true
            }
        }
        return false
    }

    private suspend fun signIn(): GoogleSignInAccount =
        suspendCancellableCoroutine { continuation ->

            // Immediately return the account instance if it is
            // available.
            val googleSignInAccount = GoogleSignIn.getLastSignedInAccount(registrar.activity())
            if (googleSignInAccount != null) {
                continuation.resume(googleSignInAccount)
                return@suspendCancellableCoroutine
            }

            val options = GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_GAMES_SIGN_IN)
                .build()
            val signInClient = GoogleSignIn.getClient(registrar.activity(), options)

            // Try to sign in silently
            signInClient
                .silentSignIn()
                .addOnSuccessListener {
                    continuation.resume(it)
                }
                .addOnFailureListener { e ->
                    Log.w(TAG, "Failed to silent sign-in, trying explicit sign-in", e)
                    // Create on activity result listener and
                    // add it to the list of listeners.
                    object : OnActivityResultListener {
                        init {
                            onActivityResultListeners += this
                        }

                        override fun onActivityResult(
                            requestCode: Int,
                            resultCode: Int,
                            data: Intent?
                        ): Boolean {
                            when (requestCode) {
                                RC_SIGN_IN -> {
                                    val result =
                                        Auth.GoogleSignInApi.getSignInResultFromIntent(data)
                                    if (result == null) {
                                        val throwable = IllegalStateException()
                                        continuation.cancel(throwable)
                                    } else if (result.isSuccess) {
                                        continuation.resume(result.signInAccount!!)
                                    } else {
                                        val message =
                                            result.status.statusMessage ?: "Error ${result.status}"
                                        val throwable = IllegalStateException(message)
                                        continuation.cancel(throwable)
                                    }
                                }
                                else -> return false
                            }
                            onActivityResultListeners -= this
                            return true
                        }
                    }

                    registrar.activity()
                        .startActivityForResult(signInClient.signInIntent, RC_SIGN_IN)
                }
        }

    /**
     * @author Artem Chepurnoy
     */
    interface OnActivityResultListener {
        fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean
    }

    private fun MethodCall.argumentLong(key: String): Long? {
        val obj = argument<Any?>(key)
        return obj as? Long ?: (obj as? Int)?.toLong()
    }

    private fun <T> MethodCall.argumentOrDefault(key: String, defaultValue: T) =
        argument(key) ?: defaultValue

}
