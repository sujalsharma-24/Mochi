package com.mochi.keyboard.components

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.TextUnit
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.mochi.keyboard.R
import com.mochi.keyboard.designsystem.MochiColor
import com.mochi.keyboard.designsystem.MochiFont
import com.mochi.keyboard.designsystem.MochiSpacing
import com.mochi.keyboard.model.KeyboardTheme

/** Ported from ios/MochiApp/Components/ThemeCard.swift */
@Composable
fun ThemeCard(theme: KeyboardTheme, modifier: Modifier = Modifier, onTap: () -> Unit = {}) {
    Column(
        modifier = modifier.clickable(onClick = onTap),
        verticalArrangement = Arrangement.spacedBy(MochiSpacing.sm)
    ) {
        Box(modifier = Modifier.fillMaxWidth().aspectRatio(1f)) {
            ThemeArt(assetName = theme.imageAssetName, seed = theme.id, modifier = Modifier.fillMaxWidth().aspectRatio(1f))

            if (theme.isPremium) {
                Box(
                    modifier = Modifier
                        .align(Alignment.TopEnd)
                        .padding(8.dp)
                        .clip(CircleShape)
                        .background(MochiColor.premiumTag)
                        .padding(6.dp)
                ) {
                    Image(
                        painter = painterResource(R.drawable.icon_premium_crown),
                        contentDescription = "Premium",
                        contentScale = ContentScale.Fit,
                        modifier = Modifier.size(12.dp)
                    )
                }
            }
        }

        Text(
            text = theme.name,
            style = MochiFont.heading(14.sp),
            color = MochiColor.textPrimary,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis
        )

        Row(
            horizontalArrangement = Arrangement.spacedBy(4.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(
                imageVector = Icons.Filled.Favorite,
                contentDescription = null,
                tint = MochiColor.pink,
                modifier = Modifier.size(11.dp)
            )
            Text(
                text = theme.likeCountFormatted,
                style = MochiFont.caption(),
                color = MochiColor.textSecondary
            )
        }
    }
}

/**
 * Ported from ios/MochiApp/Components/ThemeCard.swift's SectionHeader. Sizes solved by rendering
 * the real Inter TTFs and matching against measured glyph runs in docs/figma/1.png — defaults are
 * the Figma-measured sizes, screens pass their own live-tuned values in (see each screen's
 * Metrics). actionTitle previously used a TextButton, which carries Material's ~40dp minimum
 * touch-target height — far taller than the actual text — so a plain clickable Text is used
 * instead, letting the header hug the title's real height.
 */
@Composable
fun SectionHeader(
    title: String,
    actionTitle: String? = "see all",
    modifier: Modifier = Modifier,
    titleSize: TextUnit = 9.sp,
    actionSize: TextUnit = 9.sp,
    onAction: () -> Unit = {}
) {
    Row(
        modifier = modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.Bottom
    ) {
        Text(text = title.uppercase(), style = MochiFont.title(titleSize), color = MochiColor.textPrimary)
        if (actionTitle != null) {
            Text(
                text = actionTitle,
                style = MochiFont.body(actionSize),
                color = MochiColor.textPrimary,
                modifier = Modifier.clickable(onClick = onAction).padding(end = 2.dp)
            )
        }
    }
}
