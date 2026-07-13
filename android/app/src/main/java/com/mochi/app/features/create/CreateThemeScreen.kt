package com.mochi.app.features.create

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
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
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.Send
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.AutoAwesome
import androidx.compose.material.icons.filled.Checklist
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Colorize
import androidx.compose.material.icons.filled.Edit
import androidx.compose.material.icons.filled.Image
import androidx.compose.material.icons.filled.Palette
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.Save
import androidx.compose.material.icons.filled.TextFields
import androidx.compose.material.icons.filled.Visibility
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
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.mochi.app.R
import com.mochi.app.designsystem.MochiColor
import com.mochi.app.designsystem.MochiFont
import com.mochi.app.designsystem.MochiGradient
import com.mochi.app.designsystem.MochiRadius
import com.mochi.app.designsystem.MochiSpacing

@Preview(showBackground = true, widthDp = 393, heightDp = 3300)
@Composable
private fun CreateThemeScreenPreview() {
    CreateThemeScreen()
}

private enum class CreateTab(val title: String) { BACKGROUND("Background"), KEYS("Keys"), FONTS("Fonts"), EFFECT("Effect") }

private val rainbow = Brush.horizontalGradient(
    colors = listOf(Color.Red, Color(0xFFFFA500), Color.Yellow, Color.Green, Color.Cyan, Color.Blue, Color.Magenta)
)

/** Ported from docs/figma/4.png */
@Composable
fun CreateThemeScreen(modifier: Modifier = Modifier) {
    var selectedTab by remember { mutableStateOf(CreateTab.FONTS) }
    var selectedBg by remember { mutableStateOf(0) }
    var selectedKeyShape by remember { mutableStateOf(0) }
    var selectedFontStyle by remember { mutableStateOf(0) }
    var themeName by remember { mutableStateOf("My Dreamy Theme") }

    Box(modifier = modifier.fillMaxSize().background(MochiGradient.background)) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = MochiSpacing.md)
                .padding(top = MochiSpacing.md, bottom = 100.dp),
            verticalArrangement = Arrangement.spacedBy(MochiSpacing.lg)
        ) {
            CreateHeader()
            LivePreviewBanner()
            SegmentedTabs(selectedTab) { selectedTab = it }
            BackgroundSection(selectedBg) { selectedBg = it }
            KeyShapeSection(selectedKeyShape) { selectedKeyShape = it }
            KeyColorSection()
            LetterColorPickerSection()
            FontStyleSection(selectedFontStyle) { selectedFontStyle = it }
            LivePreviewToggleBanner()
            ThemeNameSection(themeName) { themeName = it }
            TagsSection()
            ActionButtonsRow()
        }
    }
}

@Composable
private fun CreateHeader() {
    Column(horizontalAlignment = Alignment.CenterHorizontally, modifier = Modifier.fillMaxWidth()) {
        Box(modifier = Modifier.fillMaxWidth()) {
            Box(
                modifier = Modifier
                    .align(Alignment.CenterStart)
                    .size(44.dp)
                    .clip(CircleShape)
                    .background(MochiGradient.primaryButton),
                contentAlignment = Alignment.Center
            ) {
                Icon(imageVector = Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back", tint = Color.White)
            }
            Column(modifier = Modifier.align(Alignment.Center), horizontalAlignment = Alignment.CenterHorizontally) {
                Text(text = "Create Custom Theme", style = MochiFont.title(22.sp), color = MochiColor.purple)
                Text(text = "Design your own keyboard theme", style = MochiFont.caption(12.sp), color = MochiColor.textSecondary)
            }
        }
    }
}

@Composable
private fun LivePreviewBanner() {
    Image(
        painter = painterResource(R.drawable.create_live_preview),
        contentDescription = "Live keyboard preview",
        contentScale = ContentScale.Crop,
        modifier = Modifier
            .fillMaxWidth()
            .aspectRatio(1.05f)
            .clip(RoundedCornerShape(MochiRadius.card))
    )
}

@Composable
private fun SegmentedTabs(selected: CreateTab, onSelect: (CreateTab) -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(MochiRadius.pill))
            .background(Color.White)
            .padding(4.dp),
        horizontalArrangement = Arrangement.SpaceEvenly
    ) {
        CreateTab.entries.forEach { tab ->
            val isSelected = tab == selected
            Row(
                modifier = Modifier
                    .clip(RoundedCornerShape(MochiRadius.pill))
                    .then(if (isSelected) Modifier.background(MochiGradient.primaryButton) else Modifier)
                    .clickable { onSelect(tab) }
                    .padding(horizontal = 12.dp, vertical = 10.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(4.dp)
            ) {
                val icon = when (tab) {
                    CreateTab.BACKGROUND -> Icons.Filled.Image
                    CreateTab.KEYS -> Icons.Filled.Checklist
                    CreateTab.FONTS -> Icons.Filled.TextFields
                    CreateTab.EFFECT -> Icons.Filled.AutoAwesome
                }
                Icon(imageVector = icon, contentDescription = null, tint = if (isSelected) Color.White else MochiColor.textSecondary, modifier = Modifier.size(16.dp))
                Text(text = tab.title, style = MochiFont.caption(12.sp), color = if (isSelected) Color.White else MochiColor.textSecondary)
            }
        }
    }
}

