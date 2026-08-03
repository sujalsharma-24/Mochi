package com.mochi.keyboard.features.onboarding

import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
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
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowForward
import androidx.compose.material.icons.filled.CheckCircle
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
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.mochi.keyboard.R
import com.mochi.keyboard.components.GradientButton
import com.mochi.keyboard.designsystem.MochiColor
import com.mochi.keyboard.designsystem.MochiFont
import com.mochi.keyboard.designsystem.MochiGradient
import com.mochi.keyboard.designsystem.MochiRadius
import com.mochi.keyboard.designsystem.MochiSpacing
import kotlinx.coroutines.launch

@Composable
fun SplashScreen(modifier: Modifier = Modifier, onTimeout: () -> Unit = {}) {
    LaunchedEffect(Unit) {
        kotlinx.coroutines.delay(1200)
        onTimeout()
    }

    val transition = rememberInfiniteTransition(label = "splash-pulse")
    val scale by transition.animateFloat(
        initialValue = 0.95f,
        targetValue = 1.05f,
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

private data class OnboardingPageData(
    val imageResId: Int,
    val title: String,
    val body: String,
    val badgeText: String
)

private val pages = listOf(
    OnboardingPageData(
        imageResId = R.drawable.onboarding_themes,
        title = "Discover Beautiful Themes",
        body = "Browse 250+ handcrafted keyboard themes, from cozy pastels to bold neon and animated styles.",
        badgeText = "250+ THEMES"
    ),
    OnboardingPageData(
        imageResId = R.drawable.onboarding_fonts,
        title = "Express Yourself With Fonts",
        body = "Type in playful custom fonts that make every chat, bio, and caption feel uniquely yours.",
        badgeText = "CUSTOM FONTS"
    ),
    OnboardingPageData(
        imageResId = R.drawable.onboarding_create,
        title = "Create & Share Studio",
        body = "Design your own custom keyboard with wallpapers, key shapes, fonts, and share with the community.",
        badgeText = "DIY CREATOR"
    ),
    OnboardingPageData(
        imageResId = R.drawable.onboarding_setup,
        title = "Enable Mochi Keyboard",
        body = "One quick step so Mochi can replace your default system keyboard and unlock full customization.",
        badgeText = "EASY SETUP"
    )
)

@Composable
fun OnboardingScreen(modifier: Modifier = Modifier, onFinished: () -> Unit = {}) {
    val pagerState = rememberPagerState(pageCount = { pages.size })
    val coroutineScope = rememberCoroutineScope()
    val isLastPage = pagerState.currentPage == pages.lastIndex

    Box(
        modifier = modifier
            .fillMaxSize()
            .background(
                Brush.verticalGradient(
                    colors = listOf(
                        Color(0xFFFAF5FF),
                        Color(0xFFF3E8FF),
                        Color(0xFFEDE9FE)
                    )
                )
            )
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = MochiSpacing.lg, vertical = MochiSpacing.md),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            // Top Bar: Mochi Wordmark + Skip Button
            Row(
                modifier = Modifier.fillMaxWidth().height(48.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "Mochi",
                    style = MochiFont.logo(28.sp),
                    color = Color(0xFF7C3AED)
                )

                if (!isLastPage) {
                    Text(
                        text = "Skip",
                        style = MochiFont.button(14.sp),
                        color = Color(0xFF8B5CF6),
                        fontWeight = FontWeight.SemiBold,
                        modifier = Modifier
                            .clip(RoundedCornerShape(MochiRadius.pill))
                            .clickable {
                                coroutineScope.launch {
                                    pagerState.animateScrollToPage(pages.lastIndex)
                                }
                            }
                            .padding(horizontal = 12.dp, vertical = 6.dp)
                    )
                }
            }

            Spacer(modifier = Modifier.height(MochiSpacing.sm))

            // Main Pager Content
            HorizontalPager(
                state = pagerState,
                modifier = Modifier.weight(1f).fillMaxWidth()
            ) { index ->
                val page = pages[index]
                if (index == pages.lastIndex) {
                    KeyboardSetupOnboardingPage(page)
                } else {
                    FeatureOnboardingPage(page)
                }
            }

            Spacer(modifier = Modifier.height(MochiSpacing.md))

            // Bottom Navigation Controls
            Column(
                modifier = Modifier.fillMaxWidth(),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                // Page Pill Indicator
                AnimatedPageIndicator(pageCount = pages.size, currentPage = pagerState.currentPage)

                Spacer(modifier = Modifier.height(MochiSpacing.lg))

                // Primary Next / Get Started CTA Button
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(54.dp)
                        .shadow(8.dp, RoundedCornerShape(27.dp))
                        .clip(RoundedCornerShape(27.dp))
                        .background(
                            Brush.horizontalGradient(
                                colors = listOf(Color(0xFF7C3AED), Color(0xFF8B5CF6), Color(0xFFEC4999))
                            )
                        )
                        .clickable {
                            if (isLastPage) {
                                onFinished()
                            } else {
                                coroutineScope.launch {
                                    pagerState.animateScrollToPage(pagerState.currentPage + 1)
                                }
                            }
                        },
                    contentAlignment = Alignment.Center
                ) {
                    Row(
                        horizontalArrangement = Arrangement.spacedBy(8.dp, Alignment.CenterHorizontally),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(
                            text = if (isLastPage) "Get Started" else "Continue",
                            style = MochiFont.button(16.sp),
                            color = Color.White,
                            fontWeight = FontWeight.Bold
                        )
                        Icon(
                            imageVector = Icons.AutoMirrored.Filled.ArrowForward,
                            contentDescription = null,
                            tint = Color.White,
                            modifier = Modifier.size(20.dp)
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun FeatureOnboardingPage(page: OnboardingPageData) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState()),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        // Feature Badge Chip
        Box(
            modifier = Modifier
                .clip(RoundedCornerShape(MochiRadius.pill))
                .background(Color(0xFFEDE9FE))
                .padding(horizontal = 14.dp, vertical = 6.dp)
        ) {
            Text(
                text = page.badgeText,
                style = MochiFont.caption(12.sp),
                color = Color(0xFF7C3AED),
                fontWeight = FontWeight.Bold
            )
        }

        Spacer(modifier = Modifier.height(MochiSpacing.md))

        // High-Quality PNG Hero Illustration Card
        Box(
            modifier = Modifier
                .size(270.dp)
                .shadow(12.dp, RoundedCornerShape(32.dp))
                .clip(RoundedCornerShape(32.dp))
                .background(Color.White)
                .border(1.5.dp, Color(0xFFDDD6FE), RoundedCornerShape(32.dp)),
            contentAlignment = Alignment.Center
        ) {
            Image(
                painter = painterResource(id = page.imageResId),
                contentDescription = page.title,
                contentScale = ContentScale.Fit,
                modifier = Modifier
                    .fillMaxSize()
                    .padding(16.dp)
            )
        }

        Spacer(modifier = Modifier.height(MochiSpacing.xl))

        // Title
        Text(
            text = page.title,
            style = MochiFont.title(25.sp),
            color = Color(0xFF1E1B4B),
            textAlign = TextAlign.Center,
            fontWeight = FontWeight.Bold
        )

        Spacer(modifier = Modifier.height(MochiSpacing.sm))

        // Subtitle Body
        Text(
            text = page.body,
            style = MochiFont.body(15.sp),
            color = Color(0xFF6B7280),
            textAlign = TextAlign.Center,
            modifier = Modifier.padding(horizontal = MochiSpacing.md)
        )
    }
}

@Composable
private fun KeyboardSetupOnboardingPage(page: OnboardingPageData) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState()),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Box(
            modifier = Modifier
                .clip(RoundedCornerShape(MochiRadius.pill))
                .background(Color(0xFFFCE7F3))
                .padding(horizontal = 14.dp, vertical = 6.dp)
        ) {
            Text(
                text = page.badgeText,
                style = MochiFont.caption(12.sp),
                color = Color(0xFFDB2777),
                fontWeight = FontWeight.Bold
            )
        }

        Spacer(modifier = Modifier.height(MochiSpacing.md))

        // Hero Illustration Card
        Box(
            modifier = Modifier
                .size(200.dp)
                .shadow(12.dp, RoundedCornerShape(32.dp))
                .clip(RoundedCornerShape(32.dp))
                .background(Color.White)
                .border(1.5.dp, Color(0xFFFBCFE8), RoundedCornerShape(32.dp)),
            contentAlignment = Alignment.Center
        ) {
            Image(
                painter = painterResource(id = page.imageResId),
                contentDescription = page.title,
                contentScale = ContentScale.Fit,
                modifier = Modifier
                    .fillMaxSize()
                    .padding(12.dp)
            )
        }

        Spacer(modifier = Modifier.height(MochiSpacing.lg))

        Text(
            text = page.title,
            style = MochiFont.title(24.sp),
            color = Color(0xFF1E1B4B),
            textAlign = TextAlign.Center,
            fontWeight = FontWeight.Bold
        )

        Spacer(modifier = Modifier.height(MochiSpacing.xs))

        Text(
            text = page.body,
            style = MochiFont.body(14.sp),
            color = Color(0xFF6B7280),
            textAlign = TextAlign.Center,
            modifier = Modifier.padding(horizontal = MochiSpacing.md)
        )

        Spacer(modifier = Modifier.height(MochiSpacing.md))

        // 3-Step Setup Instructions Card
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .shadow(4.dp, RoundedCornerShape(20.dp))
                .clip(RoundedCornerShape(20.dp))
                .background(Color.White)
                .padding(MochiSpacing.md),
            verticalArrangement = Arrangement.spacedBy(MochiSpacing.sm)
        ) {
            InstructionStep(1, "Open Android Settings → Languages & Input")
            InstructionStep(2, "Select 'On-screen Keyboard' → Manage Keyboards")
            InstructionStep(3, "Enable 'Mochi Keyboard' and switch input method")
        }
    }
}

