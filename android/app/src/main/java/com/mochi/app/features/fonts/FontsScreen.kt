package com.mochi.app.features.fonts

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.AutoAwesome
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.MoreVert
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.filled.Tune
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.material3.Slider
import com.mochi.app.R
import com.mochi.app.components.GradientButton
import com.mochi.app.designsystem.MochiColor
import com.mochi.app.designsystem.MochiFont
import com.mochi.app.designsystem.MochiGradient
import com.mochi.app.designsystem.MochiRadius
import com.mochi.app.designsystem.MochiSpacing

@Preview(showBackground = true, widthDp = 393, heightDp = 1700)
@Composable
private fun FontsScreenPreview() {
    FontsScreen()
}

private data class ShopFont(val name: String, val description: String, val isPremium: Boolean, val assetName: String)

private val shopFonts = listOf(
    ShopFont("Bubble Cute", "Rounded & Playful", false, "font_shop_bubble_cute"),
    ShopFont("Handwritten Elegant", "Smooth & Natural", true, "font_shop_handwritten_elegant"),
    ShopFont("Typewriter Classic", "Clean & Readable", false, "font_shop_typewriter_classic"),
    ShopFont("Bold Strong", "Bold & Impactful", true, "font_shop_bold_strong"),
    ShopFont("Nature Flow", "Fresh & Calm", false, "font_shop_nature_flow"),
    ShopFont("Gothic Dark", "Unique & Stylish", true, "font_shop_gothic_dark")
)

private val categories = listOf("All", "Cute", "Handwritten", "Minimal", "Bold", "Elegant", "Other")

/** Ported from docs/figma/5.png */
@Composable
fun FontsScreen(modifier: Modifier = Modifier) {
    var selectedCategory by remember { mutableStateOf("All") }
    var previewText by remember { mutableStateOf("") }
    var previewSize by remember { mutableFloatStateOf(0.5f) }

    Box(modifier = modifier.fillMaxSize().background(MochiGradient.background)) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = MochiSpacing.md)
                .padding(top = MochiSpacing.md, bottom = 100.dp),
            verticalArrangement = Arrangement.spacedBy(MochiSpacing.lg)
        ) {
            FontsHeader()
            CategoryChips(selectedCategory) { selectedCategory = it }
            SortFilterRow()
            FontShopGrid()
            FontPreviewPanel(previewText, { previewText = it }, previewSize) { previewSize = it }
            ApplyFontBanner()
            DownloadedFontsRow()
        }
    }
}

@Composable
private fun FontsHeader() {
    Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
        CircleIconButton(icon = Icons.AutoMirrored.Filled.ArrowBack, background = MochiGradient.primaryButton)
        Column(modifier = Modifier.weight(1f).padding(horizontal = MochiSpacing.sm), horizontalAlignment = Alignment.CenterHorizontally) {
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                Box(
                    modifier = Modifier.size(22.dp).clip(RoundedCornerShape(6.dp)).background(MochiColor.purple),
                    contentAlignment = Alignment.Center
                ) {
                    Text(text = "Aa", style = MochiFont.caption(10.sp), color = androidx.compose.ui.graphics.Color.White)
                }
                Text(text = "Fonts", style = MochiFont.title(26.sp), color = MochiColor.purple)
            }
            Text(text = "Choose the perfect font for your keyboard", style = MochiFont.caption(12.sp), color = MochiColor.textSecondary)
        }
        CircleIconButton(icon = Icons.Filled.Search, background = MochiGradient.primaryButton)
    }
}

@Composable
private fun CircleIconButton(icon: androidx.compose.ui.graphics.vector.ImageVector, background: androidx.compose.ui.graphics.Brush) {
    Box(
        modifier = Modifier.size(44.dp).clip(CircleShape).background(background),
        contentAlignment = Alignment.Center
    ) {
        Icon(imageVector = icon, contentDescription = null, tint = androidx.compose.ui.graphics.Color.White)
    }
}

