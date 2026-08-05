package com.mochi.keyboard.features.themedetail

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.FavoriteBorder
import androidx.compose.material.icons.filled.Share
import androidx.compose.material.icons.filled.Star
import androidx.compose.material.icons.filled.Verified
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.setValue
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.lifecycle.viewmodel.initializer
import androidx.lifecycle.viewmodel.viewModelFactory
import com.mochi.keyboard.MochiApplication
import com.mochi.keyboard.components.GradientButton
import com.mochi.keyboard.components.OutlineButton
import com.mochi.keyboard.components.ThemeArt
import com.mochi.keyboard.designsystem.MochiColor
import com.mochi.keyboard.designsystem.MochiFont
import com.mochi.keyboard.designsystem.MochiGradient
import com.mochi.keyboard.designsystem.MochiRadius
import com.mochi.keyboard.designsystem.MochiSpacing
import com.mochi.keyboard.mockdata.MockData
import com.mochi.keyboard.model.KeyboardTheme

/** No Figma source — see OnboardingScreen.kt header note. Layout follows the locked feature spec
 * for Screen 5 (Theme Detail): preview, name/description, hashtags, creator credit, like/apply. */
@OptIn(ExperimentalLayoutApi::class)
@Composable
fun ThemeDetailScreen(
    theme: KeyboardTheme,
    modifier: Modifier = Modifier,
    onBack: () -> Unit = {},
    onUnlockPremium: () -> Unit = {}
) {
    val application = LocalContext.current.applicationContext as MochiApplication
    // Keyed by theme.id and built inline (not the shared ViewModelFactory/rememberMochiViewModelFactory)
    // because this ViewModel needs a per-navigation argument (which theme) that a single shared
    // factory keyed only by class can't supply - see ViewModelFactory.kt's note on this.
    val viewModel: ThemeDetailViewModel = viewModel(
        key = theme.id,
        factory = viewModelFactory {
            initializer {
                ThemeDetailViewModel(
                    likeRepository = application.container.likeRepository,
                    authRepository = application.container.authRepository,
                    themeId = theme.id,
                    initialLikeCount = theme.likeCount
                )
            }
        }
    )
    val isLiked by viewModel.isLiked.collectAsStateWithLifecycle()
    val likeCount by viewModel.likeCount.collectAsStateWithLifecycle()

    Box(modifier = modifier.fillMaxSize().background(MochiGradient.background)) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(bottom = 110.dp)
        ) {
            TopBar(onBack = onBack)

            Box(modifier = Modifier.fillMaxWidth().padding(horizontal = MochiSpacing.md)) {
                ThemeArt(
                    assetName = theme.imageAssetName,
                    seed = theme.id,
                    modifier = Modifier.fillMaxWidth().aspectRatio(1.05f)
                )
                if (theme.isPremium) {
                    Row(
                        modifier = Modifier
                            .align(Alignment.TopEnd)
                            .padding(MochiSpacing.sm)
                            .clip(RoundedCornerShape(MochiRadius.pill))
                            .background(MochiColor.premiumTag)
                            .padding(horizontal = MochiSpacing.sm, vertical = 6.dp),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(4.dp)
                    ) {
                        Icon(imageVector = Icons.Filled.Star, contentDescription = null, tint = Color.White, modifier = Modifier.size(12.dp))
                        Text(text = "Premium", style = MochiFont.caption(11.sp), color = Color.White)
                    }
                }
            }

            Column(
                modifier = Modifier.padding(horizontal = MochiSpacing.md, vertical = MochiSpacing.md),
                verticalArrangement = Arrangement.spacedBy(MochiSpacing.md)
            ) {
                Text(text = theme.name, style = MochiFont.title(24.sp), color = MochiColor.textPrimary)

                CreatorRow(theme.creatorName)

                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(MochiSpacing.md)) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(4.dp),
                        modifier = Modifier.clickable(onClick = viewModel::toggleLike)
                    ) {
                        Icon(
                            imageVector = if (isLiked) Icons.Filled.Favorite else Icons.Filled.FavoriteBorder,
                            contentDescription = "Like",
                            tint = MochiColor.pink,
                            modifier = Modifier.size(20.dp)
                        )
                        Text(text = likeCount.formattedShort(), style = MochiFont.body(14.sp), color = MochiColor.textSecondary)
                    }
                }

                if (theme.description.isNotBlank()) {
                    Text(text = theme.description, style = MochiFont.body(14.sp), color = MochiColor.textSecondary)
                }

                FlowRow(horizontalArrangement = Arrangement.spacedBy(MochiSpacing.sm)) {
                    theme.hashtags.forEach { tag -> HashtagChip(tag) }
                }
            }
        }

        Column(
            modifier = Modifier
                .align(Alignment.BottomCenter)
                .fillMaxWidth()
                .background(Color.White)
                .padding(MochiSpacing.md)
        ) {
            Row(horizontalArrangement = Arrangement.spacedBy(MochiSpacing.sm)) {
                OutlineButton(title = "Preview", modifier = Modifier.weight(1f)) {}
                GradientButton(
                    title = if (theme.isPremium) "Unlock Premium" else "Apply Theme",
                    modifier = Modifier.weight(1f),
                    onClick = { if (theme.isPremium) onUnlockPremium() }
                )
            }
        }
    }
}

