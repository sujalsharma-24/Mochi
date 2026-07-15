package com.mochi.app.features.onboarding

import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
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
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Keyboard
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
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
import kotlinx.coroutines.launch

/** No Figma source for splash/onboarding/auth/theme-detail — designed to match the established
 * visual language (gradient background, Baloo 2 rounded type, solid purple logo, pink-purple
 * gradient buttons) per the locked feature spec instead of blocking on the client. */
@Composable
fun SplashScreen(modifier: Modifier = Modifier, onTimeout: () -> Unit = {}) {
    LaunchedEffect(Unit) {
        kotlinx.coroutines.delay(1200)
        onTimeout()
    }

    val transition = rememberInfiniteTransition(label = "splash-pulse")
    val scale by transition.animateFloat(
        initialValue = 0.96f,
        targetValue = 1.04f,
        animationSpec = infiniteRepeatable(tween(1100), repeatMode = RepeatMode.Reverse),
        label = "logo-scale"
    )

    Box(
        modifier = modifier.fillMaxSize().background(MochiGradient.background),
        contentAlignment = Alignment.Center
    ) {
        Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(MochiSpacing.sm)) {
            Text(
                text = "Mochi",
                style = MochiFont.logo(56.sp),
                color = MochiColor.logoSolid,
                modifier = Modifier.scale(scale)
            )
            Text(
                text = "Type with personality",
                style = MochiFont.body(15.sp),
                color = MochiColor.textSecondary
            )
        }
    }
}

private data class OnboardingPage(
    val iconResId: Int?,
    val title: String,
    val body: String
)

private val pages = listOf(
    OnboardingPage(R.drawable.icon_palette, "Discover Beautiful Themes", "Browse 250+ handcrafted keyboard themes, from cozy pastels to bold neon."),
    OnboardingPage(R.drawable.icon_library, "Express Yourself With Fonts", "Type in playful custom fonts that make every message feel like you."),
    OnboardingPage(R.drawable.icon_create_custom, "Create & Share", "Design your own keyboard and share it with the Mochi community."),
    OnboardingPage(null, "Enable Mochi Keyboard", "One quick step so Mochi can replace your system keyboard.")
)

@Composable
fun OnboardingScreen(modifier: Modifier = Modifier, onFinished: () -> Unit = {}) {
    val pagerState = rememberPagerState(pageCount = { pages.size })
    val coroutineScope = rememberCoroutineScope()

    Box(modifier = modifier.fillMaxSize().background(MochiGradient.background)) {
        Column(
            modifier = Modifier.fillMaxSize().padding(MochiSpacing.lg),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Spacer(modifier = Modifier.height(MochiSpacing.lg))

            HorizontalPager(
                state = pagerState,
                modifier = Modifier.weight(1f).fillMaxWidth()
            ) { index ->
                val page = pages[index]
                if (index == pages.lastIndex) {
                    KeyboardSetupPage(page)
                } else {
                    FeaturePage(page)
                }
            }

            PageIndicator(pageCount = pages.size, currentPage = pagerState.currentPage)

            Spacer(modifier = Modifier.height(MochiSpacing.lg))

            val isLastPage = pagerState.currentPage == pages.lastIndex
            GradientButton(title = if (isLastPage) "Get Started" else "Next") {
                if (isLastPage) {
                    onFinished()
                } else {
                    coroutineScope.launch { pagerState.animateScrollToPage(pagerState.currentPage + 1) }
                }
            }
        }
    }
}

@Composable
private fun FeaturePage(page: OnboardingPage) {
    Column(
        modifier = Modifier.fillMaxSize(),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Box(
            modifier = Modifier
                .size(160.dp)
                .clip(RoundedCornerShape(MochiRadius.card))
                .background(Color.White),
            contentAlignment = Alignment.Center
        ) {
            if (page.iconResId != null) {
                Image(
                    painter = painterResource(page.iconResId),
                    contentDescription = null,
                    modifier = Modifier.size(84.dp).clip(RoundedCornerShape(16.dp))
                )
            }
        }
        Spacer(modifier = Modifier.height(MochiSpacing.xl))
        Text(text = page.title, style = MochiFont.title(24.sp), color = MochiColor.textPrimary, textAlign = TextAlign.Center)
        Spacer(modifier = Modifier.height(MochiSpacing.sm))
        Text(
            text = page.body,
            style = MochiFont.body(15.sp),
            color = MochiColor.textSecondary,
            textAlign = TextAlign.Center,
            modifier = Modifier.padding(horizontal = MochiSpacing.md)
        )
    }
}

@Composable
private fun KeyboardSetupPage(page: OnboardingPage) {
    Column(
        modifier = Modifier.fillMaxSize(),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Box(
            modifier = Modifier
                .size(160.dp)
                .clip(RoundedCornerShape(MochiRadius.card))
                .background(Color.White),
            contentAlignment = Alignment.Center
        ) {
            Icon(imageVector = Icons.Filled.Keyboard, contentDescription = null, tint = MochiColor.purple, modifier = Modifier.size(72.dp))
        }
        Spacer(modifier = Modifier.height(MochiSpacing.xl))
        Text(text = page.title, style = MochiFont.title(24.sp), color = MochiColor.textPrimary, textAlign = TextAlign.Center)
        Spacer(modifier = Modifier.height(MochiSpacing.sm))
        Text(
            text = page.body,
            style = MochiFont.body(15.sp),
            color = MochiColor.textSecondary,
            textAlign = TextAlign.Center,
            modifier = Modifier.padding(horizontal = MochiSpacing.md)
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
            SetupStep(1, "Open Settings → General → Keyboard")
            SetupStep(2, "Tap “Keyboards” → “Add New Keyboard…”")
            SetupStep(3, "Select Mochi and enable “Allow Full Access”")
        }
    }
}

@Composable
private fun SetupStep(number: Int, text: String) {
    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(MochiSpacing.sm)) {
        Box(
            modifier = Modifier.size(22.dp).clip(CircleShape).background(MochiGradient.primaryButton),
            contentAlignment = Alignment.Center
        ) {
            Text(text = "$number", style = MochiFont.caption(11.sp).copy(fontWeight = FontWeight.Bold), color = Color.White)
        }
        Text(text = text, style = MochiFont.body(13.sp), color = MochiColor.textPrimary)
    }
}

@Composable
private fun PageIndicator(pageCount: Int, currentPage: Int) {
    Row(horizontalArrangement = Arrangement.spacedBy(MochiSpacing.xs)) {
        repeat(pageCount) { index ->
            val isSelected = index == currentPage
            Box(
                modifier = Modifier
                    .height(8.dp)
                    .width(if (isSelected) 24.dp else 8.dp)
                    .clip(RoundedCornerShape(MochiRadius.pill))
                    .background(if (isSelected) MochiColor.purple else MochiColor.purple.copy(alpha = 0.25f))
            )
        }
    }
}

@Preview(showBackground = true, widthDp = 393, heightDp = 852)
@Composable
private fun SplashScreenPreview() {
    SplashScreen()
}

@Preview(showBackground = true, widthDp = 393, heightDp = 852)
@Composable
private fun OnboardingScreenPreview() {
    OnboardingScreen()
}
