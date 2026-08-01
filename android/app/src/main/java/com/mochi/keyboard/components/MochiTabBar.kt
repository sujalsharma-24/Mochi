package com.mochi.keyboard.components

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
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
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.graphics.Outline
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.unit.Density
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.mochi.keyboard.R
import com.mochi.keyboard.designsystem.MochiColor
import com.mochi.keyboard.designsystem.MochiFont
import com.mochi.keyboard.designsystem.MochiGradient
import com.mochi.keyboard.designsystem.MochiSpacing
import com.mochi.keyboard.ui.MochiTab

private val TabIconSize = 18.dp
private val TabKeyboardWidth = 23.dp
private val TabLabelSize = 9.sp
private val TabCreateSize = 50.dp

/**
 * Figma's tab bar is one continuous vector path: a mostly straight top edge with sharp outer
 * corners and a wide symmetrical concave valley in the center that the floating Create button
 * overlaps into — confirmed against the Figma layer (fill FFFFFF, stroke 9C28B1 weight 1, corner
 * radius 0). Ported from ios/MochiApp/Components/MochiTabBar.swift's NotchedTabBarShape; each
 * cubic's control points share their own endpoint's y so the curve meets the flat top and the
 * opposite curve with a horizontal tangent (no kink, no cusp at the valley floor).
 */
private class NotchedTabBarShape(
    private val cornerRadius: androidx.compose.ui.unit.Dp = 4.dp,
    private val notchHalfWidth: androidx.compose.ui.unit.Dp = 50.dp,
    private val notchDepth: androidx.compose.ui.unit.Dp = 26.dp
) : Shape {
    override fun createOutline(size: Size, layoutDirection: LayoutDirection, density: Density): Outline {
        val corner = with(density) { cornerRadius.toPx() }
        val halfWidth = with(density) { notchHalfWidth.toPx() }
        val depth = with(density) { notchDepth.toPx() }
        val cx = size.width / 2f
        val notchBottomY = depth

        val path = Path().apply {
            moveTo(0f, corner)
            quadraticTo(0f, 0f, corner, 0f)

            lineTo(cx - halfWidth, 0f)
            cubicTo(
                cx - halfWidth * 0.5f, 0f,
                cx - halfWidth * 0.5f, notchBottomY,
                cx, notchBottomY
            )
            cubicTo(
                cx + halfWidth * 0.5f, notchBottomY,
                cx + halfWidth * 0.5f, 0f,
                cx + halfWidth, 0f
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
    val barShape = NotchedTabBarShape()

    Box(modifier = modifier.fillMaxWidth()) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .shadow(14.dp, barShape, ambientColor = Color.Black.copy(alpha = 0.06f), spotColor = Color.Black.copy(alpha = 0.06f))
                .clip(barShape)
                .background(Color.White)
                .border(1.dp, MochiColor.logoSolid, barShape)
                .padding(horizontal = MochiSpacing.md),
            verticalAlignment = Alignment.Top
        ) {
            TabButton(MochiTab.KEYBOARD, selected, onSelect, Modifier.weight(1f))
            TabButton(MochiTab.FONTS, selected, onSelect, Modifier.weight(1f))
            Box(modifier = Modifier.width(64.dp))
            TabButton(MochiTab.THEMES, selected, onSelect, Modifier.weight(1f))
            TabButton(MochiTab.COMMUNITY, selected, onSelect, Modifier.weight(1f))
        }

        // Drawn 40dp above the bar so most of the circle sits outside the Box's own bounds.
        Image(
            painter = painterResource(R.drawable.icon_tab_create),
            contentDescription = "Create",
            contentScale = ContentScale.Crop,
            modifier = Modifier
                .align(Alignment.TopCenter)
                .offset(y = (-40).dp)
                .size(TabCreateSize)
                .clip(CircleShape)
                .shadow(6.dp, CircleShape, ambientColor = MochiColor.purpleDark.copy(alpha = 0.25f), spotColor = MochiColor.purpleDark.copy(alpha = 0.25f))
                .clickable { onSelect(MochiTab.CREATE) }
        )
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
    val tint = if (isSelected) MochiColor.purple else MochiColor.textSecondary.copy(alpha = 0.6f)

    Column(
        modifier = modifier
            .clickable { onSelect(tab) }
            .padding(top = 6.dp, bottom = 24.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(4.dp)
    ) {
        TabIcon(tab, isSelected, tint)
        Text(text = tab.title, style = MochiFont.caption(TabLabelSize), color = tint)
    }
}

/**
 * Figma renders Fonts as literal "Aa" text (not an icon), the selected Keyboard tab as a real
 * cropped badge image, and Themes/Community as real cropped icons tinted to the current
 * selection state — not system glyphs, whose silhouettes don't match the design's.
 */
@Composable
private fun TabIcon(tab: MochiTab, isSelected: Boolean, tint: Color) {
    when {
        tab == MochiTab.FONTS -> Text(
            text = "Aa",
            style = if (isSelected) {
                TextStyle(
                    brush = MochiGradient.fontsAccent,
                    fontSize = MochiFont.body(TabIconSize.value.sp).fontSize,
                    fontWeight = MochiFont.body().fontWeight,
                    fontFamily = MochiFont.body().fontFamily
                )
            } else {
                MochiFont.body(TabIconSize.value.sp).copy(color = tint)
            },
            modifier = Modifier.height(TabIconSize)
        )
        tab == MochiTab.KEYBOARD && isSelected -> Image(
            painter = painterResource(R.drawable.icon_tab_keyboard),
            contentDescription = tab.title,
            contentScale = ContentScale.Crop,
            modifier = Modifier
                .width(TabKeyboardWidth)
                .height(TabKeyboardWidth / 1.43f)
                .clip(RoundedCornerShape(5.dp))
        )
        tab == MochiTab.THEMES -> Image(
            painter = painterResource(R.drawable.icon_tab_themes),
            contentDescription = tab.title,
            contentScale = ContentScale.Fit,
            colorFilter = ColorFilter.tint(tint),
            modifier = Modifier.size(TabIconSize)
        )
        tab == MochiTab.COMMUNITY -> Image(
            painter = painterResource(R.drawable.icon_tab_community),
            contentDescription = tab.title,
            contentScale = ContentScale.Fit,
            colorFilter = ColorFilter.tint(tint),
            modifier = Modifier.size(TabIconSize)
        )
        else -> Icon(
            imageVector = tab.icon,
            contentDescription = tab.title,
            tint = tint,
            modifier = Modifier.size(TabIconSize)
        )
    }
}
