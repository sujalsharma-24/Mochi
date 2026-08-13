package com.mochi.keyboard.features.profile

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
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
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material.icons.filled.Block
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.Group
import androidx.compose.material.icons.filled.MoreVert
import androidx.compose.material.icons.filled.PersonAdd
import androidx.compose.material.icons.filled.PersonRemove
import androidx.compose.material.icons.filled.PhotoCamera
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.filled.Verified
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.lifecycle.viewmodel.initializer
import androidx.lifecycle.viewmodel.viewModelFactory
import com.mochi.keyboard.MochiApplication
import com.mochi.keyboard.R
import com.mochi.keyboard.components.DownloadGlyph
import com.mochi.keyboard.components.KeyboardPreviewPlaceholder
import com.mochi.keyboard.components.PencilGlyph
import com.mochi.keyboard.components.SparkleField
import com.mochi.keyboard.components.TripleDot
import com.mochi.keyboard.designsystem.MochiColor
import com.mochi.keyboard.designsystem.MochiFont
import com.mochi.keyboard.designsystem.MochiGradient
import com.mochi.keyboard.designsystem.MochiRadius
import com.mochi.keyboard.designsystem.MochiSpacing
import com.mochi.keyboard.mockdata.MockData
import com.mochi.keyboard.model.KeyboardTheme
import com.mochi.keyboard.model.ProfileCreation
import com.mochi.keyboard.model.ProfileFollowRow
import com.mochi.keyboard.model.ProfileLikedTheme
import com.mochi.keyboard.model.ProfileSummary
import com.mochi.keyboard.model.formattedCompact

/** Assets this page draws directly by name (docs/figma/3.png), separate from ThemeArt/FontArtCard's
 * catalogs: this page never falls back to a generated placeholder — every tile here has real art —
 * and draws it flat/clipped rather than with those components' purple-tinted card shadow, since the
 * shadow here lives on the whole card instead (`.shadow(color: .black.opacity(0.05), ...)`). */
private val profileArt: Map<String, Int> = mapOf(
    "profile_art_pastel_rainbow" to R.drawable.profile_art_pastel_rainbow,
    "theme_forest" to R.drawable.theme_forest,
    "theme_pastel_pink_sky" to R.drawable.theme_pastel_pink_sky,
    "font_typewriter_classic" to R.drawable.font_typewriter_classic,
    "theme_fantasy_castle_night" to R.drawable.theme_fantasy_castle_night,
    "theme_kawaii_boba" to R.drawable.theme_kawaii_boba,
    "theme_cozy_sakura_cafe" to R.drawable.theme_cozy_sakura_cafe,
    "liked_pastel_pink_sky" to R.drawable.liked_pastel_pink_sky,
    "liked_pastel_dream" to R.drawable.liked_pastel_dream,
    "liked_pastel_rainbow" to R.drawable.liked_pastel_rainbow
)

@Composable
private fun ProfileArtImage(assetName: String, modifier: Modifier = Modifier) {
    val resId = profileArt[assetName]
    when {
        resId != null -> Image(painter = painterResource(resId), contentDescription = null, contentScale = ContentScale.Crop, modifier = modifier)
        // Real Firestore themes (ThemeDocument.toKeyboardTheme's "firestore:$id" convention) have no
        // matching entry in profileArt above - same generated-placeholder fallback ThemeArt.kt uses
        // elsewhere, just without ThemeArt's own shadow/clip since this card already applies its own.
        assetName.startsWith("firestore:") -> KeyboardPreviewPlaceholder(seed = assetName, modifier = modifier, cornerRadius = 0.dp)
    }
}

private fun KeyboardTheme.toProfileCreation(): ProfileCreation =
    ProfileCreation(id = id, name = name, kind = "Theme", imageAssetName = imageAssetName, likes = likeCount, downloads = downloadCount)

