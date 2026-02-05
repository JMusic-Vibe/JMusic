package com.jmusic.jmusic.openlist

import android.content.Context
import android.content.SharedPreferences
import android.content.res.AssetManager
import android.util.Log
import android.net.Proxy
import org.json.JSONObject
import java.net.Inet4Address
import java.net.NetworkInterface
import openlistlib.Event
import openlistlib.LogCallback
import openlistlib.Openlistlib
import java.io.File
import java.io.FileOutputStream
import java.security.SecureRandom
import java.text.SimpleDateFormat
import java.util.Locale
import java.util.zip.ZipFile

object OpenListCore : Event, LogCallback {
    private const val TAG = "OpenListCore"
    private const val PREFS_NAME = "openlist_prefs"
    private const val KEY_INITIAL_PASSWORD = "initial_admin_password"
    private const val KEY_HTTP_PORT = "http_port"
    private const val KEY_PROXY_MODE = "proxy_mode"
    private var inited = false
    private lateinit var appContext: Context
    private var dataDirPath: String = ""

    @Volatile
    private var running: Boolean = false

    fun init(context: Context, dataDir: String? = null) {
        appContext = context.applicationContext
        if (dataDir != null && dataDir.isNotEmpty()) {
            dataDirPath = dataDir
        } else if (dataDirPath.isEmpty()) {
            dataDirPath = File(appContext.filesDir, "openlist").absolutePath
        }

        val dataDirFile = File(dataDirPath)
        if (!dataDirFile.exists()) {
            dataDirFile.mkdirs()
        }

        ensureWebAssets(appContext, dataDirPath)
        ensureConfigDistDir(dataDirPath)

        try {
            Openlistlib.setConfigData(dataDirPath)
            Openlistlib.setConfigLogStd(true)
            Openlistlib.init(this, this)
            inited = true
        } catch (e: Exception) {
            Log.e(TAG, "init failed", e)
            inited = false
        }
    }

    fun start(context: Context) {
        if (!inited) {
            init(context)
        }
        try {
            if (Openlistlib.isRunning("") || running) {
                return
            }
            Openlistlib.start()
            running = true
        } catch (e: Exception) {
            Log.e(TAG, "start failed", e)
            running = false
        }
    }

    fun shutdown() {
        try {
            Openlistlib.shutdown(5000)
        } catch (e: Exception) {
            Log.e(TAG, "shutdown failed", e)
        } finally {
            running = false
            inited = false
        }
    }

    fun isRunning(): Boolean {
        return try {
            Openlistlib.isRunning("") || running
        } catch (e: Exception) {
            running
        }
    }

    fun getServiceAddress(): String {
        if (!::appContext.isInitialized) return "127.0.0.1"
        val mode = prefs().getString(KEY_PROXY_MODE, "none") ?: "none"
        if (mode == "none") {
            return getLocalIPv4() ?: "127.0.0.1"
        }
        return try {
            Openlistlib.getOutboundIPString()
        } catch (e: Exception) {
            getLocalIPv4() ?: "127.0.0.1"
        }
    }

    fun getHttpPort(): Int {
        return if (!::appContext.isInitialized) 5244 else prefs().getInt(KEY_HTTP_PORT, 5244)
    }

    fun applyConfig(
        context: Context,
        httpPort: Int,
        proxyMode: String,
        proxyHost: String,
        proxyPort: Int
    ): Boolean {
        if (isRunning()) {
            return false
        }
        if (!::appContext.isInitialized) {
            appContext = context.applicationContext
        }
        if (dataDirPath.isEmpty()) {
            dataDirPath = File(appContext.filesDir, "openlist").absolutePath
        }
        val dataDirFile = File(dataDirPath)
        if (!dataDirFile.exists()) {
            dataDirFile.mkdirs()
        }

        return try {
            val configFile = File(dataDirPath, "config.json")
            val json = if (configFile.exists()) {
                try {
                    JSONObject(configFile.readText())
                } catch (e: Exception) {
                    JSONObject()
                }
            } else {
                JSONObject()
            }

            val scheme = if (json.has("scheme")) json.optJSONObject("scheme") ?: JSONObject() else JSONObject()
            scheme.put("http_port", httpPort)
            json.put("scheme", scheme)

            when (proxyMode) {
                "custom" -> json.put("proxy_address", "http://$proxyHost:$proxyPort")
                "system" -> json.put("proxy_address", resolveSystemProxy(context) ?: "")
                else -> json.put("proxy_address", "")
            }

            configFile.writeText(json.toString(2))
            prefs().edit().putInt(KEY_HTTP_PORT, httpPort).apply()
            prefs().edit().putString(KEY_PROXY_MODE, proxyMode).apply()
            true
        } catch (e: Exception) {
            Log.e(TAG, "applyConfig failed", e)
            false
        }
    }