@Composable
private fun InstructionStep(number: Int, text: String) {
    Row(
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        Box(
            modifier = Modifier
                .size(26.dp)
                .clip(CircleShape)
                .background(
                    Brush.linearGradient(
                        colors = listOf(Color(0xFF7C3AED), Color(0xFFEC4999))
                    )
                ),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = "$number",
                style = MochiFont.caption(12.sp).copy(fontWeight = FontWeight.Bold),
                color = Color.White
            )
        }
        Text(
            text = text,
            style = MochiFont.body(13.sp),
            color = Color(0xFF374151),
            fontWeight = FontWeight.Medium
        )
    }
}

@Composable
private fun AnimatedPageIndicator(pageCount: Int, currentPage: Int) {
    Row(
        horizontalArrangement = Arrangement.spacedBy(8.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        repeat(pageCount) { index ->
            val isSelected = index == currentPage
            Box(
                modifier = Modifier
                    .height(8.dp)
                    .width(if (isSelected) 28.dp else 8.dp)
                    .clip(RoundedCornerShape(MochiRadius.pill))
                    .background(
                        if (isSelected) {
                            Brush.horizontalGradient(
                                colors = listOf(Color(0xFF7C3AED), Color(0xFFEC4999))
                            )
                        } else {
                            SolidColor(Color(0xFFCBD5E1))
                        }
                    )
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
