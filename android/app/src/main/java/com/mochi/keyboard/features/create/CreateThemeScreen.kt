package com.mochi.keyboard.features.create

import android.net.Uri
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
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
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBars
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.Send
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.AutoAwesome
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Colorize
import androidx.compose.material.icons.filled.Edit
import androidx.compose.material.icons.filled.PhotoLibrary
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.Visibility
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.BiasAlignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.mochi.keyboard.R
import com.mochi.keyboard.components.ColorWheelGlyph
import com.mochi.keyboard.components.FloppyGlyph
import com.mochi.keyboard.components.HexagonShape
import com.mochi.keyboard.components.KeycapGlyph
import com.mochi.keyboard.components.SparkleField
import com.mochi.keyboard.data.rememberMochiViewModelFactory
import com.mochi.keyboard.designsystem.CreateMetrics
import com.mochi.keyboard.designsystem.MochiColor
import com.mochi.keyboard.designsystem.MochiFont
import com.mochi.keyboard.designsystem.MochiGradient

@Preview(showBackground = true, widthDp = 393, heightDp = 3200)
@Composable
private fun CreateThemeScreenPreview() {
    CreateThemeScreenContent()
}

private enum class EditorTab(val label: String) { BACKGROUND("Background"), KEYS("Keys"), FONTS("Fonts"), EFFECT("Effect") }

private val backgroundArt = listOf(R.drawable.create_bg_thumb_1, R.drawable.create_bg_thumb_2, R.drawable.create_bg_thumb_3, R.drawable.create_bg_thumb_4)
private val fontStyleSpecimens = listOf(
    R.drawable.create_fontstyle_default to "Default",
    R.drawable.create_fontstyle_rounded to "Rounded",
    R.drawable.create_fontstyle_cute to "Cute",
    R.drawable.create_fontstyle_classic to "Classic",
    R.drawable.create_fontstyle_handwritten to "Handwritten"
)

/** Ported from ios/MochiApp/Features/Create/CreateThemeView.swift against docs/figma/4.png. iOS
 * lays this one page out on an absolute canvas — three ragged columns overlap vertically in the
 * middle third (KEY SHAPE / KEY COLOR / RECENT, then LETTER COLOR / FONT STYLE) — because no stack
 * of rows reproduces that without inventing spacing the design never had. Per-element sizes are
 * carried over via CreateMetrics (each measured Figma px * k, k = 402/2161, the same convention
 * every other screen's Metrics file uses); the column *grouping* is reproduced with ordinary
 * Row/Column nesting instead of iOS's x/y coordinates, the same call Profile's and Themes'
 * absolute-canvas sections made, just applied at a larger structural scale here. The saturation
 * squares, hue rails and their knobs are static in iOS too — no gesture is wired to them there
 * either, so none is added here. */
@Composable
fun CreateThemeScreen(
    modifier: Modifier = Modifier,
    viewModel: CreateThemeViewModel = viewModel(factory = rememberMochiViewModelFactory())
) {
    val publishState by viewModel.publishState.collectAsStateWithLifecycle()
    CreateThemeScreenContent(
        modifier = modifier,
        publishState = publishState,
        onSave = { name, tags, presetBackground, galleryUri, keyShape, fontStyle, publish ->
            viewModel.save(name, tags, presetBackground, galleryUri, keyShape, fontStyle, publish)
        }
    )
}

/** Split from CreateThemeScreen so @Preview can render this directly without going through
 * rememberMochiViewModelFactory() - that factory casts LocalContext's application to
 * MochiApplication, which Preview's fake context isn't, and would crash the preview. Same pattern
 * as HomeScreen/ThemesScreen. */