@Composable
private fun SectionCard(content: @Composable ColumnScope.() -> Unit) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(MochiRadius.card))
            .background(Color.White)
            .padding(MochiSpacing.md),
        verticalArrangement = Arrangement.spacedBy(MochiSpacing.sm),
        content = content
    )
}

@Composable
private fun BackgroundSection(selected: Int, onSelect: (Int) -> Unit) {
    val swatches = listOf(R.drawable.bg_swatch_purple_clouds, R.drawable.bg_swatch_pink_space, R.drawable.bg_swatch_peach_clouds, R.drawable.bg_swatch_night_moon)
    SectionCard {
        Text(text = "BACKGROUND", style = MochiFont.heading(13.sp), color = MochiColor.textPrimary)
        Row(
            modifier = Modifier.horizontalScroll(rememberScrollState()),
            horizontalArrangement = Arrangement.spacedBy(MochiSpacing.sm)
        ) {
            OptionTile(label = "Gallery", isSelected = false, onClick = {}) {
                Icon(imageVector = Icons.Filled.Add, contentDescription = null, tint = MochiColor.purple)
            }
            OptionTile(label = "Colors", isSelected = false, onClick = {}) {
                Icon(imageVector = Icons.Filled.Palette, contentDescription = null, tint = MochiColor.purple)
            }
            swatches.forEachIndexed { index, res ->
                Box(
                    modifier = Modifier
                        .size(76.dp)
                        .clip(RoundedCornerShape(MochiRadius.card))
                        .border(2.dp, if (selected == index) MochiColor.purple else Color.Transparent, RoundedCornerShape(MochiRadius.card))
                        .clickable { onSelect(index) }
                ) {
                    Image(painter = painterResource(res), contentDescription = null, contentScale = ContentScale.Crop, modifier = Modifier.fillMaxSize().clip(RoundedCornerShape(MochiRadius.card)))
                    if (selected == index) {
                        Box(
                            modifier = Modifier.align(Alignment.TopEnd).padding(4.dp).size(16.dp).clip(CircleShape).background(MochiColor.purple),
                            contentAlignment = Alignment.Center
                        ) {
                            Text(text = "✓", style = MochiFont.caption(9.sp), color = Color.White)
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun OptionTile(label: String, isSelected: Boolean, onClick: () -> Unit, icon: @Composable () -> Unit) {
    Column(
        modifier = Modifier
            .size(76.dp)
            .clip(RoundedCornerShape(MochiRadius.card))
            .border(1.dp, MochiColor.purple.copy(alpha = 0.35f), RoundedCornerShape(MochiRadius.card))
            .clickable(onClick = onClick)
            .padding(6.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        icon()
        Spacer(modifier = Modifier.height(4.dp))
        Text(text = label, style = MochiFont.caption(10.sp), color = MochiColor.textPrimary)
    }
}

@Composable
private fun KeyShapeSection(selected: Int, onSelect: (Int) -> Unit) {
    Column(verticalArrangement = Arrangement.spacedBy(MochiSpacing.sm)) {
        Text(text = "KEY SHAPE", style = MochiFont.heading(13.sp), color = MochiColor.textPrimary)
        Row(horizontalArrangement = Arrangement.spacedBy(MochiSpacing.sm)) {
            val shapes = listOf<Any>(RoundedCornerShape(10.dp), RoundedCornerShape(16.dp), CircleShape, RoundedCornerShape(4.dp))
            shapes.forEachIndexed { index, shape ->
                Box(
                    modifier = Modifier
                        .size(64.dp)
                        .clip(RoundedCornerShape(MochiRadius.card))
                        .background(Color.White)
                        .border(1.dp, if (selected == index) MochiColor.purple else MochiColor.purple.copy(alpha = 0.2f), RoundedCornerShape(MochiRadius.card))
                        .clickable { onSelect(index) },
                    contentAlignment = Alignment.Center
                ) {
                    Box(
                        modifier = Modifier
                            .size(32.dp)
                            .clip(shape as androidx.compose.ui.graphics.Shape)
                            .background(MochiColor.lavender)
                    )
                }
            }
        }
    }
}

@Composable
private fun KeyColorSection() {
    Column(verticalArrangement = Arrangement.spacedBy(MochiSpacing.sm)) {
        Text(text = "KEY COLOR", style = MochiFont.heading(13.sp), color = MochiColor.textPrimary)
        ColorGradientPicker(brush = Brush.horizontalGradient(listOf(Color(0xFFB388FF), Color(0xFF6A1FD0))))
        Text(text = "RECENT", style = MochiFont.heading(11.sp), color = MochiColor.textSecondary)
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            listOf(Color(0xFFF3B6E0), Color(0xFFE8709B), Color(0xFF8FC8EC), Color(0xFFE3A6BE), Color(0xFFE9C2B8), Color(0xFF9B7FCB)).forEach { color ->
                Box(modifier = Modifier.size(28.dp).clip(RoundedCornerShape(6.dp)).background(color))
            }
            Box(
                modifier = Modifier.size(28.dp).clip(RoundedCornerShape(6.dp)).border(1.dp, MochiColor.purple.copy(alpha = 0.3f), RoundedCornerShape(6.dp)),
                contentAlignment = Alignment.Center
            ) {
                Icon(imageVector = Icons.Filled.Colorize, contentDescription = "Pick color", tint = MochiColor.purple, modifier = Modifier.size(14.dp))
            }
        }
    }
}

@Composable
private fun LetterColorPickerSection() {
    Column(verticalArrangement = Arrangement.spacedBy(MochiSpacing.sm)) {
        Text(text = "LETTER COLOR", style = MochiFont.heading(13.sp), color = MochiColor.textPrimary)
        ColorGradientPicker(brush = Brush.horizontalGradient(listOf(Color(0xFFBFBFBF), Color(0xFF6A1FD0))))
    }
}

@Composable
private fun ColorGradientPicker(brush: Brush) {
    Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(56.dp)
                .clip(RoundedCornerShape(MochiRadius.pill))
                .background(brush),
            contentAlignment = Alignment.Center
        ) {
            Box(modifier = Modifier.size(22.dp).clip(CircleShape).background(Color.White).border(2.dp, Color.White, CircleShape))
        }
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(10.dp)
                .clip(RoundedCornerShape(MochiRadius.pill))
                .background(rainbow)
        )
    }
}

private val fontStyles = listOf("Default", "Rounded", "Cute", "Classic", "Handwritten")

@Composable
private fun FontStyleSection(selected: Int, onSelect: (Int) -> Unit) {
    Column(verticalArrangement = Arrangement.spacedBy(MochiSpacing.sm)) {
        Text(text = "FONT STYLE", style = MochiFont.heading(13.sp), color = MochiColor.textPrimary)
        Row(
            modifier = Modifier.horizontalScroll(rememberScrollState()),
            horizontalArrangement = Arrangement.spacedBy(MochiSpacing.sm)
        ) {
            fontStyles.forEachIndexed { index, style ->
                Column(
                    modifier = Modifier
                        .size(width = 78.dp, height = 76.dp)
                        .clip(RoundedCornerShape(MochiRadius.card))
                        .background(Color.White)
                        .border(1.dp, if (selected == index) MochiColor.purple else MochiColor.purple.copy(alpha = 0.15f), RoundedCornerShape(MochiRadius.card))
                        .clickable { onSelect(index) },
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.Center
                ) {
                    Text(text = "Aa", style = MochiFont.logo(22.sp), color = MochiColor.textPrimary)
                    Text(text = style, style = MochiFont.caption(9.sp), color = MochiColor.textSecondary)
                }
            }
        }
    }
}

@Composable
private fun LivePreviewToggleBanner() {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(MochiRadius.card))
            .background(Color.White)
            .padding(MochiSpacing.md),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(imageVector = Icons.Filled.Visibility, contentDescription = null, tint = MochiColor.purple, modifier = Modifier.size(24.dp))
        Column(modifier = Modifier.weight(1f).padding(horizontal = MochiSpacing.sm)) {
            Text(text = "LIVE PREVIEW", style = MochiFont.heading(13.sp), color = MochiColor.purple)
            Text(text = "See Real-Time Changes On The Keyboard Above", style = MochiFont.caption(10.sp), color = MochiColor.textSecondary)
        }
        Row(
            modifier = Modifier
                .clip(RoundedCornerShape(MochiRadius.pill))
                .border(1.dp, MochiColor.purple.copy(alpha = 0.3f), RoundedCornerShape(MochiRadius.pill))
                .padding(horizontal = 12.dp, vertical = 8.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(4.dp)
        ) {
            Icon(imageVector = Icons.Filled.Refresh, contentDescription = null, tint = MochiColor.purple, modifier = Modifier.size(14.dp))
            Text(text = "Reset All", style = MochiFont.caption(12.sp), color = MochiColor.purple)
        }
    }
}

@Composable
private fun ThemeNameSection(name: String, onNameChange: (String) -> Unit) {
    Column(verticalArrangement = Arrangement.spacedBy(MochiSpacing.sm)) {
        Text(text = "THEME NAME", style = MochiFont.heading(13.sp), color = MochiColor.textPrimary)
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(MochiRadius.pill))
                .background(Color.White)
                .border(1.dp, MochiColor.purple.copy(alpha = 0.2f), RoundedCornerShape(MochiRadius.pill))
                .padding(horizontal = MochiSpacing.md, vertical = 14.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            BasicTextField(
                value = name,
                onValueChange = onNameChange,
                textStyle = MochiFont.body(14.sp).copy(color = MochiColor.textPrimary),
                modifier = Modifier.weight(1f)
            )
            Icon(imageVector = Icons.Filled.Edit, contentDescription = "Edit name", tint = MochiColor.purple, modifier = Modifier.size(16.dp))
        }
    }
}

@Composable
private fun TagsSection() {
    var tags by remember { mutableStateOf(listOf("Cute", "Purple", "Dream", "Cloud")) }
    Column(verticalArrangement = Arrangement.spacedBy(MochiSpacing.sm)) {
        Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(4.dp)) {
            Text(text = "TAGS", style = MochiFont.heading(13.sp), color = MochiColor.textPrimary)
            Text(text = "(Optional)", style = MochiFont.caption(11.sp), color = MochiColor.textSecondary)
        }
        Row(
            modifier = Modifier.horizontalScroll(rememberScrollState()),
            horizontalArrangement = Arrangement.spacedBy(6.dp)
        ) {
            tags.forEach { tag ->
                Row(
                    modifier = Modifier
                        .clip(RoundedCornerShape(MochiRadius.pill))
                        .background(MochiGradient.primaryButton)
                        .padding(horizontal = 12.dp, vertical = 8.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(4.dp)
                ) {
                    Text(text = tag, style = MochiFont.caption(12.sp), color = Color.White)
                    Icon(
                        imageVector = Icons.Filled.Close,
                        contentDescription = "Remove $tag",
                        tint = Color.White,
                        modifier = Modifier.size(12.dp).clickable { tags = tags.filter { it != tag } }
                    )
                }
            }
            Box(
                modifier = Modifier
                    .size(32.dp)
                    .clip(CircleShape)
                    .border(1.dp, MochiColor.purple.copy(alpha = 0.3f), CircleShape),
                contentAlignment = Alignment.Center
            ) {
                Icon(imageVector = Icons.Filled.Add, contentDescription = "Add tag", tint = MochiColor.purple, modifier = Modifier.size(16.dp))
            }
        }
    }
}

@Composable
private fun ActionButtonsRow() {
    Row(horizontalArrangement = Arrangement.spacedBy(MochiSpacing.sm)) {
        ActionButtonCard(
            icon = Icons.Filled.Save,
            title = "Save Draft",
            subtitle = "Save Your Work For Later",
            modifier = Modifier.weight(1f),
            filled = false
        )
        ActionButtonCard(
            icon = Icons.AutoMirrored.Filled.Send,
            title = "Publish Theme",
            subtitle = "Share With The Community",
            modifier = Modifier.weight(1f),
            filled = true
        )
    }
}

@Composable
private fun ActionButtonCard(icon: androidx.compose.ui.graphics.vector.ImageVector, title: String, subtitle: String, modifier: Modifier = Modifier, filled: Boolean) {
    val textColor = if (filled) Color.White else MochiColor.textPrimary
    val subtitleColor = if (filled) Color.White.copy(alpha = 0.85f) else MochiColor.textSecondary
    Column(
        modifier = modifier
            .clip(RoundedCornerShape(MochiRadius.card))
            .then(if (filled) Modifier.background(MochiGradient.primaryButton) else Modifier.background(Color.White).border(1.dp, MochiColor.purple.copy(alpha = 0.25f), RoundedCornerShape(MochiRadius.card)))
            .clickable {}
            .padding(MochiSpacing.md),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(2.dp)
    ) {
        Icon(imageVector = icon, contentDescription = null, tint = textColor, modifier = Modifier.size(20.dp))
        Text(text = title, style = MochiFont.heading(13.sp), color = textColor)
        Text(text = subtitle, style = MochiFont.caption(10.sp), color = subtitleColor)
    }
}