/** Ported from ios/MochiApp/Features/Profile/ProfileView.swift. iOS lays this page out as one
 * absolute canvas keyed to Figma's own pixel coordinates (no Mac to preview against, so every
 * figure had to be checkable straight against the export) — Android has a working device/Preview
 * loop, so this reproduces the same content, order, sizes and colors as an ordinary flow layout
 * instead of porting the coordinate math verbatim.
 *
 * [uid] null means "the signed-in user's own profile" (the only mode this screen originally had);
 * a real uid views someone else's - Follow/Block replace Edit Profile/the premium banners in that
 * mode, and MY DOWNLOADS / the Followers-Following card disappear entirely rather than attributing
 * MockData to a specific real person (see ProfileViewModel's doc comment on why those two sections
 * have no real-data path at all - no schema for either exists in firestore.rules). */
@Composable
fun ProfileScreen(
    modifier: Modifier = Modifier,
    uid: String? = null,
    onBack: () -> Unit = {},
    onSettingsClick: () -> Unit = {},
    onPaywallClick: () -> Unit = {}
) {
    val application = LocalContext.current.applicationContext as MochiApplication
    val viewModel: ProfileViewModel = viewModel(
        key = uid ?: "own-profile",
        factory = viewModelFactory {
            initializer {
                ProfileViewModel(
                    userRepository = application.container.userRepository,
                    themeRepository = application.container.themeRepository,
                    likeRepository = application.container.likeRepository,
                    followRepository = application.container.followRepository,
                    blockRepository = application.container.blockRepository,
                    authRepository = application.container.authRepository,
                    billingRepository = application.container.billingRepository,
                    profileUid = uid
                )
            }
        }
    )
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    val isPremium by viewModel.isPremium.collectAsStateWithLifecycle()

    when (val state = uiState) {
        is ProfileUiState.Data -> ProfileScreenContent(
            modifier = modifier,
            profile = state.summary,
            isOwnProfile = state.isOwnProfile,
            isFollowing = state.isFollowing,
            isBlocked = state.isBlocked,
            isPremium = isPremium,
            creations = state.creations.map { it.toProfileCreation() },
            likedThemes = state.likedThemes.map { ProfileLikedTheme(it.id, it.name, it.creatorName, it.imageAssetName, it.likeCount) },
            onBack = onBack,
            onSettingsClick = onSettingsClick,
            onPaywallClick = onPaywallClick,
            onToggleFollow = viewModel::toggleFollow,
            onToggleBlock = viewModel::toggleBlock
        )
        is ProfileUiState.Error -> if (uid == null) {
            OwnProfileMockFallback(onBack, onSettingsClick, onPaywallClick)
        } else {
            ProfileMessageState(message = state.message, onBack = onBack)
        }
        ProfileUiState.Loading -> if (uid == null) {
            OwnProfileMockFallback(onBack, onSettingsClick, onPaywallClick)
        } else {
            ProfileMessageState(message = null, onBack = onBack)
        }
    }
}

/** Loading/Error on the OWN profile route falls back to MockData, same convention Home/Themes/
 * Community already use - the pixel-tuned layout never breaks for the screen every user hits on
 * every launch. Viewing someone else's profile has no such stand-in (see ProfileMessageState). */
@Composable
private fun OwnProfileMockFallback(onBack: () -> Unit, onSettingsClick: () -> Unit, onPaywallClick: () -> Unit) {
    ProfileScreenContent(
        profile = MockData.profile,
        isOwnProfile = true,
        isFollowing = false,
        isBlocked = false,
        isPremium = false,
        creations = MockData.profileCreations,
        likedThemes = MockData.profileLikedThemes,
        onBack = onBack,
        onSettingsClick = onSettingsClick,
        onPaywallClick = onPaywallClick,
        onToggleFollow = {},
        onToggleBlock = {}
    )
}

@Composable
private fun ProfileMessageState(message: String?, onBack: () -> Unit) {
    Box(modifier = Modifier.fillMaxSize().background(MochiGradient.background), contentAlignment = Alignment.Center) {
        Box(modifier = Modifier.align(Alignment.TopStart).padding(MochiSpacing.md)) { BackButton(onBack) }
        if (message != null) {
            Text(text = message, style = MochiFont.body(14.sp), color = MochiColor.textSecondary, modifier = Modifier.padding(horizontal = MochiSpacing.xl))
        } else {
            CircularProgressIndicator(color = MochiColor.logoSolid)
        }
    }
}

