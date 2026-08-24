import PhotosUI
import SwiftUI

/// Built against docs/figma/4.png — the Create Custom Theme frame — the same way HomeView is built
/// against 1.png and ThemesView against 8.png: every number below is a pixel measured off that
/// export, not an eyeballed value.
///
/// **Why this page is laid out absolutely rather than in stacks.** Unlike the other frames, 4.png
/// is not a column of rows. Its middle third interleaves three ragged columns whose blocks overlap
/// vertically — "LETTER COLOR"'s cap (y=2426) sits *above* the KEY COLOR rail (y=2463) which sits
/// above the eyedropper (y=2425–2515) in the next column over — so no arrangement of HStacks and
/// VStacks reproduces it without inventing spacing the design never had. Every element is
/// therefore placed at its measured Figma coordinate on a canvas that is the frame, scaled.
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
    var body: some View {
        GeometryReader { geo in
            ScrollView(showsIndicators: false) {
                CreateThemeCanvas(k: geo.size.width / CreateFrame.width)
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

    @State private var tab: EditorTab = .fonts
    /// `nil` when a gallery photo is picked instead — mutually exclusive with `galleryImageData`,
    /// matching android/.../CreateThemeScreen.kt's `presetBackground: Int?` / `galleryUri: Uri?`.
    @State private var background: Int? = 0
    @State private var keyShape: Int = 0
    @State private var fontStyle: Int = 0
    @State private var themeName: String = ""
    @State private var tags: [String] = ["Cute", "Purple", "Dream", "Cloud"]

    @State private var galleryPickerItem: PhotosPickerItem?
    @State private var galleryImageData: Data?

    @StateObject private var viewModel = CreateThemeViewModel(container: AppContainer.shared)

    var body: some View {
        ZStack(alignment: .topLeading) {
            header
            keyboardPreview
            editorTabs
            backgroundCard
            keyShapeSection
            keyColorSection
            recentSection
            letterColorSection
            fontStyleSection
            livePreviewCard
            nameAndTags
            statusBanner
            actionButtons
        }
        // `of:perform:` rather than the two-parameter `of:initial:_:` — this project's deployment
        // target is iOS 16, and the newer overload needs 17.
        .onChange(of: galleryPickerItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    galleryImageData = data
                    background = nil
                }
            }
        }
        .onChange(of: viewModel.publishState) { newState in
            if case .success = newState {
                themeName = ""
                tags = []
                galleryImageData = nil
                galleryPickerItem = nil
                background = 0
            }
        }
    }

    private func save(publish: Bool) {
        viewModel.save(
            name: themeName,
            tags: tags,
            presetBackgroundIndex: background,
            galleryImageData: galleryImageData,
            keyShapeIndex: keyShape,
            fontStyleIndex: fontStyle,
            publish: publish
        )
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
            Circle()
                .fill(MochiGradient.themeCircleButton)
                .overlay(
                    Image(systemName: "arrow.left")
                        .font(.system(size: s(78), weight: .medium))
                        .foregroundStyle(MochiColor.textPrimary)
                )
                .modifier(box(77, 76, 153, 153))

            // 864px of ink, cap 137–196px: Inter Bold at 81.6px, in the wordmark's flat #9C28B1.
            centredInk("Create Custom Theme", at: 1080, capTop: 137,
                       size: 80.7, .bold, MochiColor.logoSolid)

            // 636px of ink: Inter Regular at 42.4px, in the warm grey the Fonts frame also uses.
            centredInk("Design your own keyboard theme", at: 1080, capTop: 221,
                       size: 40, .regular, MochiColor.textGreyWarm)
        }
    }

    // MARK: Live keyboard — 2009x1083px of artwork, 60px corner.

    private var keyboardPreview: some View {
        Image("create_keyboard_preview")
            .resizable()
            // The crop is 2009x1084 and the slot is 2009x1083, so `fill` trims a single pixel
            // rather than stretching the art the way `fit` letterboxing would force.
            .aspectRatio(contentMode: .fill)
            .frame(width: s(2009), height: s(1083))
            // Clipped before the offset, never after: `.offset` is a render-time transform, so a
            // clip shape applied downstream of it is still laid out at the *un*-offset origin and
            // slices the artwork in half.
            .clipShape(RoundedRectangle(cornerRadius: s(60), style: .continuous))
            .offset(x: s(76), y: s(320))
    }

    // MARK: Editor tabs — one white capsule, 2003x102px, with the selected label on a 294px pill.

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
    }

    private var editorTabs: some View {
        ZStack(alignment: .topLeading) {
            Capsule()
                .fill(Color.white)
                .overlay(Capsule().stroke(MochiColor.outline, lineWidth: panelStroke))
                .modifier(box(CreateFrame.contentLeft, 1466, CreateFrame.contentWidth, 102))

            Capsule()
                .fill(MochiGradient.editorPill)
                .modifier(box(tab.centre - 147, 1471, 294, 92))
                .animation(.easeInOut(duration: 0.18), value: tab)

            ForEach(EditorTab.allCases) { item in
                centred(
                    HStack(spacing: s(item.iconGap)) {
                        tabIcon(item)
                            .frame(width: s(item.iconWidth), height: s(item.iconWidth))
                        Text(item.rawValue)
                            .font(font(.regular, 51))
                    }
                    .frame(height: s(70))
                    .foregroundStyle(tab == item ? MochiColor.textPrimary : MochiColor.textGreyWarm),
                    at: item.centre, top: 1466, height: 102
                )
                .contentShape(Rectangle())
                .onTapGesture { tab = item }
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

    // MARK: BACKGROUND card — six 271x248px tiles on a 318px pitch inside a 2003x382px panel.

    private static let tileWidth: CGFloat = 271
    private static let tilePitch: CGFloat = 318
    private static let tileTop: CGFloat = 1708
    private static let tileHeight: CGFloat = 248

    private func tileX(_ index: Int) -> CGFloat { 150 + CGFloat(index) * Self.tilePitch }

    private var backgroundCard: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: s(38), style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: s(38), style: .continuous)
                        .stroke(MochiColor.outline, lineWidth: panelStroke)
                )
                .modifier(box(CreateFrame.contentLeft, 1608, CreateFrame.contentWidth, 382))

            ink("BACKGROUND", x: 153, capTop: 1644, size: 50.9, .bold)

            // 86x84px of ink, stroked about 12px — drawn rather than taken from SF, whose `plus`
            // has no size at which both its bar length and its weight match the frame's.
            PhotosPicker(selection: $galleryPickerItem, matching: .images) {
                sourceTile(index: 0, glyph: AnyView(
                    ZStack {
                        Capsule().frame(width: s(86), height: s(12))
                        Capsule().frame(width: s(12), height: s(84))
                    }
                    .foregroundStyle(MochiColor.logoSolid)
                ), glyphHeight: 84, caption: "Gallery", isSelected: galleryImageData != nil)
            }
            .buttonStyle(.plain)

            // Colors has no gesture wired, matching the saturation-square precedent elsewhere on
            // this screen — only Gallery became real (a system photo picker + Storage upload).
            sourceTile(index: 1, glyph: AnyView(
                ColorWheelGlyph().frame(width: s(108), height: s(108))
            ), glyphHeight: 108, caption: "Colors", isSelected: false)

            ForEach(0..<4, id: \.self) { artwork in
                artworkTile(artwork)
            }
        }
    }

    /// The two left-hand tiles: a white chip outlined in #9C28B1 with a mark over a caption. Mark
    /// and caption are placed against their own measurements rather than stacked, because the two
    /// marks are different heights (84px and 108px) and a shared VStack lets the taller one push
    /// its caption down out of line with the other tile's.
    private func sourceTile(index: Int, glyph: AnyView, glyphHeight: CGFloat, caption: String, isSelected: Bool) -> some View {
        let x = tileX(index)
        let centre = x + Self.tileWidth / 2
        return ZStack(alignment: .topTrailing) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: s(30), style: .continuous)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: s(30), style: .continuous)
                            .stroke(MochiColor.logoSolid, lineWidth: panelStroke)
                    )
                    .modifier(box(x, Self.tileTop, Self.tileWidth, Self.tileHeight))

                centred(glyph, at: centre, top: 1815 - glyphHeight / 2, height: glyphHeight)
                centredInk(caption, at: centre, capTop: 1900, size: 40, .regular, MochiColor.logoSolid)
            }
            if isSelected {
                checkBadge(52).offset(x: s(x + Self.tileWidth - 26), y: s(Self.tileTop - 16))
            }
        }
    }

    /// The four artwork tiles, cropped straight out of 4.png so they are the design's own images.
    private func artworkTile(_ artwork: Int) -> some View {
        let x = tileX(artwork + 2)
        let selected = background == artwork
        return ZStack(alignment: .topTrailing) {
            Image("create_bg_thumb_\(artwork + 1)")
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
        .offset(x: s(x), y: s(Self.tileTop))
        .onTapGesture {
            background = artwork
            galleryImageData = nil
            galleryPickerItem = nil
        }
    }

    // MARK: KEY SHAPE — four 178px chips on a 208px pitch, each holding a 100px preview.

    private var keyShapeSection: some View {
        ZStack(alignment: .topLeading) {
            ink("KEY SHAPE", x: 80, capTop: 2044, size: 50.9, .bold)

            ForEach(0..<4, id: \.self) { index in
                let x = 139 + CGFloat(index) * 208
                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: s(28), style: .continuous)
                        .stroke(MochiColor.logoSolid, lineWidth: panelStroke)
                        .frame(width: s(178), height: s(178))
                        .overlay(shapePreview(index).frame(width: s(100), height: s(100)))

                    if keyShape == index {
                        checkBadge(48).offset(x: s(18), y: s(-14))
                    }
                }
                .frame(width: s(178), height: s(178), alignment: .topLeading)
                .offset(x: s(x), y: s(2148))
                .onTapGesture { keyShape = index }
            }
        }
    }

    @ViewBuilder
    private func shapePreview(_ index: Int) -> some View {
        switch index {
        case 0:
            Rectangle()
                .fill(MochiGradient.keyShapePreview)
                .overlay(Rectangle().stroke(MochiColor.outline.opacity(0.7), lineWidth: panelStroke * 0.6))
        case 1:
            RoundedRectangle(cornerRadius: s(26), style: .continuous)
                .fill(MochiGradient.keyShapePreview)
                .overlay(
                    RoundedRectangle(cornerRadius: s(26), style: .continuous)
                        .stroke(MochiColor.outline.opacity(0.7), lineWidth: panelStroke * 0.6)
                )
        case 2:
            Circle()
                .fill(MochiGradient.keyShapePreview)
                .overlay(Circle().stroke(MochiColor.outline.opacity(0.7), lineWidth: panelStroke * 0.6))
        default:
            HexagonShape()
                .fill(MochiGradient.keyShapePreview)
                .overlay(HexagonShape().stroke(MochiColor.outline.opacity(0.7), lineWidth: panelStroke * 0.6))
        }
    }

    // MARK: KEY COLOR — a 612x294px saturation/value square over a 610x35px hue rail.

    private var keyColorSection: some View {
        ZStack(alignment: .topLeading) {
            ink("KEY COLOR", x: 1007, capTop: 2044, size: 50.9, .bold)
            saturationSquare(x: 998, y: 2125, w: 612, h: 294, knob: CGPoint(x: 1300, y: 2262))
            hueRail(x: 1000, y: 2463, w: 610, h: 35, knob: 1305)
        }
    }

    /// White across, black down — the standard picker square. The hue it resolves toward is
    /// `pickerHue`, solved from the frame rather than taken from the app palette.
    private func saturationSquare(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat, knob: CGPoint) -> some View {
        RoundedRectangle(cornerRadius: s(40), style: .continuous)
            .fill(
                LinearGradient(colors: [.white, MochiColor.pickerHue],
                               startPoint: .leading, endPoint: .trailing)
            )
            .overlay(
                RoundedRectangle(cornerRadius: s(40), style: .continuous)
                    .fill(
                        LinearGradient(stops: [.init(color: .black.opacity(0), location: 0.12),
                                              .init(color: .black.opacity(0.78), location: 1.0)],
                                       startPoint: .top, endPoint: .bottom)
                    )
            )
            .overlay(alignment: .topLeading) {
                Circle()
                    .stroke(.white, lineWidth: s(7))
                    .frame(width: s(56), height: s(56))
                    .offset(x: s(knob.x - x) - s(28), y: s(knob.y - y) - s(28))
            }
            .modifier(box(x, y, w, h))
    }

    private func hueRail(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat, knob: CGFloat?) -> some View {
        Capsule()
            .fill(MochiGradient.hueSpectrum)
            .overlay(alignment: .leading) {
                if let knob {
                    Circle()
                        .fill(.white)
                        .frame(width: s(52), height: s(52))
                        .offset(x: s(knob - x) - s(26))
                }
            }
            .modifier(box(x, y, w, h))
    }

    // MARK: RECENT — a 3x2 grid of 119x107px swatches, plus the eyedropper below it.

    private var recentSection: some View {
        ZStack(alignment: .topLeading) {
            // 143px wide against 267px for "KEY SHAPE": this heading is set noticeably smaller
            // than the others on the frame — 28px of cap rather than 37px.
            ink("RECENT", x: 1634, capTop: 2077, size: 35.5, .bold)

            ForEach(0..<6, id: \.self) { index in
                let column = index % 3, row = index / 3
                RoundedRectangle(cornerRadius: s(22), style: .continuous)
                    .fill(MochiColor.recentSwatches[index])
                    .modifier(box(1672 + CGFloat(column) * 146,
                                  2152 + CGFloat(row) * 137,
                                  119, 107))
            }

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
                .modifier(box(1809, 2425, 142, 90))
        }
    }

    // MARK: LETTER COLOR — the same pair of controls, 712px wide, in the left column.

    private var letterColorSection: some View {
        ZStack(alignment: .topLeading) {
            ink("LETTER COLOR", x: 81, capTop: 2426, size: 50.9, .bold)
            saturationSquare(x: 77, y: 2509, w: 712, h: 265, knob: CGPoint(x: 416, y: 2627))
            // This rail carries no knob in the frame; its counterpart under KEY COLOR does.
            hueRail(x: 80, y: 2782, w: 708, h: 37, knob: nil)
        }
    }

    // MARK: FONT STYLE — five 221x184px chips ending flush with the right margin.

    /// Measured left edges. The frame does not space these evenly — the gaps run 25, 29, 29 and
    /// 37px — so an averaged pitch walks the last two chips several pixels off.
    private static let fontChipX: [CGFloat] = [857, 1103, 1353, 1603, 1861]

    private static let fontStyles: [(asset: String, caption: String)] = [
        ("create_fontstyle_default", "Default"),
        ("create_fontstyle_rounded", "Rounded"),
        ("create_fontstyle_cute", "Cute"),
        ("create_fontstyle_classic", "Classic"),
        ("create_fontstyle_handwritten", "Handwritten")
    ]

    private var fontStyleSection: some View {
        ZStack(alignment: .topLeading) {
            ink("FONT STYLE", x: 855, capTop: 2544, size: 50.9, .bold)

            ForEach(Array(Self.fontStyles.enumerated()), id: \.offset) { index, style in
                let x = Self.fontChipX[index]
                let selected = fontStyle == index
                // Top-*leading*: with `.topTrailing` the specimen and its caption, neither of
                // which fills the chip, were pinned to the chip's right edge and drifted right of
                // where the frame draws them.
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: s(26), style: .continuous)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: s(26), style: .continuous)
                                .stroke(MochiColor.outline, lineWidth: panelStroke)
                        )
                        .frame(width: s(221), height: s(184))

                    // The five specimens are cropped from 4.png. Only Inter, Fredoka and Baloo2
                    // are bundled, and none of them is a script face — rendering "Handwritten" in
                    // a substitute would have been the one chip that visibly missed.
                    Image(style.asset)
                        .resizable()
                        .scaledToFit()
                        .frame(width: s(197))
                        .offset(x: s(12), y: s(16))

                    Text(style.caption)
                        .font(font(.regular, 27.5))
                        .foregroundStyle(selected ? MochiColor.logoSolid : MochiColor.textGreyWarm)
                        .frame(width: s(221))
                        // "Classic" is the one caption the frame sets 8px higher than the rest.
                        .offset(y: s((index == 3 ? 2751 : 2759) - 2632) - CreateFrame.capInset * s(27.5))

                    if selected {
                        checkBadge(44).offset(x: s(221 - 28), y: s(-12))
                    }
                }
                .frame(width: s(221), height: s(184), alignment: .topLeading)
                .offset(x: s(x), y: s(2632))
                .onTapGesture { fontStyle = index }
            }
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
            ink("See Real-Time Changes On The Keyboard Above",
                x: 253, capTop: 2976, size: 36.1, .regular, MochiColor.textGreyWarm)

            Capsule()
                .fill(Color.white)
                .overlay(Capsule().stroke(MochiColor.logoSolid, lineWidth: panelStroke))
                .overlay(
                    // Mark 37px of ink, then 30px, then 149px of label — 215px centred in a 284px
                    // capsule.
                    HStack(spacing: s(30)) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: s(32), weight: .regular))
                        Text("Reset All").font(font(.regular, 37))
                    }
                    .foregroundStyle(MochiColor.logoSolid)
                )
                .modifier(box(1739, 2914, 284, 92))
        }
    }

    // MARK: Theme name and tags — two 112px fields under their headings.

    private var nameAndTags: some View {
        ZStack(alignment: .topLeading) {
            // Reproduced verbatim: the frame really does head the theme-name field "LETTER COLOR",
            // a copy-paste left over from the block above it. Corrected to "THEME NAME" the moment
            // the design is.
            ink("LETTER COLOR", x: 83, capTop: 3118, size: 50.9, .bold)

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
                    TextField("", text: $themeName, prompt:
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

            // Tags
            RoundedRectangle(cornerRadius: s(56), style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: s(56), style: .continuous)
                        .stroke(MochiColor.outline, lineWidth: panelStroke)
                )
                .modifier(box(965, 3196, 1117, 112))

            ForEach(Array(tags.prefix(Self.tagX.count).enumerated()), id: \.offset) { index, tag in
                Capsule()
                    .fill(MochiGradient.tagPill)
                    .overlay(
                        HStack(spacing: s(26)) {
                            Text(tag).font(font(.regular, 37.5))
                            Text("X").font(font(.regular, 37.5))
                        }
                        .foregroundStyle(MochiColor.textPrimary)
                    )
                    .modifier(box(Self.tagX[index], 3215, 220, 73))
                    .onTapGesture { tags.remove(at: index) }
            }

            Image(systemName: "plus")
                .resizable()
                .scaledToFit()
                .foregroundStyle(MochiColor.textPrimary)
                .modifier(box(1994, 3228, 47, 47))
        }
    }

    /// Measured left edges of the four chips; the frame's own pitch drifts by a few pixels.
    private static let tagX: [CGFloat] = [1000, 1241, 1491, 1741]

    /// No Figma source for this — the design has no error/status affordance anywhere on the page,
    /// same "no UI exists for this yet" gap android/.../CreateThemeScreen.kt's StatusBanner notes.
    @ViewBuilder
    private var statusBanner: some View {
        let message: (text: String, color: Color)? = {
            switch viewModel.publishState {
            case .success(let published):
                return (published ? "Published! It'll appear in Community once approved." : "Draft saved.", MochiColor.logoSolid)
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

    // MARK: Save Draft / Publish Theme — two 977x186px halves with a 50px gutter.

    private var actionButtons: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: s(38), style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: s(38), style: .continuous)
                        .stroke(MochiColor.outline, lineWidth: panelStroke)
                )
                .modifier(box(CreateFrame.contentLeft, 3356, 977, 186))
                .contentShape(Rectangle())
                .onTapGesture { if !isSaving { save(publish: false) } }

            RoundedRectangle(cornerRadius: s(38), style: .continuous)
                .fill(MochiGradient.softButton)
                .modifier(box(1105, 3356, 977, 186))
                .contentShape(Rectangle())
                .onTapGesture { if !isSaving { save(publish: true) } }

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

#Preview {
    CreateThemeView()
}
