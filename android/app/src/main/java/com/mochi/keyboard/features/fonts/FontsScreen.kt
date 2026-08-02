package com.mochi.keyboard.features.fonts

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.detectDragGestures
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBars
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.windowInsetsPadding
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
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.FavoriteBorder
import androidx.compose.material.icons.filled.GridView
import androidx.compose.material.icons.filled.MoreHoriz
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.graphics.StrokeJoin
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.mochi.keyboard.R
import com.mochi.keyboard.components.FunnelGlyph
import com.mochi.keyboard.components.PencilGlyph
import com.mochi.keyboard.components.SlidersGlyph
import com.mochi.keyboard.components.SparkleCluster
import com.mochi.keyboard.components.SparkleField
import com.mochi.keyboard.components.TripleDot
import com.mochi.keyboard.designsystem.FontsMetrics
import com.mochi.keyboard.designsystem.FontsType
import com.mochi.keyboard.designsystem.MochiColor
import com.mochi.keyboard.designsystem.MochiFont
import com.mochi.keyboard.designsystem.MochiGradient
import com.mochi.keyboard.mockdata.MockData
import com.mochi.keyboard.model.FontItem

@Preview(showBackground = true, widthDp = 393, heightDp = 3000)
@Composable
private fun FontsScreenPreview() {
    FontsScreen()
}

/** Figma spells the sort control "Soft by" — corrected to "Sort by" like iOS's own port does
 * (a straightforward typo, unlike Community's deliberately-kept "serch themes"). */
private enum class FontCategory(val label: String) {
    ALL("All"), CUTE("Cute"), HANDWRITTEN("Handwritten"), MINIMAL("Minimal"),
    BOLD("Bold"), ELEGANT("Elegant"), OTHER("Other")
}

/** Grid/downloaded-strip art, distinct from Home's small `font_*` tile (ThemeArt's knownFontArt) —
 * this page draws the larger `fontart_*` crop, flat/unshadowed like Themes' cards. */
private val fontsArt: Map<String, Int> = mapOf(
    "fontart_bubble_cute" to R.drawable.fontart_bubble_cute,
    "fontart_handwritten_elegant" to R.drawable.fontart_handwritten_elegant,
    "fontart_typewriter_classic" to R.drawable.fontart_typewriter_classic,
    "fontart_bold_strong" to R.drawable.fontart_bold_strong,
    "fontart_nature_flow" to R.drawable.fontart_nature_flow,
    "fontart_gothic_dark" to R.drawable.fontart_gothic_dark
)

@Composable
private fun FontsArtImage(assetName: String, modifier: Modifier = Modifier) {
    val resId = fontsArt[assetName] ?: return
    Image(painter = painterResource(resId), contentDescription = null, contentScale = ContentScale.Crop, modifier = modifier)
}

/** Approximates SwiftUI's `.minimumScaleFactor` — iOS shrinks the grid card title down to 0.75x
 * rather than truncate it, specifically so "Handwritten Elegant" clears its Free/Pro chip the way
 * Figma draws it. Shrinks one step per recomposition until the single line fits or minScale is hit. */
@Composable
private fun ShrinkToFitText(text: String, style: TextStyle, color: Color, minScale: Float, modifier: Modifier = Modifier) {
    var scale by remember(text) { mutableFloatStateOf(1f) }
    Text(
        text = text,
        style = style.copy(fontSize = style.fontSize * scale),
        color = color,
        maxLines = 1,
        softWrap = false,
        overflow = TextOverflow.Clip,
        modifier = modifier,
        onTextLayout = { result ->
            if (result.didOverflowWidth && scale > minScale) {
                scale = (scale - 0.05f).coerceAtLeast(minScale)
            }
        }
    )
}

/** Ported from ios/MochiApp/Features/Fonts/FontsView.swift against docs/figma/5.png. Geometry
 * lives in FontsMetrics/FontsType (designsystem/FontsMetrics.kt), not here. The preview scale
 * slider and sample-text field are wired to local state but — matching iOS exactly — neither
 * actually resizes the letter grid or changes the static "100%" label; both are cosmetic there. */
