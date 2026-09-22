package com.mochi.keyboard.features.themedetail

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.detectHorizontalDragGestures
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBars
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBars
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.FavoriteBorder
import androidx.compose.material.icons.filled.Palette
import androidx.compose.material.icons.filled.Star
import androidx.compose.material.icons.filled.Visibility
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.SheetState
import androidx.compose.material3.Text
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.blur
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.viewinterop.AndroidView
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.lifecycle.viewmodel.initializer
import androidx.lifecycle.viewmodel.viewModelFactory
import com.mochi.keyboard.MochiApplication
import com.mochi.keyboard.designsystem.MochiColor
import com.mochi.keyboard.designsystem.MochiFont
import com.mochi.keyboard.designsystem.MochiGradient
import com.mochi.keyboard.designsystem.MochiSpacing
import com.mochi.keyboard.data.RenderableTheme
import com.mochi.keyboard.ime.render.BufferTextDocument
import com.mochi.keyboard.ime.render.KeyboardInputEngine
import com.mochi.keyboard.ime.render.KeyboardSurfaceView
import com.mochi.keyboard.ime.render.MochiKeyboardTheme
import com.mochi.keyboard.mockdata.MockData
import com.mochi.keyboard.model.KeyboardTheme
import kotlinx.coroutines.launch
import kotlin.math.min