@Composable
private fun CategoryChips(selected: String, onSelect: (String) -> Unit) {
    Row(
        modifier = Modifier.horizontalScroll(rememberScrollState()),
        horizontalArrangement = Arrangement.spacedBy(MochiSpacing.sm)
    ) {
        categories.forEach { category ->
            val isSelected = category == selected
            Row(
                modifier = Modifier
                    .clip(RoundedCornerShape(MochiRadius.pill))
                    .then(
                        if (isSelected) Modifier.background(MochiGradient.primaryButton)
                        else Modifier.background(androidx.compose.ui.graphics.Color.White).border(1.dp, MochiColor.purple.copy(alpha = 0.25f), RoundedCornerShape(MochiRadius.pill))
                    )
                    .clickable { onSelect(category) }
                    .padding(horizontal = 16.dp, vertical = 10.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(6.dp)
            ) {
                Text(text = category, style = MochiFont.body(13.sp), color = MochiColor.textPrimary)
            }
        }
    }
}

@Composable
private fun SortFilterRow() {
    Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
        Text(text = "Sort by ", style = MochiFont.caption(13.sp), color = MochiColor.textSecondary)
        Text(text = "Popular", style = MochiFont.heading(13.sp), color = MochiColor.textPrimary)
        Spacer(modifier = Modifier.weight(1f))
        Row(
            modifier = Modifier
                .clip(RoundedCornerShape(MochiRadius.pill))
                .border(1.dp, MochiColor.purple.copy(alpha = 0.25f), RoundedCornerShape(MochiRadius.pill))
                .padding(horizontal = 14.dp, vertical = 8.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(4.dp)
        ) {
            Text(text = "Filter", style = MochiFont.caption(13.sp), color = MochiColor.textPrimary)
        }
        Spacer(modifier = Modifier.width(8.dp))
        Box(
            modifier = Modifier
                .size(36.dp)
                .clip(CircleShape)
                .border(1.dp, MochiColor.purple.copy(alpha = 0.25f), CircleShape),
            contentAlignment = Alignment.Center
        ) {
            Icon(imageVector = Icons.Filled.Tune, contentDescription = "Filter options", tint = MochiColor.textPrimary, modifier = Modifier.size(18.dp))
        }
    }
}

@Composable
private fun FontShopGrid() {
    Column(verticalArrangement = Arrangement.spacedBy(MochiSpacing.md)) {
        shopFonts.chunked(3).forEach { row ->
            Row(horizontalArrangement = Arrangement.spacedBy(MochiSpacing.md)) {
                row.forEach { font ->
                    FontShopCard(font, Modifier.weight(1f))
                }
                repeat(3 - row.size) { Spacer(modifier = Modifier.weight(1f)) }
            }
        }
    }
}

@Composable
private fun FontShopCard(font: ShopFont, modifier: Modifier = Modifier) {
    val resId = androidx.compose.ui.res.painterResource(
        id = when (font.assetName) {
            "font_shop_bubble_cute" -> R.drawable.font_shop_bubble_cute
            "font_shop_handwritten_elegant" -> R.drawable.font_shop_handwritten_elegant
            "font_shop_typewriter_classic" -> R.drawable.font_shop_typewriter_classic
            "font_shop_bold_strong" -> R.drawable.font_shop_bold_strong
            "font_shop_nature_flow" -> R.drawable.font_shop_nature_flow
            else -> R.drawable.font_shop_gothic_dark
        }
    )
    Column(
        modifier = modifier
            .clip(RoundedCornerShape(MochiRadius.card))
            .background(androidx.compose.ui.graphics.Color.White),
        verticalArrangement = Arrangement.spacedBy(6.dp)
    ) {
        Box {
            Image(
                painter = resId,
                contentDescription = font.name,
                contentScale = ContentScale.Crop,
                modifier = Modifier.fillMaxWidth().aspectRatio(1f)
            )
            Box(
                modifier = Modifier
                    .align(Alignment.TopEnd)
                    .padding(6.dp)
                    .size(22.dp)
                    .clip(CircleShape)
                    .background(androidx.compose.ui.graphics.Color.White),
                contentAlignment = Alignment.Center
            ) {
                Icon(imageVector = Icons.Filled.Favorite, contentDescription = null, tint = MochiColor.purple, modifier = Modifier.size(11.dp))
            }
        }
        Column(modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp), verticalArrangement = Arrangement.spacedBy(4.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text(text = font.name, style = MochiFont.heading(12.sp), color = MochiColor.textPrimary, maxLines = 1, modifier = Modifier.weight(1f))
            }
            PriceTag(isPremium = font.isPremium)
            Text(text = font.description, style = MochiFont.caption(10.sp), color = MochiColor.purple)
            Row(horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                SmallPillButton(title = "Preview", modifier = Modifier.weight(1f), filled = false) {}
                SmallPillButton(title = "Apply", modifier = Modifier.weight(1f), filled = true) {}
            }
        }
    }
}

