package de.vibecode.crisis.core.model

import kotlinx.serialization.Serializable

@Serializable
enum class DisplayCurrency(val code: String, val title: String) {
    EUR("EUR", "Euro (€)"),
    USD("USD", "US-Dollar ($)");

    companion object {
        fun fromCode(code: String): DisplayCurrency? {
            return entries.firstOrNull { it.code.equals(code, ignoreCase = true) }
        }
    }
}
