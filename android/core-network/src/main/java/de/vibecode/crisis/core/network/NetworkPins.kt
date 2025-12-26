package de.vibecode.crisis.core.network

object NetworkPins {
    /**
     * Add certificate pins in sha256/<base64> format keyed by hostname.
     * Keep this empty until you validate and rotate pins for production.
     */
    val hostPins: Map<String, List<String>> = emptyMap()
}
