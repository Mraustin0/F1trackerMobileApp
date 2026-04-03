package com.example.flutter_application_1

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class NextRaceWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val prefs = HomeWidgetPlugin.getData(context)

        val raceName    = prefs.getString("race_name",        "F1 Tracker") ?: "F1 Tracker"
        val circuitName = prefs.getString("circuit_name",     "—")          ?: "—"
        val countryFlag = prefs.getString("country_flag",     "🏎")         ?: "🏎"
        val countdown   = prefs.getString("countdown",        "—")          ?: "—"
        val qualifying  = prefs.getString("qualifying_label", "—")          ?: "—"
        val d0 = formatDriver(prefs, 0)
        val d1 = formatDriver(prefs, 1)
        val d2 = formatDriver(prefs, 2)

        val opts = appWidgetManager.getAppWidgetOptions(appWidgetId)
        val minWidth = opts.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 110)
        val layoutId = if (minWidth >= 250) R.layout.next_race_widget_medium
                       else R.layout.next_race_widget_small

        val views = RemoteViews(context.packageName, layoutId)

        if (layoutId == R.layout.next_race_widget_small) {
            views.setTextViewText(R.id.wg_race_name,    raceName)
            views.setTextViewText(R.id.wg_circuit_name, circuitName)
            views.setTextViewText(R.id.wg_country_flag, countryFlag)
            views.setTextViewText(R.id.wg_countdown,    countdown)
            views.setTextViewText(R.id.wg_qualifying,   "QUAL: $qualifying")
        } else {
            views.setTextViewText(R.id.wg_m_race_name,  raceName)
            views.setTextViewText(R.id.wg_m_circuit,    circuitName)
            views.setTextViewText(R.id.wg_m_flag,       countryFlag)
            views.setTextViewText(R.id.wg_m_countdown,  countdown)
            views.setTextViewText(R.id.wg_m_qualifying, "QUAL: $qualifying")
            views.setTextViewText(R.id.wg_m_d0, d0)
            views.setTextViewText(R.id.wg_m_d1, d1)
            views.setTextViewText(R.id.wg_m_d2, d2)
        }

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    private fun formatDriver(prefs: android.content.SharedPreferences, index: Int): String {
        val code = prefs.getString("driver_${index}_code", "—") ?: "—"
        val pts  = prefs.getString("driver_${index}_pts",  "—") ?: "—"
        return "${index + 1}  $code  ${pts}pt"
    }
}