@Composable
fun FontsScreen(modifier: Modifier = Modifier, onSearchClick: () -> Unit = {}) {
    var category by remember { mutableStateOf(FontCategory.ALL) }
    var liked by remember { mutableStateOf(MockData.fontCollection.map { it.id }.toSet()) }
    var sampleText by remember { mutableStateOf("") }
    var previewScale by remember { mutableFloatStateOf(0.45f) }

    Box(modifier = modifier.fillMaxSize()) {
        Image(
            painter = painterResource(R.drawable.fonts_background),
            contentDescription = null,
            contentScale = ContentScale.Crop,
            modifier = Modifier.fillMaxSize()
        )
        SparkleField(modifier = Modifier.fillMaxSize())

        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .windowInsetsPadding(WindowInsets.statusBars)
                .padding(horizontal = FontsMetrics.margin)
                .padding(bottom = 100.dp)
                .offset(y = FontsMetrics.contentTop)
        ) {
            Spacer(modifier = Modifier.height(FontsMetrics.headerTop))
            FontsHeader(onSearchClick)

            Spacer(modifier = Modifier.height(FontsMetrics.headerToPills))
            CategoryBar(selected = category, onSelect = { category = it })

            Spacer(modifier = Modifier.height(FontsMetrics.pillsToSort))
            SortRow()

            Spacer(modifier = Modifier.height(FontsMetrics.sortToGrid))
            CardGrid(themes = MockData.fontCollection, liked = liked, onToggleLike = { id ->
                liked = if (id in liked) liked - id else liked + id
            })

            Spacer(modifier = Modifier.height(FontsMetrics.gridToPanel))
            FontPreviewPanel(sampleText, { sampleText = it }, previewScale) { previewScale = it }

            Spacer(modifier = Modifier.height(FontsMetrics.panelToApply))
            ApplyPanel()

            Spacer(modifier = Modifier.height(FontsMetrics.applyToDownloads))
            DownloadedSection(MockData.downloadedFonts)
        }
    }
}

// region Header

@Composable
private fun FontsHeader(onSearchClick: () -> Unit) {
    Box(modifier = Modifier.fillMaxWidth().height(FontsMetrics.circleButton)) {
        Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
            FontsCircleButton(icon = Icons.AutoMirrored.Filled.ArrowBack, filled = false)
            Spacer(modifier = Modifier.weight(1f))
            FontsCircleButton(icon = Icons.Filled.Search, filled = true, onClick = onSearchClick)
        }

        Column(
            modifier = Modifier.align(Alignment.Center),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(FontsMetrics.titleToSubtitle)
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(FontsMetrics.badgeToTitle)
            ) {
                Box(
                    modifier = Modifier
                        .size(FontsMetrics.badge.width, FontsMetrics.badge.height)
                        .clip(RoundedCornerShape(FontsMetrics.badgeRadius))
                        .background(MochiGradient.fontsAccent),
                    contentAlignment = Alignment.Center
                ) {
                    Text(text = "Aa", style = MochiFont.itemName(FontsType.badgeGlyph), color = MochiColor.textPrimary)
                }
                Text(text = "Fonts", style = MochiFont.itemName(FontsType.pageTitle), color = MochiColor.logoSolid)
            }
            Text(
                text = "Choose the perfect font for your keyboard",
                style = MochiFont.body(FontsType.pageSubtitle),
                color = MochiColor.textGreyWarm
            )
        }
    }
}

/** The back button is a pink->orchid ramp; the search button a flat logoSolid disc — a
 * deliberately unmatched pair, unlike Themes' two identically-treated header discs. */
@Composable
private fun FontsCircleButton(icon: ImageVector, filled: Boolean, onClick: () -> Unit = {}) {
    Box(
        modifier = Modifier
            .size(FontsMetrics.circleButton)
            .clip(CircleShape)
            .background(
                brush = if (filled) SolidColor(MochiColor.logoSolid)
                else androidx.compose.ui.graphics.Brush.horizontalGradient(listOf(MochiColor.backButtonStart, MochiColor.backButtonEnd))
            )
            .clickable(onClick = onClick),
        contentAlignment = Alignment.Center
    ) {
        Icon(
            imageVector = icon,
            contentDescription = null,
            tint = if (filled) Color.White else MochiColor.textPrimary,
            modifier = Modifier.size(FontsMetrics.circleButton * 0.42f)
        )
    }
}

