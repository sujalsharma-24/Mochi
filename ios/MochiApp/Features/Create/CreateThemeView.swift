import PhotosUI
import SwiftUI

/// Built against docs/figma/4.png — the Create Custom Theme frame — the same way HomeView is built
/// against 1.png and ThemesView against 8.png: every number below is a pixel measured off that
/// export, not an eyeballed value.
///
/// **This screen is a real editor, not a static transcription of the frame.** Every control below
/// mutates one shared `ThemeDraft` (`CreateThemeViewModel.draft`), which is the single source of
/// truth for the live keyboard preview, `CustomThemeStore` persistence, and the eventual Firestore
/// document — see `ThemeDraft.swift` for why intent is stored and everything else is derived from
/// it. Switching the `EditorTab` only changes which band of controls is visible; nothing about the
/// underlying draft is created or destroyed by that switch, which is what keeps a colour picked on
/// one tab intact when the user moves to another.
///
/// **Why this page is laid out absolutely rather than in stacks.** Unlike the other frames, 4.png
/// is not a column of rows. Its middle third interleaves three ragged columns whose blocks overlap
/// vertically — "LETTER COLOR"'s cap (y=2426) sits *above* the KEY COLOR rail (y=2463) which sits
/// above the eyedropper (y=2425–2515) in the next column over — so no arrangement of HStacks and
/// VStacks reproduces it without inventing spacing the design never had. Every element is
/// therefore placed at its measured Figma coordinate on a canvas that is the frame, scaled. That
/// interleaved block is exactly what the "Keys" tab shows as one unit; "Background" and "Fonts"
/// each get their own single section, and "Effect" — for which 4.png has no corresponding content
/// at all, the frame's own tab bar names a fourth tab with nothing drawn under it — gets a new
/// panel built from this same visual language rather than left non-functional.
///
/// **The scale.** 4.png is 2161x3840px, a 16:9 canvas. `k = screenWidth / 2161` maps it to the
/// device, so on a 402pt iPhone one Figma pixel is 0.186pt and the whole frame lands in 714pt.
/// Unlike Fonts and Themes this page needs **no vertical lift**: those frames left ~150pt of slack
/// once width-mapped and had to grow their type to fill it, whereas 4.png is dense enough that its
/// 3840px come to 714pt against 874pt of screen — 59pt of that is the status bar and the rest is
/// exactly the tab bar's footprint. Scaling type here would only push the page under the tab bar
/// and break the one-to-one mapping, so `k` is applied to *everything*: positions, sizes and type.
///
/// **Type weights** are assigned per role from the design, not applied in bulk: section headings
/// and button titles are Bold, everything else — subtitles, tab labels, chip captions, the field
/// placeholder — is Regular. An earlier pass ran nearly all of this at Bold, which is what made
/// the page read heavier than the frame.
struct CreateThemeView: View {
    /// Where the header's back disc goes. Defaults to a no-op only so `#Preview` keeps compiling
    /// standalone — every real call site (`RootView`) supplies the tab switch.
    var onBack: () -> Void = {}

    var body: some View {
        GeometryReader { geo in
            ScrollView(showsIndicators: false) {
                CreateThemeCanvas(k: geo.size.width / CreateFrame.width, onBack: onBack)
                    .frame(
                        width: geo.size.width,
                        height: CreateFrame.height * (geo.size.width / CreateFrame.width),
                        alignment: .topLeading
                    )
                    // Figma's y=0 is the literal top of the screen — it draws no status bar — so
                    // the back disc's 76px inset is measured from there. Riding 6pt back into the
                    // safe area keeps the header as high as the design puts it without colliding
                    // with the clock, the same trim ThemesView uses.
                    .padding(.top, -6)
                    // Clears MochiTabBar, which RootView overlays edge to edge on every tab.
                    .padding(.bottom, 96)
            }
            .background(alignment: .top) {
                ZStack(alignment: .top) {
                    // Reconstructed from 4.png itself: the frame's own background, with every
                    // panel the design draws on top of it replaced by a colour field fitted to the
                    // pixels it leaves uncovered. That keeps the real artwork — the orchid
                    // top-left corner, the sweep down the right edge, the sparkles and blobs in
                    // the margins — instead of approximating the page with a plain ramp.
                    Image("create_background")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                    SparkleField()
                }
                .ignoresSafeArea()
            }
        }
    }
}

/// The Figma canvas 4.png was exported at.
private enum CreateFrame {
    static let width: CGFloat = 2161
    static let height: CGFloat = 3840

    /// Inter's ascent is 0.969em against a cap height of 0.727em, so a `Text`'s ink starts
    /// 0.242em below the frame it is laid out in. Every `capTop:` below is a Figma *ink*
    /// coordinate, so the text frame is pulled up by that much to land the ink where it belongs.
    static let capInset: CGFloat = 0.242

    /// Content runs 79px to 2081px on this frame — a 2003px column, symmetric to the pixel.
    static let contentLeft: CGFloat = 79
    static let contentRight: CGFloat = 2081
    static let contentWidth: CGFloat = 2003
}

// MARK: - Canvas

private struct CreateThemeCanvas: View {
    /// Figma pixels to points.
    let k: CGFloat
    let onBack: () -> Void

    /// Starts on Background rather than 4.png's own default (Fonts) — the natural first step in
    /// building a theme, and there is no product reason to open on the fourth control instead of
    /// the first.
    @State private var tab: EditorTab = .background

    @State private var galleryPickerItem: PhotosPickerItem?
    @State private var showBackgroundGallery = false
    @State private var showBackgroundColorSheet = false
    @State private var showEyedropper = false
    @State private var showAddTag = false
    @State private var newTagText = ""

    @StateObject private var viewModel = CreateThemeViewModel(container: AppContainer.shared)

