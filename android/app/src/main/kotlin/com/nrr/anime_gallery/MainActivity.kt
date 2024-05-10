package com.nrr.anime_gallery

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import net.openid.appauth.*

class MainActivity: FlutterActivity() {
    //Channel to send data to flutter
    private lateinit var channel: MethodChannel

    companion object {
        private const val MAIN_AUTH_URL = "https://myanimelist.net"
        private const val AUTH_CODE_URI = "${MAIN_AUTH_URL}/v1/oauth2/authorize"
        private const val AUTH_TOKEN_URI = "${MAIN_AUTH_URL}/v1/oauth2/token"
        private const val AUTH_CODE_REQ_CODE = 123
    }

    private object AuthRequestParams {
        const val CODE_VERIFIER = "DVH70vGRitZz5mj-2cyeKjn0OjOOAhVxtv6IUnqW5zM"
        const val REDIRECT_URI = "com.nrr://handler"
    }

    private val authServiceConfig: AuthorizationServiceConfiguration = AuthorizationServiceConfiguration(
        Uri.parse(AUTH_CODE_URI),
        Uri.parse(AUTH_TOKEN_URI)
    )

    private fun authorization(): String {
        val authRequest: AuthorizationRequest = AuthorizationRequest.Builder(
            authServiceConfig,
            clientId,
            "code",
            Uri.parse(AuthRequestParams.REDIRECT_URI)
        )
            .setCodeVerifier(
                AuthRequestParams.CODE_VERIFIER,
                AuthRequestParams.CODE_VERIFIER,
                "plain"
            )
            .setScopes("write:users")
            .build()
        val authService = AuthorizationService(this)
        val authRequestIntent: Intent = authService.getAuthorizationRequestIntent(authRequest)
        startActivityForResult(authRequestIntent, AUTH_CODE_REQ_CODE)
        return "auth code exchange completed!"
    }

    private fun token(authCode: String): String {
        try {
            val authService = AuthorizationService(this)
            val tokenRequest: TokenRequest = TokenRequest.Builder(
                authServiceConfig,
                clientId
            )
                .setCodeVerifier(AuthRequestParams.CODE_VERIFIER)
                .setAuthorizationCode(authCode)
                .setScopes("write:users")
                .setGrantType("authorization_code")
                .setRedirectUri(Uri.parse(AuthRequestParams.REDIRECT_URI))
                .build()
            authService.performTokenRequest(
                tokenRequest
            ) { response, _ ->
                response?.accessToken?.let {
                    channel.invokeMethod("accessToken", it)
                    Log.i("my-app", "access token: $it")
                }
                response?.refreshToken?.let {
                    channel.invokeMethod("refreshToken", it)
                    Log.i("my-app", "refresh token: $it")
                }
            }
            return "token received"
        } catch (e: Exception) {
            Log.e("my-app", e.message!!)
            return "fail"
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == AUTH_CODE_REQ_CODE) {
            if (resultCode == Activity.RESULT_OK) {
                if (data != null) {
                    Log.i("my-app", "intent is not null")
                    val authResponse: AuthorizationResponse? = AuthorizationResponse.fromIntent(data)
                    val authException: AuthorizationException? = AuthorizationException.fromIntent(data)
                    authResponse?.authorizationCode?.let {
                        channel.invokeMethod("authCode", it )
                        Log.i("my-app", "code received, doing access token exchange")
                        token(it)
                    }
                } else Log.i("my-app", "intent from authorization request is null")
            } else if (resultCode == Activity.RESULT_CANCELED) {
                Log.i("my-app", "authorization process canceled")
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        this.channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "authorization:android")
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "android:authorization")
            .setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
                if (call.method == "authorization") {
                    authorization()
                    result.success("authorization in progress")
                }
            }
    }
}