// endregion

// region Category bar

@Composable
private fun CategoryBar(selected: FontCategory, onSelect: (FontCategory) -> Unit) {
    Row(
        modifier = Modifier
            .height(FontsMetrics.pillBarHeight)
            .clip(CircleShape)
            .background(Color.White)
            .horizontalScroll(rememberScrollState())
            .padding(horizontal = FontsMetrics.pillBarInset),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(FontsMetrics.pillGap)
    ) {
        FontCategory.entries.forEach { item ->
            CategoryPill(item = item, isSelected = item == selected, onSelect = { onSelect(item) })
        }
    }
}

@Composable
private fun CategoryPill(item: FontCategory, isSelected: Boolean, onSelect: () -> Unit) {
    Row(
        modifier = Modifier
            .height(FontsMetrics.pillHeight)
            .clip(CircleShape)
            .then(
                if (isSelected) Modifier.background(MochiGradient.fontsAccent)
                else Modifier.border(FontsMetrics.hairline, MochiColor.logoSolid, CircleShape)
            )
            .clickable(onClick = onSelect)
            .padding(horizontal = FontsMetrics.pillPad),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(FontsMetrics.pillIconGap)
    ) {
        CategoryIcon(item)
        Text(text = item.label, style = MochiFont.body(FontsType.pill), color = MochiColor.textPrimary, maxLines = 1)
    }
}

/** Three marks are set in type ("Aa", "B", "E") — the only Bold text in the row — three are line
 * icons, and "Cute" is rendered artwork (a purple bow) rather than a glyph. */
@Composable
private fun CategoryIcon(item: FontCategory) {
    val density = LocalDensity.current
    val pencilStrokePx = with(density) { (FontsMetrics.hairline * 1.4f).toPx() }

    when (item) {
        FontCategory.ALL -> Icon(
            imageVector = Icons.Filled.GridView,
            contentDescription = null,
            tint = MochiColor.textPrimary,
            modifier = Modifier.size((FontsType.pill.value * 0.95f).dp)
        )
        FontCategory.CUTE -> Image(
            painter = painterResource(R.drawable.icon_bow),
            contentDescription = null,
            contentScale = ContentScale.Fit,
            modifier = Modifier.height(FontsMetrics.pillHeight * 0.72f)
        )
        FontCategory.HANDWRITTEN -> PencilGlyph(
            color = MochiColor.textPrimary,
            strokeWidth = pencilStrokePx,
            modifier = Modifier.size((FontsType.pill.value * 1.15f).dp)
        )
        FontCategory.MINIMAL -> Text(text = "Aa", style = MochiFont.title(FontsType.pill), color = MochiColor.textPrimary)
        FontCategory.BOLD -> Text(text = "B", style = MochiFont.title(FontsType.pill * 1.05f), color = MochiColor.textPrimary)
        FontCategory.ELEGANT -> Text(text = "E", style = MochiFont.title(FontsType.pill * 1.05f), color = MochiColor.textPrimary)
        FontCategory.OTHER -> TripleDot(
            color = MochiColor.textPrimary,
            modifier = Modifier.size(width = (FontsType.pill.value * 0.95f).dp, height = (FontsType.pill.value * 0.26f).dp)
        )
    }
}

// endregion

// region Sort row

