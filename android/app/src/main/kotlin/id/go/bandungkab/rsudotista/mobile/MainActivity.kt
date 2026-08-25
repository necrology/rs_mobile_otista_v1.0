package id.go.bandungkab.rsudotista.mobile

import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "id.go.bandungkab.rsudotista.mobile/mobile_jkn"
    private val mobileJknPackage = "app.bpjs.mobile"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "openMobileJkn" -> {
                    try {
                        openMobileJkn()
                        result.success(null)
                    } catch (_: ActivityNotFoundException) {
                        result.error(
                            "PLAY_STORE_NOT_FOUND",
                            "Google Play Store tidak tersedia di perangkat ini.",
                            null
                        )
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun openMobileJkn() {
        val launchIntent = packageManager
            .getLaunchIntentForPackage(mobileJknPackage)
            ?.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)

        if (launchIntent != null) {
            startActivity(launchIntent)
            return
        }

        openMobileJknPlayStore()
    }

    private fun openMobileJknPlayStore() {
        val marketIntent = Intent(
            Intent.ACTION_VIEW,
            Uri.parse("market://details?id=$mobileJknPackage")
        ).apply {
            setPackage("com.android.vending")
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }

        startActivity(marketIntent)
    }
}