@Composable
private fun ProfileScreenContent(
    modifier: Modifier = Modifier,
    profile: ProfileSummary,
    isOwnProfile: Boolean,
    isFollowing: Boolean,
    isBlocked: Boolean,
    isPremium: Boolean,
    creations: List<ProfileCreation>,
    likedThemes: List<ProfileLikedTheme>,
    onBack: () -> Unit,
    onSettingsClick: () -> Unit = {},
    onPaywallClick: () -> Unit,
    onToggleFollow: () -> Unit,
    onToggleBlock: () -> Unit
) {
    var filter by remember { mutableStateOf("Theme") }

    Box(modifier = modifier.fillMaxSize()) {
        Image(
            painter = painterResource(R.drawable.profile_background),
            contentDescription = null,
            contentScale = ContentScale.FillWidth,
            modifier = Modifier.fillMaxWidth()
        )
        SparkleField(modifier = Modifier.fillMaxWidth().height(500.dp))

        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = MochiSpacing.md)
                .padding(top = MochiSpacing.lg, bottom = 100.dp),
            verticalArrangement = Arrangement.spacedBy(MochiSpacing.lg)
        ) {
            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                BackButton(onBack)
                if (isOwnProfile) {
                    SettingsButton(onSettingsClick)
                }
            }
            ProfileHeader(profile, isOwnProfile, isFollowing, isBlocked, onToggleFollow, onToggleBlock)
            // Both banners used to render unconditionally regardless of real subscription status -
            // "You're on Premium Plan" and "Go Premium" showing together for the same user at once.
            // Real isPremium (BillingRepository, via ProfileViewModel) now picks exactly one.
            if (isOwnProfile && isPremium) {
                PremiumBanner(
                    title = "Mochi Pro",
                    titleColor = MochiColor.logoSolid,
                    subtitleLines = listOf("You're on Premium Plan  Enjoy all premium", "features and unlimited creations."),
                    onUpgradeClick = onPaywallClick
                )
            }
            CreationsSection(creations, isOwnProfile)
            if (isOwnProfile) {
                DownloadsSection(filter) { filter = it }
            }
            Row(horizontalArrangement = Arrangement.spacedBy(MochiSpacing.sm)) {
                LikedThemesCard(likedThemes, modifier = Modifier.weight(1f))
                if (isOwnProfile) {
                    FollowersCard(modifier = Modifier.weight(1f))
                }
            }
            if (isOwnProfile && !isPremium) {
                PremiumBanner(
                    title = "Go Premium",
                    subtitleLines = listOf("Unlock all premium themes, fonts, and features."),
                    onUpgradeClick = onPaywallClick
                )
            }
        }
    }
}

/** The disc carries the same short pink->orchid ramp the Themes header discs do, with a black
 * glyph on top — not the flat primaryButton-gradient white-glyph circle Android had before. */
