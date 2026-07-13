package com.mochi.app.features.paywall

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Close
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.mochi.app.R
import com.mochi.app.components.GradientButton
import com.mochi.app.designsystem.MochiColor
import com.mochi.app.designsystem.MochiFont
import com.mochi.app.designsystem.MochiGradient
import com.mochi.app.designsystem.MochiRadius
import com.mochi.app.designsystem.MochiSpacing

private enum class Plan(val title: String, val price: String, val period: String, val badge: String?) {
    MONTHLY("Monthly", "$2.99", "/ month", null),
    YEARLY("Yearly", "$19.99", "/ year", "Most Popular")
}

private val perks = listOf(
    "All 250 premium keyboard themes",
    "Every custom font in the library",
    "All key-press, background & trail effects",
    "All sticker packs",
    "All 5 animated live wallpapers"
)

/** No Figma source — see OnboardingScreen.kt header note. Pricing is the locked spec (decision #3
 * in project memory): $2.99/mo · $19.99/yr · 3-day trial, native billing only. Figma's paywall
 * frames (docs/figma/11.png-12.png) show $199/$999/$1999 and a custom payment form — ignored
 * intentionally, since that pricing was never approved and the custom checkout would violate
 * App Store Guideline 3.1.1 (digital subscriptions must use native IAP). */
@Composable
fun PaywallScreen(modifier: Modifier = Modifier, onClose: () -> Unit = {}) {
    var selectedPlan by remember { mutableStateOf(Plan.YEARLY) }

    Box(modifier = modifier.fillMaxSize().background(MochiGradient.background)) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(MochiSpacing.lg),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.End) {
                Box(
                    modifier = Modifier
                        .size(36.dp)
                        .clip(CircleShape)
                        .background(Color.White)
                        .clickable(onClick = onClose),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(imageVector = Icons.Filled.Close, contentDescription = "Close", tint = MochiColor.textPrimary, modifier = Modifier.size(18.dp))
                }
            }

            Spacer(modifier = Modifier.height(MochiSpacing.md))

            Image(
                painter = painterResource(R.drawable.icon_premium_crown),
                contentDescription = null,
                modifier = Modifier.size(72.dp).clip(CircleShape)
            )
            Spacer(modifier = Modifier.height(MochiSpacing.md))
            Text(text = "Unlock Mochi Premium", style = MochiFont.title(24.sp), color = MochiColor.textPrimary, textAlign = TextAlign.Center)
            Spacer(modifier = Modifier.height(4.dp))
            Text(
                text = "Every theme, font, and effect — no limits.",
                style = MochiFont.body(14.sp),
                color = MochiColor.textSecondary,
                textAlign = TextAlign.Center
            )

            Spacer(modifier = Modifier.height(MochiSpacing.lg))

            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(MochiRadius.card))
                    .background(Color.White)
                    .padding(MochiSpacing.md),
                verticalArrangement = Arrangement.spacedBy(MochiSpacing.sm)
            ) {
                perks.forEach { perk -> PerkRow(perk) }
            }

            Spacer(modifier = Modifier.height(MochiSpacing.lg))

            Column(
                modifier = Modifier.fillMaxWidth(),
                verticalArrangement = Arrangement.spacedBy(MochiSpacing.sm)
            ) {
                Plan.entries.forEach { plan ->
                    PlanCard(plan = plan, isSelected = plan == selectedPlan) { selectedPlan = plan }
                }
            }

            Spacer(modifier = Modifier.height(MochiSpacing.sm))
            Text(
                text = "3-day free trial, cancel anytime",
                style = MochiFont.caption(12.sp),
                color = MochiColor.textSecondary
            )

            Spacer(modifier = Modifier.height(MochiSpacing.lg))
            GradientButton(title = "Start Free Trial") {}

            Spacer(modifier = Modifier.height(MochiSpacing.md))
            Text(
                text = "Restore Purchase",
                style = MochiFont.caption(13.sp),
                color = MochiColor.purple,
                modifier = Modifier.clickable {}
            )

            Spacer(modifier = Modifier.height(MochiSpacing.md))
            Text(
                text = "Payment charged via your App Store or Play Store account. Subscriptions auto-renew unless cancelled at least 24 hours before the end of the current period.",
                style = MochiFont.caption(10.sp),
                color = MochiColor.textSecondary,
                textAlign = TextAlign.Center
            )
        }
    }
}

@Composable
private fun PerkRow(text: String) {
    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(MochiSpacing.sm)) {
        Icon(imageVector = Icons.Filled.CheckCircle, contentDescription = null, tint = MochiColor.purple, modifier = Modifier.size(18.dp))
        Text(text = text, style = MochiFont.body(13.sp), color = MochiColor.textPrimary)
    }
}

@Composable
private fun PlanCard(plan: Plan, isSelected: Boolean, onSelect: () -> Unit) {
    Box {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(MochiRadius.card))
                .background(Color.White)
                .then(
                    if (isSelected) {
                        Modifier.border(2.dp, MochiGradient.primaryButton, RoundedCornerShape(MochiRadius.card))
                    } else {
                        Modifier.border(1.dp, MochiColor.textSecondary.copy(alpha = 0.15f), RoundedCornerShape(MochiRadius.card))
                    }
                )
                .clickable(onClick = onSelect)
                .padding(MochiSpacing.md),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column {
                Text(text = plan.title, style = MochiFont.heading(15.sp), color = MochiColor.textPrimary)
                Row {
                    Text(text = plan.price, style = MochiFont.title(18.sp).copy(fontWeight = FontWeight.Black), color = MochiColor.purple)
                    Text(text = " ${plan.period}", style = MochiFont.caption(12.sp), color = MochiColor.textSecondary)
                }
            }
            RadioDot(isSelected)
        }

        if (plan.badge != null) {
            Text(
                text = plan.badge,
                style = MochiFont.caption(10.sp).copy(fontWeight = FontWeight.Bold),
                color = Color.White,
                modifier = Modifier
                    .align(Alignment.TopEnd)
                    .padding(top = (-8).dp, end = MochiSpacing.md)
                    .clip(RoundedCornerShape(MochiRadius.pill))
                    .background(MochiGradient.primaryButton)
                    .padding(horizontal = 10.dp, vertical = 4.dp)
            )
        }
    }
}

@Composable
private fun RadioDot(isSelected: Boolean) {
    if (isSelected) {
        Icon(imageVector = Icons.Filled.CheckCircle, contentDescription = null, tint = MochiColor.purple, modifier = Modifier.size(24.dp))
    } else {
        Box(
            modifier = Modifier
                .size(22.dp)
                .clip(CircleShape)
                .border(1.5.dp, MochiColor.textSecondary.copy(alpha = 0.3f), CircleShape)
        )
    }
}

@Preview(showBackground = true, widthDp = 393, heightDp = 852)
@Composable
private fun PaywallScreenPreview() {
    PaywallScreen()
}
