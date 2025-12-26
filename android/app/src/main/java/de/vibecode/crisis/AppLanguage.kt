package de.vibecode.crisis

import androidx.annotation.StringRes

enum class AppLanguage(val tag: String, @StringRes val labelRes: Int) {
    GERMAN("de", R.string.language_de),
    ENGLISH("en", R.string.language_en),
    FRENCH("fr", R.string.language_fr),
    SPANISH("es", R.string.language_es);

    companion object {
        fun fromTag(tag: String?): AppLanguage {
            if (tag.isNullOrBlank()) return GERMAN
            return entries.firstOrNull { it.tag.equals(tag, ignoreCase = true) } ?: GERMAN
        }
    }
}
