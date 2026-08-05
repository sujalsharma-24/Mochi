package com.mochi.keyboard.data

import android.app.Activity
import android.content.Context
import com.revenuecat.purchases.CustomerInfo
import com.revenuecat.purchases.LogLevel
import com.revenuecat.purchases.Offerings
import com.revenuecat.purchases.Package
import com.revenuecat.purchases.Purchases
import com.revenuecat.purchases.PurchasesConfiguration
import com.revenuecat.purchases.PurchasesError
import com.revenuecat.purchases.interfaces.PurchaseCallback
import com.revenuecat.purchases.interfaces.ReceiveCustomerInfoCallback
import com.revenuecat.purchases.interfaces.ReceiveOfferingsCallback
import com.revenuecat.purchases.models.StoreTransaction
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException

/**
 * RevenueCat wraps Play Billing for the locked $2.99/mo · $19.99/yr subscription (3-day trial).
 * Ships fully coded but inert - [configure] no-ops until [apiKey] is replaced with a real
 * RevenueCat Android API key (RevenueCat dashboard -> Project -> API keys), same gated pattern as
 * AuthRepository.googleWebClientId so the build stays green with no RevenueCat/Play Console
 * account set up yet. [entitlementId] must also match whatever identifier the RevenueCat
 * dashboard's "premium" entitlement is actually created with.
 */
class BillingRepository(private val context: Context) {

    private val apiKey = PLACEHOLDER_API_KEY
    private val entitlementId = "premium"

    private val _isPremium = MutableStateFlow(false)
    val isPremium: StateFlow<Boolean> = _isPremium.asStateFlow()

    val isConfigured: Boolean get() = apiKey != PLACEHOLDER_API_KEY

    /** Call once from MochiApplication.onCreate(), after Firebase Auth has a current user id if
     * one exists - RevenueCat ties purchases to Firebase's uid as its appUserID so entitlement
     * state survives reinstalls/device switches for the same account. */
    fun configure(appUserId: String?) {
        if (!isConfigured) return
        Purchases.logLevel = LogLevel.DEBUG
        Purchases.configure(
            PurchasesConfiguration.Builder(context, apiKey)
                .appUserID(appUserId)
                .build()
        )
        Purchases.sharedInstance.updatedCustomerInfoListener =
            com.revenuecat.purchases.interfaces.UpdatedCustomerInfoListener { info ->
                _isPremium.value = info.isPremium()
            }
    }

    suspend fun currentOfferings(): Offerings {
        checkConfigured()
        return suspendCancellableCoroutine { continuation ->
            Purchases.sharedInstance.getOfferings(object : ReceiveOfferingsCallback {
                override fun onReceived(offerings: Offerings) = continuation.resume(offerings)
                override fun onError(error: PurchasesError) =
                    continuation.resumeWithException(BillingException(error.message))
            })
        }
    }

    suspend fun purchase(activity: Activity, packageToBuy: Package) {
        checkConfigured()
        val info: CustomerInfo = suspendCancellableCoroutine { continuation ->
            Purchases.sharedInstance.purchase(
                com.revenuecat.purchases.PurchaseParams.Builder(activity, packageToBuy).build(),
                object : PurchaseCallback {
                    override fun onCompleted(purchase: StoreTransaction, customerInfo: CustomerInfo) =
                        continuation.resume(customerInfo)
                    override fun onError(error: PurchasesError, userCancelled: Boolean) {
                        if (userCancelled) {
                            continuation.cancel()
                        } else {
                            continuation.resumeWithException(BillingException(error.message))
                        }
                    }
                }
            )
        }
        _isPremium.value = info.isPremium()
    }

    suspend fun restorePurchases() {
        checkConfigured()
        val info = awaitCustomerInfoCallback { callback -> Purchases.sharedInstance.restorePurchases(callback) }
        _isPremium.value = info.isPremium()
    }

    suspend fun refreshCustomerInfo() {
        checkConfigured()
        val info = awaitCustomerInfoCallback { callback -> Purchases.sharedInstance.getCustomerInfo(callback) }
        _isPremium.value = info.isPremium()
    }

    private suspend fun awaitCustomerInfoCallback(
        call: (ReceiveCustomerInfoCallback) -> Unit
    ): CustomerInfo = suspendCancellableCoroutine { continuation ->
        call(object : ReceiveCustomerInfoCallback {
            override fun onReceived(customerInfo: CustomerInfo) = continuation.resume(customerInfo)
            override fun onError(error: PurchasesError) =
                continuation.resumeWithException(BillingException(error.message))
        })
    }

    private fun CustomerInfo.isPremium(): Boolean = entitlements[entitlementId]?.isActive == true

    private fun checkConfigured() = check(isConfigured) {
        "Billing isn't configured yet - create a RevenueCat project, add the $2.99/mo and " +
            "$19.99/yr Play Billing products under a \"$entitlementId\" entitlement, and paste " +
            "the Android API key into BillingRepository.apiKey."
    }

    class BillingException(message: String) : Exception(message)

    private companion object {
        const val PLACEHOLDER_API_KEY = "REPLACE_WITH_REVENUECAT_ANDROID_API_KEY"
    }
}