@Composable
private fun SortRow() {
    val density = LocalDensity.current
    val glyphStrokePx = with(density) { (FontsMetrics.hairline * 1.6f).toPx() }

    Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
        Row(
            modifier = Modifier
                .height(FontsMetrics.sortHeight)
                .clip(CircleShape)
                .background(Color.White)
                .border(FontsMetrics.hairline, MochiColor.logoSolid, CircleShape)
                .padding(horizontal = 7.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(6.5.dp)
        ) {
            Text(text = "Sort by", style = MochiFont.body(FontsType.sort), color = MochiColor.logoSolid)
            Text(text = "Popular", style = MochiFont.body(FontsType.sort), color = MochiColor.textPrimary)
        }

        Spacer(modifier = Modifier.weight(1f))

        Row(
            modifier = Modifier
                .height(FontsMetrics.sortHeight)
                .clip(CircleShape)
                .background(Color.White)
                .border(FontsMetrics.hairline, MochiColor.logoSolid, CircleShape)
                .padding(horizontal = 8.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(3.5.dp)
        ) {
            FunnelGlyph(
                color = MochiColor.logoSolid,
                style = Stroke(width = glyphStrokePx, join = StrokeJoin.Round),
                modifier = Modifier.size(FontsType.sort.value.dp * 0.95f)
            )
            Text(text = "Filter", style = MochiFont.body(FontsType.sort), color = MochiColor.logoSolid)
        }

        Spacer(modifier = Modifier.width(3.dp))

        Box(
            modifier = Modifier
                .size(FontsMetrics.settings.width, FontsMetrics.settings.height)
                .clip(CircleShape)
                .background(Color.White)
                .border(FontsMetrics.hairline, MochiColor.logoSolid, CircleShape),
            contentAlignment = Alignment.Center
        ) {
            SlidersGlyph(
                color = MochiColor.logoSolid,
                strokeWidth = glyphStrokePx,
                modifier = Modifier.size(width = FontsMetrics.settings.width * 0.42f, height = FontsMetrics.settings.height * 0.30f)
            )
        }
    }
}

// endregion

// region Card grid

@Composable
private fun CardGrid(themes: List<FontItem>, liked: Set<String>, onToggleLike: (String) -> Unit) {
    Column(verticalArrangement = Arrangement.spacedBy(FontsMetrics.cardGap)) {
        themes.chunked(3).forEach { row ->
            Row(horizontalArrangement = Arrangement.spacedBy(FontsMetrics.cardGap)) {
                row.forEach { font -> FontGridCard(font, isLiked = font.id in liked, onToggleLike = { onToggleLike(font.id) }) }
            }
        }
    }
}

@Composable
private fun FontGridCard(font: FontItem, isLiked: Boolean, onToggleLike: () -> Unit) {
    Column(
        modifier = Modifier
            .width(FontsMetrics.cardWidth)
            .clip(RoundedCornerShape(FontsMetrics.cardRadius))
    ) {
        Box {
            FontsArtImage(
                assetName = font.artAssetName,
                modifier = Modifier
                    .width(FontsMetrics.cardWidth)
                    .height(FontsMetrics.cardWidth / FontsMetrics.cardArtAspect)
            )
            Box(
                modifier = Modifier
                    .align(Alignment.TopEnd)
                    .padding(top = FontsMetrics.heartTopInset, end = FontsMetrics.heartInset)
                    .size(FontsMetrics.heart)
                    .clip(CircleShape)
                    .background(Color.White)
                    .clickable(onClick = onToggleLike),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = if (isLiked) Icons.Filled.Favorite else Icons.Filled.FavoriteBorder,
                    contentDescription = null,
                    tint = MochiColor.logoSolid,
                    modifier = Modifier.size(FontsMetrics.heart * 0.52f)
                )
            }
        }

        Column(
            modifier = Modifier
                .width(FontsMetrics.cardWidth)
                .height(FontsMetrics.cardBodyHeight)
                .background(Color.White)
                .padding(horizontal = FontsMetrics.cardPad)
        ) {
            Spacer(modifier = Modifier.height(2.6.dp))

            Row(verticalAlignment = Alignment.CenterVertically) {
                ShrinkToFitText(
                    text = font.name,
                    style = MochiFont.itemName(FontsType.cardTitle),
                    color = MochiColor.textPrimary,
                    minScale = 0.75f,
                    modifier = Modifier.weight(1f, fill = false)
                )
                Spacer(modifier = Modifier.width(2.dp))
                FontsTierChip(isPremium = font.isPremium, size = FontsType.chip)
            }

            Spacer(modifier = Modifier.height(1.4.dp))

            Text(
                text = font.styleDescription,
                style = MochiFont.itemName(FontsType.cardSubtitle),
                color = MochiColor.logoSolid,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )

            Spacer(modifier = Modifier.weight(1f))

            Row(horizontalArrangement = Arrangement.spacedBy(FontsMetrics.cardButtonGap)) {
                Box(
                    modifier = Modifier
                        .weight(1f)
                        .height(FontsMetrics.cardButtonHeight)
                        .clip(CircleShape)
                        .background(Color.White)
                        .border(FontsMetrics.hairline, MochiColor.logoSolid, CircleShape),
                    contentAlignment = Alignment.Center
                ) {
                    Text(text = "Preview", style = MochiFont.body(FontsType.cardButton), color = MochiColor.textPrimary)
                }
                Box(
                    modifier = Modifier
                        .weight(1f)
                        .height(FontsMetrics.cardButtonHeight)
                        .clip(CircleShape)
                        .background(MochiGradient.fontsAccent),
                    contentAlignment = Alignment.Center
                ) {
                    Text(text = "Apply", style = MochiFont.body(FontsType.cardButton), color = MochiColor.textPrimary)
                }
            }

            Spacer(modifier = Modifier.height(3.4.dp))
        }
    }
}