@Composable
private fun BackButton(onBack: () -> Unit) {
    Box(
        modifier = Modifier.size(44.dp).clip(CircleShape).background(MochiGradient.themeCircleButton).clickable(onClick = onBack),
        contentAlignment = Alignment.Center
    ) {
        Icon(imageVector = Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back", tint = MochiColor.textPrimary)
    }
}

/** No Figma reference has a visible settings entry point on this screen (docs/figma/3.png), but
 * the feature spec (Screen 8 - Profile) lists "Settings shortcut" for the own-profile route, and
 * onSettingsClick was already threaded as far as this composable's parameter list without ever
 * being wired to a tap target - this is that missing wiring, placed opposite BackButton rather
 * than invented mid-layout. */
@Composable
private fun SettingsButton(onClick: () -> Unit) {
    Box(
        modifier = Modifier.size(44.dp).clip(CircleShape).background(MochiGradient.themeCircleButton).clickable(onClick = onClick),
        contentAlignment = Alignment.Center
    ) {
        Icon(imageVector = Icons.Filled.Settings, contentDescription = "Settings", tint = MochiColor.textPrimary)
    }
}

@Composable
private fun ProfileHeader(
    profile: ProfileSummary,
    isOwnProfile: Boolean,
    isFollowing: Boolean,
    isBlocked: Boolean,
    onToggleFollow: () -> Unit,
    onToggleBlock: () -> Unit
) {
    Row(verticalAlignment = Alignment.Top, horizontalArrangement = Arrangement.spacedBy(MochiSpacing.md)) {
        Box {
            Image(
                painter = painterResource(R.drawable.avatar_mochi_creator),
                contentDescription = profile.displayName,
                contentScale = ContentScale.Crop,
                modifier = Modifier.size(96.dp).clip(CircleShape)
            )
            // The camera badge overlaps the ring's lower-right, matching the fraction ProfileMetrics
            // measures off the export (cameraCentreFraction ~0.79, 0.80 of the avatar). Own profile
            // only - changing someone else's photo isn't a real action.
            if (isOwnProfile) {
                Box(
                    modifier = Modifier
                        .align(Alignment.BottomEnd)
                        .padding(end = 4.dp, bottom = 2.dp)
                        .size(29.dp)
                        .clip(CircleShape)
                        .background(MochiColor.cardBackground),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(imageVector = Icons.Filled.PhotoCamera, contentDescription = "Change photo", tint = MochiColor.logoSolid, modifier = Modifier.size(14.dp))
                }
            }
        }
        Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(3.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                Text(text = profile.displayName, style = MochiFont.itemName(20.sp), color = MochiColor.textPrimary)
                if (profile.isVerified) {
                    Image(painter = painterResource(R.drawable.icon_verified), contentDescription = "Verified", modifier = Modifier.size(17.dp))
                }
            }
            if (profile.handle.isNotBlank()) {
                Text(text = profile.handle, style = MochiFont.itemName(13.sp), color = MochiColor.creatorLink)
            }
            Spacer(modifier = Modifier.height(2.dp))
            if (profile.bio.isNotBlank()) {
                Text(text = profile.bio, style = MochiFont.body(11.sp), color = MochiColor.textGreyWarm)
            } else if (isOwnProfile) {
                // Figma's explicit break: "...themes to" / "make typing more fun!" — a naive wrap
                // would have set "...keyboard themes" / "to make typing more fun!" instead. Kept as
                // the own-profile placeholder copy since a real bio field exists but is usually blank
                // (no bio-editing UI has been built yet - EditProfileButton below is still a no-op).
                Text(text = "Creating cute & colorful keyboard themes to", style = MochiFont.body(11.sp), color = MochiColor.textGreyWarm)
                Text(text = "make typing more fun!", style = MochiFont.body(11.sp), color = MochiColor.textGreyWarm)
            }
            Spacer(modifier = Modifier.height(6.dp))
            Row(horizontalArrangement = Arrangement.spacedBy(MochiSpacing.lg)) {
                profile.stats.forEach { StatColumn(it.value.formattedCompact(), it.label) }
            }
        }
    }
    Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.End, verticalAlignment = Alignment.CenterVertically) {
        if (isOwnProfile) {
            EditProfileButton()
        } else {
            Row(horizontalArrangement = Arrangement.spacedBy(MochiSpacing.sm)) {
                BlockButton(isBlocked = isBlocked, onClick = onToggleBlock)
                FollowButton(isFollowing = isFollowing, onClick = onToggleFollow)
            }
        }
    }
}

@Composable
private fun StatColumn(value: String, label: String) {
    Column {
        Text(text = value, style = MochiFont.itemName(14.sp), color = MochiColor.textPrimary)
        Text(text = label, style = MochiFont.body(8.sp), color = MochiColor.textGreyWarm)
    }
}

/** White capsule with a 2px editProfileStroke outline; the pencil and label share editProfileInk,
 * a separate (deeper) color from the stroke — mixing the two read visibly muddy in an earlier pass. */
@Composable
private fun EditProfileButton() {
    Row(
        modifier = Modifier
            .clip(RoundedCornerShape(MochiRadius.pill))
            .background(MochiColor.cardBackground)
            .border(1.dp, MochiColor.editProfileStroke, RoundedCornerShape(MochiRadius.pill))
            .padding(horizontal = 14.dp, vertical = 8.dp)
            .clickable {},
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(5.dp)
    ) {
        PencilGlyph(color = MochiColor.editProfileInk, strokeWidth = 1.3f, bodyHalfWidth = 0.105f, modifier = Modifier.size(width = 13.dp, height = 11.dp))
        Text(text = "Edit Profile", style = MochiFont.itemName(11.sp), color = MochiColor.editProfileInk)
    }
}