/**
 * Port of `ios/MochiApp/Features/ThemeDetail/ThemeDetailView.swift`, matched structurally rather
 * than reinvented: full-bleed blurred theme art behind everything, a translucent-circle top bar
 * (back + like, not back + share), a 100%-clean live keyboard card with no overlay blocking the
 * keys, a centred info row (like count • category • creator), and two pill buttons sized to the
 * card's own width. "Preview" opens [KeyboardTrySheet], the same real keyboard in a bottom sheet —
 * "Apply Theme" persists the choice via [com.mochi.keyboard.data.AppliedThemeRepository], which
 * `MochiInputMethodService` reads live (Android's IME runs in-process, so unlike iOS's App-Group
 * hand-off this needs no separate write-and-resync step).
 *
 * Every theme now gets a *real* live preview, not just the ones with their own authored render
 * document — [RenderableTheme.resolve] falls back to the nearest built-in by name, then by mood
 * (dark/night keywords), exactly like iOS's own `RenderableTheme.swift`.
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ThemeDetailScreen(
    theme: KeyboardTheme,
    modifier: Modifier = Modifier,
    onBack: () -> Unit = {},
    onUnlockPremium: () -> Unit = {},
    onCreatorClick: (String) -> Unit = {}
) {
    val application = LocalContext.current.applicationContext as MochiApplication
    // Keyed by theme.id and built inline (not the shared ViewModelFactory/rememberMochiViewModelFactory)
    // because this ViewModel needs a per-navigation argument (which theme) that a single shared
    // factory keyed only by class can't supply - see ViewModelFactory.kt's note on this.
    val viewModel: ThemeDetailViewModel = viewModel(
        key = theme.id,
        factory = viewModelFactory {
            initializer {
                ThemeDetailViewModel(
                    likeRepository = application.container.likeRepository,
                    followRepository = application.container.followRepository,
                    authRepository = application.container.authRepository,
                    billingRepository = application.container.billingRepository,
                    themeId = theme.id,
                    creatorUid = theme.creatorUid,
                    initialLikeCount = theme.likeCount
                )
            }
        }
    )
    val isLiked by viewModel.isLiked.collectAsStateWithLifecycle()
    val likeCount by viewModel.likeCount.collectAsStateWithLifecycle()
    val isUserPremium by viewModel.isUserPremium.collectAsStateWithLifecycle()
    // The content-tier flag (theme.isPremium) only says this theme requires a subscription - a
    // user who already has one isn't locked out of it, so the CTA/badge gate on both together.
    val isLocked = theme.isPremium && !isUserPremium

    val appliedThemeRepository = application.container.appliedThemeRepository
    val appliedThemeId by appliedThemeRepository.appliedThemeId.collectAsStateWithLifecycle(initialValue = null)
    val isApplied = appliedThemeId == theme.id
    val scope = rememberCoroutineScope()

    val resolved = remember(theme.id) { RenderableTheme.resolve(theme) }

    var showTrySheet by remember { mutableStateOf(false) }
    var trySheetApplied by remember { mutableStateOf(false) }

    BoxWithConstraints(
        modifier = modifier
            .fillMaxSize()
            .pointerInput(onBack) {
                // Swipe-right-to-go-back, matching iOS's DragGesture(minimumDistance: 24).
                var totalDx = 0f
                var totalDy = 0f
                detectHorizontalDragGestures(
                    onDragStart = { totalDx = 0f; totalDy = 0f },
                    onHorizontalDrag = { change, dragAmount ->
                        totalDx += dragAmount
                        totalDy += change.previousPosition.y - change.position.y
                    },
                    onDragEnd = {
                        if (totalDx > 90f && kotlin.math.abs(totalDy) < 120f) onBack()
                    }
                )
            }
    ) {
        val cardWidth = min(maxWidth.value - 40f, 400f).dp

        BlurredThemeBackground(assetName = theme.imageAssetName, modifier = Modifier.fillMaxSize())

        Column(
            modifier = Modifier
                .fillMaxSize()
                .windowInsetsPadding(WindowInsets.statusBars)
        ) {
            TopBar(onBack = onBack, isLiked = isLiked, onLikeClick = viewModel::toggleLike)

            Spacer(modifier = Modifier.height(8.dp))

            if (theme.isPremium) {
                PremiumBadge(modifier = Modifier.align(Alignment.CenterHorizontally).padding(bottom = 20.dp))
            }

            // The keyboard card: a real, typable keyboard — the same engine the IME runs — with
            // zero overlays on top of the keys, matching iOS's "100% clean" card exactly.
            LiveKeyboardPreview(
                theme = resolved.theme,
                showsTypedTextBar = false,
                modifier = Modifier
                    .align(Alignment.CenterHorizontally)
                    .width(cardWidth)
                    .clip(RoundedCornerShape(22.dp))
                    .background(Color.Black)
            )

            Spacer(modifier = Modifier.height(14.dp))

            InfoSection(theme = theme, isLiked = isLiked, likeCount = likeCount, onLikeClick = viewModel::toggleLike, isExact = resolved.isExact)

            Spacer(modifier = Modifier.height(16.dp))

            ButtonsSection(
                cardWidth = cardWidth,
                isLocked = isLocked,
                isApplied = isApplied,
                onPreview = { trySheetApplied = false; showTrySheet = true },
                onUnlock = onUnlockPremium,
                onApply = {
                    scope.launch {
                        appliedThemeRepository.apply(theme.id)
                        trySheetApplied = true
                        showTrySheet = true
                    }
                },
                onAppliedTap = { trySheetApplied = false; showTrySheet = true }
            )

            Spacer(modifier = Modifier.height(60.dp))
        }
    }

    if (showTrySheet) {
        val sheetState: SheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)
        ModalBottomSheet(
            onDismissRequest = { showTrySheet = false },
            sheetState = sheetState,
            containerColor = Color(0xFF1A1A1A),
            dragHandle = null
        ) {
            KeyboardTrySheetContent(
                theme = resolved.theme,
                themeName = theme.name,
                applied = trySheetApplied,
                isExact = resolved.isExact,
                onDone = { showTrySheet = false }
            )
        }
    }
}

@Composable
private fun BlurredThemeBackground(assetName: String, modifier: Modifier = Modifier) {
    val context = LocalContext.current
    val resId = remember(assetName) {
        context.resources.getIdentifier(assetName, "drawable", context.packageName).takeIf { it != 0 }
    }
    if (resId != null) {
        Box(modifier = modifier) {
            Image(
                painter = painterResource(resId),
                contentDescription = null,
                contentScale = ContentScale.Crop,
                // API 31+ only - androidx.compose.ui.draw.blur silently no-ops below that, which
                // is an acceptable degrade (the darkening scrim below still keeps text legible).
                modifier = Modifier.fillMaxSize().blur(40.dp)
            )
            Box(modifier = Modifier.fillMaxSize().background(Color.Black.copy(alpha = 0.45f)))
        }
    } else {
        Box(modifier = modifier.background(MochiGradient.background))
    }
}

@Composable
private fun TopBar(onBack: () -> Unit, isLiked: Boolean, onLikeClick: () -> Unit) {
    Row(
        modifier = Modifier.fillMaxWidth().padding(horizontal = 20.dp).padding(top = 8.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        TranslucentCircleButton(icon = Icons.AutoMirrored.Filled.ArrowBack, tint = Color.White, onClick = onBack)
        TranslucentCircleButton(
            icon = if (isLiked) Icons.Filled.Favorite else Icons.Filled.FavoriteBorder,
            tint = if (isLiked) MochiColor.heart else Color.White,
            onClick = onLikeClick
        )
    }
}

@Composable
private fun TranslucentCircleButton(icon: androidx.compose.ui.graphics.vector.ImageVector, tint: Color, onClick: () -> Unit) {
    Box(
        modifier = Modifier
            .size(42.dp)
            .clip(CircleShape)
            .background(Color.Black.copy(alpha = 0.35f))
            .clickable(onClick = onClick),
        contentAlignment = Alignment.Center
    ) {
        Icon(imageVector = icon, contentDescription = null, tint = tint, modifier = Modifier.size(18.dp))
    }
}

@Composable
private fun PremiumBadge(modifier: Modifier = Modifier) {
    Row(
        modifier = modifier
            .clip(RoundedCornerShape(percent = 50))
            .background(MochiColor.premiumTag)
            .padding(horizontal = 10.dp, vertical = 5.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(4.dp)
    ) {
        Icon(imageVector = Icons.Filled.Star, contentDescription = null, tint = Color.White, modifier = Modifier.size(9.dp))
        Text(text = "Premium", style = MochiFont.caption(10.sp), color = Color.White)
    }
}

@Composable
private fun InfoSection(theme: KeyboardTheme, isLiked: Boolean, likeCount: Int, onLikeClick: () -> Unit, isExact: Boolean) {
    Column(
        modifier = Modifier.fillMaxWidth().padding(horizontal = 24.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = theme.name,
            style = MochiFont.title(22.sp),
            color = Color.White,
            textAlign = androidx.compose.ui.text.style.TextAlign.Center
        )

        Spacer(modifier = Modifier.height(6.dp))

        Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(4.dp),
                modifier = Modifier.clickable(onClick = onLikeClick)
            ) {
                Icon(
                    imageVector = if (isLiked) Icons.Filled.Favorite else Icons.Filled.FavoriteBorder,
                    contentDescription = "Like",
                    tint = if (isLiked) MochiColor.heart else Color.White.copy(alpha = 0.9f),
                    modifier = Modifier.size(14.dp)
                )
                Text(text = likeCount.formattedShort(), style = MochiFont.caption(12.sp), color = Color.White.copy(alpha = 0.9f))
            }
            Text(text = "•", style = MochiFont.caption(12.sp), color = Color.White.copy(alpha = 0.4f))
            Text(text = theme.category.uppercase(), style = MochiFont.caption(12.sp), color = Color.White.copy(alpha = 0.75f))
            if (theme.creatorName.isNotEmpty()) {
                Text(text = "•", style = MochiFont.caption(12.sp), color = Color.White.copy(alpha = 0.4f))
                Text(
                    text = if (theme.creatorName.startsWith("by ")) theme.creatorName else "by ${theme.creatorName}",
                    style = MochiFont.caption(12.sp),
                    color = Color.White.copy(alpha = 0.75f)
                )
            }
        }

        if (!isExact) {
            Spacer(modifier = Modifier.height(2.dp))
            Text(
                text = "Preview shown with a matching Mochi theme — this design's own artwork is still in production.",
                style = MochiFont.caption(11.sp),
                color = Color.White.copy(alpha = 0.70f),
                textAlign = androidx.compose.ui.text.style.TextAlign.Center
            )
        }
    }
}

@Composable
private fun ButtonsSection(
    cardWidth: androidx.compose.ui.unit.Dp,
    isLocked: Boolean,
    isApplied: Boolean,
    onPreview: () -> Unit,
    onUnlock: () -> Unit,
    onApply: () -> Unit,
    onAppliedTap: () -> Unit
) {
    Row(
        modifier = Modifier.width(cardWidth).padding(horizontal = MochiSpacing.md),
        horizontalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        ThemeDetailActionButton(
            title = "Preview",
            icon = Icons.Filled.Visibility,
            filled = false,
            modifier = Modifier.weight(1f),
            onClick = onPreview
        )
        when {
            isLocked -> ThemeDetailActionButton(
                title = "Unlock Premium", icon = Icons.Filled.Star, filled = true,
                modifier = Modifier.weight(1f), onClick = onUnlock
            )
            isApplied -> ThemeDetailActionButton(
                title = "Applied", icon = Icons.Filled.Check, filled = true,
                modifier = Modifier.weight(1f), onClick = onAppliedTap
            )
            else -> ThemeDetailActionButton(
                title = "Apply Theme", icon = Icons.Filled.Palette, filled = true,
                modifier = Modifier.weight(1f), onClick = onApply
            )
        }
    }
}

@Composable
private fun ThemeDetailActionButton(
    title: String,
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    filled: Boolean,
    modifier: Modifier = Modifier,
    onClick: () -> Unit
) {
    Row(
        modifier = modifier
            .height(48.dp)
            .clip(CircleShape)
            .background(if (filled) MochiGradient.softButton else androidx.compose.ui.graphics.Brush.linearGradient(listOf(Color.White, Color.White)))
            .clickable(onClick = onClick),
        horizontalArrangement = Arrangement.spacedBy(6.dp, Alignment.CenterHorizontally),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(
            imageVector = icon,
            contentDescription = null,
            tint = if (filled) Color.White else MochiColor.logoSolid,
            modifier = Modifier.size(16.dp)
        )
        Text(
            text = title,
            style = MochiFont.body(14.sp),
            color = if (filled) Color.White else MochiColor.logoSolid,
            maxLines = 1
        )
    }
}

/** A real, typable keyboard — the same [KeyboardSurfaceView]/[KeyboardInputEngine] pair
 * `MochiInputMethodService` runs, driven here by an in-memory [BufferTextDocument] instead of a
 * real [android.view.inputmethod.InputConnection] since there is no host text field to type into.
 * What you see here is what the keyboard actually renders — not a second, easily-drifting copy. */