@Composable
private fun CreateThemeScreenContent(
    modifier: Modifier = Modifier,
    publishState: PublishUiState = PublishUiState.Idle,
    onSave: (
        name: String,
        tags: List<String>,
        presetBackground: Int?,
        galleryUri: Uri?,
        keyShape: Int,
        fontStyle: Int,
        publish: Boolean
    ) -> Unit = { _, _, _, _, _, _, _ -> }
) {
    var tab by remember { mutableStateOf(EditorTab.FONTS) }
    var presetBackground by remember { mutableStateOf<Int?>(0) }
    var galleryUri by remember { mutableStateOf<Uri?>(null) }
    var keyShape by remember { mutableStateOf(0) }
    var fontStyle by remember { mutableStateOf(0) }
    var themeName by remember { mutableStateOf("") }
    var tags by remember { mutableStateOf(listOf("Cute", "Purple", "Dream", "Cloud")) }

    val galleryPicker = rememberLauncherForActivityResult(ActivityResultContracts.GetContent()) { uri ->
        if (uri != null) {
            galleryUri = uri
            presetBackground = null
        }
    }

    LaunchedEffect(publishState) {
        if (publishState is PublishUiState.Success) {
            themeName = ""
            tags = emptyList()
            galleryUri = null
            presetBackground = 0
        }
    }

    Box(modifier = modifier.fillMaxSize()) {
        Image(
            painter = painterResource(R.drawable.create_background),
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
                .padding(horizontal = CreateMetrics.margin)
                .padding(bottom = 96.dp)
                .offset(y = CreateMetrics.contentTop),
            verticalArrangement = Arrangement.spacedBy(14.dp)
        ) {
            CreateHeader()
            KeyboardPreview()
            EditorTabBar(selected = tab, onSelect = { tab = it })
            BackgroundCard(
                selectedPreset = presetBackground,
                gallerySelected = galleryUri != null,
                onSelectPreset = { presetBackground = it; galleryUri = null },
                onGalleryClick = { galleryPicker.launch("image/*") }
            )

            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                KeyShapeSection(selected = keyShape, onSelect = { keyShape = it }, modifier = Modifier.weight(1.75f))
                KeyColorSection(modifier = Modifier.weight(1.35f))
                RecentSection(modifier = Modifier.weight(0.95f))
            }

            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                LetterColorSection(modifier = Modifier.weight(1.4f))
                FontStyleSection(selected = fontStyle, onSelect = { fontStyle = it }, modifier = Modifier.weight(2.8f))
            }

            LivePreviewCard()

            Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                ThemeNameField(
                    value = themeName,
                    onValueChange = { themeName = it },
                    modifier = Modifier.weight(CreateMetrics.nameFieldWeight)
                )
                TagsField(
                    tags = tags,
                    onRemove = { tag -> tags = tags.filterNot { it == tag } },
                    modifier = Modifier.weight(CreateMetrics.tagsFieldWeight)
                )
            }

            StatusBanner(publishState)

            ActionButtonsRow(
                isSaving = publishState is PublishUiState.Saving,
                onSaveDraft = {
                    onSave(themeName, tags, presetBackground, galleryUri, keyShape, fontStyle, false)
                },
                onPublish = {
                    onSave(themeName, tags, presetBackground, galleryUri, keyShape, fontStyle, true)
                }
            )
        }
    }
}

@Composable
private fun StatusBanner(state: PublishUiState) {
    val message = when (state) {
        is PublishUiState.Success -> if (state.published) "Published! It'll appear in Community once approved." else "Draft saved."
        is PublishUiState.Error -> state.message
        else -> null
    } ?: return
    val color = if (state is PublishUiState.Error) MochiColor.heart else MochiColor.logoSolid
    Text(text = message, style = MochiFont.body(13.sp), color = color)
}

/** The purple ring every white panel on this frame carries. */
private fun Modifier.panelBorder(shape: Shape) = this.border(CreateMetrics.panelStroke, MochiColor.outline, shape)

private fun Modifier.panelBorderSolid(shape: Shape) = this.border(CreateMetrics.panelStroke, MochiColor.logoSolid, shape)

@Composable
private fun CheckBadge(diameter: Dp) {
    Box(
        modifier = Modifier.size(diameter).clip(CircleShape).background(MochiColor.logoSolid),
        contentAlignment = Alignment.Center
    ) {
        Icon(imageVector = Icons.Filled.Check, contentDescription = null, tint = Color.White, modifier = Modifier.size(diameter * 0.52f))
    }
}

// region Header / preview / tabs

@Composable
private fun CreateHeader() {
    Box(modifier = Modifier.fillMaxWidth()) {
        Box(
            modifier = Modifier
                .align(Alignment.CenterStart)
                .size(CreateMetrics.circleButton)
                .clip(CircleShape)
                .background(MochiGradient.themeCircleButton),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                contentDescription = "Back",
                tint = MochiColor.textPrimary,
                modifier = Modifier.size(CreateMetrics.backArrowIcon)
            )
        }
        Column(modifier = Modifier.align(Alignment.Center), horizontalAlignment = Alignment.CenterHorizontally) {
            Text(text = "Create Custom Theme", style = MochiFont.title(CreateMetrics.titleSize), color = MochiColor.logoSolid)
            Text(text = "Design your own keyboard theme", style = MochiFont.body(CreateMetrics.subtitleSize), color = MochiColor.textGreyWarm)
        }
    }
}