/** No Figma/iOS source for "viewing someone else's profile" exists (see ProfileViewModel's doc
 * comment - iOS has no block feature at all), so this pill matches EditProfileButton's shape/scale
 * rather than following a design reference. Filled solid once following, matching the outline-vs-
 * filled convention Community's creator-tile follow pill already uses. */
@Composable
private fun FollowButton(isFollowing: Boolean, onClick: () -> Unit) {
    Row(
        modifier = Modifier
            .clip(RoundedCornerShape(MochiRadius.pill))
            .then(
                if (isFollowing) Modifier.border(1.dp, MochiColor.editProfileStroke, RoundedCornerShape(MochiRadius.pill))
                else Modifier.background(MochiGradient.softButton)
            )
            .clickable(onClick = onClick)
            .padding(horizontal = 14.dp, vertical = 8.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(5.dp)
    ) {
        Icon(
            imageVector = if (isFollowing) Icons.Filled.PersonRemove else Icons.Filled.PersonAdd,
            contentDescription = null,
            tint = if (isFollowing) MochiColor.editProfileInk else MochiColor.textPrimary,
            modifier = Modifier.size(14.dp)
        )
        Text(
            text = if (isFollowing) "Following" else "Follow",
            style = MochiFont.itemName(11.sp),
            color = if (isFollowing) MochiColor.editProfileInk else MochiColor.textPrimary
        )
    }
}

@Composable
private fun BlockButton(isBlocked: Boolean, onClick: () -> Unit) {
    var showConfirm by remember { mutableStateOf(false) }
    Box(
        modifier = Modifier
            .size(36.dp)
            .clip(CircleShape)
            .border(1.dp, MochiColor.editProfileStroke, CircleShape)
            .clickable { if (isBlocked) onClick() else showConfirm = true },
        contentAlignment = Alignment.Center
    ) {
        Icon(
            imageVector = Icons.Filled.Block,
            contentDescription = if (isBlocked) "Unblock" else "Block",
            tint = if (isBlocked) MochiColor.heart else MochiColor.editProfileInk,
            modifier = Modifier.size(16.dp)
        )
    }
    if (showConfirm) {
        AlertDialog(
            onDismissRequest = { showConfirm = false },
            title = { Text("Block this creator?") },
            text = { Text("They won't be notified. You can unblock them from their profile at any time.") },
            confirmButton = {
                TextButton(onClick = { showConfirm = false; onClick() }) { Text("Block") }
            },
            dismissButton = {
                TextButton(onClick = { showConfirm = false }) { Text("Cancel") }
            }
        )
    }
}

/** White card, outlined (no shadow) — the "Mochi Pro" title is flat logoSolid; "Go Premium" is
 * painted through softButton's gradient via a Brush TextStyle. */
@Composable
private fun PremiumBanner(title: String, subtitleLines: List<String>, onUpgradeClick: () -> Unit, titleColor: Color? = null) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(MochiRadius.card))
            .background(MochiColor.cardBackground)
            .border(1.dp, MochiColor.outline, RoundedCornerShape(MochiRadius.card))
            .padding(MochiSpacing.md),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Image(painter = painterResource(R.drawable.mascot_mochi_pro), contentDescription = null, modifier = Modifier.size(48.dp))
        Column(modifier = Modifier.weight(1f).padding(horizontal = MochiSpacing.sm), verticalArrangement = Arrangement.spacedBy(2.dp)) {
            if (titleColor != null) {
                Text(text = title, style = MochiFont.heading(17.sp), color = titleColor)
            } else {
                Text(text = title, style = MochiFont.heading(17.sp).copy(brush = MochiGradient.softButton))
            }
            subtitleLines.forEach { line -> Text(text = line, style = MochiFont.body(9.sp), color = MochiColor.textMuted) }
        }
        Row(
            modifier = Modifier
                .clip(RoundedCornerShape(MochiRadius.pill))
                .background(MochiGradient.softButton)
                .clickable(onClick = onUpgradeClick)
                .padding(horizontal = 12.dp, vertical = 8.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(5.dp)
        ) {
            Image(painter = painterResource(R.drawable.icon_crown), contentDescription = null, modifier = Modifier.size(width = 15.dp, height = 10.dp))
            Text(text = "Upgrade Plan", style = MochiFont.itemName(9.sp), color = MochiColor.textPrimary)
            Icon(imageVector = Icons.AutoMirrored.Filled.KeyboardArrowRight, contentDescription = null, tint = MochiColor.textPrimary, modifier = Modifier.size(12.dp))
        }
    }
}

