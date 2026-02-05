package com.jmusic.jmusic

import com.jmusic.jmusic.openlist.OpenListServiceBridge
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : AudioServiceActivity() {
	private var openListBridge: OpenListServiceBridge? = null

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)
		val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.jmusic.openlist/service")
		openListBridge = OpenListServiceBridge(this, channel)
	}
}