    override fun onStartError(type: String?, err: String?) {
        Log.e(TAG, "onStartError: $type, $err")
    }

    override fun onShutdown(type: String?) {
        Log.d(TAG, "onShutdown: $type")
        running = false
    }

    override fun onProcessExit(code: Long) {
        Log.d(TAG, "onProcessExit: $code")
        running = false
    }

    private val dateFormatter by lazy { SimpleDateFormat("MM-dd HH:mm:ss", Locale.getDefault()) }

    override fun onLog(level: Short, time: Long, message: String?) {
        if (!message.isNullOrBlank()) {
            val marker = "Successfully created the admin user and the initial password is:"
            if (message.contains(marker)) {
                val pwd = message.substringAfter(marker).trim()
                if (pwd.isNotEmpty()) {
                    saveInitialPassword(pwd)
                }
            }
        }
        Log.d(TAG, "onLog: $level, ${dateFormatter.format(time)}, $message")
    }

    fun getInitialAdminPassword(): String? {
        if (!::appContext.isInitialized) return null
        return prefs().getString(KEY_INITIAL_PASSWORD, null)
    }

    fun clearInitialAdminPassword() {
        if (!::appContext.isInitialized) return
        prefs().edit().remove(KEY_INITIAL_PASSWORD).apply()
    }

    fun resetAdminPasswordRandom(): String {
        if (!::appContext.isInitialized) {
            throw IllegalStateException("OpenListCore not initialized")
        }
        val pwd = generatePassword(16)
        Openlistlib.setAdminPassword(pwd)
        return pwd
    }

    private fun generatePassword(length: Int): String {
        val chars = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789"
        val random = SecureRandom()
        val sb = StringBuilder(length)
        repeat(length) {
            sb.append(chars[random.nextInt(chars.length)])
        }
        return sb.toString()
    }

    private fun prefs(): SharedPreferences {
        return appContext.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    }

    private fun resolveSystemProxy(context: Context): String? {
        val host = System.getProperty("http.proxyHost") ?: Proxy.getHost(context)
        val port = System.getProperty("http.proxyPort")?.toIntOrNull() ?: Proxy.getPort(context)
        return if (!host.isNullOrEmpty() && port > 0) "http://$host:$port" else null
    }

    private fun getLocalIPv4(): String? {
        return try {
            NetworkInterface.getNetworkInterfaces().toList().asSequence()
                .filter { it.isUp && !it.isLoopback }
                .flatMap { it.inetAddresses.toList().asSequence() }
                .filterIsInstance<Inet4Address>()
                .map { it.hostAddress }
                .firstOrNull()
        } catch (e: Exception) {
            null
        }
    }

    private fun saveInitialPassword(pwd: String) {
        prefs().edit().putString(KEY_INITIAL_PASSWORD, pwd).apply()
    }

