package com.mochi.keyboard.features.paywall

import android.app.Activity
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.mochi.keyboard.data.BillingRepository
import com.revenuecat.purchases.Package
import com.revenuecat.purchases.PackageType
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

enum class PaywallPlan { MONTHLY, YEARLY }

data class PaywallUiState(
    val isConfigured: Boolean = false,
    val isLoadingOfferings: Boolean = false,
    val monthlyPackage: Package? = null,
    val yearlyPackage: Package? = null,
    val selectedPlan: PaywallPlan = PaywallPlan.YEARLY,
    val isPurchasing: Boolean = false,
    val isPremium: Boolean = false,
    val errorMessage: String? = null
)

/**
 * Wires PaywallScreen to the real [BillingRepository]. Packages are matched by RevenueCat's own
 * [PackageType] (MONTHLY/ANNUAL) rather than a hardcoded product identifier, so this works against
 * whatever the RevenueCat dashboard's "default" offering is actually configured with once a real
 * API key replaces [BillingRepository]'s placeholder - no dashboard access exists yet to confirm
 * exact identifiers. Until that key is set, [BillingRepository.isConfigured] is false and every
 * action here surfaces a clear "not set up yet" message instead of crashing (checkConfigured()'s
 * exception) or silently doing nothing.
 */
class PaywallViewModel(private val billingRepository: BillingRepository) : ViewModel() {

    private val _uiState = MutableStateFlow(PaywallUiState(isConfigured = billingRepository.isConfigured))
    val uiState: StateFlow<PaywallUiState> = _uiState.asStateFlow()

    init {
        viewModelScope.launch {
            billingRepository.isPremium.collect { premium -> _uiState.update { it.copy(isPremium = premium) } }
        }
        loadOfferings()
    }

    fun loadOfferings() {
        if (!billingRepository.isConfigured) return
        _uiState.update { it.copy(isLoadingOfferings = true) }
        viewModelScope.launch {
            runCatching { billingRepository.currentOfferings() }
                .onSuccess { offerings ->
                    val current = offerings.current
                    val monthly = current?.monthly
                        ?: current?.availablePackages?.firstOrNull { it.packageType == PackageType.MONTHLY }
                    val yearly = current?.annual
                        ?: current?.availablePackages?.firstOrNull { it.packageType == PackageType.ANNUAL }
                    _uiState.update { it.copy(isLoadingOfferings = false, monthlyPackage = monthly, yearlyPackage = yearly) }
                }
                .onFailure { e ->
                    _uiState.update { it.copy(isLoadingOfferings = false, errorMessage = e.message ?: "Couldn't load plans.") }
                }
        }
    }

    fun selectPlan(plan: PaywallPlan) = _uiState.update { it.copy(selectedPlan = plan) }

    fun purchase(activity: Activity, onSuccess: () -> Unit) {
        val state = _uiState.value
        if (state.isPurchasing) return
        if (!state.isConfigured) {
            _uiState.update { it.copy(errorMessage = "Subscriptions aren't set up yet - check back soon.") }
            return
        }
        val packageToBuy = if (state.selectedPlan == PaywallPlan.MONTHLY) state.monthlyPackage else state.yearlyPackage
        if (packageToBuy == null) {
            _uiState.update { it.copy(errorMessage = "That plan isn't available right now.") }
            return
        }
        _uiState.update { it.copy(isPurchasing = true) }
        viewModelScope.launch {
            try {
                billingRepository.purchase(activity, packageToBuy)
                _uiState.update { it.copy(isPurchasing = false) }
                onSuccess()
            } catch (e: CancellationException) {
                // BillingRepository.purchase() models the user backing out of the Play Billing
                // sheet as continuation.cancel(), not an error - just stop the spinner.
                _uiState.update { it.copy(isPurchasing = false) }
            } catch (e: Exception) {
                _uiState.update { it.copy(isPurchasing = false, errorMessage = e.message ?: "Purchase failed.") }
            }
        }
    }

    fun restore(onSuccess: () -> Unit) {
        if (_uiState.value.isPurchasing) return
        if (!billingRepository.isConfigured) {
            _uiState.update { it.copy(errorMessage = "Subscriptions aren't set up yet - check back soon.") }
            return
        }
        _uiState.update { it.copy(isPurchasing = true) }
        viewModelScope.launch {
            runCatching { billingRepository.restorePurchases() }
                .onSuccess {
                    _uiState.update { it.copy(isPurchasing = false) }
                    if (billingRepository.isPremium.value) onSuccess()
                    else _uiState.update { it.copy(errorMessage = "No previous purchase found for this account.") }
                }
                .onFailure { e ->
                    _uiState.update { it.copy(isPurchasing = false, errorMessage = e.message ?: "Couldn't restore purchases.") }
                }
        }
    }

    fun clearError() = _uiState.update { it.copy(errorMessage = null) }
}