@Composable
private fun LiveKeyboardPreview(theme: MochiKeyboardTheme, showsTypedTextBar: Boolean, modifier: Modifier = Modifier) {
    var typed by remember(theme.id) { mutableStateOf("") }
    val document = remember(theme.id) { BufferTextDocument().apply { onChange = { typed = it } } }
    val engine = remember(theme.id) { KeyboardInputEngine(document) }

    Column(modifier = modifier) {
        if (showsTypedTextBar) {
            Box(
                modifier = Modifier.fillMaxWidth().height(56.dp).padding(horizontal = MochiSpacing.md),
                contentAlignment = Alignment.CenterStart
            ) {
                Text(
                    text = typed.ifEmpty { "Tap the keys to try this theme…" },
                    style = MochiFont.body(17.sp),
                    color = if (typed.isEmpty()) Color.White.copy(alpha = 0.35f) else Color.White,
                    maxLines = 3
                )
            }
        }
        AndroidView(
            factory = { context ->
                KeyboardSurfaceView(context, theme, includesNextKeyboardKey = false).apply {
                    onAction = { action -> engine.handle(action) }
                    onInsertText = { text -> engine.insert(text) }
                    engine.onStateChange = { state -> shiftState = state }
                    engine.onPlaneChange = { plane -> setPlane(plane) }
                }
            },
            modifier = Modifier.fillMaxWidth()
        )
    }
}

