import SwiftUI

/// Ported from android/.../features/paywall/PaywallScreen.kt.
///
/// Pricing is the locked spec ($2.99/mo · $19.99/yr · 3-day trial) — **not** the $199/$999 the
/// Figma paywall frames (docs/figma/11-12.png) show, which was never approved and whose custom
/// checkout would violate App Store Guideline 3.1.1. `BillingRepository` is inert until a real IAP
/// integration exists, so "Start Free Trial" / "Restore Purchase" surface a "not set up yet" notice
/// rather than a silent no-op. "Unlock anyway (demo)" grants premium locally so the gated UI
/// elsewhere can be exercised.
struct PaywallView: View {
    var onClose: () -> Void = {}

    @ObservedObject private var billing = BillingRepository.shared
    @State private var selectedPlanId = "yearly"
    @State private var notice: String?

    var body: some View {
        ZStack {
            MochiGradient.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        Button(action: onClose) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(MochiColor.textPrimary)
                                .frame(width: 36, height: 36)
                                .background(Color.white, in: Circle())
                        }
                        .accessibilityIdentifier("paywall.close")
                    }

                    Image("icon_premium_crown")
                        .resizable().scaledToFill()
                        .frame(width: 72, height: 72)
                        .clipShape(Circle())
                        .padding(.top, MochiSpacing.md)

                    Text("Unlock Mochi Premium")
                        .font(MochiFont.title(24)).foregroundStyle(MochiColor.textPrimary)
                        .padding(.top, MochiSpacing.md)
                    Text("Every theme, font, and effect — no limits.")
                        .font(MochiFont.body(14)).foregroundStyle(MochiColor.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)

                    VStack(alignment: .leading, spacing: MochiSpacing.sm) {
                        ForEach(billing.perks, id: \.self) { perk in
                            HStack(spacing: MochiSpacing.sm) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 17)).foregroundStyle(MochiColor.purple)
                                Text(perk).font(MochiFont.body(13)).foregroundStyle(MochiColor.textPrimary)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(MochiSpacing.md)
                    .background(Color.white, in: RoundedRectangle(cornerRadius: MochiRadius.card, style: .continuous))
                    .padding(.top, MochiSpacing.lg)

                    VStack(spacing: MochiSpacing.sm) {
                        ForEach(billing.plans) { plan in
                            planCard(plan)
                        }
                    }
                    .padding(.top, MochiSpacing.lg)

                    Text("3-day free trial, cancel anytime")
                        .font(MochiFont.caption(12)).foregroundStyle(MochiColor.textSecondary)
                        .padding(.top, MochiSpacing.sm)

                    GradientButton(title: "Start Free Trial") {
                        notice = "Subscriptions aren't set up yet — this needs the App Store payment key."
                    }
                    .padding(.top, MochiSpacing.lg)

                    Button("Restore Purchase") {
                        notice = "Nothing to restore — subscriptions aren't set up yet."
                    }
                    .font(MochiFont.caption(13)).foregroundStyle(MochiColor.purple)
                    .padding(.top, MochiSpacing.md)

                    if !billing.isUserPremium {
                        Button("Unlock anyway (demo)") {
                            billing.grantPremiumLocally()
                            onClose()
                        }
                        .font(MochiFont.caption(12)).foregroundStyle(MochiColor.textSecondary)
                        .padding(.top, MochiSpacing.sm)
                    }

                    Text("Payment is charged to your App Store account. Subscriptions auto-renew unless cancelled at least 24 hours before the end of the current period.")
                        .font(MochiFont.caption(10)).foregroundStyle(MochiColor.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, MochiSpacing.md)
                }
                .padding(MochiSpacing.lg)
            }
            .scrollIndicators(.hidden)
        }
        .alert("Couldn't complete that", isPresented: Binding(get: { notice != nil }, set: { if !$0 { notice = nil } })) {
            Button("OK") { notice = nil }
        } message: {
            Text(notice ?? "")
        }
        .onChange(of: billing.isUserPremium) { isPremium in
            if isPremium { onClose() }
        }
    }

    private func planCard(_ plan: BillingRepository.Plan) -> some View {
        let isSelected = plan.id == selectedPlanId
        return HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(plan.title).font(MochiFont.heading(15)).foregroundStyle(MochiColor.textPrimary)
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(plan.price).font(MochiFont.title(18)).foregroundStyle(MochiColor.purple)
                    Text(plan.period).font(MochiFont.caption(12)).foregroundStyle(MochiColor.textSecondary)
                }
            }
            Spacer()
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 22))
                .foregroundStyle(isSelected ? MochiColor.purple : MochiColor.textSecondary.opacity(0.4))
        }
        .padding(MochiSpacing.md)
        .background(Color.white, in: RoundedRectangle(cornerRadius: MochiRadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: MochiRadius.card, style: .continuous)
                .stroke(isSelected ? MochiColor.purple : MochiColor.textSecondary.opacity(0.15),
                        lineWidth: isSelected ? 2 : 1)
        )
        .overlay(alignment: .topTrailing) {
            if let badge = plan.badge {
                Text(badge)
                    .font(MochiFont.caption(10)).fontWeight(.bold).foregroundStyle(.white)
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(MochiGradient.primaryButton, in: Capsule())
                    .offset(x: -MochiSpacing.md, y: -8)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { selectedPlanId = plan.id }
    }
}

#Preview {
    PaywallView()
}
