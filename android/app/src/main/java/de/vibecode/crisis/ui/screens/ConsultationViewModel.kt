package de.vibecode.crisis.ui.screens

import android.app.Application
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import de.vibecode.crisis.CrisisApp
import de.vibecode.crisis.core.data.ConsultationRequest
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.util.Locale

class ConsultationViewModel(application: Application) : AndroidViewModel(application) {
    private val service = (application as CrisisApp).container.consultationService

    var name by mutableStateOf("")
        private set
    var email by mutableStateOf("")
        private set
    var phone by mutableStateOf("")
        private set
    var message by mutableStateOf("")
        private set
    var isSubmitting by mutableStateOf(false)
        private set
    var errorMessage by mutableStateOf<String?>(null)
        private set

    fun updateName(value: String) { name = value }
    fun updateEmail(value: String) { email = value }
    fun updatePhone(value: String) { phone = value }
    fun updateMessage(value: String) { message = value }

    val validationError: String?
        get() {
            if (name.trim().length < 2) return "Bitte geben Sie Ihren Namen an."
            if (email.trim().isEmpty() || !emailPattern.matches(email.trim())) return "Bitte geben Sie eine gültige E-Mail-Adresse an."
            if (phone.trim().length < 5) return "Bitte geben Sie Ihre Telefonnummer an."
            if (message.trim().length < 10) return "Ihre Nachricht sollte mindestens 10 Zeichen enthalten."
            return null
        }

    suspend fun submit(): SubmissionResult {
        val error = validationError
        if (error != null) return SubmissionResult.Failure(error)

        isSubmitting = true
        errorMessage = null

        val request = ConsultationRequest(
            name = name.trim(),
            email = email.trim(),
            phone = phone.trim(),
            message = message.trim(),
            locale = Locale.getDefault().toLanguageTag()
        )

        return try {
            withContext(Dispatchers.IO) {
                service.submit(request)
            }
            isSubmitting = false
            SubmissionResult.Success
        } catch (e: Exception) {
            isSubmitting = false
            errorMessage = e.message
            SubmissionResult.Failure(e.message ?: "Fehler beim Senden")
        }
    }

    private val emailPattern = Regex("^([A-Z0-9._%+-]+)@([A-Z0-9.-]+)\\.([A-Z]{2,})$", RegexOption.IGNORE_CASE)
}

sealed class SubmissionResult {
    data object Success : SubmissionResult()
    data class Failure(val message: String) : SubmissionResult()
}
