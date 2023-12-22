package io.revoltgames.game_services_firebase_auth

import android.app.Activity
import android.content.Context
import android.content.Intent

import android.util.Log
import com.google.android.gms.auth.api.Auth
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInAccount
import com.google.android.gms.auth.api.signin.GoogleSignInClient
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import com.google.android.gms.common.api.ApiException
import com.google.android.gms.common.api.Status
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.FirebaseAuthException
import com.google.firebase.auth.PlayGamesAuthProvider
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.*
import io.flutter.plugin.common.MethodChannel.Result
import java.lang.Exception

private const val CHANNEL_NAME = "game_services_firebase_auth"
private const val RC_SIGN_IN = 9000

private const val LOG_PREFIX = "game_services_firebase"

object Methods {
    const val signInWithGameService = "sign_in_with_game_service"
    const val linkGameServicesCredentialsToCurrentUser =
        "link_game_services_credentials_to_current_user"
}

class GameServicesFirebaseAuthPlugin(private var activity: Activity? = null) : FlutterPlugin,
    MethodChannel.MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener {

    private var googleSignInClient: GoogleSignInClient? = null
    private var activityPluginBinding: ActivityPluginBinding? = null
    private var channel: MethodChannel? = null
    private var pendingOperation: PendingOperation? = null
    private lateinit var context: Context

    private var method: String? = null
    private var clientId: String? = null
    private var gResult: Result? = null
    private var forceSignInIfCredentialAlreadyUsed: Boolean = false

    companion object {
        @JvmStatic
        fun getResourceFromContext(context: Context, resName: String): String {
            val stringRes = context.resources.getIdentifier(resName, "string", context.packageName)
            if (stringRes == 0) {
                throw IllegalArgumentException(
                    String.format(
                        "The 'R.string.%s' value it's not defined in your project's resources file.",
                        resName
                    )
                )
            }
            return context.getString(stringRes)
        }

    }

    private fun silentSignIn() {
        val activity = activity ?: return

        val authCode = clientId ?: getResourceFromContext(context, "default_web_client_id")

        val builder = GoogleSignInOptions.Builder(
            GoogleSignInOptions.DEFAULT_GAMES_SIGN_IN
        ).requestServerAuthCode(authCode)
        googleSignInClient = GoogleSignIn.getClient(activity, builder.build())
        googleSignInClient?.silentSignIn()?.addOnCompleteListener { task ->
            pendingOperation = PendingOperation(method!!, gResult!!)

            if (task.isSuccessful) {
                handleSignInResult()
            } else {
                Log.e(LOG_PREFIX, "signInError", task.exception)
                Log.i(LOG_PREFIX, "Trying explicit sign in")
                explicitSignIn(clientId)
            }
        }
    }

    private fun explicitSignIn(clientId: String?) {
        val activity = activity ?: return

        val authCode = clientId ?: getResourceFromContext(context, "default_web_client_id")

        Log.i(LOG_PREFIX, "explicitSignIn: authCode: $authCode")

        val builder = GoogleSignInOptions.Builder(
            GoogleSignInOptions.DEFAULT_GAMES_SIGN_IN
        ).requestServerAuthCode(authCode)
        googleSignInClient = GoogleSignIn.getClient(activity, builder.build())
        activity.startActivityForResult(googleSignInClient?.signInIntent, RC_SIGN_IN)

        Log.i(LOG_PREFIX, "explicitSignIn: started sign in flow")
    }

    private fun handleSignInResult() {
        val activity = this.activity!!

        val account = GoogleSignIn.getLastSignedInAccount(activity)

        if (account != null) {
            if (method == Methods.signInWithGameService) {
                signInFirebaseWithPlayGames(account)
            } else if (method == Methods.linkGameServicesCredentialsToCurrentUser) {
                linkCredentialsFirebaseWithPlayGames(account)
            }
        } else {
            Log.w(LOG_PREFIX, "last signed in account is null")
        }
    }

    private fun signInFirebaseWithPlayGames(acct: GoogleSignInAccount) {
        val auth = FirebaseAuth.getInstance()

        val authCode = acct.serverAuthCode ?: throw Exception("auth_code_null")

        val credential = PlayGamesAuthProvider.getCredential(authCode)

        auth.signInWithCredential(credential).addOnCompleteListener { result ->
            if (result.isSuccessful) {
                finishPendingOperationWithSuccess()
            } else {
                finishPendingOperationWithError(
                    result.exception
                        ?: Exception("signInWithCredential failed")
                )
            }
        }
    }

    private fun linkCredentialsFirebaseWithPlayGames(acct: GoogleSignInAccount) {
        val auth = FirebaseAuth.getInstance()

        val currentUser = auth.currentUser ?: throw  Exception("current_user_null")

        val authCode = acct.serverAuthCode ?: throw Exception("auth_code_null")

        val credential = PlayGamesAuthProvider.getCredential(authCode)


        currentUser.linkWithCredential(credential).addOnCompleteListener { result ->
            if (result.isSuccessful) {
                finishPendingOperationWithSuccess()
            } else {
                if (result.exception is FirebaseAuthException) {
                    if ((result.exception as FirebaseAuthException).errorCode == "ERROR_CREDENTIAL_ALREADY_IN_USE" && forceSignInIfCredentialAlreadyUsed) {
                        method = Methods.signInWithGameService
                        silentSignIn()
                    } else {
                        finishPendingOperationWithError(
                            result.exception
                                ?: Exception("linkWithCredential failed")
                        )
                    }
                } else {
                    finishPendingOperationWithError(
                        result.exception
                            ?: Exception("linkWithCredential failed")
                    )
                }
            }
        }
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        setupChannel(binding.binaryMessenger)
        context = binding.applicationContext
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        teardownChannel()
    }

    private fun setupChannel(messenger: BinaryMessenger) {
        channel = MethodChannel(messenger, CHANNEL_NAME)
        channel?.setMethodCallHandler(this)
    }

    private fun teardownChannel() {
        channel?.setMethodCallHandler(null)
        channel = null
    }


    private fun disposeActivity() {
        activityPluginBinding?.removeActivityResultListener(this)
        activityPluginBinding = null
    }

    override fun onDetachedFromActivity() {
        disposeActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityPluginBinding = binding
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    private class PendingOperation constructor(val method: String, val result: Result)

    private fun finishPendingOperationWithSuccess() {
        try {
            Log.i(LOG_PREFIX, pendingOperation?.method + ": success")
            pendingOperation?.result?.success(true)
        } catch (e: IllegalStateException) {
            Log.w(LOG_PREFIX, "finishPendingOperationWithSuccess: problem", e)
        } finally {
            pendingOperation = null
        }
    }

    private fun finishPendingOperationWithError(exception: Exception) {
        try {
            Log.i(LOG_PREFIX, pendingOperation?.method+ ": error", exception)
            when (exception) {
                is FirebaseAuthException -> {
                    pendingOperation?.result?.error(
                        exception.errorCode,
                        exception.localizedMessage,
                        null
                    )
                }
                is ApiException -> {
                    pendingOperation?.result?.error(
                        exception.statusCode.toString(),
                        exception.localizedMessage,
                        null
                    )
                }
                else -> {
                    pendingOperation?.result?.error("error", exception.localizedMessage, null)
                }
            }
        } catch (e: IllegalStateException) {
            Log.w(LOG_PREFIX, "finishPendingOperationWithError: problem", e)
        } finally {
            pendingOperation = null
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == RC_SIGN_IN) {
            if (data == null) {
                Log.w(LOG_PREFIX, "activity finished with null data")
                return false
            }
            val result = Auth.GoogleSignInApi.getSignInResultFromIntent(data)

            val signInAccount = result?.signInAccount

            if (result?.isSuccess == true && signInAccount != null) {
                Log.i(LOG_PREFIX, "sign in activity success")
                handleSignInResult()
            } else {
                Log.w(LOG_PREFIX, "sign in activity failed: " + result.toString())
                finishPendingOperationWithError(ApiException(result?.status ?: Status(0)))
            }
            return true
        }
        Log.w(LOG_PREFIX, "unknown activity requestCode: $requestCode")
        return false
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            Methods.signInWithGameService -> {
                method = Methods.signInWithGameService

                clientId = call.argument<String>("client_id")

                gResult = result

                silentSignIn()
            }
            Methods.linkGameServicesCredentialsToCurrentUser -> {
                method = Methods.linkGameServicesCredentialsToCurrentUser
                clientId = call.argument<String>("client_id")
                forceSignInIfCredentialAlreadyUsed =
                    call.argument<Boolean>("force_sign_in_credential_already_used") == true
                gResult = result
                silentSignIn()
            }
            else -> result.notImplemented()
        }
    }
}