@Composable
private fun KeyboardPreview() {
    Image(
        painter = painterResource(R.drawable.create_keyboard_preview),
        contentDescription = "Live keyboard preview",
        contentScale = ContentScale.Crop,
        modifier = Modifier
            .fillMaxWidth()
            .aspectRatio(CreateMetrics.keyboardPreviewAspect)
            .clip(RoundedCornerShape(CreateMetrics.keyboardPreviewRadius))
    )
}

@Composable
private fun EditorTabBar(selected: EditorTab, onSelect: (EditorTab) -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(CircleShape)
            .background(Color.White)
            .panelBorderSolid(CircleShape)
            .padding(3.dp),
        horizontalArrangement = Arrangement.SpaceEvenly,
        verticalAlignment = Alignment.CenterVertically
    ) {
        EditorTab.entries.forEach { item ->
            val isSelected = item == selected
            Row(
                modifier = Modifier
                    .height(CreateMetrics.tabPillHeight)
                    .clip(CircleShape)
                    .then(if (isSelected) Modifier.background(MochiGradient.editorPill) else Modifier)
                    .clickable { onSelect(item) }
                    .padding(horizontal = 10.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(3.dp)
            ) {
                val tint = if (isSelected) MochiColor.textPrimary else MochiColor.textGreyWarm
                Box(modifier = Modifier.size(12.dp), contentAlignment = Alignment.Center) {
                    when (item) {
                        EditorTab.BACKGROUND -> Icon(Icons.Filled.PhotoLibrary, null, tint = tint, modifier = Modifier.size(11.dp))
                        EditorTab.KEYS -> KeycapGlyph(fillColor = tint, sparkleColor = Color.White, modifier = Modifier.size(12.dp))
                        EditorTab.FONTS -> Text(text = "Aa", style = MochiFont.title(11.sp), color = tint)
                        EditorTab.EFFECT -> Icon(Icons.Filled.AutoAwesome, null, tint = tint, modifier = Modifier.size(11.dp))
                    }
                }
                Text(text = item.label, style = MochiFont.body(CreateMetrics.tabTextSize), color = tint, maxLines = 1)
            }
        }
    }
}

// endregion

// region Background card

@Composable
private fun BackgroundCard(
    selectedPreset: Int?,
    gallerySelected: Boolean,
    onSelectPreset: (Int) -> Unit,
    onGalleryClick: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(CreateMetrics.bgPanelRadius))
            .background(Color.White)
            .panelBorderSolid(RoundedCornerShape(CreateMetrics.bgPanelRadius))
            .padding(12.dp),
        verticalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        Text(text = "BACKGROUND", style = MochiFont.title(CreateMetrics.bgHeadingSize), color = MochiColor.textPrimary)
        Row(
            modifier = Modifier.horizontalScroll(rememberScrollState()),
            horizontalArrangement = Arrangement.spacedBy(CreateMetrics.bgTileGap)
        ) {
            SourceTile(caption = "Gallery", isSelected = gallerySelected, onClick = onGalleryClick) {
                Icon(Icons.Filled.Add, contentDescription = null, tint = MochiColor.logoSolid, modifier = Modifier.size(20.dp))
            }
            SourceTile(caption = "Colors", isSelected = false, onClick = {}) {
                ColorWheelGlyph(modifier = Modifier.size(20.dp))
            }
            backgroundArt.forEachIndexed { index, res ->
                ArtworkTile(res = res, isSelected = selectedPreset == index, onClick = { onSelectPreset(index) })
            }
        }
    }
}

/** Colors has no gesture wired, matching iOS/the saturation-square precedent elsewhere on this
 * screen — only Gallery becomes real (a system photo picker + Storage upload). */
