package com.jmusic.jmusic.openlist

import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import android.net.Uri
import android.provider.Settings

class OpenListServiceBridge(
    private val context: Context,
    private val channel: MethodChannel
) : MethodChannel.MethodCallHandler {

    companion object {
        private const val TAG = "OpenListServiceBridge"
    }

    init {
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "startService" -> {
                    result.success(startOpenListService())
                }
                "stopService" -> {
                    result.success(stopOpenListService())
                }
                "isServiceRunning" -> {
                    result.success(OpenListCore.isRunning())
                }
                "getServiceAddress" -> {
                    result.success(OpenListCore.getServiceAddress())
                }
                "getHttpPort" -> {
                    result.success(OpenListCore.getHttpPort())
                }
                "getInitialAdminPassword" -> {
                    result.success(OpenListCore.getInitialAdminPassword())
                }
                "clearInitialAdminPassword" -> {
                    OpenListCore.clearInitialAdminPassword()
                    result.success(true)
                }
                "resetAdminPassword" -> {
                    result.success(OpenListCore.resetAdminPasswordRandom())
                }
                "applyConfig" -> {
                    val port = call.argument<Int>("port") ?: 5244
                    val proxyMode = call.argument<String>("proxyMode") ?: "none"
                    val proxyHost = call.argument<String>("proxyHost") ?: "127.0.0.1"
                    val proxyPort = call.argument<Int>("proxyPort") ?: 7890
                    result.success(OpenListCore.applyConfig(context, port, proxyMode, proxyHost, proxyPort))
                }
                // battery optimization related methods removed — handled via user settings
                "openAutoStartSettings" -> {
                    try {
                        var handled = false
                        // Try some common vendor-specific auto-start settings
                        val manufacturers = mapOf(
                            "xiaomi" to "com.miui.securitycenter",
                            "huawei" to "com.huawei.systemmanager",
                            "oppo" to "com.oppo.safe",
                            "vivo" to "com.iqoo.secure",
                            "letv" to "com.letv.android.letvsafe",
                            "samsung" to "com.samsung.android.lool"
                        )
                        val manu = Build.MANUFACTURER.lowercase()
                        if (manufacturers.containsKey(manu)) {
                            val pkg = manufacturers[manu]
                            val launchIntent = context.packageManager.getLaunchIntentForPackage(pkg!!)
                            if (launchIntent != null) {
                                launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                context.startActivity(launchIntent)
                                handled = true
                            }
                        }

                        if (!handled) {
                            // Fallback: open application details settings
                            val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
                            intent.data = Uri.parse("package:${context.packageName}")
                            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            context.startActivity(intent)
                        }
                        result.success(true)
                    } catch (e: Exception) {
                        Log.w(TAG, "openAutoStartSettings failed", e)
                        result.success(false)
                    }
                }
                else -> result.notImplemented()
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error handling ${call.method}", e)
            result.error("ERROR", e.message, e.toString())
        }
    }

    private fun startOpenListService(): Boolean {
        return try {
            val intent = Intent(context, OpenListService::class.java)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
            true
        } catch (e: Exception) {
            Log.e(TAG, "Failed to start service", e)
            false
        }
    }

    private fun stopOpenListService(): Boolean {
        return try {
            val intent = Intent(context, OpenListService::class.java)
            context.stopService(intent)
            true
        } catch (e: Exception) {
            Log.e(TAG, "Failed to stop service", e)
            false
        }
    }
}
