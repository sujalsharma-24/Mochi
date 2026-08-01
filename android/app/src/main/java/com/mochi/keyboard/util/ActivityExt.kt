package com.mochi.keyboard.util

import android.app.Activity
import android.content.Context
import android.content.ContextWrapper

/** Credential Manager and PhoneAuthOptions both need a real Activity, not just a Context -
 * Compose's LocalContext.current can be wrapped (theming, etc.), so unwrap to find it. */
fun Context.findActivity(): Activity? {
    var context = this
    while (context is ContextWrapper) {
        if (context is Activity) return context
        context = context.baseContext
    }
    return null
}