@Composable
private fun SourceTile(caption: String, isSelected: Boolean, onClick: () -> Unit, glyph: @Composable () -> Unit) {
    Box {
        Column(
            modifier = Modifier
                .size(CreateMetrics.bgTileWidth, CreateMetrics.bgTileHeight)
                .clip(RoundedCornerShape(CreateMetrics.sourceTileRadius))
                .background(Color.White)
                .panelBorderSolid(RoundedCornerShape(CreateMetrics.sourceTileRadius))
                .clickable(onClick = onClick),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            glyph()
            Spacer(modifier = Modifier.height(2.dp))
            Text(text = caption, style = MochiFont.body(CreateMetrics.sourceCaptionSize), color = MochiColor.logoSolid)
        }
        if (isSelected) {
            Box(modifier = Modifier.align(Alignment.TopEnd).padding(2.dp)) {
                CheckBadge(CreateMetrics.bgCheckBadge)
            }
        }
    }
}

@Composable
private fun ArtworkTile(res: Int, isSelected: Boolean, onClick: () -> Unit) {
    Box(
        modifier = Modifier
            .size(CreateMetrics.bgTileWidth, CreateMetrics.bgTileHeight)
            .clip(RoundedCornerShape(CreateMetrics.sourceTileRadius))
            .clickable(onClick = onClick)
    ) {
        Image(
            painter = painterResource(res),
            contentDescription = null,
            contentScale = ContentScale.Crop,
            modifier = Modifier
                .fillMaxSize()
                .then(
                    if (isSelected) Modifier.border(CreateMetrics.panelStroke * 2, MochiColor.logoSolid, RoundedCornerShape(CreateMetrics.sourceTileRadius))
                    else Modifier
                )
        )
        if (isSelected) {
            Box(modifier = Modifier.align(Alignment.TopEnd).padding(2.dp)) {
                CheckBadge(CreateMetrics.bgCheckBadge)
            }
        }
    }
}

// endregion

// region Key shape / key color / recent

