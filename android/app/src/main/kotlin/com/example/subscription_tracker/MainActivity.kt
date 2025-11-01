package com.example.subscription_tracker

import android.app.AppOpsManager
import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.os.Binder
import android.os.Build
import android.os.Process
import android.provider.Settings
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.TimeUnit

class MainActivity : FlutterActivity() {
    private val CHANNEL = "usage_stats"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "hasPermission" -> {
                    result.success(hasUsagePermission(applicationContext))
                }
                "openUsageAccessSettings" -> {
                    try {
                        startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("settings_error", e.message, null)
                    }
                }
                "getUsageMinutes" -> {
                    val packageName = call.argument<String>("packageName")
                    val days = call.argument<Int>("days") ?: 30
                    if (packageName.isNullOrBlank()) {
                        result.error("bad_args", "packageName required", null)
                        return@setMethodCallHandler
                    }
                    try {
                        val minutes = queryUsageMinutes(applicationContext, packageName, days)
                        result.success(minutes)
                    } catch (e: Exception) {
                        result.error("query_error", e.message, null)
                    }
                }
                "listInstalledApps" -> {
                    try {
                        val apps = listLauncherApps(applicationContext)
                        result.success(apps)
                    } catch (e: Exception) {
                        result.error("list_error", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun hasUsagePermission(context: Context): Boolean {
        val appOps = context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                context.packageName
            )
        } else {
            @Suppress("DEPRECATION")
            appOps.checkOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), context.packageName)
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun queryUsageMinutes(context: Context, targetPackage: String, days: Int): Long {
        val usm = context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val end = System.currentTimeMillis()
        val start = end - TimeUnit.DAYS.toMillis(days.toLong())

        val stats: List<UsageStats> = usm.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, start, end)
        var totalMs = 0L
        for (s in stats) {
            if (s.packageName == targetPackage) {
                totalMs += s.totalTimeInForeground
            }
        }
        return TimeUnit.MILLISECONDS.toMinutes(totalMs)
    }

    private fun listLauncherApps(context: Context): ArrayList<HashMap<String, String>> {
        val pm: PackageManager = context.packageManager
        val intent = Intent(Intent.ACTION_MAIN, null)
        intent.addCategory(Intent.CATEGORY_LAUNCHER)

        val resolveInfos = pm.queryIntentActivities(intent, 0)
        val seen = HashSet<String>()
        val apps = ArrayList<HashMap<String, String>>()
        for (ri in resolveInfos) {
            val pkg = ri.activityInfo.packageName
            if (seen.add(pkg)) {
                val label = ri.loadLabel(pm)?.toString() ?: pkg
                val map = HashMap<String, String>()
                map["packageName"] = pkg
                map["appName"] = label
                apps.add(map)
            }
        }
        apps.sortBy { it["appName"]?.lowercase() }
        return apps
    }
}