/** MY CREATIONS strip. `creations` is always real data once this composable is reached (the
 * Loading/Error states substitute MockData at the whole-screen level via OwnProfileMockFallback,
 * not here) - a genuinely empty list is real state (this creator hasn't published anything yet),
 * shown as an empty message rather than masked with MockData, same convention Community's
 * "Following"/"My Likes" tabs established. Real theme count can be anything, not always 4, so this
 * no longer assumes the Figma 4-tile edge-to-edge row - `weight(1f)` still divides evenly for any
 * count without a horizontal scroll. */
@Composable
private fun CreationsSection(creations: List<ProfileCreation>, isOwnProfile: Boolean) {
    Column(verticalArrangement = Arrangement.spacedBy(MochiSpacing.sm)) {
        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
            Text(text = if (isOwnProfile) "MY CREATIONS" else "CREATIONS", style = MochiFont.title(11.sp), color = MochiColor.textPrimary)
            if (creations.isNotEmpty()) {
                Text(text = "see all", style = MochiFont.body(11.sp), color = MochiColor.textPrimary)
            }
        }
        if (creations.isEmpty()) {
            Text(
                text = if (isOwnProfile) "You haven't published any themes yet." else "No published themes yet.",
                style = MochiFont.body(11.sp),
                color = MochiColor.textGreyWarm
            )
        } else {
            Row(horizontalArrangement = Arrangement.spacedBy(MochiSpacing.sm)) {
                creations.take(4).forEach { item -> CreationCard(item, Modifier.weight(1f)) }
            }
        }
    }
}

@Composable
private fun CreationCard(item: ProfileCreation, modifier: Modifier = Modifier) {
    val shape = RoundedCornerShape(MochiRadius.card)
    Column(
        modifier = modifier
            .shadow(4.dp, shape, ambientColor = Color.Black.copy(alpha = 0.05f), spotColor = Color.Black.copy(alpha = 0.05f))
            .clip(shape)
            .background(MochiColor.cardBackground)
    ) {
        Box {
            ProfileArtImage(item.imageAssetName, modifier = Modifier.fillMaxWidth().aspectRatio(1f))
            Box(
                modifier = Modifier.align(Alignment.TopEnd).padding(6.dp).size(20.dp).clip(CircleShape).background(MochiColor.cardBackground),
                contentAlignment = Alignment.Center
            ) {
                TripleDot(color = MochiColor.textPrimary, modifier = Modifier.width(11.dp).height(2.5.dp))
            }
        }
        Column(modifier = Modifier.padding(6.dp), verticalArrangement = Arrangement.spacedBy(2.dp)) {
            Text(text = item.name, style = MochiFont.itemName(9.sp), color = MochiColor.textPrimary, maxLines = 1, overflow = TextOverflow.Ellipsis)
            Text(text = item.kind, style = MochiFont.itemName(8.5.sp), color = MochiColor.creatorLink)
            Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                Icon(imageVector = Icons.Filled.Favorite, contentDescription = null, tint = MochiColor.heart, modifier = Modifier.size(9.dp))
                Spacer(modifier = Modifier.width(3.dp))
                Text(text = item.likes.formattedCompact(), style = MochiFont.itemName(8.sp), color = MochiColor.textPrimary, modifier = Modifier.weight(1f))
                DownloadGlyph(color = MochiColor.downloadGlyph, strokeWidth = 1.3f, modifier = Modifier.size(9.dp))
                Spacer(modifier = Modifier.width(3.dp))
                Text(text = item.downloads?.formattedCompact().orEmpty(), style = MochiFont.itemName(8.sp), color = MochiColor.textPrimary)
            }
        }
    }
}