/** A wide, shallow lozenge — 27px of air each side of the label and only 7px above/below it in
 * Figma, not the evenly-padded tag a naive ratio produces. Shared by the grid card and the
 * downloaded strip, at two different sizes. */
@Composable
private fun FontsTierChip(isPremium: Boolean, size: androidx.compose.ui.unit.TextUnit) {
    Text(
        text = if (isPremium) "Pro" else "Free",
        style = MochiFont.itemName(size),
        color = if (isPremium) MochiColor.proChipText else MochiColor.freeChipText,
        maxLines = 1,
        modifier = Modifier
            .clip(RoundedCornerShape(FontsMetrics.chipRadius))
            .background(if (isPremium) MochiColor.proChipBackground else MochiColor.freeChipBackground)
            .padding(horizontal = size.value.dp * 0.82f, vertical = size.value.dp * 0.11f)
    )
}

// endregion

// region Font preview panel

@Composable
private fun FontPreviewPanel(text: String, onTextChange: (String) -> Unit, scale: Float, onScaleChange: (Float) -> Unit) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(FontsMetrics.panelRadius))
            .background(Color.White)
            .border(0.8.dp, MochiColor.logoSolid, RoundedCornerShape(FontsMetrics.panelRadius))
            .padding(FontsMetrics.panelPad)
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Text(
                text = "FONT PREVIEW",
                style = MochiFont.title(FontsType.panelHeading),
                color = MochiColor.textPrimary,
                modifier = Modifier.weight(1f, fill = false)
            )
            Spacer(modifier = Modifier.width(6.dp))
            Box(
                modifier = Modifier
                    .size(FontsMetrics.fieldSize.width, FontsMetrics.fieldSize.height)
                    .clip(CircleShape)
                    .background(Color.White)
                    .border(FontsMetrics.hairline, MochiColor.logoSolid, CircleShape)
                    .padding(horizontal = FontsMetrics.fieldSize.height * 0.42f),
                contentAlignment = Alignment.CenterStart
            ) {
                BasicTextField(
                    value = text,
                    onValueChange = onTextChange,
                    singleLine = true,
                    textStyle = MochiFont.body(FontsType.placeholder).copy(color = MochiColor.textPrimary),
                    modifier = Modifier.fillMaxWidth(),
                    decorationBox = { inner ->
                        if (text.isEmpty()) {
                            Text(text = "Type something...", style = MochiFont.body(FontsType.placeholder), color = MochiColor.textGreyWarm)
                        }
                        inner()
                    }
                )
            }
        }

        Spacer(modifier = Modifier.height(FontsMetrics.headingToGrid))

        LetterGrid()

        Spacer(modifier = Modifier.height(FontsMetrics.gridToSlider))

        Row(verticalAlignment = Alignment.CenterVertically) {
            Text(text = "FONT PREVIEW", style = MochiFont.title(FontsType.sliderLabel), color = MochiColor.textPrimary, maxLines = 1)
            Spacer(modifier = Modifier.width(6.dp))
            Text(text = "A", style = MochiFont.body(FontsType.sliderLabel * 1.25f), color = MochiColor.textPrimary)
            Spacer(modifier = Modifier.width(3.dp))
            ScaleSlider(value = scale, onValueChange = onScaleChange, modifier = Modifier.width(129.1.dp).height(FontsMetrics.sliderKnob))
            Spacer(modifier = Modifier.width(3.dp))
            Text(text = "A", style = MochiFont.body(FontsType.sliderLabel * 2.1f), color = MochiColor.textPrimary)
            Spacer(modifier = Modifier.weight(1f))
            // Static, matching iOS exactly — the slider doesn't drive this label there either.
            Text(text = "100%", style = MochiFont.body(FontsType.percent), color = MochiColor.textPrimary, maxLines = 1)
        }
    }
}

