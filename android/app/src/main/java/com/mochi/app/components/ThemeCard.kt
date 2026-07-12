package com.mochi.app.components

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
import androidx.compose.material.icons.filled.Star
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.mochi.app.designsystem.MochiColor
import com.mochi.app.designsystem.MochiFont
import com.mochi.app.designsystem.MochiSpacing
import com.mochi.app.model.KeyboardTheme

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
                    Icon(
                        imageVector = Icons.Filled.Star,
                        contentDescription = "Premium",
                        tint = Color.White,
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

@Composable
fun SectionHeader(
    title: String,
    actionTitle: String? = "see all",
    modifier: Modifier = Modifier,
    onAction: () -> Unit = {}
) {
    Row(
        modifier = modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(text = title.uppercase(), style = MochiFont.heading(13.sp), color = MochiColor.textPrimary)
        if (actionTitle != null) {
            TextButton(onClick = onAction) {
                Text(text = actionTitle, style = MochiFont.caption(), color = MochiColor.textPrimary)
            }
        }
    }
}
