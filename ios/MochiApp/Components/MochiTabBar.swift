import SwiftUI

struct MochiTabBar: View {
    /// Optional because Profile is presented over the tabs with **no** tab selected — that is how
    /// docs/figma/3.png draws the bar, and a non-optional binding cannot express it.
    @Binding var selected: MochiTab?

    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                tabButton(.keyboard)
                tabButton(.fonts)
                Spacer().frame(width: 64)
                tabButton(.themes)
                tabButton(.community)
            }
            .padding(.horizontal, MochiSpacing.md)
            .background(
                Color.white
                    .clipShape(NotchedTabBarShape())
                    .overlay(
                        // Figma's exported layer for this bar carries a 1pt stroke in the exact
                        // same solid purple as the "Mochi" wordmark (#9C28B1) — not just a shadow.
                        NotchedTabBarShape()
                            .stroke(MochiColor.logoSolid, lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.06), radius: 14, y: -4)
                    // Extends the white bar through the home-indicator safe area down to the true
                    // bottom edge (matching Figma) without pushing the icon row itself down there.
                    .ignoresSafeArea(edges: .bottom)
            )

            // Drawn 40pt above the bar, so most of the circle sits outside the ZStack's bounds.
            // SwiftUI still renders it there but will not deliver touches outside a parent's
            // bounds, so the button is given the room it needs inside the stack instead of relying
            // on the offset alone.
            createButton
                .offset(y: -40)
                .zIndex(1)
        }
    }

    private func tabButton(_ tab: MochiTab) -> some View {
        let isSelected = selected == tab
        let tint = isSelected ? MochiColor.purple : MochiColor.textSecondary.opacity(0.6)

        return Button {
            selected = tab
        } label: {
            VStack(spacing: 4) {
                tabIcon(tab, isSelected: isSelected, tint: tint)
                    .frame(height: HomeMetrics.tabIconSize)
                Text(tab.title)
                    .font(MochiFont.caption(HomeMetrics.tabLabelSize))
            }
            .foregroundStyle(tint)
            .frame(maxWidth: .infinity)
            // The bar's top and bottom padding lives HERE rather than on the enclosing HStack, so
            // it counts as part of each button's tappable area instead of dead space around them.
            // On the HStack the buttons measured 33pt tall inside a 63pt bar — under Apple's 44pt
            // minimum, with the whole lower strip of visible white unresponsive. Geometry and
            // appearance are identical either way; only the hit area changes.
            //
            // The bottom inset is the home-indicator clearance: the full safe-area value is 34pt,
            // trimmed to 24pt so the labels stay clear of the gesture zone without the bar reading
            // top-heavy. The white background still bleeds below it to the true screen edge.
            .padding(.top, 6)
            .padding(.bottom, 24)
            .contentShape(Rectangle())
        }
        .accessibilityIdentifier("tab.\(tab.rawValue)")
    }

    /// Figma renders Fonts as literal "Aa" text (not an icon), the selected Keyboard tab as a real
    /// cropped badge image (not a tinted symbol), and Themes/Community as real cropped icons tinted
    /// to match the current selection state.
    ///
    /// Themes used to fall through to an SF Symbol, whose palette silhouette (thumb-hole placement
    /// and paint-dot arrangement) doesn't match the design's. `icon_tab_themes` is cropped straight
    /// out of the tab bar in docs/figma/1.png and stored as an alpha-only template so the tint
    /// still tracks selection state.
    @ViewBuilder
    private func tabIcon(_ tab: MochiTab, isSelected: Bool, tint: Color) -> some View {
        switch tab {
        case .fonts:
            // Figma's "Aa" is 19.3 x 13.3pt — a light sans, not the bold rounded system face. When
            // the tab is selected it is filled with the page's pink->periwinkle ramp rather than
            // flat purple; unselected it stays on the row's grey like every other icon.
            Text("Aa")
                .font(MochiFont.body(HomeMetrics.tabIconSize))
                .foregroundStyle(.clear)
                .overlay {
                    if isSelected {
                        MochiGradient.fontsAccent.mask(
                            Text("Aa").font(MochiFont.body(HomeMetrics.tabIconSize))
                        )
                    } else {
                        Text("Aa")
                            .font(MochiFont.body(HomeMetrics.tabIconSize))
                            .foregroundStyle(tint)
                    }
                }
        case .keyboard where isSelected:
            // 122 x 85px in the export = a 1.43:1 badge, not the square-ish frame used before.
            Image("icon_tab_keyboard")
                .resizable()
                .frame(width: HomeMetrics.tabKeyboardWidth, height: HomeMetrics.tabKeyboardWidth / 1.43)
                .clipShape(RoundedRectangle(cornerRadius: 5))
        case .themes:
            Image("icon_tab_themes")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: HomeMetrics.tabIconSize, height: HomeMetrics.tabIconSize)
                .foregroundStyle(tint)
        case .community:
            Image("icon_tab_community")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: HomeMetrics.tabIconSize, height: HomeMetrics.tabIconSize)
                .foregroundStyle(tint)
        default:
            Image(systemName: tab.systemImage)
                .font(.system(size: HomeMetrics.tabIconSize, weight: .semibold))
        }
    }

    private var createButton: some View {
        Button {
            selected = .create
        } label: {
            Image("icon_tab_create")
                .resizable()
                .frame(width: HomeMetrics.tabCreateSize, height: HomeMetrics.tabCreateSize)
                .clipShape(Circle())
                .shadow(color: MochiColor.purpleDark.opacity(0.25), radius: 6, y: 3)
        }
        .accessibilityIdentifier("tab.create")
    }
}

/// Figma's tab bar is a single continuous vector path: a mostly straight top edge with sharp
/// (near-zero radius) outer corners, and a wide symmetrical concave valley in the center — built
/// from continuous Béziers, not a separate boolean-cutout notch — that the floating Create button
/// overlaps into. Confirmed directly against the Figma layer's Design panel (fill FFFFFF, stroke
/// 9C28B1 weight 1, corner radius reads 0 on the shape itself).
struct NotchedTabBarShape: Shape {
    var cornerRadius: CGFloat = 4
    var notchHalfWidth: CGFloat = 50
    var notchDepth: CGFloat = 26

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cx = rect.midX
        let notchBottom = CGPoint(x: cx, y: rect.minY + notchDepth)

        path.move(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))
        path.addQuadCurve(to: CGPoint(x: rect.minX + cornerRadius, y: rect.minY), control: CGPoint(x: rect.minX, y: rect.minY))

        path.addLine(to: CGPoint(x: cx - notchHalfWidth, y: rect.minY))
        // Each cubic's control points sit at the SAME y as its own endpoint (not the other
        // endpoint's y, which is what the previous quad-curve version did) — that's what forces a
        // horizontal tangent at every junction: where the flat top edge meets the curve (so it
        // blends in with no kink) and where the two curves meet at the bottom (so the valley floor
        // is one smooth continuous sweep instead of a cusp).
        path.addCurve(
            to: notchBottom,
            control1: CGPoint(x: cx - notchHalfWidth * 0.5, y: rect.minY),
            control2: CGPoint(x: cx - notchHalfWidth * 0.5, y: notchBottom.y)
        )
        path.addCurve(
            to: CGPoint(x: cx + notchHalfWidth, y: rect.minY),
            control1: CGPoint(x: cx + notchHalfWidth * 0.5, y: notchBottom.y),
            control2: CGPoint(x: cx + notchHalfWidth * 0.5, y: rect.minY)
        )

        path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY + cornerRadius), control: CGPoint(x: rect.maxX, y: rect.minY))

        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()

        return path
    }
}