    var body: some View {
        ZStack(alignment: .topLeading) {
            header
            keyboardPreview

            // Everything from the tab bar down moves as one block, shifted by `previewHeightGrowth`
            // — the extra height the live preview above needs now that it draws the suggestion-bar
            // row, not just the key grid. Keeping every measured Figma y-coordinate below literal and
            // pushing the delta into a single offset (rather than hand-editing ~40 constants) is what
            // keeps this block re-diffable against 4.png later; only this one number is a deviation.
            ZStack(alignment: .topLeading) {
                editorTabs

                switch tab {
                case .background:
                    backgroundCard
                case .keys:
                    keyShapeSection
                    keyColorSection
                    recentSection
                    letterColorSection
                case .fonts:
                    fontStyleSection
                case .effect:
                    effectsSection
                }

                livePreviewCard
                nameAndTags
                statusBanner
                actionButtons
            }
            // Explicit bounds, not an implicit size inferred from children — every child here is
            // positioned via `box`/`.offset`, which never contributes to a ZStack's own reported
            // size, so left implicit this wrapper could report a much smaller frame than what it
            // actually draws. That has never bitten rendering (SwiftUI draws offset content outside
            // a view's own frame without clipping), but it is exactly the kind of ambiguity that can
            // make an enclosing scroll view's hit-testing region disagree with what's on screen.
            // Pinning it to the full canvas removes the ambiguity outright.
            .frame(width: s(CreateFrame.width), height: s(CreateFrame.height), alignment: .topLeading)
            .offset(y: s(Self.previewHeightGrowth))
        }
        // `of:perform:` rather than the two-parameter `of:initial:_:` — this project's deployment
        // target is iOS 16, and the newer overload needs 17.
        .onChange(of: galleryPickerItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    viewModel.applyPickedPhoto(data: data)
                }
            }
        }
        .sheet(isPresented: $showBackgroundGallery) {
            BackgroundGallerySheet(background: binding(\.background)) {
                galleryPickerItem = nil
            }
        }
        .sheet(isPresented: $showBackgroundColorSheet) {
            BackgroundColorSheet(background: binding(\.background)) {
                galleryPickerItem = nil
            }
        }
        .sheet(isPresented: $showEyedropper) {
            EyedropperSheet(themeColor: viewModel.draft.keyColor) { picked in
                let hsb = picked.hsbComponents
                viewModel.draft.keyHue = hsb.hue
                viewModel.draft.keySaturation = hsb.saturation
                viewModel.draft.keyBrightness = hsb.brightness
                commitKeyColor()
            }
        }
        .alert("Add Tag", isPresented: $showAddTag) {
            TextField("", text: $newTagText,
                      prompt: Text("e.g. Cozy").foregroundColor(MochiColor.textSecondary))
            Button("Add") { commitNewTag() }
            Button("Cancel", role: .cancel) { newTagText = "" }
        }
        .onDisappear { viewModel.flushPendingSave() }
    }

    // MARK: State plumbing

    /// One binding factory for every plain-value field on `ThemeDraft`, so a control never mutates
    /// the draft without also scheduling the autosave that makes "leave and come back" work.
    private func binding<Value>(_ keyPath: WritableKeyPath<ThemeDraft, Value>) -> Binding<Value> {
        Binding(
            get: { viewModel.draft[keyPath: keyPath] },
            set: { newValue in
                viewModel.draft[keyPath: keyPath] = newValue
                viewModel.scheduleAutosave()
            }
        )
    }

    /// Pushes the current key colour to the front of RECENT (deduped, capped at 6). Called when a
    /// colour drag ends and when the eyedropper returns a value — not on every drag tick, which
    /// would make the grid churn constantly instead of recording deliberate choices.
    private func commitKeyColor() {
        let hex = viewModel.draft.keyColor.hexString
        var recents = viewModel.draft.recentKeyColors.filter { $0 != hex }
        recents.insert(hex, at: 0)
        viewModel.draft.recentKeyColors = Array(recents.prefix(6))
        viewModel.scheduleAutosave()
    }

    private func commitNewTag() {
        let trimmed = newTagText.trimmingCharacters(in: .whitespacesAndNewlines)
        newTagText = ""
        guard !trimmed.isEmpty, viewModel.draft.tags.count < Self.tagX.count else { return }
        guard !viewModel.draft.tags.contains(where: { $0.caseInsensitiveCompare(trimmed) == .orderedSame }) else { return }
        viewModel.draft.tags.append(trimmed)
        viewModel.scheduleAutosave()
    }

    private func save(publish: Bool) {
        viewModel.save(publish: publish)
    }

    // MARK: Scaling helpers

    /// A Figma-pixel length in points.
    private func s(_ px: CGFloat) -> CGFloat { px * k }

    private enum Weight { case bold, semibold, medium, regular }

    private func font(_ weight: Weight, _ px: CGFloat) -> Font {
        switch weight {
        case .bold:     return MochiFont.title(s(px))
        case .semibold: return MochiFont.heading(s(px))
        case .medium:   return MochiFont.itemName(s(px))
        case .regular:  return MochiFont.body(s(px))
        }
    }

    /// Text pinned by its left edge and the top of its capitals — how the frame was measured.
    private func ink(
        _ string: String,
        x: CGFloat,
        capTop: CGFloat,
        size: CGFloat,
        _ weight: Weight = .regular,
        _ color: Color = MochiColor.textPrimary
    ) -> some View {
        Text(string)
            .font(font(weight, size))
            .foregroundStyle(color)
            .fixedSize()
            .offset(x: s(x), y: s(capTop) - CreateFrame.capInset * s(size))
    }

    /// A view centred on a Figma x, with its top on a Figma y. Used wherever the design centres
    /// content inside a shape rather than aligning it to an edge — letting the content size itself
    /// and then centring is sturdier than pinning both edges of a string whose advance widths
    /// cannot be predicted to the pixel.
    ///
    /// Only the *width* is constrained. An earlier version also pinned the height and let the
    /// content centre inside that band, which made every vertical landing depend on SwiftUI's line
    /// height for Inter rather than on the measurement — the page title came out 3pt low that way.
    private func centred<V: View>(_ view: V, at cx: CGFloat, top: CGFloat) -> some View {
        view
            .fixedSize()
            .frame(width: s(CreateFrame.width))
            .offset(x: s(cx) - s(CreateFrame.width) / 2, y: s(top))
    }

    /// `centred`, but also centred vertically inside a Figma-measured band. Safe for shapes and
    /// icon rows, whose heights are known; not for text, whose landing then depends on Inter's
    /// line height rather than on the measurement.
    private func centred<V: View>(_ view: V, at cx: CGFloat, top: CGFloat, height: CGFloat) -> some View {
        view
            .fixedSize()
            .frame(width: s(CreateFrame.width), height: s(height))
            .offset(x: s(cx) - s(CreateFrame.width) / 2, y: s(top))
    }

    /// `centred`, for a string pinned by the top of its capitals.
    private func centredInk(
        _ string: String,
        at cx: CGFloat,
        capTop: CGFloat,
        size: CGFloat,
        _ weight: Weight = .regular,
        _ color: Color = MochiColor.textPrimary
    ) -> some View {
        centred(
            Text(string).font(font(weight, size)).foregroundStyle(color),
            at: cx, top: capTop - CreateFrame.capInset * size
        )
    }

    /// A shape positioned and sized entirely in Figma pixels.
    ///
    /// **Never apply this inside a `Button`'s label.** It is `.frame` + `.offset`, and `.offset`
    /// moves pixels without moving the layout frame the Button derives its tap region from — so a
    /// button built as `Button { } label: { shape.modifier(box(…)) }` draws in the right place and
    /// is tappable somewhere else entirely. Every control on this screen that did that reported an
    /// accessibility frame of {{0, 106.3}, …} — the un-offset origin — regardless of where it drew,
    /// stacking the four editor tabs, Reset All and Save Draft on top of each other at one dead
    /// point. The working pattern, used by the plate tiles, key shapes, font and effect chips, is to
    /// size the label (`.frame(width:height:)` + `.contentShape`) and position the *Button*:
    ///
    ///     Button { … } label: { shape.frame(width: s(w), height: s(h)).contentShape(Rectangle()) }
    ///         .buttonStyle(.plain)
    ///         .offset(x: s(x), y: s(y))
    ///
    /// `box` remains correct for everything non-interactive — panels, rails, ink, decoration.
    private func box(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> some ViewModifier {
        BoxModifier(x: s(x), y: s(y), w: s(w), h: s(h))
    }

    /// The purple ring every white panel on this frame carries: #8A4FA0 at roughly 3px, which is
    /// 0.56pt once mapped. Chips inside the panels use `logoSolid` instead — measured, not assumed.
    private var panelStroke: CGFloat { max(0.5, s(3)) }

    private func checkBadge(_ diameter: CGFloat) -> some View {
        Circle()
            .fill(MochiColor.logoSolid)
            .frame(width: s(diameter), height: s(diameter))
            .overlay(
                Image(systemName: "checkmark")
                    .font(.system(size: s(diameter) * 0.52, weight: .bold))
                    .foregroundStyle(.white)
            )
    }

    // MARK: Header — a 153px disc on the margin, with the title block centred on the page.

    private var header: some View {
        ZStack(alignment: .topLeading) {
            Button {
                // Autosave already keeps the draft current within `autosaveDebounce`; flushing
                // here makes that guarantee immediate at the one moment it actually matters — see
                // `CreateThemeViewModel`'s doc comment on why this replaces a discard dialog.
                viewModel.flushPendingSave()
                onBack()
            } label: {
                Circle()
                    .fill(MochiGradient.themeCircleButton)
                    .overlay(
                        Image(systemName: "arrow.left")
                            .font(.system(size: s(78), weight: .medium))
                            .foregroundStyle(MochiColor.textPrimary)
                    )
                    .frame(width: s(153), height: s(153))
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .offset(x: s(77), y: s(76))
            .accessibilityIdentifier("create.back")

            // 864px of ink, cap 137–196px: Inter Bold at 81.6px, in the wordmark's flat #9C28B1.
            centredInk("Create Custom Theme", at: 1080, capTop: 137,
                       size: 80.7, .bold, MochiColor.logoSolid)

            // 636px of ink: Inter Regular at 42.4px, in the warm grey the Fonts frame also uses.
            centredInk("Design your own keyboard theme", at: 1080, capTop: 221,
                       size: 40, .regular, MochiColor.textGreyWarm)
        }
    }

    // MARK: Live keyboard — the real renderer, fit into the frame's 2009x1083px slot.

    /// A representative device width for the preview's own `KeyboardMetrics` — not this device's
    /// actual width, which would make the preview's proportions depend on whatever phone the editor
    /// happens to be running on. `SizedKeyboardThemePreview` (used everywhere else this renderer
    /// appears) makes the same choice implicitly via its `GeometryReader`; this slot is a *fixed*
    /// Figma box, so the fit has to be computed explicitly instead.
    private static let previewReferenceWidth: CGFloat = 402
    private static let previewSlotHeight: CGFloat = 1354

    /// The extra Figma-px height the preview slot needs now that it draws the suggestion-bar row on
    /// top of the key grid, not just the keys — `1354 - 1083`. Everything from `editorTabs` down is
    /// pushed by exactly this much (see the offset in `body`) so the taller preview has room without
    /// touching a single one of the measured coordinates below it. `CreateFrame.height` (3840) has
    /// 298px of slack below the current lowest control, more than this needs, so nothing else moves.
    fileprivate static let previewHeightGrowth: CGFloat = previewSlotHeight - 1083

    private var keyboardPreview: some View {
        let theme = viewModel.draft.renderTheme
        let naturalHeight = KeyboardThemePreview.preferredHeight(
            for: theme, width: Self.previewReferenceWidth, includesSuggestionBar: true
        )
        let slotWidth = s(2009)
        let slotHeight = s(Self.previewSlotHeight)
        // `max`, not `min`: the original static asset was itself cropped to fill this slot (see the
        // repo's own note on why — "fill trims a single pixel rather than stretching"), and matching
        // that is what keeps the real preview from suddenly looking letterboxed next to where a
        // static image used to sit flush. The slot's own aspect is now tuned to the suggestion-bar
        // keyboard's true aspect, so fit and fill agree to within rounding — `max` just guards against
        // a hairline seam if that drifts a pixel on some device width.
        let fitScale = max(slotWidth / Self.previewReferenceWidth, slotHeight / naturalHeight)

        return KeyboardThemePreview(
            theme: theme, showsSuggestionBar: true, containerURL: CustomThemeStore.mediaRootURL
        )
        .frame(width: Self.previewReferenceWidth, height: naturalHeight)
        .scaleEffect(fitScale)
        .frame(width: slotWidth, height: slotHeight)
        .clipShape(RoundedRectangle(cornerRadius: s(60), style: .continuous))
        .offset(x: s(76), y: s(320))
        .allowsHitTesting(false)
        .accessibilityIdentifier("create.livePreview")
    }

    // MARK: - Editor tabs — one white capsule, 2003x102px, with the selected label on a 294px pill.

    private enum EditorTab: String, CaseIterable, Identifiable {
        case background = "Background", keys = "Keys", fonts = "Fonts", effect = "Effect"
        var id: String { rawValue }

        /// Ink centre on the frame. The four are *not* evenly spaced — the design nudged each
        /// group by hand, and equal-width segments land "Background" 60px left of where it sits —
        /// so each carries its own measured centre rather than a computed one.
        var centre: CGFloat {
            switch self {
            case .background: return 388.5
            case .keys:       return 880.5
            case .fonts:      return 1328.5
            case .effect:     return 1815
            }
        }

        /// Ink width of the mark, and the gap from it to the label. Both measured per tab.
        var iconWidth: CGFloat {
            switch self {
            case .background: return 52
            case .keys:       return 46
            case .fonts:      return 56
            case .effect:     return 70
            }
        }

        var iconGap: CGFloat {
            switch self {
            case .background: return 28
            case .keys:       return 19
            case .fonts:      return 23
            case .effect:     return 33
            }
        }

        /// Tap-target band: each tab claims the strip up to the midpoint with its neighbour, so the
        /// four bands are adjacent and non-overlapping and together span the whole capsule. Needed
        /// because `centred(_:at:top:height:)` (used for the *label*, immediately below) frames its
        /// content at the full canvas width to get centring for free — harmless while these tabs
        /// were decorative, but as an actual tap target that made all four bands span the entire
        /// screen width and overlap completely, so only one of them could ever receive a touch.
        var tapRange: (x: CGFloat, width: CGFloat) {
            let all = EditorTab.allCases
            guard let index = all.firstIndex(of: self) else { return (CreateFrame.contentLeft, CreateFrame.contentWidth) }
            let left = index == all.startIndex ? CreateFrame.contentLeft : (all[index - 1].centre + centre) / 2
            let right = index == all.index(before: all.endIndex) ? CreateFrame.contentRight : (centre + all[index + 1].centre) / 2
            return (left, right - left)
        }
    }

    private var editorTabs: some View {
        ZStack(alignment: .topLeading) {
            Capsule()
                .fill(Color.white)
                .overlay(Capsule().stroke(MochiColor.outline, lineWidth: panelStroke))
                .modifier(box(CreateFrame.contentLeft, 1466, CreateFrame.contentWidth, 102))

            // The highlight used to be a second, independently-measured 294x92 capsule centred on
            // `item.centre` — a fixed width that fit none of the four labels (each icon+text pair
            // has its own advance width), so it either clipped the longest label ("Background") or
            // floated with dead space around the shortest ("Keys"). Making the pill the label's own
            // `.background` means it can never be narrower than its content — SwiftUI sizes it from
            // the actual rendered HStack, not a guessed width. A plain `.animation(value:)` handles
            // the slide/resize; an earlier version used `matchedGeometryEffect` here, which turned
            // out to eat every tap on this row (its cross-view geometry synchronisation appears to
            // install its own hit-testable proxy despite the `.allowsHitTesting(false)` below) —
            // exactly the "one gesture recognizer swallows every touch on the page" failure mode this
            // screen's Button-only convention exists to avoid, so it's out.
            ForEach(EditorTab.allCases) { item in
                centred(
                    HStack(spacing: s(item.iconGap)) {
                        tabIcon(item)
                            .frame(width: s(item.iconWidth), height: s(item.iconWidth))
                        Text(item.rawValue)
                            .font(font(.regular, 51))
                    }
                    .foregroundStyle(tab == item ? MochiColor.textPrimary : MochiColor.textGreyWarm)
                    .padding(.horizontal, s(46))
                    .frame(height: s(92))
                    .background {
                        if tab == item {
                            Capsule().fill(MochiGradient.editorPill)
                        }
                    }
                    .animation(.easeInOut(duration: 0.18), value: tab),
                    at: item.centre, top: 1466, height: 102
                )
                .allowsHitTesting(false)
            }

            // The real tap targets: one bounded, non-overlapping band per tab. `Button`, not
            // `.onTapGesture` — see `actionButtons`' doc comment on why every control on this
            // screen is a real button now, not a tap-gesture-bearing shape.
            //
            // **The position is applied to the Button, never inside its label** — see `box`'s own
            // doc comment. With `box` inside the label these four reported an accessibility frame of
            // {{0, 106.3}, …} each: all four stacked at one point nowhere near the pills they draw,
            // which is exactly why tapping Keys/Fonts/Effect did nothing at all.
            ForEach(EditorTab.allCases) { item in
                let range = item.tapRange
                Button {
                    withAnimation(.easeInOut(duration: 0.18)) { tab = item }
                } label: {
                    Color.clear
                        .frame(width: s(range.width), height: s(102))
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .offset(x: s(range.x), y: s(1466))
                .accessibilityIdentifier("create.tab.\(item.rawValue.lowercased())")
                .accessibilityLabel(item.rawValue)
                .accessibilityAddTraits(tab == item ? .isSelected : [])
            }
        }
    }

    @ViewBuilder
    private func tabIcon(_ item: EditorTab) -> some View {
        switch item {
        case .background:
            // Filled, not outlined: Figma's mark is a solid photo card with a second card angled
            // behind it. `.resizable()` on an SF symbol discards its stroke weight and renders
            // these two hairline-thin, so both are sized through `.font` instead.
            Image(systemName: "photo.fill.on.rectangle.fill")
                .font(.system(size: s(44)))
        case .keys:
            KeycapGlyph()
        case .fonts:
            Text("Aa").font(font(.bold, 48)).minimumScaleFactor(0.5)
        case .effect:
            Image(systemName: "sparkles")
                .font(.system(size: s(58)))
        }
    }

    // MARK: BACKGROUND card — a 6-column, 4-row grid of 271x224px tiles inside a 2003x1208px panel.
    //
    // The panel used to stop after one row (382px tall), leaving ~874px of empty white card above
    // "Live Preview" — this session's own brief calls that out by name. 2816 is not an invented
    // bottom edge: it is where the Fonts tab's chips and the Keys tab's letter-colour rail already
    // land in this same vertical band, so growing Background to match keeps every tab's footprint
    // consistent instead of introducing a new boundary. The horizontal rhythm (271-wide tile on a
    // 318px pitch, six across) is untouched from the original single row; the vertical pitch (271)
    // reuses that same 47px gap the horizontal pitch already implies (318 - 271), so the grid reads
    // as one consistent spacing system rather than two independently chosen ones.
    private static let tileWidth: CGFloat = 271
    private static let tileHeight: CGFloat = 224
    private static let tilePitchX: CGFloat = 318
    private static let tilePitchY: CGFloat = 271
    private static let tileTop: CGFloat = 1708
    private static let tileColumns = 6
    /// 24 grid slots minus the 2 fixed source tiles (Gallery, Colors), which always occupy row 1.
    private static let maxArtworkTiles = tileColumns * 4 - 2

    /// The four plates the single-row layout curated by hand stay first, so row one keeps the exact
    /// look it always had; everything else `BackgroundChoice.availablePlates` has art for follows in
    /// catalogue order, filling the rest of the grid.
    private static let curatedPlateNames = [
        "Cozy Sakura Café", "Zen Garden", "Fantasy Castle Night", "Kawaii Strawberry Dream"
    ]

    private var orderedPlates: [(assetName: String, displayName: String)] {
        let all = BackgroundChoice.availablePlates
        let curated = Self.curatedPlateNames.compactMap { name in all.first { $0.displayName == name } }
        let curatedNames = Set(curated.map(\.displayName))
        return curated + all.filter { !curatedNames.contains($0.displayName) }
    }

    /// What actually renders in the grid — capped at the panel's real capacity so this can never
    /// overflow the 4 rows even if the catalogue grows past 22 plates later.
    private var gridPlates: [(assetName: String, displayName: String)] {
        Array(orderedPlates.prefix(Self.maxArtworkTiles))
    }

    /// "See All" only earns a place once the grid can't show everything — with the current 28-plate
    /// catalogue that's true (22 fit, 6 don't), but this keeps the button from lingering once the
    /// grid alone is the complete set.
    private var hasMorePlatesThanGrid: Bool {
        orderedPlates.count > Self.maxArtworkTiles
    }

    /// Grid-slot geometry: slot 0 and 1 are the fixed Gallery/Colors source tiles, slots 2... are
    /// artwork, all sharing one 6-wide row-major layout so a tile's position is purely a function of
    /// its slot index.
    private func tileX(_ slot: Int) -> CGFloat { 150 + CGFloat(slot % Self.tileColumns) * Self.tilePitchX }
    private func tileY(_ slot: Int) -> CGFloat { Self.tileTop + CGFloat(slot / Self.tileColumns) * Self.tilePitchY }

    private var backgroundCard: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: s(38), style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: s(38), style: .continuous)
                        .stroke(MochiColor.outline, lineWidth: panelStroke)
                )
                .modifier(box(CreateFrame.contentLeft, 1608, CreateFrame.contentWidth, 1208))

            ink("BACKGROUND", x: 153, capTop: 1644, size: 50.9, .bold)

            // Not in 4.png — a minimal, same-language addition. Even with the grid now showing 22 of
            // 28 plates at real size, 6 still don't fit, and this app already uses "See All" as its
            // own idiom elsewhere (the Fonts screen's downloaded-styles strip). Padded well past its
            // own text so the tap target isn't just the ink's ~10pt-tall box.
            if hasMorePlatesThanGrid {
                Button { showBackgroundGallery = true } label: {
                    Text("See All →")
                        .font(font(.regular, 38))
                        .foregroundStyle(MochiColor.logoSolid)
                        .padding(.horizontal, s(30))
                        .padding(.vertical, s(24))
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .offset(x: s(1750 - 30), y: s(1644) - CreateFrame.capInset * s(38) - s(24))
                .accessibilityIdentifier("create.background.seeAll")
            }

            // 76x74px of ink, stroked about 12px — drawn rather than taken from SF, whose `plus`
            // has no size at which both its bar length and its weight match the frame's.
            PhotosPicker(selection: $galleryPickerItem, matching: .images) {
                sourceTile(glyph: AnyView(
                    ZStack {
                        Capsule().frame(width: s(76), height: s(11))
                        Capsule().frame(width: s(11), height: s(74))
                    }
                    .foregroundStyle(MochiColor.logoSolid)
                ), glyphHeight: 74, caption: "Gallery", isSelected: isPhotoBackground)
            }
            .buttonStyle(.plain)
            .offset(x: s(tileX(0)), y: s(tileY(0)))
            .accessibilityIdentifier("create.background.gallery")

            Button { showBackgroundColorSheet = true } label: {
                sourceTile(glyph: AnyView(
                    ColorWheelGlyph().frame(width: s(96), height: s(96))
                ), glyphHeight: 96, caption: "Colors", isSelected: isColorBackground)
            }
            .buttonStyle(.plain)
            .offset(x: s(tileX(1)), y: s(tileY(1)))
            .accessibilityIdentifier("create.background.colors")

            ForEach(Array(gridPlates.enumerated()), id: \.offset) { index, plate in
                artworkTile(slot: index + 2, assetName: plate.assetName, displayName: plate.displayName)
            }
        }
    }

    private var isPhotoBackground: Bool {
        if case .photo = viewModel.draft.background { return true }
        return false
    }

    private var isColorBackground: Bool {
        switch viewModel.draft.background {
        case .gradient, .solid: return true
        default: return false
        }
    }

    /// The two left-hand tiles: a white chip outlined in #9C28B1 with a mark over a caption. Mark
    /// and caption are placed against their own measurements rather than stacked, because the two
    /// marks are different heights (74px and 96px) and a shared VStack lets the taller one push its
    /// caption down out of line with the other tile's. Always slot 0/1, so always row 1 — the glyph
    /// and caption positions below are measured off `tileTop` directly rather than a generic row y.
    ///
    /// Self-contained and origin-relative — the caller positions the *Button* wrapping it, so the
    /// tap region lands where the tile draws (see `box`'s doc comment on why that matters here).
    private func sourceTile(glyph: AnyView, glyphHeight: CGFloat, caption: String, isSelected: Bool) -> some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: s(30), style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: s(30), style: .continuous)
                        .stroke(MochiColor.logoSolid, lineWidth: panelStroke)
                )
                .frame(width: s(Self.tileWidth), height: s(Self.tileHeight))

            glyph
                .frame(width: s(Self.tileWidth), height: s(glyphHeight))
                .offset(y: s(96 - glyphHeight / 2))

            Text(caption)
                .font(font(.regular, 40))
                .foregroundStyle(MochiColor.logoSolid)
                .frame(width: s(Self.tileWidth))
                .offset(y: s(168) - CreateFrame.capInset * s(40))

            if isSelected {
                checkBadge(52).offset(x: s(Self.tileWidth - 26), y: s(-16))
            }
        }
        .frame(width: s(Self.tileWidth), height: s(Self.tileHeight), alignment: .topLeading)
        .contentShape(Rectangle())
    }

    /// A grid tile showing a real `themebg_*` plate. `slot` is screen position (2...23, row-major
    /// over the 6-column grid); `assetName` is the actual bundled asset selecting this tile writes
    /// into the draft.
    private func artworkTile(slot: Int, assetName: String, displayName: String) -> some View {
        let x = tileX(slot)
        let y = tileY(slot)
        let selected: Bool = {
            if case .plate(let selectedName, _) = viewModel.draft.background { return selectedName == assetName }
            return false
        }()
        return Button {
            viewModel.draft.background = .plate(assetName: assetName, displayName: displayName)
            galleryPickerItem = nil
            viewModel.scheduleAutosave()
        } label: {
            ZStack(alignment: .topTrailing) {
                // `.fill`, not `.fit` — every plate is meant to fill its tile edge to edge exactly as
                // the curated row already did; growing the grid must not thin out or letterbox art
                // that already looks right, it should just show more of it at the same treatment.
                Image(assetName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: s(Self.tileWidth), height: s(Self.tileHeight))
                    .clipShape(RoundedRectangle(cornerRadius: s(30), style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: s(30), style: .continuous)
                            .stroke(MochiColor.logoSolid, lineWidth: selected ? panelStroke * 2 : 0)
                    )

                if selected {
                    checkBadge(52).offset(x: s(20), y: s(-16))
                }
            }
            .frame(width: s(Self.tileWidth), height: s(Self.tileHeight), alignment: .topLeading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .offset(x: s(x), y: s(y))
        .accessibilityIdentifier("create.background.plate.\(assetName)")
    }

    // MARK: KEY SHAPE — four 178px chips on a 208px pitch, each holding a 100px preview.
    //
    // 4.png starts the Keys block at y=2044, 476px below the tab pills — a gap that reads as a hole
    // in the page once the tabs actually switch (the frame is a static mockup, so nothing above this
    // block ever changed there). The whole Keys group — this section, KEY COLOR, RECENT and LETTER
    // COLOR — is therefore lifted by `keysLift` so its headings land level with where BACKGROUND's
    // heading sits, directly under the pills. Every measured relationship *within* the group is
    // preserved exactly: one constant, applied uniformly.
    private static let keysLift: CGFloat = 400

    private var keyShapeSection: some View {
        ZStack(alignment: .topLeading) {
            ink("KEY SHAPE", x: 80, capTop: 2044 - Self.keysLift, size: 50.9, .bold)

            ForEach(Array(KeyShapeOption.allCases.enumerated()), id: \.offset) { index, option in
                let x = 139 + CGFloat(index) * 208
                Button {
                    viewModel.draft.keyShape = option
                    viewModel.scheduleAutosave()
                } label: {
                    ZStack(alignment: .topTrailing) {
                        RoundedRectangle(cornerRadius: s(28), style: .continuous)
                            .stroke(MochiColor.logoSolid, lineWidth: panelStroke)
                            .frame(width: s(178), height: s(178))
                            .overlay(shapePreview(option).frame(width: s(100), height: s(100)))

                        if viewModel.draft.keyShape == option {
                            checkBadge(48).offset(x: s(18), y: s(-14))
                        }
                    }
                    .frame(width: s(178), height: s(178), alignment: .topLeading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .offset(x: s(x), y: s(2148 - Self.keysLift))
                .accessibilityIdentifier("create.keyShape.\(option.rawValue)")
            }
        }
    }

    @ViewBuilder
    private func shapePreview(_ option: KeyShapeOption) -> some View {
        switch option {
        case .square:
            Rectangle()
                .fill(MochiGradient.keyShapePreview)
                .overlay(Rectangle().stroke(MochiColor.outline.opacity(0.7), lineWidth: panelStroke * 0.6))
        case .rounded:
            RoundedRectangle(cornerRadius: s(26), style: .continuous)
                .fill(MochiGradient.keyShapePreview)
                .overlay(
                    RoundedRectangle(cornerRadius: s(26), style: .continuous)
                        .stroke(MochiColor.outline.opacity(0.7), lineWidth: panelStroke * 0.6)
                )
        case .circle:
            Circle()
                .fill(MochiGradient.keyShapePreview)
                .overlay(Circle().stroke(MochiColor.outline.opacity(0.7), lineWidth: panelStroke * 0.6))
        case .hexagon:
            HexagonShape()
                .fill(MochiGradient.keyShapePreview)
                .overlay(HexagonShape().stroke(MochiColor.outline.opacity(0.7), lineWidth: panelStroke * 0.6))
        }
    }

    // MARK: KEY COLOR — a 612x294px saturation/value square over a 610x35px hue rail.

    private var keyColorSection: some View {
        ZStack(alignment: .topLeading) {
            ink("KEY COLOR", x: 1007, capTop: 2044 - Self.keysLift, size: 50.9, .bold)
            saturationSquare(
                x: 998, y: 2125 - Self.keysLift, w: 612, h: 294, cornerRadius: 40,
                hue: binding(\.keyHue), saturation: binding(\.keySaturation), brightness: binding(\.keyBrightness),
                onCommit: commitKeyColor
            )
            .accessibilityIdentifier("create.keyColor.square")
            hueRail(x: 1000, y: 2463 - Self.keysLift, w: 610, h: 35, hue: binding(\.keyHue), onCommit: commitKeyColor)
                .accessibilityIdentifier("create.keyColor.hueRail")
        }
    }

    /// White across, black down — the standard picker square. `hue` tints the square's own gradient
    /// live, so dragging the rail visibly changes what the square offers before the user even drags
    /// it — a static square tinted to one fixed hue (4.png's own rendering, and this file's earlier
    /// static version) is the exact "looks interactive but has no underlying behaviour" complaint
    /// this session exists to fix.
    private func saturationSquare(
        x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat, cornerRadius: CGFloat,
        hue: Binding<Double>, saturation: Binding<Double>, brightness: Binding<Double>,
        onCommit: @escaping () -> Void = {}
    ) -> some View {
        // Clamped, not just computed: at the extremes (saturation 0, brightness 0 or 1) the raw
        // fraction puts the knob's centre exactly on the square's edge, which hangs three-quarters
        // of the 56px ring outside the fill — most visibly at the new white-key default, which opens
        // on saturation 0. Keeping the knob's own radius inside the box reads as "the knob is on the
        // edge" instead of "the knob fell off," at every value, not just this one.
        let knobRadius = s(28)
        let knobX = min(max(saturation.wrappedValue * s(w), knobRadius), s(w) - knobRadius)
        let knobY = min(max((1 - brightness.wrappedValue) * s(h), knobRadius), s(h) - knobRadius)
        return RoundedRectangle(cornerRadius: s(cornerRadius), style: .continuous)
            .fill(
                LinearGradient(colors: [.white, Color(hue: hue.wrappedValue, saturation: 1, brightness: 1)],
                               startPoint: .leading, endPoint: .trailing)
            )
            .overlay(
                RoundedRectangle(cornerRadius: s(cornerRadius), style: .continuous)
                    .fill(
                        LinearGradient(stops: [.init(color: .black.opacity(0), location: 0.0),
                                              .init(color: .black.opacity(0.94), location: 1.0)],
                                       startPoint: .top, endPoint: .bottom)
                    )
            )
            .overlay(alignment: .topLeading) {
                Circle()
                    .stroke(.white, lineWidth: s(7))
                    .shadow(color: .black.opacity(0.35), radius: 2)
                    .frame(width: s(56), height: s(56))
                    .offset(x: knobX - s(28), y: knobY - s(28))
                    .allowsHitTesting(false)
            }
            // Sized and gesture-bound first, positioned after — same rule as the buttons (see `box`).
            // The drag reads `value.location` in this view's own space, which the outer `.offset`
            // leaves untouched, so the 0...w / 0...h maths below stays correct.
            .frame(width: s(w), height: s(h))
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        saturation.wrappedValue = Double(min(max(value.location.x, 0), s(w)) / s(w))
                        brightness.wrappedValue = Double(1 - min(max(value.location.y, 0), s(h)) / s(h))
                    }
                    .onEnded { _ in onCommit() }
            )
            .offset(x: s(x), y: s(y))
    }

    /// `hueSpectrum` stops at magenta rather than wrapping back to red (11/12 of the wheel, not a
    /// full turn — see `MochiGradient.hueSpectrum`'s own comment), so the rail's drag fraction maps
    /// to that same 0...11/12 span rather than a full 0...1 turn. Getting this wrong is exactly the
    /// kind of bug that looks fine until the knob visually sits somewhere the rail doesn't draw.
    private static let hueDomain: Double = 11.0 / 12.0

    private func hueRail(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat, hue: Binding<Double>, onCommit: @escaping () -> Void = {}) -> some View {
        let fraction = min(1, max(0, hue.wrappedValue / Self.hueDomain))
        let knobX = fraction * s(w)
        return Capsule()
            .fill(MochiGradient.hueSpectrum)
            .overlay(alignment: .leading) {
                Circle()
                    .fill(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2)
                    .frame(width: s(52), height: s(52))
                    .offset(x: knobX - s(26))
                    .allowsHitTesting(false)
            }
            .frame(width: s(w), height: s(h))
            // A 35px rail is 6.5pt tall — far under a usable touch target — so the hit area is
            // padded vertically well past the ink without moving the rail itself.
            .contentShape(Rectangle().inset(by: -s(60)))
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let clamped = min(max(value.location.x, 0), s(w))
                        hue.wrappedValue = Double(clamped / s(w)) * Self.hueDomain
                    }
                    .onEnded { _ in onCommit() }
            )
            .offset(x: s(x), y: s(y))
    }

    // MARK: RECENT — a 3x2 grid of 119x107px swatches, plus the eyedropper below it.

    private var recentSection: some View {
        // Real recents fill from the front; any remaining slots keep the frame's own decorative
        // defaults rather than rendering empty, so a brand-new draft's grid still looks complete.
        let hexes = viewModel.draft.recentKeyColors
        return ZStack(alignment: .topLeading) {
            // 143px wide against 267px for "KEY SHAPE": this heading is set noticeably smaller
            // than the others on the frame — 28px of cap rather than 37px.
            ink("RECENT", x: 1634, capTop: 2077 - Self.keysLift, size: 35.5, .bold)

            ForEach(0..<6, id: \.self) { index in
                let column = index % 3, row = index / 3
                let color = index < hexes.count
                    ? Color(ThemeColor(hex: hexes[index])?.uiColor ?? UIColor(MochiColor.recentSwatches[index]))
                    : MochiColor.recentSwatches[index]
                Button {
                    guard index < hexes.count, let picked = ThemeColor(hex: hexes[index]) else { return }
                    let hsb = picked.hsbComponents
                    viewModel.draft.keyHue = hsb.hue
                    viewModel.draft.keySaturation = hsb.saturation
                    viewModel.draft.keyBrightness = hsb.brightness
                    commitKeyColor()
                } label: {
                    RoundedRectangle(cornerRadius: s(22), style: .continuous)
                        .fill(color)
                        .frame(width: s(119), height: s(107))
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .offset(x: s(1672 + CGFloat(column) * 146), y: s(2152 + CGFloat(row) * 137 - Self.keysLift))
                .accessibilityIdentifier("create.recent.\(index)")
            }

            Button { showEyedropper = true } label: {
                RoundedRectangle(cornerRadius: s(24), style: .continuous)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: s(24), style: .continuous)
                            .stroke(MochiColor.outline, lineWidth: panelStroke)
                    )
                    .overlay(
                        Image(systemName: "eyedropper")
                            .font(.system(size: s(44), weight: .regular))
                            .foregroundStyle(MochiColor.logoSolid)
                    )
                    .frame(width: s(142), height: s(90))
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .offset(x: s(1809), y: s(2425 - Self.keysLift))
            .accessibilityIdentifier("create.eyedropper")
        }
    }

    // MARK: LETTER COLOR — the same pair of controls, 712px wide, in the left column.

    private var letterColorSection: some View {
        ZStack(alignment: .topLeading) {
            ink("LETTER COLOR", x: 81, capTop: 2426 - Self.keysLift, size: 50.9, .bold)
            saturationSquare(
                x: 77, y: 2509 - Self.keysLift, w: 712, h: 265, cornerRadius: 40,
                hue: binding(\.letterHue), saturation: binding(\.letterSaturation), brightness: binding(\.letterBrightness)
            )
            .accessibilityIdentifier("create.letterColor.square")
            // 4.png draws this rail with no knob at all — the one control on the page with no
            // visible state. Now that it actually moves the letter colour, leaving it knob-less
            // would hide the one thing a live control has to show: where it currently is.
            hueRail(x: 80, y: 2782 - Self.keysLift, w: 708, h: 37, hue: binding(\.letterHue))
                .accessibilityIdentifier("create.letterColor.hueRail")
        }
    }

    // MARK: FONT STYLE — five chips spread across the full content column.
    //
    // 4.png packs these five into the right half of the page (x=857…2082) and drops them at y=2632,
    // which left the Fonts tab as a huddle of chips low and to the right with the whole left side
    // and the band under the pills empty. With the tabs actually switching, this section owns the
    // page on its own, so it starts where BACKGROUND's row starts and runs margin to margin: the
    // same 150…2011 column the background tiles use, five 280px chips on a 398px pitch.
    private static let fontChipWidth: CGFloat = 280
    private static let fontChipHeight: CGFloat = 184
    private static let fontChipTop: CGFloat = 1708
    private static let fontChipPitch: CGFloat = 398
    private static func fontChipX(_ index: Int) -> CGFloat { 139 + CGFloat(index) * fontChipPitch }

    private static let fontStyleAssets: [TypographyOption: (asset: String, caption: String)] = [
        .default: ("create_fontstyle_default", "Default"),
        .rounded: ("create_fontstyle_rounded", "Rounded"),
        .cute: ("create_fontstyle_cute", "Cute"),
        .classic: ("create_fontstyle_classic", "Classic"),
        .handwritten: ("create_fontstyle_handwritten", "Handwritten")
    ]

    private var fontStyleSection: some View {
        ZStack(alignment: .topLeading) {
            ink("FONT STYLE", x: 80, capTop: 1644, size: 50.9, .bold)

            ForEach(Array(TypographyOption.allCases.enumerated()), id: \.offset) { index, option in
                let x = Self.fontChipX(index)
                let selected = viewModel.draft.typography == option
                let spec = Self.fontStyleAssets[option] ?? (asset: "create_fontstyle_default", caption: option.displayName)
                // Top-*leading*: with `.topTrailing` the specimen and its caption, neither of
                // which fills the chip, were pinned to the chip's right edge and drifted right of
                // where the frame draws them.
                Button {
                    viewModel.draft.typography = option
                    viewModel.scheduleAutosave()
                } label: {
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: s(26), style: .continuous)
                            .fill(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: s(26), style: .continuous)
                                    .stroke(MochiColor.outline, lineWidth: panelStroke)
                            )
                            .frame(width: s(Self.fontChipWidth), height: s(Self.fontChipHeight))

                        // The five specimens are cropped from 4.png. Only Inter, Fredoka and Baloo2
                        // are bundled, and none of them is a script face — rendering "Handwritten"
                        // in a substitute would have been the one chip that visibly missed. The
                        // chip still shows that static crop; what actually changes on selection is
                        // `ThemeTypography` on the live preview above, via `TypographyOption`.
                        Image(spec.asset)
                            .resizable()
                            .scaledToFit()
                            .frame(width: s(249))
                            .offset(x: s((Self.fontChipWidth - 249) / 2), y: s(16))

                        Text(spec.caption)
                            .font(font(.regular, 27.5))
                            .foregroundStyle(selected ? MochiColor.logoSolid : MochiColor.textGreyWarm)
                            .frame(width: s(Self.fontChipWidth))
                            // "Classic" is the one caption the frame sets 8px higher than the rest.
                            .offset(y: s(option == .classic ? 119 : 127) - CreateFrame.capInset * s(27.5))

                        if selected {
                            checkBadge(44).offset(x: s(Self.fontChipWidth - 28), y: s(-12))
                        }
                    }
                    .frame(width: s(Self.fontChipWidth), height: s(Self.fontChipHeight), alignment: .topLeading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .offset(x: s(x), y: s(Self.fontChipTop))
                .accessibilityIdentifier("create.font.\(option.rawValue)")
            }
        }
    }

    // MARK: EFFECT — new panel; 4.png names this tab but draws nothing under it.

    private var effectsSection: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: s(38), style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: s(38), style: .continuous)
                        .stroke(MochiColor.outline, lineWidth: panelStroke)
                )
                // 620 ended the panel at y=2228, but `Slider` is the one control here whose height
                // is intrinsic points rather than scaled Figma pixels — about 44pt, i.e. ~236px on
                // this frame — so the intensity row started inside the card and finished outside it.
                // The panel now runs to 2500, which clears the slider's full height with the same
                // ~100px breathing room the chips above it get.
                .modifier(box(CreateFrame.contentLeft, 1608, CreateFrame.contentWidth, 892))

            ink("EFFECTS", x: 153, capTop: 1644, size: 50.9, .bold)
            ink("Ambient particles on the real keyboard — not a preview overlay",
                x: 153, capTop: 1710, size: 34, .regular, MochiColor.textGreyWarm)

            ForEach(Array(EffectOption.allCases.enumerated()), id: \.offset) { index, option in
                let x = 150 + CGFloat(index) * 460
                let selected = viewModel.draft.effect == option
                Button {
                    viewModel.draft.effect = option
                    viewModel.scheduleAutosave()
                } label: {
                    ZStack(alignment: .topTrailing) {
                        RoundedRectangle(cornerRadius: s(26), style: .continuous)
                            .fill(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: s(26), style: .continuous)
                                    .stroke(selected ? MochiColor.logoSolid : MochiColor.outline, lineWidth: selected ? panelStroke * 2 : panelStroke)
                            )
                            .overlay(
                                VStack(spacing: s(14)) {
                                    Image(systemName: effectIcon(option))
                                        .font(.system(size: s(56)))
                                        .foregroundStyle(MochiColor.logoSolid)
                                    Text(option.displayName)
                                        .font(font(.regular, 34))
                                        .foregroundStyle(selected ? MochiColor.logoSolid : MochiColor.textGreyWarm)
                                }
                            )
                            .frame(width: s(420), height: s(220))
                        if selected {
                            checkBadge(44).offset(x: s(-10), y: s(10))
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .offset(x: s(x), y: s(1800))
                .accessibilityIdentifier("create.effect.\(option.rawValue)")
            }

            ink("INTENSITY", x: 153, capTop: 2110, size: 44, .bold)
            Slider(value: binding(\.effectIntensity), in: 0...1)
                .tint(MochiColor.logoSolid)
                // Height pinned so the row occupies a known band rather than whatever the control's
                // intrinsic point height happens to be — that's what put it outside the card.
                .frame(width: s(1750), height: s(240))
                .offset(x: s(150), y: s(2190))
                .disabled(viewModel.draft.effect == .none)
                .opacity(viewModel.draft.effect == .none ? 0.4 : 1)
                .accessibilityIdentifier("create.effect.intensity")
        }
    }

    private func effectIcon(_ option: EffectOption) -> String {
        switch option {
        case .none: return "slash.circle"
        case .sparkle: return "sparkles"
        case .snowfall: return "snowflake"
        case .confetti: return "party.popper"
        }
    }

    // MARK: LIVE PREVIEW — a 2003x193px panel with a 284x92px Reset All capsule at its right.

    private var livePreviewCard: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: s(38), style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: s(38), style: .continuous)
                        .stroke(MochiColor.outline, lineWidth: panelStroke)
                )
                .modifier(box(CreateFrame.contentLeft, 2864, CreateFrame.contentWidth, 193))

            Image(systemName: "eye.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(MochiColor.logoSolid)
                .modifier(box(167, 2930, 65, 44))

            ink("LIVE PREVIEW", x: 253, capTop: 2913, size: 50.9, .bold, MochiColor.logoSolid)
            ink(
                validationCaption,
                x: 253, capTop: 2976, size: 34.1, .regular,
                validationHasErrors ? MochiColor.heart : MochiColor.textGreyWarm
            )

            Button { viewModel.resetAll() } label: {
                Capsule()
                    .fill(Color.white)
                    .overlay(Capsule().stroke(MochiColor.logoSolid, lineWidth: panelStroke))
                    .overlay(
                        // Mark 37px of ink, then 30px, then 149px of label — 215px centred in a
                        // 284px capsule.
                        HStack(spacing: s(30)) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: s(32), weight: .regular))
                            Text("Reset All").font(font(.regular, 37))
                        }
                        .foregroundStyle(MochiColor.logoSolid)
                    )
                    .frame(width: s(284), height: s(92))
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .offset(x: s(1739), y: s(2914))
            .accessibilityIdentifier("create.resetAll")
        }
    }

    /// Live-validates the *current* draft on every render — this is a `ThemeValidator.Report` read,
    /// not a cached value, so the moment a colour choice makes a key illegible the caption below
    /// "Live Preview" says so immediately, before the user ever taps Publish and finds out then.
    private var validationHasErrors: Bool { !viewModel.validation.isPublishable }

    private var validationCaption: String {
        if let first = viewModel.validation.errors.first {
            return first.message
        }
        return "See Real-Time Changes On The Keyboard Above"
    }

    // MARK: Theme name and tags — two 112px fields under their headings.

    /// Measured left edges of the four chips; the frame's own pitch drifts by a few pixels. Also the
    /// hard cap on tag count — the panel is exactly wide enough for four, and this screen deliberately
    /// isn't reflowing that box to fit a fifth.
    private static let tagX: [CGFloat] = [1000, 1241, 1491, 1741]

    private var nameAndTags: some View {
        ZStack(alignment: .topLeading) {
            // The Figma frame heads the theme-name field "LETTER COLOR" — a copy-paste left over
            // from the KEY/LETTER COLOR block above it. Corrected here rather than reproduced: a
            // name field labelled "LETTER COLOR" is a delivery defect regardless of the source.
            ink("THEME NAME", x: 83, capTop: 3118, size: 50.9, .bold)

            HStack(spacing: s(14)) {
                Text("TAGS").font(font(.bold, 50.9)).foregroundStyle(MochiColor.textPrimary)
                Text("(Optional)").font(font(.regular, 50.9)).foregroundStyle(MochiColor.textGreyWarm)
            }
            .fixedSize()
            .offset(x: s(975), y: s(3118) - CreateFrame.capInset * s(50.9))

            // Theme name field
            RoundedRectangle(cornerRadius: s(56), style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: s(56), style: .continuous)
                        .stroke(MochiColor.outline, lineWidth: panelStroke)
                )
                .overlay(alignment: .leading) {
                    TextField("", text: binding(\.name), prompt:
                        Text("My Dreamy Theme")
                            .font(font(.regular, 44))
                            .foregroundColor(MochiColor.textGreyWarm)
                    )
                    .font(font(.regular, 44))
                    .foregroundStyle(MochiColor.textPrimary)
                    .textInputAutocapitalization(.words)
                    .padding(.leading, s(41))
                    .padding(.trailing, s(160))
                }
                .overlay(alignment: .trailing) {
                    Image(systemName: "pencil.line")
                        .font(.system(size: s(52), weight: .regular))
                        .foregroundStyle(MochiColor.logoSolid)
                        .padding(.trailing, s(62))
                }
                .modifier(box(CreateFrame.contentLeft, 3196, 833, 112))
                .accessibilityIdentifier("create.name")

            // Tags
            RoundedRectangle(cornerRadius: s(56), style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: s(56), style: .continuous)
                        .stroke(MochiColor.outline, lineWidth: panelStroke)
                )
                .modifier(box(965, 3196, 1117, 112))

            ForEach(Array(viewModel.draft.tags.prefix(Self.tagX.count).enumerated()), id: \.offset) { index, tag in
                Button {
                    viewModel.draft.tags.remove(at: index)
                    viewModel.scheduleAutosave()
                } label: {
                    Capsule()
                        .fill(MochiGradient.tagPill)
                        .overlay(
                            HStack(spacing: s(26)) {
                                Text(tag).font(font(.regular, 37.5))
                                Text("X").font(font(.regular, 37.5))
                            }
                            .foregroundStyle(MochiColor.textPrimary)
                        )
                        .frame(width: s(220), height: s(73))
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .offset(x: s(Self.tagX[index]), y: s(3215))
                .accessibilityIdentifier("create.tag.\(index)")
            }

            if viewModel.draft.tags.count < Self.tagX.count {
                Button { showAddTag = true } label: {
                    Image(systemName: "plus")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(MochiColor.textPrimary)
                        .frame(width: s(47), height: s(47))
                        // Padded well past the 47px glyph: a 9pt mark is under half the 44pt
                        // minimum touch target, and this one sits inside a crowded field row.
                        .padding(s(30))
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .offset(x: s(1994) - s(30), y: s(3228) - s(30))
                .accessibilityIdentifier("create.tag.add")
            }
        }
    }

    /// No Figma source for this — the design has no error/status affordance anywhere on the page,
    /// same "no UI exists for this yet" gap android/.../CreateThemeScreen.kt's StatusBanner notes.
    @ViewBuilder
    private var statusBanner: some View {
        let message: (text: String, color: Color)? = {
            switch viewModel.publishState {
            case .success(let published):
                return (published ? "Published! It's already live in Themes, and queued for the community feed." : "Draft saved.", MochiColor.logoSolid)
            case .error(let message):
                return (message, MochiColor.heart)
            case .idle, .saving:
                return nil
            }
        }()
        if let message {
            centredInk(message.text, at: 1080, capTop: 3330, size: 34, .regular, message.color)
        }
    }

    private var isSaving: Bool { viewModel.publishState == .saving }

    /// Every interactive control on this screen is a real `Button`, never bare `.onTapGesture`.
    /// This canvas is one enormous flat `ZStack` — every tile, chip, tab and swatch is a sibling of
    /// everything else, absolutely positioned to a Figma coordinate — and on-device that many
    /// concurrent `.onTapGesture` recognizers competing in one view tree turned out to be
    /// genuinely broken: this session's own end-to-end UI test caught every single tap, anywhere
    /// on the page, being delivered to whichever `.onTapGesture` happened to be attached last (the
    /// Publish button), regardless of where the touch actually landed. `Button` gives each control
    /// its own real, independent touch-handling machinery instead of a shared gesture-recognizer
    /// pool, and the tap-target bugs did not reproduce once every control was converted.
    ///
    /// The picker square and hue rail below are the one exception — they need continuous
    /// `DragGesture` tracking, which `Button` cannot express — and having only four of those,
    /// spatially disjoint, is what keeps them out of the failure mode above.

    // MARK: Save Draft / Publish Theme — two 977x186px halves with a 50px gutter.

    private var actionButtons: some View {
        ZStack(alignment: .topLeading) {
            Button { if !isSaving { save(publish: false) } } label: {
                RoundedRectangle(cornerRadius: s(38), style: .continuous)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: s(38), style: .continuous)
                            .stroke(MochiColor.outline, lineWidth: panelStroke)
                    )
                    .frame(width: s(977), height: s(186))
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .offset(x: s(CreateFrame.contentLeft), y: s(3356))
            .accessibilityIdentifier("create.saveDraft")

            Button { if !isSaving { save(publish: true) } } label: {
                RoundedRectangle(cornerRadius: s(38), style: .continuous)
                    .fill(MochiGradient.softButton)
                    .frame(width: s(977), height: s(186))
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .offset(x: s(1105), y: s(3356))
            .accessibilityIdentifier("create.publish")

            buttonLabel(
                // Neither half centres its label on the button: the frame sets both rows a little
                // to the left of centre, so each row carries its own measured centre.
                titleCentre: 554, subtitleCentre: 538,
                icon: AnyView(
                    FloppyGlyph()
                        .stroke(MochiColor.logoSolid, lineWidth: s(5))
                        .frame(width: s(46), height: s(56))
                ),
                iconGap: 31,
                title: "Save Draft",
                subtitle: "Save Your Work For Later",
                titleColour: MochiColor.logoSolid,
                subtitleColour: MochiColor.textGreyWarm
            )

            buttonLabel(
                titleCentre: 1570, subtitleCentre: 1568,
                icon: AnyView(
                    Image(systemName: "paperplane")
                        .resizable()
                        .scaledToFit()
                        .frame(width: s(60), height: s(60))
                        .foregroundStyle(MochiColor.textPrimary)
                ),
                iconGap: 33,
                title: "Publish Theme",
                subtitle: "Share With The Community",
                titleColour: MochiColor.textPrimary,
                subtitleColour: MochiColor.textPrimary
            )
        }
    }

    /// Both halves carry the same two lines: a mark beside a title whose caps sit on y=3398, then
    /// a lighter line whose caps sit on y=3467. The two are placed independently rather than
    /// stacked — a VStack's spacing has to absorb the line boxes of two different sizes, and the
    /// 69px the frame leaves between the two cap tops came out at 102px that way, close enough to
    /// collide.
    ///
    /// The title is **SemiBold, not Bold**. At Bold the strokes came out visibly heavier than the
    /// frame's while the word itself ran short, which is the "everything is bold" tell.
    private func buttonLabel(
        titleCentre: CGFloat,
        subtitleCentre: CGFloat,
        icon: AnyView,
        iconGap: CGFloat,
        title: String,
        subtitle: String,
        titleColour: Color,
        subtitleColour: Color
    ) -> some View {
        ZStack(alignment: .topLeading) {
            centred(
                HStack(spacing: s(iconGap)) {
                    icon
                    Text(title).font(font(.semibold, 55)).foregroundStyle(titleColour)
                }
                .frame(height: s(66)),
                at: titleCentre, top: 3388, height: 66
            )
            centredInk(subtitle, at: subtitleCentre, capTop: 3467, size: 47, .regular, subtitleColour)
        }
    }
}

