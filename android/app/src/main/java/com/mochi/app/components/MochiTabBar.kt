package com.mochi.app.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
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
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Outline
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.unit.Density
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.mochi.app.designsystem.MochiFont
import com.mochi.app.designsystem.MochiGradient
import com.mochi.app.designsystem.MochiSpacing
import com.mochi.app.ui.MochiTab

private val TabBarUnselected = Color(0xFF918989)
private val TabBarSelected = Color(0xFF9C28B1)

/** Shallow "cradle" cut into the top edge so the Create circle looks nested into the bar, matching Figma. */
private class NotchedBarShape(private val cornerRadius: androidx.compose.ui.unit.Dp, private val notchRadius: androidx.compose.ui.unit.Dp) : Shape {
    override fun createOutline(size: Size, layoutDirection: LayoutDirection, density: Density): Outline {
        val corner = with(density) { cornerRadius.toPx() }
        val notch = with(density) { notchRadius.toPx() }
        val centerX = size.width / 2f
        val path = Path().apply {
            moveTo(0f, corner)
            quadraticTo(0f, 0f, corner, 0f)
            lineTo(centerX - notch * 1.7f, 0f)
            cubicTo(
                centerX - notch * 0.9f, 0f,
                centerX - notch, notch * 1.15f,
                centerX, notch * 1.15f
            )
            cubicTo(
                centerX + notch, notch * 1.15f,
                centerX + notch * 0.9f, 0f,
                centerX + notch * 1.7f, 0f
            )
            lineTo(size.width - corner, 0f)
            quadraticTo(size.width, 0f, size.width, corner)
            lineTo(size.width, size.height)
            lineTo(0f, size.height)
            close()
        }
        return Outline.Generic(path)
    }
}

/** Ported from ios/MochiApp/Components/MochiTabBar.swift */
@Composable
fun MochiTabBar(selected: MochiTab, onSelect: (MochiTab) -> Unit, modifier: Modifier = Modifier) {
    val barShape = NotchedBarShape(cornerRadius = 28.dp, notchRadius = 38.dp)

    Box(modifier = modifier.fillMaxWidth()) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .shadow(12.dp, barShape)
                .background(Color.White, barShape)
                .border(1.dp, TabBarSelected, barShape)
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
                .offset(y = (-22).dp)
                .size(64.dp)
                .shadow(10.dp, CircleShape)
                .clip(CircleShape)
                .background(MochiGradient.primaryButton)
                .clickable { onSelect(MochiTab.CREATE) },
            contentAlignment = Alignment.Center
        ) {
            Text(text = "Create", style = MochiFont.button(13.sp), color = Color.White)
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
    val tint = if (isSelected) TabBarSelected else TabBarUnselected

    Column(
        modifier = modifier.clickable { onSelect(tab) },
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(4.dp)
    ) {
        if (tab == MochiTab.FONTS) {
            Text(text = "Aa", style = MochiFont.heading(20.sp), color = tint)
        } else if (isSelected && tab == MochiTab.KEYBOARD) {
            Box(
                modifier = Modifier
                    .size(40.dp)
                    .clip(RoundedCornerShape(12.dp))
                    .background(MochiGradient.primaryButton),
                contentAlignment = Alignment.Center
            ) {
                Icon(imageVector = tab.icon, contentDescription = tab.title, tint = Color.White, modifier = Modifier.size(22.dp))
            }
        } else {
            Icon(imageVector = tab.icon, contentDescription = tab.title, tint = tint)
        }
        Text(text = tab.title, style = MochiFont.caption(), color = tint)
    }
}
