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
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.Group
import androidx.compose.material.icons.filled.MoreVert
import androidx.compose.material.icons.filled.PhotoCamera
import androidx.compose.material.icons.filled.Verified
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
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.mochi.keyboard.R
import com.mochi.keyboard.components.DownloadGlyph
import com.mochi.keyboard.components.PencilGlyph
import com.mochi.keyboard.components.SparkleField
import com.mochi.keyboard.components.TripleDot
import com.mochi.keyboard.designsystem.MochiColor
import com.mochi.keyboard.designsystem.MochiFont
import com.mochi.keyboard.designsystem.MochiGradient
import com.mochi.keyboard.designsystem.MochiRadius
import com.mochi.keyboard.designsystem.MochiSpacing
import com.mochi.keyboard.mockdata.MockData
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
    val resId = profileArt[assetName] ?: return
    Image(painter = painterResource(resId), contentDescription = null, contentScale = ContentScale.Crop, modifier = modifier)
}

/** Ported from ios/MochiApp/Features/Profile/ProfileView.swift. iOS lays this page out as one
 * absolute canvas keyed to Figma's own pixel coordinates (no Mac to preview against, so every
 * figure had to be checkable straight against the export) — Android has a working device/Preview
 * loop, so this reproduces the same content, order, sizes and colors as an ordinary flow layout
 * instead of porting the coordinate math verbatim. */
@Composable
fun ProfileScreen(
    modifier: Modifier = Modifier,
    onBack: () -> Unit = {},
    onSettingsClick: () -> Unit = {},
    onPaywallClick: () -> Unit = {}
) {
    var filter by remember { mutableStateOf("Theme") }
    val profile = MockData.profile

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
            BackButton(onBack)
            ProfileHeader(profile)
            PremiumBanner(
                title = "Mochi Pro",
                titleColor = MochiColor.logoSolid,
                subtitleLines = listOf("You're on Premium Plan  Enjoy all premium", "features and unlimited creations."),
                onUpgradeClick = onPaywallClick
            )
            CreationsSection()
            DownloadsSection(filter) { filter = it }
            Row(horizontalArrangement = Arrangement.spacedBy(MochiSpacing.sm)) {
                LikedThemesCard(modifier = Modifier.weight(1f))
                FollowersCard(modifier = Modifier.weight(1f))
            }
            PremiumBanner(
                title = "Go Premium",
                subtitleLines = listOf("Unlock all premium themes, fonts, and features."),
                onUpgradeClick = onPaywallClick
            )
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

@Composable
private fun ProfileHeader(profile: ProfileSummary) {
    Row(verticalAlignment = Alignment.Top, horizontalArrangement = Arrangement.spacedBy(MochiSpacing.md)) {
        Box {
            Image(
                painter = painterResource(R.drawable.avatar_mochi_creator),
                contentDescription = profile.displayName,
                contentScale = ContentScale.Crop,
                modifier = Modifier.size(96.dp).clip(CircleShape)
            )
            // The camera badge overlaps the ring's lower-right, matching the fraction ProfileMetrics
            // measures off the export (cameraCentreFraction ~0.79, 0.80 of the avatar).
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
        Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(3.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                Text(text = profile.displayName, style = MochiFont.itemName(20.sp), color = MochiColor.textPrimary)
                if (profile.isVerified) {
                    Image(painter = painterResource(R.drawable.icon_verified), contentDescription = "Verified", modifier = Modifier.size(17.dp))
                }
            }
            Text(text = profile.handle, style = MochiFont.itemName(13.sp), color = MochiColor.creatorLink)
            Spacer(modifier = Modifier.height(2.dp))
            // Figma's explicit break: "...themes to" / "make typing more fun!" — a naive wrap
            // would have set "...keyboard themes" / "to make typing more fun!" instead.
            Text(text = "Creating cute & colorful keyboard themes to", style = MochiFont.body(11.sp), color = MochiColor.textGreyWarm)
            Text(text = "make typing more fun!", style = MochiFont.body(11.sp), color = MochiColor.textGreyWarm)
            Spacer(modifier = Modifier.height(6.dp))
            Row(horizontalArrangement = Arrangement.spacedBy(MochiSpacing.lg)) {
                profile.stats.forEach { StatColumn(it.value.formattedCompact(), it.label) }
            }
        }
    }
    Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.End) {
        EditProfileButton()
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

@Composable
private fun CreationsSection() {
    Column(verticalArrangement = Arrangement.spacedBy(MochiSpacing.sm)) {
        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
            Text(text = "MY CREATIONS", style = MochiFont.title(11.sp), color = MochiColor.textPrimary)
            Text(text = "see all", style = MochiFont.body(11.sp), color = MochiColor.textPrimary)
        }
        // Figma fits all 4 tiles in one row edge-to-edge (4 columns + 3 gaps = the content width
        // exactly), not a horizontally-scrolling strip.
        Row(horizontalArrangement = Arrangement.spacedBy(MochiSpacing.sm)) {
            MockData.profileCreations.forEach { item -> CreationCard(item, Modifier.weight(1f)) }
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
private fun LikedThemesCard(modifier: Modifier = Modifier) {
    val shape = RoundedCornerShape(MochiRadius.card)
    Column(
        modifier = modifier.shadow(5.dp, shape, ambientColor = Color.Black.copy(alpha = 0.05f), spotColor = Color.Black.copy(alpha = 0.05f)).clip(shape).background(MochiColor.cardBackground).padding(10.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        PairHeader(chevron = false)
        MockData.profileLikedThemes.forEach { LikedRow(it) }
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

@Preview(showBackground = true, widthDp = 393, heightDp = 3000)
@Composable
private fun ProfileScreenPreview() {
    ProfileScreen()
}