@Composable
private fun DownloadsSection(selected: String, onSelect: (String) -> Unit) {
    Column(verticalArrangement = Arrangement.spacedBy(MochiSpacing.sm)) {
        Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(MochiSpacing.sm)) {
            Text(text = "MY DOWNLOADS", style = MochiFont.title(11.sp), color = MochiColor.textPrimary)
            Spacer(modifier = Modifier.weight(1f))
            listOf("Theme", "Font").forEach { option ->
                val isSelected = option == selected
                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(MochiRadius.pill))
                        .then(
                            if (isSelected) Modifier.background(MochiColor.logoSolid)
                            else Modifier.border(1.dp, MochiColor.logoSolid, RoundedCornerShape(MochiRadius.pill))
                        )
                        .clickable { onSelect(option) }
                        .padding(horizontal = 10.dp, vertical = 5.dp)
                ) {
                    Text(text = option, style = MochiFont.itemName(9.sp), color = if (isSelected) MochiColor.cardBackground else MochiColor.logoSolid)
                }
            }
        }
        Row(horizontalArrangement = Arrangement.spacedBy(MochiSpacing.sm)) {
            MockData.profileDownloads.forEach { item -> DownloadCard(item, Modifier.weight(1f)) }
        }
    }
}

@Composable
private fun DownloadCard(item: ProfileCreation, modifier: Modifier = Modifier) {
    val shape = RoundedCornerShape(MochiRadius.card)
    Column(
        modifier = modifier
            .shadow(4.dp, shape, ambientColor = Color.Black.copy(alpha = 0.05f), spotColor = Color.Black.copy(alpha = 0.05f))
            .clip(shape)
            .background(MochiColor.cardBackground)
    ) {
        Box {
            ProfileArtImage(item.imageAssetName, modifier = Modifier.fillMaxWidth().aspectRatio(1f))
            Box(
                modifier = Modifier.align(Alignment.TopEnd).padding(6.dp).size(18.dp).clip(CircleShape).background(MochiColor.cardBackground),
                contentAlignment = Alignment.Center
            ) {
                Icon(imageVector = Icons.Filled.Check, contentDescription = null, tint = MochiColor.logoSolid, modifier = Modifier.size(11.dp))
            }
        }
        Row(modifier = Modifier.padding(horizontal = 5.dp, vertical = 4.dp), verticalAlignment = Alignment.CenterVertically) {
            Text(text = item.name, style = MochiFont.body(8.5.sp), color = MochiColor.textPrimary, maxLines = 1, overflow = TextOverflow.Ellipsis, modifier = Modifier.weight(1f))
            Icon(imageVector = Icons.Filled.Favorite, contentDescription = null, tint = MochiColor.heart, modifier = Modifier.size(8.dp))
            Spacer(modifier = Modifier.width(3.dp))
            Text(text = item.likes.formattedCompact(), style = MochiFont.itemName(8.sp), color = MochiColor.textPrimary)
        }
    }
}

/** Figma heads BOTH cards "Liked Themes" with the same heart — the right-hand one lists
 * Followers/Following under it and adds a chevron after its "See all". Almost certainly a
 * copy-paste slip in the design, reproduced here rather than corrected. */
