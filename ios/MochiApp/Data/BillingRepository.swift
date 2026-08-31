import Foundation
import SwiftUI

/// Subscription state + purchase actions.
///
/// Deliberately inert, exactly like android/.../data/BillingRepository.kt: there is no StoreKit /
/// RevenueCat integration yet (needs a real API key + App Store Connect products), so `isConfigured`
/// is `false`, prices fall back to the locked spec ($2.99/mo · $19.99/yr · 3-day trial — decision #3
/// in project memory, **not** the $199/$999 the Figma paywall frames show), and every purchase
/// action surfaces a "not set up yet" message instead of a silent no-op.
///
/// `isUserPremium` is an in-app override so the rest of the app (Theme Detail's lock gate, the
/// Wallpapers grid) has something real to read; it persists locally so a "granted" state survives
/// relaunch. Wiring real entitlements replaces only the guts of this type.
@MainActor
final class BillingRepository: ObservableObject {
    static let shared = BillingRepository()

    let isConfigured = false

    @AppStorage("mochi.isUserPremium") private(set) var isUserPremium = false

    struct Plan: Identifiable {
        let id: String
        let title: String
        let price: String
        let period: String
        let badge: String?
    }

    let plans: [Plan] = [
        Plan(id: "monthly", title: "Monthly", price: "$2.99", period: "/ month", badge: nil),
        Plan(id: "yearly", title: "Yearly", price: "$19.99", period: "/ year", badge: "Most Popular")
    ]

    let perks = [
        "All 250 premium keyboard themes",
        "Every custom font in the library",
        "All key-press, background & trail effects",
        "All sticker packs",
        "All 5 animated live wallpapers"
    ]

    enum BillingResult { case notConfigured }

    /// Real flow would launch StoreKit here. Today it reports that billing isn't set up.
    func purchase(planId: String) -> BillingResult { .notConfigured }
    func restore() -> BillingResult { .notConfigured }

    /// Local-only unlock, so premium-gated UI can be exercised end-to-end before real IAP exists.
    func grantPremiumLocally() { isUserPremium = true }
}