/// Places and sizes a view in points that were computed from Figma pixels. Kept as a modifier so
/// the call sites stay one line and read as `(x, y, w, h)` the way the measurements do.
private struct BoxModifier: ViewModifier {
    let x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat

    func body(content: Content) -> some View {
        content
            .frame(width: w, height: h)
            .offset(x: x, y: y)
    }
}

// MARK: - Background gallery (new — no Figma source; see the type doc on why)

/// The full browsable set of real background plates. Not pixel-matched to anything in 4.png — no
/// frame for it exists — built from the app's own design tokens instead so it reads as part of this
/// screen rather than a foreign sheet.
private struct BackgroundGallerySheet: View {
    @Binding var background: BackgroundChoice
    var onSelect: () -> Void
    @Environment(\.dismiss) private var dismiss

    private let plates = BackgroundChoice.availablePlates
    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 14)]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 18) {
                    ForEach(plates, id: \.assetName) { plate in
                        tile(assetName: plate.assetName, displayName: plate.displayName)
                    }
                }
                .padding(18)
            }
            .background(MochiColor.screenBackgroundFallback.opacity(0.4))
            .navigationTitle("Choose a Background")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private func isSelected(_ assetName: String) -> Bool {
        if case .plate(let name, _) = background { return name == assetName }
        return false
    }

    private func tile(assetName: String, displayName: String) -> some View {
        Button {
            background = .plate(assetName: assetName, displayName: displayName)
            onSelect()
            dismiss()
        } label: {
            VStack(spacing: 8) {
                Image(assetName)
                    .resizable()
                    .aspectRatio(1.6, contentMode: .fill)
                    .frame(height: 96)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(isSelected(assetName) ? MochiColor.logoSolid : Color.clear, lineWidth: 3)
                    )
                    .overlay(alignment: .topTrailing) {
                        if isSelected(assetName) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(MochiColor.logoSolid)
                                .background(Circle().fill(.white))
                                .padding(6)
                        }
                    }
                Text(displayName)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(MochiColor.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("create.gallery.\(assetName)")
    }
}