@Composable
private fun LikedThemesCard(likedThemes: List<ProfileLikedTheme>, modifier: Modifier = Modifier) {
    val shape = RoundedCornerShape(MochiRadius.card)
    Column(
        modifier = modifier.shadow(5.dp, shape, ambientColor = Color.Black.copy(alpha = 0.05f), spotColor = Color.Black.copy(alpha = 0.05f)).clip(shape).background(MochiColor.cardBackground).padding(10.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        PairHeader(chevron = false)
        if (likedThemes.isEmpty()) {
            Text(text = "No liked themes yet.", style = MochiFont.body(8.5.sp), color = MochiColor.textMuted)
        } else {
            likedThemes.take(3).forEach { LikedRow(it) }
        }
    }
}

@Composable
private fun FollowersCard(modifier: Modifier = Modifier) {
    val shape = RoundedCornerShape(MochiRadius.card)
    Column(
        modifier = modifier.shadow(5.dp, shape, ambientColor = Color.Black.copy(alpha = 0.05f), spotColor = Color.Black.copy(alpha = 0.05f)).clip(shape).background(MochiColor.cardBackground).padding(10.dp),
        verticalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        PairHeader(chevron = true)
        MockData.profileFollowRows.forEach { FollowRow(it) }
    }
}

@Composable
private fun PairHeader(chevron: Boolean) {
    Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
        Icon(imageVector = Icons.Filled.Favorite, contentDescription = null, tint = MochiColor.heart, modifier = Modifier.size(11.dp))
        Spacer(modifier = Modifier.width(6.dp))
        Text(text = "Liked Themes", style = MochiFont.heading(9.sp), color = MochiColor.textPrimary, modifier = Modifier.weight(1f))
        Row(verticalAlignment = Alignment.CenterVertically) {
            Text(text = "See all", style = MochiFont.heading(8.5.sp), color = MochiColor.logoSolid)
            if (chevron) {
                Icon(imageVector = Icons.AutoMirrored.Filled.KeyboardArrowRight, contentDescription = null, tint = MochiColor.logoSolid, modifier = Modifier.size(10.dp))
            }
        }
    }
}

@Composable
private fun LikedRow(item: ProfileLikedTheme) {
    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(6.dp)) {
        ProfileArtImage(item.imageAssetName, modifier = Modifier.width(38.dp).height(32.dp).clip(RoundedCornerShape(6.dp)))
        Column(modifier = Modifier.weight(1f)) {
            Text(text = item.name, style = MochiFont.heading(8.5.sp), color = MochiColor.textPrimary, maxLines = 1)
            Text(text = "by ${item.creatorName}", style = MochiFont.body(8.sp), color = MochiColor.textMuted)
        }
        Icon(imageVector = Icons.Filled.Favorite, contentDescription = null, tint = MochiColor.heart, modifier = Modifier.size(7.dp))
        Spacer(modifier = Modifier.width(2.dp))
        Text(text = item.likes.formattedCompact(), style = MochiFont.itemName(6.5.sp), color = MochiColor.textPrimary)
    }
}

@Composable
private fun FollowRow(item: ProfileFollowRow) {
    Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp)) {
        Box(
            modifier = Modifier.size(28.dp).clip(RoundedCornerShape(7.dp)).background(MochiColor.logoSolid),
            contentAlignment = Alignment.Center
        ) {
            Icon(imageVector = Icons.Filled.Group, contentDescription = null, tint = MochiColor.cardBackground, modifier = Modifier.size(14.dp))
        }
        Text(text = item.label, style = MochiFont.itemName(8.5.sp), color = MochiColor.textPrimary, modifier = Modifier.weight(1f))
        Row(verticalAlignment = Alignment.CenterVertically) {
            Text(text = item.value.formattedCompact(), style = MochiFont.itemName(7.sp), color = MochiColor.textPrimary)
            Icon(imageVector = Icons.AutoMirrored.Filled.KeyboardArrowRight, contentDescription = null, tint = MochiColor.textPrimary, modifier = Modifier.size(10.dp))
        }
    }
}

/** Calls ProfileScreenContent directly, not ProfileScreen - the real composable now casts
 * LocalContext's application to MochiApplication via rememberMochiViewModelFactory's pattern,
 * which Preview's fake context isn't, and would crash the preview (same reason Community/Themes/
 * Home split their own Preview off their real screen entry point). */
@Preview(showBackground = true, widthDp = 393, heightDp = 3000)
@Composable
private fun ProfileScreenPreview() {
    ProfileScreenContent(
        profile = MockData.profile,
        isOwnProfile = true,
        isFollowing = false,
        isBlocked = false,
        isPremium = false,
        creations = MockData.profileCreations,
        likedThemes = MockData.profileLikedThemes,
        onBack = {},
        onPaywallClick = {},
        onToggleFollow = {},
        onToggleBlock = {}
    )
}
