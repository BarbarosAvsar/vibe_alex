package de.vibecode.crisis.core.model

sealed class AsyncState<out T> {
    data object Idle : AsyncState<Nothing>()
    data object Loading : AsyncState<Nothing>()
    data class Loaded<T>(val value: T) : AsyncState<T>()
    data class Failed(val message: String) : AsyncState<Nothing>()
}