/** A-Z then a-z over four rows of thirteen, each in an outlined cell, set in the *previewed* font
 * (Kaushan Script) rather than the UI face. */
@Composable
private fun LetterGrid() {
    val letters = ('A'..'Z').map { it.toString() } + ('a'..'z').map { it.toString() }
    LazyVerticalGrid(
        columns = GridCells.Fixed(FontsMetrics.letterColumns),
        verticalArrangement = Arrangement.spacedBy(FontsMetrics.letterRowGap),
        horizontalArrangement = Arrangement.spacedBy(0.dp),
        userScrollEnabled = false,
        modifier = Modifier
            .fillMaxWidth()
            .height(FontsMetrics.letterCellHeight * 4 + FontsMetrics.letterRowGap * 3)
    ) {
        items(letters) { letter ->
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(FontsMetrics.letterCellHeight)
                    .border(0.6.dp, MochiColor.logoSolid, RoundedCornerShape(FontsMetrics.letterCellRadius)),
                contentAlignment = Alignment.Center
            ) {
                Text(text = letter, style = MochiFont.script(FontsType.letter), color = MochiColor.textPrimary)
            }
        }
    }
}

/** A hairline rail with a small solid knob — not Material's Slider, whose knob and track are both
 * far too large at this scale (matching iOS's own reasoning for hand-drawing this rather than
 * tinting UIKit's control). */
@Composable
private fun ScaleSlider(value: Float, onValueChange: (Float) -> Unit, modifier: Modifier = Modifier) {
    val density = LocalDensity.current
    val knobPx = with(density) { FontsMetrics.sliderKnob.toPx() }
    val trackPx = with(density) { FontsMetrics.sliderTrack.toPx() }

    Canvas(
        modifier = modifier.pointerInput(Unit) {
            detectDragGestures { change, _ ->
                change.consume()
                val usable = (size.width - knobPx).coerceAtLeast(1f)
                val x = (change.position.x - knobPx / 2f).coerceIn(0f, usable)
                onValueChange(x / usable)
            }
        }
    ) {
        val usable = (size.width - knobPx).coerceAtLeast(1f)
        val knobX = knobPx / 2f + usable * value.coerceIn(0f, 1f)
        val midY = size.height / 2f
        drawLine(
            color = MochiColor.logoSolid.copy(alpha = 0.22f),
            start = Offset(0f, midY),
            end = Offset(size.width, midY),
            strokeWidth = trackPx
        )
        drawLine(
            color = MochiColor.logoSolid,
            start = Offset(0f, midY),
            end = Offset(knobX, midY),
            strokeWidth = trackPx
        )
        drawCircle(color = MochiColor.logoSolid, radius = knobPx / 2f, center = Offset(knobX, midY))
    }
}

// endregion

// region Apply panel