@Composable
private fun SmallPillButton(title: String, modifier: Modifier = Modifier, filled: Boolean, onClick: () -> Unit) {
    Box(
        modifier = modifier
            .clip(RoundedCornerShape(MochiRadius.pill))
            .then(
                if (filled) Modifier.background(MochiGradient.primaryButton)
                else Modifier.background(Color.White).border(1.dp, MochiColor.purple.copy(alpha = 0.35f), RoundedCornerShape(MochiRadius.pill))
            )
            .padding(vertical = 6.dp),
        contentAlignment = Alignment.Center
    ) {
        Text(text = title, style = MochiFont.caption(9.sp), color = MochiColor.textPrimary)
    }
}

@Composable
private fun PriceTag(isPremium: Boolean) {
    val bg = if (isPremium) androidx.compose.ui.graphics.Color(0xFFFDEDC6) else androidx.compose.ui.graphics.Color(0xFFF4F6D2)
    val fg = if (isPremium) androidx.compose.ui.graphics.Color(0xFFFD981B) else androidx.compose.ui.graphics.Color(0xFF77A509)
    Box(modifier = Modifier.clip(RoundedCornerShape(6.dp)).background(bg).padding(horizontal = 8.dp, vertical = 2.dp)) {
        Text(text = if (isPremium) "Pro" else "Free", style = MochiFont.caption(10.sp), color = fg)
    }
}

@Composable
private fun FontPreviewPanel(
    text: String,
    onTextChange: (String) -> Unit,
    size: Float,
    onSizeChange: (Float) -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(MochiRadius.card))
            .background(androidx.compose.ui.graphics.Color.White)
            .border(1.dp, MochiColor.purple.copy(alpha = 0.2f), RoundedCornerShape(MochiRadius.card))
            .padding(MochiSpacing.md),
        verticalArrangement = Arrangement.spacedBy(MochiSpacing.sm)
    ) {
        Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
            Text(text = "FONT PREVIEW", style = MochiFont.heading(13.sp), color = MochiColor.textPrimary, modifier = Modifier.weight(1f))
            Box(
                modifier = Modifier
                    .clip(RoundedCornerShape(MochiRadius.pill))
                    .border(1.dp, MochiColor.purple.copy(alpha = 0.25f), RoundedCornerShape(MochiRadius.pill))
                    .padding(horizontal = 12.dp, vertical = 6.dp)
            ) {
                BasicTextField(
                    value = text,
                    onValueChange = onTextChange,
                    textStyle = MochiFont.caption(12.sp).copy(color = MochiColor.textPrimary),
                    modifier = Modifier.width(110.dp),
                    decorationBox = { inner ->
                        if (text.isEmpty()) {
                            Text(text = "Type something...", style = MochiFont.caption(12.sp), color = MochiColor.textSecondary)
                        }
                        inner()
                    }
                )
            }
        }

        LazyVerticalGrid(
            columns = GridCells.Fixed(13),
            horizontalArrangement = Arrangement.spacedBy(4.dp),
            verticalArrangement = Arrangement.spacedBy(4.dp),
            modifier = Modifier.height(160.dp)
        ) {
            items(('A'..'Z').toList() + ('a'..'z').toList()) { letter ->
                Box(
                    modifier = Modifier
                        .aspectRatio(1f)
                        .clip(RoundedCornerShape(6.dp))
                        .border(1.dp, MochiColor.purple.copy(alpha = 0.3f), RoundedCornerShape(6.dp)),
                    contentAlignment = Alignment.Center
                ) {
                    Text(text = letter.toString(), style = MochiFont.body(12.sp), color = MochiColor.textPrimary)
                }
            }
        }

        Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            Text(text = "A", style = MochiFont.caption(12.sp), color = MochiColor.textSecondary)
            Slider(value = size, onValueChange = onSizeChange, modifier = Modifier.weight(1f))
            Text(text = "A", style = MochiFont.heading(20.sp), color = MochiColor.textPrimary)
            Text(text = "${(size * 200).toInt()}%", style = MochiFont.caption(12.sp), color = MochiColor.textSecondary)
        }
    }
}