/** Port of iOS's `KeyboardTrySheet` — the payoff of tapping Preview or Apply: the real keyboard,
 * full width, in a bottom sheet, with a typed-text field above it. */
@Composable
private fun KeyboardTrySheetContent(theme: MochiKeyboardTheme, themeName: String, applied: Boolean, isExact: Boolean, onDone: () -> Unit) {
    Column(modifier = Modifier.fillMaxWidth().windowInsetsPadding(WindowInsets.navigationBars)) {
        Row(
            modifier = Modifier.fillMaxWidth().padding(horizontal = MochiSpacing.md).padding(top = 10.dp, bottom = 6.dp),
            horizontalArrangement = Arrangement.End
        ) {
            Text(
                text = "Done",
                style = MochiFont.body(15.sp),
                color = Color.White,
                modifier = Modifier.clickable(onClick = onDone)
            )
        }

        if (applied) {
            TrySheetBanner(icon = Icons.Filled.Check, tint = MochiColor.purple, text = "“$themeName” is now your Mochi keyboard.")
        }
        if (!isExact) {
            TrySheetBanner(icon = Icons.Filled.Palette, tint = Color.White.copy(alpha = 0.7f), text = "Preview shown with a matching Mochi theme — this design's own artwork is still in production.")
        }

        LiveKeyboardPreview(theme = theme, showsTypedTextBar = true, modifier = Modifier.fillMaxWidth())
    }
}

@Composable
private fun TrySheetBanner(icon: androidx.compose.ui.graphics.vector.ImageVector, tint: Color, text: String) {
    Row(
        modifier = Modifier.fillMaxWidth().padding(horizontal = MochiSpacing.md).padding(vertical = 8.dp),
        horizontalArrangement = Arrangement.spacedBy(8.dp),
        verticalAlignment = Alignment.Top
    ) {
        Icon(imageVector = icon, contentDescription = null, tint = tint, modifier = Modifier.size(18.dp))
        Text(text = text, style = MochiFont.caption(12.sp), color = Color.White.copy(alpha = 0.85f))
    }
}

private fun Int.formattedShort(): String = when {
    this >= 1_000_000 -> "%.1fM".format(this / 1_000_000.0)
    this >= 1_000 -> "%.1fK".format(this / 1_000.0)
    else -> "$this"
}

@Preview(showBackground = true, widthDp = 393, heightDp = 852)
@Composable
private fun ThemeDetailScreenPreview() {
    ThemeDetailScreen(theme = MockData.popularThemes.first())
}