@Composable
private fun KeyShapeSection(selected: Int, onSelect: (Int) -> Unit, modifier: Modifier = Modifier) {
    Column(modifier = modifier, verticalArrangement = Arrangement.spacedBy(8.dp)) {
        Text(text = "KEY SHAPE", style = MochiFont.title(CreateMetrics.bgHeadingSize), color = MochiColor.textPrimary, maxLines = 1)
        Row(horizontalArrangement = Arrangement.spacedBy(CreateMetrics.keyShapeGap)) {
            repeat(4) { index ->
                Box(
                    modifier = Modifier
                        .size(CreateMetrics.keyShapeChip)
                        .clip(RoundedCornerShape(CreateMetrics.keyShapeChipRadius))
                        .panelBorderSolid(RoundedCornerShape(CreateMetrics.keyShapeChipRadius))
                        .clickable { onSelect(index) },
                    contentAlignment = Alignment.Center
                ) {
                    KeyShapePreview(index, modifier = Modifier.size(CreateMetrics.keyShapeInner))
                    if (selected == index) {
                        Box(modifier = Modifier.align(Alignment.TopEnd).padding(2.dp)) {
                            CheckBadge(CreateMetrics.keyShapeCheckBadge)
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun KeyShapePreview(index: Int, modifier: Modifier = Modifier) {
    val outline = Modifier.border(CreateMetrics.panelStroke * 0.6f, MochiColor.outline.copy(alpha = 0.7f))
    when (index) {
        0 -> Box(modifier.background(MochiGradient.keyShapePreview).then(outline))
        1 -> Box(modifier.clip(RoundedCornerShape(6.dp)).background(MochiGradient.keyShapePreview).border(CreateMetrics.panelStroke * 0.6f, MochiColor.outline.copy(alpha = 0.7f), RoundedCornerShape(6.dp)))
        2 -> Box(modifier.clip(CircleShape).background(MochiGradient.keyShapePreview).border(CreateMetrics.panelStroke * 0.6f, MochiColor.outline.copy(alpha = 0.7f), CircleShape))
        else -> Box(modifier.clip(HexagonShape()).background(MochiGradient.keyShapePreview).border(CreateMetrics.panelStroke * 0.6f, MochiColor.outline.copy(alpha = 0.7f), HexagonShape()))
    }
}

@Composable
private fun KeyColorSection(modifier: Modifier = Modifier) {
    Column(modifier = modifier, verticalArrangement = Arrangement.spacedBy(8.dp)) {
        Text(text = "KEY COLOR", style = MochiFont.title(CreateMetrics.bgHeadingSize), color = MochiColor.textPrimary, maxLines = 1)
        SaturationSquare(size = CreateMetrics.keySatSize, knobBias = BiasAlignment(-0.01f, -0.07f))
        HueRail(size = CreateMetrics.keyHueSize, showKnob = true)
    }
}

@Composable
private fun RecentSection(modifier: Modifier = Modifier) {
    Column(modifier = modifier, verticalArrangement = Arrangement.spacedBy(8.dp)) {
        Text(text = "RECENT", style = MochiFont.title(CreateMetrics.recentHeadingSize), color = MochiColor.textPrimary, maxLines = 1)
        Column(verticalArrangement = Arrangement.spacedBy(CreateMetrics.swatchRowGap)) {
            MochiColor.recentSwatches.chunked(3).forEach { row ->
                Row(horizontalArrangement = Arrangement.spacedBy(CreateMetrics.swatchColGap)) {
                    row.forEach { color ->
                        Box(
                            modifier = Modifier
                                .size(CreateMetrics.swatchWidth, CreateMetrics.swatchHeight)
                                .clip(RoundedCornerShape(CreateMetrics.swatchRadius))
                                .background(color)
                        )
                    }
                }
            }
        }
        Box(
            modifier = Modifier
                .size(CreateMetrics.eyedropperSize.width, CreateMetrics.eyedropperSize.height)
                .clip(RoundedCornerShape(CreateMetrics.eyedropperRadius))
                .background(Color.White)
                .panelBorderSolid(RoundedCornerShape(CreateMetrics.eyedropperRadius)),
            contentAlignment = Alignment.Center
        ) {
            Icon(Icons.Filled.Colorize, contentDescription = null, tint = MochiColor.logoSolid, modifier = Modifier.size(CreateMetrics.eyedropperIcon))
        }
    }
}

/** White across, black down — no gesture wired in iOS either; the knob sits at a fixed measured
 * position. */
@Composable
private fun SaturationSquare(size: androidx.compose.ui.unit.DpSize, knobBias: BiasAlignment) {
    Box(
        modifier = Modifier
            .size(size.width, size.height)
            .clip(RoundedCornerShape(CreateMetrics.satRadius))
            .background(Brush.horizontalGradient(listOf(Color.White, MochiColor.pickerHue)))
    ) {
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(
                    Brush.verticalGradient(
                        colorStops = arrayOf(0.12f to Color.Black.copy(alpha = 0f), 1f to Color.Black.copy(alpha = 0.78f))
                    )
                )
        )
        Box(
            modifier = Modifier
                .align(knobBias)
                .size(CreateMetrics.knobDia)
                .border(CreateMetrics.knobStroke, Color.White, CircleShape)
        )
    }
}

@Composable
private fun HueRail(size: androidx.compose.ui.unit.DpSize, showKnob: Boolean) {
    Box(
        modifier = Modifier
            .size(size.width, size.height)
            .clip(CircleShape)
            .background(MochiGradient.hueSpectrum)
    ) {
        if (showKnob) {
            Box(
                modifier = Modifier
                    .align(Alignment.Center)
                    .size(CreateMetrics.hueKnobDia)
                    .clip(CircleShape)
                    .background(Color.White)
            )
        }
    }
}

// endregion

// region Letter color / font style

@Composable
private fun LetterColorSection(modifier: Modifier = Modifier) {
    Column(modifier = modifier, verticalArrangement = Arrangement.spacedBy(8.dp)) {
        Text(text = "LETTER COLOR", style = MochiFont.title(CreateMetrics.bgHeadingSize), color = MochiColor.textPrimary, maxLines = 1)
        SaturationSquare(size = CreateMetrics.letterSatSize, knobBias = BiasAlignment(-0.05f, -0.11f))
        HueRail(size = CreateMetrics.letterHueSize, showKnob = false)
    }
}

@Composable
private fun FontStyleSection(selected: Int, onSelect: (Int) -> Unit, modifier: Modifier = Modifier) {
    Column(modifier = modifier, verticalArrangement = Arrangement.spacedBy(8.dp)) {
        Text(text = "FONT STYLE", style = MochiFont.title(CreateMetrics.bgHeadingSize), color = MochiColor.textPrimary, maxLines = 1)
        Row(
            modifier = Modifier.horizontalScroll(rememberScrollState()),
            horizontalArrangement = Arrangement.spacedBy(CreateMetrics.fontChipGap)
        ) {
            fontStyleSpecimens.forEachIndexed { index, (res, caption) ->
                val isSelected = selected == index
                Box(
                    modifier = Modifier
                        .size(CreateMetrics.fontChipWidth, CreateMetrics.fontChipHeight)
                        .clip(RoundedCornerShape(CreateMetrics.fontChipRadius))
                        .background(Color.White)
                        .panelBorderSolid(RoundedCornerShape(CreateMetrics.fontChipRadius))
                        .clickable { onSelect(index) }
                ) {
                    Column(
                        modifier = Modifier.fillMaxSize().padding(4.dp),
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.Center
                    ) {
                        Image(
                            painter = painterResource(res),
                            contentDescription = null,
                            contentScale = ContentScale.Fit,
                            modifier = Modifier.width(CreateMetrics.fontSpecimenW).weight(1f, fill = false)
                        )
                        Text(
                            text = caption,
                            style = MochiFont.body(CreateMetrics.fontCaptionSize),
                            color = if (isSelected) MochiColor.logoSolid else MochiColor.textGreyWarm,
                            maxLines = 1
                        )
                    }
                    if (isSelected) {
                        Box(modifier = Modifier.align(Alignment.TopEnd).padding(2.dp)) {
                            CheckBadge(CreateMetrics.fontCheckBadge)
                        }
                    }
                }
            }
        }
    }
}

// endregion

// region Live preview toggle

@Composable
private fun LivePreviewCard() {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(CreateMetrics.livePanelRadius))
            .background(Color.White)
            .panelBorderSolid(RoundedCornerShape(CreateMetrics.livePanelRadius))
            .padding(12.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(
            imageVector = Icons.Filled.Visibility,
            contentDescription = null,
            tint = MochiColor.logoSolid,
            modifier = Modifier.size(CreateMetrics.liveEyeSize.height)
        )
        Spacer(modifier = Modifier.width(8.dp))
        Column(modifier = Modifier.weight(1f)) {
            Text(text = "LIVE PREVIEW", style = MochiFont.title(CreateMetrics.liveHeadingSize), color = MochiColor.logoSolid, maxLines = 1)
            Text(
                text = "See Real-Time Changes On The Keyboard Above",
                style = MochiFont.body(CreateMetrics.liveSubtitleSize),
                color = MochiColor.textGreyWarm,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
        }
        Spacer(modifier = Modifier.width(6.dp))
        Row(
            modifier = Modifier
                .height(CreateMetrics.resetCapsule.height)
                .clip(CircleShape)
                .background(Color.White)
                .panelBorderSolid(CircleShape)
                .padding(horizontal = 10.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(CreateMetrics.resetGap)
        ) {
            Icon(Icons.Filled.Refresh, contentDescription = null, tint = MochiColor.logoSolid, modifier = Modifier.size(CreateMetrics.resetIcon))
            Text(text = "Reset All", style = MochiFont.body(CreateMetrics.resetTextSize), color = MochiColor.logoSolid, maxLines = 1)
        }
    }
}

// endregion

// region Theme name / tags

/** Reproduced verbatim: the frame really does head the theme-name field "LETTER COLOR" — a
 * copy-paste slip left over from the block above it, per iOS's own comment. Not corrected here,
 * matching the project's "reproduce iOS's own quirks" precedent (Themes' duplicate "Liked Themes"
 * heading, Search's copied font names). */
@Composable
private fun ThemeNameField(value: String, onValueChange: (String) -> Unit, modifier: Modifier = Modifier) {
    Column(modifier = modifier, verticalArrangement = Arrangement.spacedBy(8.dp)) {
        Text(text = "LETTER COLOR", style = MochiFont.title(CreateMetrics.tagsHeadingSize), color = MochiColor.textPrimary, maxLines = 1)
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .height(CreateMetrics.nameFieldHeight)
                .clip(RoundedCornerShape(CreateMetrics.nameFieldRadius))
                .background(Color.White)
                .panelBorderSolid(RoundedCornerShape(CreateMetrics.nameFieldRadius))
                .padding(horizontal = 8.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(modifier = Modifier.weight(1f)) {
                BasicTextField(
                    value = value,
                    onValueChange = onValueChange,
                    singleLine = true,
                    textStyle = MochiFont.body(CreateMetrics.namePlaceholderSize).copy(color = MochiColor.textPrimary),
                    modifier = Modifier.fillMaxWidth()
                )
                if (value.isEmpty()) {
                    Text(text = "My Dreamy Theme", style = MochiFont.body(CreateMetrics.namePlaceholderSize), color = MochiColor.textGreyWarm)
                }
            }
            Icon(Icons.Filled.Edit, contentDescription = "Edit name", tint = MochiColor.logoSolid, modifier = Modifier.size(CreateMetrics.namePencilIcon))
        }
    }
}

@Composable
private fun TagsField(tags: List<String>, onRemove: (String) -> Unit, modifier: Modifier = Modifier) {
    Column(modifier = modifier, verticalArrangement = Arrangement.spacedBy(8.dp)) {
        Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(3.dp)) {
            Text(text = "TAGS", style = MochiFont.title(CreateMetrics.tagsHeadingSize), color = MochiColor.textPrimary, maxLines = 1)
            Text(text = "(Optional)", style = MochiFont.body(CreateMetrics.tagsHeadingSize), color = MochiColor.textGreyWarm, maxLines = 1)
        }
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .height(CreateMetrics.nameFieldHeight)
                .clip(RoundedCornerShape(CreateMetrics.nameFieldRadius))
                .background(Color.White)
                .panelBorderSolid(RoundedCornerShape(CreateMetrics.nameFieldRadius))
                .padding(horizontal = 6.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Row(
                modifier = Modifier.weight(1f, fill = false).horizontalScroll(rememberScrollState()),
                horizontalArrangement = Arrangement.spacedBy(4.dp)
            ) {
                tags.forEach { tag ->
                    Row(
                        modifier = Modifier
                            .height(CreateMetrics.tagPillHeight)
                            .clip(CircleShape)
                            .background(MochiGradient.tagPill)
                            .padding(horizontal = 8.dp),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(4.dp)
                    ) {
                        Text(text = tag, style = MochiFont.body(CreateMetrics.tagTextSize), color = MochiColor.textPrimary, maxLines = 1)
                        Icon(
                            imageVector = Icons.Filled.Close,
                            contentDescription = "Remove $tag",
                            tint = MochiColor.textPrimary,
                            modifier = Modifier.size(9.dp).clickable { onRemove(tag) }
                        )
                    }
                }
            }
            Spacer(modifier = Modifier.width(4.dp))
            Icon(Icons.Filled.Add, contentDescription = "Add tag", tint = MochiColor.textPrimary, modifier = Modifier.size(CreateMetrics.plusIcon))
        }
    }
}

// endregion

// region Action buttons

@Composable
private fun ActionButtonsRow(isSaving: Boolean, onSaveDraft: () -> Unit, onPublish: () -> Unit) {
    Row(horizontalArrangement = Arrangement.spacedBy(CreateMetrics.actionGutter)) {
        Column(
            modifier = Modifier
                .weight(1f)
                .height(CreateMetrics.actionBtnHeight)
                .clip(RoundedCornerShape(CreateMetrics.actionRadius))
                .background(Color.White)
                .panelBorderSolid(RoundedCornerShape(CreateMetrics.actionRadius))
                .clickable(enabled = !isSaving, onClick = onSaveDraft),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(CreateMetrics.saveIconGap)) {
                FloppyGlyph(color = MochiColor.logoSolid, strokeWidth = 3f, modifier = Modifier.size(CreateMetrics.floppySize.width, CreateMetrics.floppySize.height))
                Text(text = "Save Draft", style = MochiFont.heading(CreateMetrics.actionTitleSize), color = MochiColor.logoSolid, maxLines = 1)
            }
            Text(text = "Save Your Work For Later", style = MochiFont.body(CreateMetrics.actionSubtitleSize), color = MochiColor.textGreyWarm, maxLines = 1)
        }

        Column(
            modifier = Modifier
                .weight(1f)
                .height(CreateMetrics.actionBtnHeight)
                .clip(RoundedCornerShape(CreateMetrics.actionRadius))
                .background(MochiGradient.softButton)
                .clickable(enabled = !isSaving, onClick = onPublish),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(CreateMetrics.publishIconGap)) {
                Icon(Icons.AutoMirrored.Filled.Send, contentDescription = null, tint = MochiColor.textPrimary, modifier = Modifier.size(CreateMetrics.publishIcon))
                Text(text = "Publish Theme", style = MochiFont.heading(CreateMetrics.actionTitleSize), color = MochiColor.textPrimary, maxLines = 1)
            }
            Text(text = "Share With The Community", style = MochiFont.body(CreateMetrics.actionSubtitleSize), color = MochiColor.textPrimary, maxLines = 1)
        }
    }
}

// endregion