    private fun ensureWebAssets(context: Context, dataDir: String) {
        val targetDir = File(dataDir, "public/dist")
        val indexFile = File(targetDir, "index.html")
        if (indexFile.exists()) return

        try {
            val cwd = File(".").absolutePath
            Log.e(TAG, "ensureWebAssets: cwd=$cwd")
            Log.e(TAG, "ensureWebAssets: dataDir=$dataDir targetDir=${targetDir.absolutePath}")
            logAssetProbe(context.assets)
            val assetBasePath = findWebAssetBasePath(context.assets)
            if (assetBasePath != null) {
                Log.e(TAG, "Copying web assets from: $assetBasePath")
                copyAssetPath(context.assets, assetBasePath, targetDir, assetBasePath)
                val ok = indexFile.exists()
                Log.e(TAG, "After copy, index.html exists=$ok")
                if (ok) {
                    return
                }
            } else {
                Log.e(TAG, "Web assets not found in APK assets, trying APK zip extract")
            }
            if (extractFromApk(context, targetDir)) {
                Log.e(TAG, "Extracted web assets from APK")
            } else {
                Log.e(TAG, "Failed to extract web assets from APK")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to copy web assets", e)
        }
    }

    private fun copyAssetPath(
        assetManager: AssetManager,
        assetPath: String,
        destDir: File,
        rootPath: String
    ) {
        val children = assetManager.list(assetPath)
        if (children == null || children.isEmpty()) {
            val rel = assetPath.removePrefix(rootPath).trimStart('/')
            val outFile = File(destDir, rel)
            outFile.parentFile?.mkdirs()
            assetManager.open(assetPath).use { input ->
                FileOutputStream(outFile).use { output ->
                    input.copyTo(output)
                }
            }
            Log.e(TAG, "Copied asset file: $assetPath -> ${outFile.absolutePath}")
            return
        }

        for (name in children) {
            val childAssetPath = "$assetPath/$name"
            copyAssetPath(assetManager, childAssetPath, destDir, rootPath)
        }
    }

    private fun findWebAssetBasePath(assetManager: AssetManager): String? {
        val candidates = listOf(
            "openlist/dist",
            "flutter_assets/openlist/dist",
            "flutter_assets/android/app/src/main/assets/openlist/dist"
        )
        for (base in candidates) {
            if (assetExists(assetManager, "$base/index.html")) {
                return base
            }
        }
        return null
    }

    private fun logAssetProbe(assetManager: AssetManager) {
        try {
            val roots = assetManager.list("")?.joinToString(", ") ?: "<empty>"
            Log.e(TAG, "Asset root entries: $roots")
            val openlistRoot = assetManager.list("openlist")?.joinToString(", ") ?: "<none>"
            Log.e(TAG, "Asset openlist entries: $openlistRoot")
            val openlistDist = assetManager.list("openlist/dist")?.joinToString(", ") ?: "<none>"
            Log.e(TAG, "Asset openlist/dist entries: $openlistDist")
            val flutterRoot = assetManager.list("flutter_assets")?.joinToString(", ") ?: "<none>"
            Log.e(TAG, "Asset flutter_assets entries: $flutterRoot")
            val flutterOpenlist = assetManager.list("flutter_assets/openlist")?.joinToString(", ") ?: "<none>"
            Log.e(TAG, "Asset flutter_assets/openlist entries: $flutterOpenlist")
            val flutterDist = assetManager.list("flutter_assets/openlist/dist")?.joinToString(", ") ?: "<none>"
            Log.e(TAG, "Asset flutter_assets/openlist/dist entries: $flutterDist")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to probe assets", e)
        }
    }

    private fun extractFromApk(context: Context, targetDir: File): Boolean {
        return try {
            val apkPath = context.applicationInfo.sourceDir
            val prefixes = listOf(
                "assets/openlist/dist/",
                "assets/flutter_assets/openlist/dist/"
            )
            var count = 0
            ZipFile(apkPath).use { zip ->
                val entries = zip.entries()
                while (entries.hasMoreElements()) {
                    val entry = entries.nextElement()
                    val name = entry.name
                    val prefix = prefixes.firstOrNull { name.startsWith(it) }
                    if (prefix != null && !entry.isDirectory) {
                        val rel = name.removePrefix(prefix)
                        val outFile = File(targetDir, rel)
                        outFile.parentFile?.mkdirs()
                        zip.getInputStream(entry).use { input ->
                            FileOutputStream(outFile).use { output ->
                                input.copyTo(output)
                            }
                        }
                        count++
                    }
                }
            }
            Log.e(TAG, "extractFromApk: copied $count files")
            count > 0
        } catch (e: Exception) {
            Log.e(TAG, "extractFromApk failed", e)
            false
        }
    }

    private fun assetExists(assetManager: AssetManager, assetPath: String): Boolean {
        return try {
            assetManager.open(assetPath).close()
            true
        } catch (_: Exception) {
            false
        }
    }

    private fun ensureConfigDistDir(dataDir: String) {
        try {
            val configFile = File(dataDir, "config.json")
            val distDir = File(dataDir, "public/dist").absolutePath
            val jsonText = if (configFile.exists()) {
                configFile.readText()
            } else {
                "{}"
            }
            val json = org.json.JSONObject(jsonText)
            if (!json.has("dist_dir") || json.optString("dist_dir").isBlank()) {
                json.put("dist_dir", distDir)
                configFile.parentFile?.mkdirs()
                configFile.writeText(json.toString(2))
                Log.e(TAG, "ensureConfigDistDir: set dist_dir=$distDir")
            }
        } catch (e: Exception) {
            Log.e(TAG, "ensureConfigDistDir failed", e)
        }
    }
}