@Composable
private fun ApplyPanel() {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .height(FontsMetrics.applyPanelHeight)
            .clip(RoundedCornerShape(FontsMetrics.panelRadius))
            .background(Color.White)
            .border(0.8.dp, MochiColor.logoSolid, RoundedCornerShape(FontsMetrics.panelRadius))
            .padding(horizontal = FontsMetrics.panelPad),
        verticalAlignment = Alignment.CenterVertically
    ) {
        SparkleCluster(color = MochiColor.logoSolid, modifier = Modifier.size(FontsType.applyHeading.value.dp * 1.85f))

        Spacer(modifier = Modifier.width(5.dp))

        Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(1.5.dp)) {
            Text(
                text = "APPLY THIS FONT TO YOUR KEYBOARD",
                style = MochiFont.title(FontsType.applyHeading),
                color = MochiColor.logoSolid,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
            Text(
                text = "You Can Change It Anytime In Settings",
                style = MochiFont.body(FontsType.applySubtitle),
                color = MochiColor.textGreyWarm,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
        }

        Spacer(modifier = Modifier.width(4.dp))

        Row(
            modifier = Modifier
                .height(FontsMetrics.applyButton.height)
                .clip(RoundedCornerShape(FontsMetrics.applyButton.height * 0.24f))
                .background(MochiGradient.fontsAccent)
                .padding(
                    start = FontsMetrics.applyButton.height * 0.41f,
                    end = FontsMetrics.applyButton.height * 0.52f
                ),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(FontsMetrics.applyButton.height * 0.24f)
        ) {
            Box(
                modifier = Modifier
                    .size(FontsMetrics.applyButton.height * 0.61f)
                    .clip(CircleShape)
                    .background(Color.White),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = Icons.Filled.Check,
                    contentDescription = null,
                    tint = MochiColor.logoSolid,
                    modifier = Modifier.size(FontsMetrics.applyButton.height * 0.30f)
                )
            }
            Text(text = "Apply Font", style = MochiFont.itemName(FontsType.applyButton), color = MochiColor.textPrimary, maxLines = 1)
        }
    }
}

// endregion

// region Downloaded strip

@Composable
private fun DownloadedSection(fonts: List<FontItem>) {
    Column {
        Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
            Text(
                text = "MY DOWNLOADED FONTS",
                style = MochiFont.title(FontsType.sectionTitle),
                color = MochiColor.textPrimary,
                modifier = Modifier.weight(1f)
            )
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(2.5.dp)) {
                Text(text = "see all", style = MochiFont.body(FontsType.seeAll), color = MochiColor.logoSolid)
                Icon(
                    imageVector = Icons.AutoMirrored.Filled.KeyboardArrowRight,
                    contentDescription = null,
                    tint = MochiColor.logoSolid,
                    modifier = Modifier.size((FontsType.seeAll.value * 0.8f).dp)
                )
            }
        }

        Spacer(modifier = Modifier.height(FontsMetrics.headingToDownloads))

        Row(
            modifier = Modifier.horizontalScroll(rememberScrollState()),
            horizontalArrangement = Arrangement.spacedBy(FontsMetrics.downloadCardGap)
        ) {
            fonts.forEach { font -> FontDownloadCard(font) }
        }
    }
}

@Composable
private fun FontDownloadCard(font: FontItem) {
    Column(
        modifier = Modifier
            .width(FontsMetrics.downloadCard)
            .clip(RoundedCornerShape(FontsMetrics.downloadRadius))
    ) {
        Box {
            FontsArtImage(
                assetName = font.artAssetName,
                modifier = Modifier
                    .width(FontsMetrics.downloadCard)
                    .height(FontsMetrics.downloadCard / FontsMetrics.downloadArtAspect)
            )
            Box(
                modifier = Modifier
                    .align(Alignment.TopEnd)
                    .padding(4.dp)
                    .size(FontsMetrics.downloadCard * 0.19f)
                    .clip(CircleShape)
                    .background(Color.White),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = Icons.Filled.MoreHoriz,
                    contentDescription = null,
                    tint = MochiColor.textPrimary,
                    modifier = Modifier.size(FontsMetrics.downloadCard * 0.10f)
                )
            }
        }

        Row(
            modifier = Modifier
                .width(FontsMetrics.downloadCard)
                .height(FontsMetrics.downloadBodyHeight)
                .background(Color.White)
                .padding(horizontal = 3.4.dp),
            verticalAlignment = Alignment.Top
        ) {
            Text(
                text = font.name,
                style = MochiFont.body(FontsType.downloadName),
                color = MochiColor.textPrimary,
                maxLines = 2,
                overflow = TextOverflow.Ellipsis,
                modifier = Modifier.weight(1f, fill = false)
            )
            Spacer(modifier = Modifier.width(1.dp))
            FontsTierChip(isPremium = font.isPremium, size = FontsType.downloadChip)
        }
    }
}

// endregion
