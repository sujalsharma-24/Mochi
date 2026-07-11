package com.mochi.app.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AutoAwesome
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.mochi.app.designsystem.MochiColor
import com.mochi.app.designsystem.MochiFont
import com.mochi.app.designsystem.MochiGradient
import com.mochi.app.designsystem.MochiSpacing
import com.mochi.app.ui.MochiTab

/** Ported from ios/MochiApp/Components/MochiTabBar.swift */
@Composable
fun MochiTabBar(selected: MochiTab, onSelect: (MochiTab) -> Unit, modifier: Modifier = Modifier) {
    Box(modifier = modifier.fillMaxWidth()) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .shadow(12.dp, RoundedCornerShape(topStart = 28.dp, topEnd = 28.dp))
                .background(Color.White, RoundedCornerShape(topStart = 28.dp, topEnd = 28.dp))
                .padding(horizontal = MochiSpacing.md, vertical = MochiSpacing.sm),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            TabButton(MochiTab.KEYBOARD, selected, onSelect, Modifier.weight(1f))
            TabButton(MochiTab.FONTS, selected, onSelect, Modifier.weight(1f))
            Box(modifier = Modifier.weight(1f))
            TabButton(MochiTab.THEMES, selected, onSelect, Modifier.weight(1f))
            TabButton(MochiTab.COMMUNITY, selected, onSelect, Modifier.weight(1f))
        }

        Box(
            modifier = Modifier
                .align(Alignment.TopCenter)
                .offset(y = (-18).dp)
                .size(60.dp)
                .shadow(10.dp, CircleShape)
                .clip(CircleShape)
                .background(MochiGradient.primaryButton)
                .clickable { onSelect(MochiTab.CREATE) },
            contentAlignment = Alignment.Center
        ) {
            Icon(
                imageVector = Icons.Filled.AutoAwesome,
                contentDescription = MochiTab.CREATE.title,
                tint = Color.White
            )
        }
    }
}

@Composable
private fun RowScope.TabButton(
    tab: MochiTab,
    selected: MochiTab,
    onSelect: (MochiTab) -> Unit,
    modifier: Modifier = Modifier
) {
    val isSelected = tab == selected
    Column(
        modifier = modifier.clickable { onSelect(tab) },
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(4.dp)
    ) {
        Icon(
            imageVector = tab.icon,
            contentDescription = tab.title,
            tint = if (isSelected) MochiColor.purple else MochiColor.textSecondary.copy(alpha = 0.6f)
        )
        Text(
            text = tab.title,
            style = MochiFont.caption(),
            color = if (isSelected) MochiColor.purple else MochiColor.textSecondary.copy(alpha = 0.6f)
        )
    }
}
