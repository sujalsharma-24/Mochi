package com.mochi.app.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.unit.dp
import com.mochi.app.designsystem.MochiColor
import com.mochi.app.designsystem.MochiFont
import com.mochi.app.designsystem.MochiGradient
import com.mochi.app.designsystem.MochiSpacing

/** Ported from ios/MochiApp/Components/GradientButton.swift */
@Composable
fun GradientButton(
    title: String,
    modifier: Modifier = Modifier,
    icon: ImageVector? = null,
    onClick: () -> Unit
) {
    TextButton(
        onClick = onClick,
        modifier = modifier
            .fillMaxWidth()
            .clip(CircleShape)
            .background(MochiGradient.primaryButton),
        contentPadding = androidx.compose.foundation.layout.PaddingValues(vertical = 14.dp)
    ) {
        Row(
            horizontalArrangement = Arrangement.spacedBy(MochiSpacing.xs, Alignment.CenterHorizontally)
        ) {
            if (icon != null) {
                Icon(imageVector = icon, contentDescription = null, tint = Color.White)
            }
            Text(text = title, style = MochiFont.button(), color = Color.White)
        }
    }
}

@Composable
fun OutlineButton(
    title: String,
    modifier: Modifier = Modifier,
    onClick: () -> Unit
) {
    TextButton(
        onClick = onClick,
        modifier = modifier
            .fillMaxWidth()
            .clip(CircleShape)
            .background(Color.White)
            .border(1.dp, MochiColor.purple.copy(alpha = 0.35f), CircleShape),
        contentPadding = androidx.compose.foundation.layout.PaddingValues(vertical = 14.dp)
    ) {
        Text(text = title, style = MochiFont.button(), color = MochiColor.textPrimary)
    }
}
