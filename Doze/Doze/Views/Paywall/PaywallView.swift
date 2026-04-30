import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isPurchasing = false

    private var purchaseManager: PurchaseManager { PurchaseManager.shared }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    featuresSection
                    pricingSection
                    restoreButton
                    disclaimer
                }
                .padding()
            }
            .navigationTitle("Doze Premium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .task {
                await purchaseManager.loadProducts()
                await purchaseManager.updatePurchasedProducts()
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "moon.zzz.fill")
                .font(.system(size: 48))
                .foregroundStyle(.blue)
            Text("Unlock Doze Premium")
                .font(.title2)
                .fontWeight(.bold)
            Text("Get the full sleep tracking experience")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 20)
    }

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            FeatureRow(icon: "infinity", text: "Unlimited sleep history")
            FeatureRow(icon: "square.and.arrow.up", text: "Data export (CSV)")
            FeatureRow(icon: "icloud", text: "iCloud sync across devices")
            FeatureRow(icon: "chart.line.uptrend.xyaxis", text: "Monthly & yearly trends")
            FeatureRow(icon: "brain.head.profile", text: "Sleep pattern insights")
            FeatureRow(icon: "star", text: "Priority support & early access")
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var pricingSection: some View {
        VStack(spacing: 12) {
            if let monthly = purchaseManager.monthlyProduct {
                PricingCard(
                    title: "Monthly",
                    price: monthly.displayPrice,
                    subtitle: "per month",
                    isBestValue: false
                ) {
                    await purchase(monthly)
                }
            }

            if let yearly = purchaseManager.yearlyProduct {
                PricingCard(
                    title: "Yearly",
                    price: yearly.displayPrice,
                    subtitle: "per year (save 37%)",
                    isBestValue: true
                ) {
                    await purchase(yearly)
                }
            }

            if let lifetime = purchaseManager.lifetimeProduct {
                PricingCard(
                    title: "Lifetime",
                    price: lifetime.displayPrice,
                    subtitle: "pay once, own forever",
                    isBestValue: false
                ) {
                    await purchase(lifetime)
                }
            }
        }
    }

    private var restoreButton: some View {
        Button("Restore Purchases") {
            Task {
                await purchaseManager.restorePurchases()
                if purchaseManager.isProUser {
                    dismiss()
                }
            }
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }

    private var disclaimer: some View {
        Text("Payment will be charged to your Apple ID account at confirmation of purchase. Subscription automatically renews unless cancelled at least 24 hours before the end of the current period.")
            .font(.caption2)
            .foregroundStyle(.tertiary)
            .multilineTextAlignment(.center)
    }

    private func purchase(_ product: Product) async {
        isPurchasing = true
        let success = await purchaseManager.purchase(product)
        isPurchasing = false
        if success {
            dismiss()
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
            Spacer()
            Image(systemName: "checkmark")
                .foregroundStyle(.green)
                .font(.caption)
        }
    }
}

struct PricingCard: View {
    let title: String
    let price: String
    let subtitle: String
    let isBestValue: Bool
    let action: () async -> Void

    @State private var isPurchasing = false

    var body: some View {
        Button {
            isPurchasing = true
            Task { await action() }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(title)
                            .font(.headline)
                        if isBestValue {
                            Text("Best Value")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(.blue)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                    }
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(price)
                    .font(.title2)
                    .fontWeight(.bold)
            }
            .padding()
            .background(isBestValue ? Color.blue.opacity(0.1) : Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isBestValue ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .disabled(isPurchasing)
    }
}