@Composable
private fun ApplyFontBanner() {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(MochiRadius.card))
            .background(androidx.compose.ui.graphics.Color.White)
            .border(1.dp, MochiColor.purple.copy(alpha = 0.2f), RoundedCornerShape(MochiRadius.card))
            .padding(MochiSpacing.md),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(imageVector = Icons.Filled.AutoAwesome, contentDescription = null, tint = MochiColor.purple, modifier = Modifier.size(28.dp))
        Column(modifier = Modifier.weight(1f).padding(horizontal = MochiSpacing.sm)) {
            Text(text = "Apply this font to your keyboard", style = MochiFont.heading(13.sp), color = MochiColor.purple)
            Text(text = "You can change it anytime in settings", style = MochiFont.caption(11.sp), color = MochiColor.textSecondary)
        }
        GradientButton(title = "Apply Font", modifier = Modifier.width(120.dp)) {}
    }
}

@Composable
private fun DownloadedFontsRow() {
    Column(verticalArrangement = Arrangement.spacedBy(MochiSpacing.sm)) {
        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
            Text(text = "MY DOWNLOADED FONTS", style = MochiFont.heading(13.sp), color = MochiColor.textPrimary)
            Text(text = "see all", style = MochiFont.caption(13.sp), color = MochiColor.textPrimary)
        }
        Row(
            modifier = Modifier.horizontalScroll(rememberScrollState()),
            horizontalArrangement = Arrangement.spacedBy(MochiSpacing.sm)
        ) {
            shopFonts.filter { it.name != "Typewriter Classic" }.forEach { font ->
                Column(
                    modifier = Modifier
                        .width(90.dp)
                        .clip(RoundedCornerShape(MochiRadius.card))
                        .background(androidx.compose.ui.graphics.Color.White),
                    verticalArrangement = Arrangement.spacedBy(4.dp)
                ) {
                    Box {
                        Image(
                            painter = painterResource(
                                id = when (font.assetName) {
                                    "font_shop_bubble_cute" -> R.drawable.font_shop_bubble_cute
                                    "font_shop_handwritten_elegant" -> R.drawable.font_shop_handwritten_elegant
                                    "font_shop_typewriter_classic" -> R.drawable.font_shop_typewriter_classic
                                    "font_shop_bold_strong" -> R.drawable.font_shop_bold_strong
                                    "font_shop_nature_flow" -> R.drawable.font_shop_nature_flow
                                    else -> R.drawable.font_shop_gothic_dark
                                }
                            ),
                            contentDescription = font.name,
                            contentScale = ContentScale.Crop,
                            modifier = Modifier.fillMaxWidth().aspectRatio(1f)
                        )
                        Icon(
                            imageVector = Icons.Filled.MoreVert,
                            contentDescription = null,
                            tint = androidx.compose.ui.graphics.Color.White,
                            modifier = Modifier
                                .align(Alignment.TopEnd)
                                .padding(4.dp)
                                .clip(CircleShape)
                                .background(androidx.compose.ui.graphics.Color.Black.copy(alpha = 0.3f))
                                .size(16.dp)
                        )
                    }
                    Text(
                        text = font.name,
                        style = MochiFont.caption(10.sp),
                        color = MochiColor.textPrimary,
                        maxLines = 1,
                        textAlign = TextAlign.Center,
                        modifier = Modifier.padding(horizontal = 4.dp).padding(bottom = 4.dp)
                    )
                }
            }
        }
    }
}