/// The "Colors" tile's destination: two authored gradients plus a real system colour picker (which
/// includes its own eyedropper) for a solid background.
private struct BackgroundColorSheet: View {
    @Binding var background: BackgroundChoice
    var onSelect: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var customColor: Color

    init(background: Binding<BackgroundChoice>, onSelect: @escaping () -> Void) {
        _background = background
        self.onSelect = onSelect
        if case .solid(let hue, let saturation, let brightness) = background.wrappedValue {
            _customColor = State(initialValue: Color(ThemeColor(hue: hue, saturation: saturation, brightness: brightness).uiColor))
        } else {
            _customColor = State(initialValue: .white)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 28) {
                Text("Gradient").font(.headline).foregroundStyle(MochiColor.textPrimary)
                HStack(spacing: 20) {
                    ForEach(GradientPreset.allCases) { preset in
                        gradientSwatch(preset)
                    }
                    Spacer()
                }

                Divider()

                Text("Solid Color").font(.headline).foregroundStyle(MochiColor.textPrimary)
                ColorPicker("Pick a colour", selection: $customColor, supportsOpacity: false)
                    .onChange(of: customColor) { newColor in
                        let hsb = ThemeColor(uiColor: UIColor(newColor)).hsbComponents
                        background = .solid(hue: hsb.hue, saturation: hsb.saturation, brightness: hsb.brightness)
                        onSelect()
                    }

                Spacer()
            }
            .padding(24)
            .navigationTitle("Background Color")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private func isSelected(_ preset: GradientPreset) -> Bool {
        if case .gradient(let current) = background { return current == preset }
        return false
    }

    private func gradientSwatch(_ preset: GradientPreset) -> some View {
        Button {
            background = .gradient(preset)
            onSelect()
            dismiss()
        } label: {
            VStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(LinearGradient(
                        colors: preset.stops.map { Color($0.uiColor) },
                        startPoint: .top, endPoint: .bottom
                    ))
                    .frame(width: 84, height: 64)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(isSelected(preset) ? MochiColor.logoSolid : Color.clear, lineWidth: 3)
                    )
                Text(preset.displayName).font(.caption).foregroundStyle(MochiColor.textPrimary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("create.gradient.\(preset.rawValue)")
    }
}

/// A real colour picker — including the system's own eyedropper tool — for the key colour. A
/// second hand-built HSB square here would duplicate `saturationSquare`/`hueRail` for no reason;
/// this is a genuinely different, system-provided interaction (sampling any colour on screen), not
/// a re-skin of the same one.
private struct EyedropperSheet: View {
    let themeColor: ThemeColor
    var onPick: (ThemeColor) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var picked: Color

    init(themeColor: ThemeColor, onPick: @escaping (ThemeColor) -> Void) {
        self.themeColor = themeColor
        self.onPick = onPick
        _picked = State(initialValue: Color(themeColor.uiColor))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                ColorPicker("Key Color", selection: $picked, supportsOpacity: false)
                    .font(.headline)
                Text("Tap the swatch, then use the eyedropper in the system picker to sample any colour on screen.")
                    .font(.footnote)
                    .foregroundStyle(MochiColor.textGreyWarm)
                Spacer()
            }
            .padding(24)
            .navigationTitle("Eyedropper")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        onPick(ThemeColor(uiColor: UIColor(picked)))
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    CreateThemeView()
}
