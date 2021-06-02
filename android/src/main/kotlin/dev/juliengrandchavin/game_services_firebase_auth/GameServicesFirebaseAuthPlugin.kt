package dev.juliengrandchavin.game_services_firebase_auth

import android.app.Activity
import android.content.Context
import android.content.Intent

import android.util.Log
import android.view.Gravity
import androidx.annotation.NonNull
import com.google.android.gms.auth.api.Auth
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInAccount
import com.google.android.gms.auth.api.signin.GoogleSignInClient
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import com.google.android.gms.common.api.ApiException
import com.google.android.gms.common.api.Status
import com.google.android.gms.games.Games
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.FirebaseAuthException
import com.google.firebase.auth.PlayGamesAuthProvider
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import java.lang.Exception
import kotlin.reflect.typeOf

private const val CHANNEL_NAME = "game_services_firebase_auth"
private const val RC_SIGN_IN = 9000

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
        fun getResourceFromContext(@NonNull context: Context, resName: String): String {
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
                Log.e("Error", "signInError", task.exception)
                Log.i("ExplicitSignIn", "Trying explicit sign in")
                explicitSignIn(clientId)
            }
        }
    }

    private fun explicitSignIn(clientId: String?) {
        val activity = activity ?: return

        val authCode = clientId ?: getResourceFromContext(context, "default_web_client_id")

        val builder = GoogleSignInOptions.Builder(
            GoogleSignInOptions.DEFAULT_GAMES_SIGN_IN
        ).requestServerAuthCode(authCode)
        googleSignInClient = GoogleSignIn.getClient(activity, builder.build())
        activity.startActivityForResult(googleSignInClient?.signInIntent, RC_SIGN_IN)
    }

    private fun handleSignInResult() {
        val activity = this.activity!!

        val gamesClient =
            Games.getGamesClient(activity, GoogleSignIn.getLastSignedInAccount(activity)!!)
        gamesClient.setViewForPopups(activity.findViewById(android.R.id.content))
        gamesClient.setGravityForPopups(Gravity.TOP or Gravity.CENTER_HORIZONTAL)

        val account = GoogleSignIn.getLastSignedInAccount(activity)

        if (account != null) {
            if (method == Methods.signInWithGameService) {
                signInFirebaseWithPlayGames(account)
            } else if (method == Methods.linkGameServicesCredentialsToCurrentUser) {
                linkCredentialsFirebaseWithPlayGames(account)
            }
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
        Log.i(pendingOperation!!.method, "success")
        pendingOperation!!.result.success(true)
        pendingOperation = null
    }

    private fun finishPendingOperationWithError(exception: Exception) {
        Log.i(pendingOperation!!.method, "error")

        when (exception) {
            is FirebaseAuthException -> {
                pendingOperation!!.result.error(exception.errorCode, exception.localizedMessage, null)
            }
            is ApiException -> {
                pendingOperation!!.result.error(
                    exception.statusCode.toString(),
                    exception.localizedMessage,
                    null
                )
            }
            else -> {
                pendingOperation!!.result.error("error", exception.localizedMessage, null)
                pendingOperation = null
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == RC_SIGN_IN) {
            val result = Auth.GoogleSignInApi.getSignInResultFromIntent(data)

            val signInAccount = result?.signInAccount

            if (result?.isSuccess == true && signInAccount != null) {
                handleSignInResult()
            } else {
                finishPendingOperationWithError(ApiException(result?.status ?: Status(0)))
            }
            return true
        }
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