@Composable
private fun TopBar(onBack: () -> Unit) {
    Row(
        modifier = Modifier.fillMaxWidth().padding(MochiSpacing.md),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        CircleIconButton(icon = Icons.AutoMirrored.Filled.ArrowBack, onClick = onBack)
        CircleIconButton(icon = Icons.Filled.Share, onClick = {})
    }
}

@Composable
private fun CircleIconButton(icon: androidx.compose.ui.graphics.vector.ImageVector, onClick: () -> Unit) {
    Box(
        modifier = Modifier
            .size(40.dp)
            .clip(CircleShape)
            .background(Color.White)
            .clickable(onClick = onClick),
        contentAlignment = Alignment.Center
    ) {
        Icon(imageVector = icon, contentDescription = null, tint = MochiColor.textPrimary, modifier = Modifier.size(20.dp))
    }
}

@Composable
private fun CreatorRow(creatorName: String) {
    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(MochiSpacing.sm)) {
        Box(
            modifier = Modifier.size(32.dp).clip(CircleShape).background(MochiColor.lavender),
            contentAlignment = Alignment.Center
        ) {
            Text(text = creatorName.take(1).uppercase(), style = MochiFont.heading(14.sp), color = MochiColor.purpleDark)
        }
        Text(text = creatorName, style = MochiFont.body(14.sp), color = MochiColor.textPrimary)
        Icon(imageVector = Icons.Filled.Verified, contentDescription = null, tint = MochiColor.purple, modifier = Modifier.size(14.dp))
        Spacer(modifier = Modifier.weight(1f))
        Text(
            text = "Follow",
            style = MochiFont.caption(12.sp),
            color = MochiColor.purple,
            modifier = Modifier
                .clip(RoundedCornerShape(MochiRadius.pill))
                .background(MochiColor.purple.copy(alpha = 0.1f))
                .clickable {}
                .padding(horizontal = MochiSpacing.sm, vertical = 6.dp)
        )
    }
}

@Composable
private fun HashtagChip(tag: String) {
    Text(
        text = "#$tag",
        style = MochiFont.caption(12.sp),
        color = MochiColor.purple,
        modifier = Modifier
            .clip(RoundedCornerShape(MochiRadius.pill))
            .background(Color.White)
            .clickable {}
            .padding(horizontal = MochiSpacing.sm, vertical = 6.dp)
    )
}

private fun Int.formattedShort(): String = when {
    this >= 1_000_000 -> "%.1fM".format(this / 1_000_000.0)
    this >= 1_000 -> "%.1fK".format(this / 1_000.0)
    else -> "$this"
}

@Preview(showBackground = true, widthDp = 393, heightDp = 852)
@Composable
private fun ThemeDetailScreenPreview() {
    ThemeDetailScreen(theme = MockData.popularThemes.first())
}
