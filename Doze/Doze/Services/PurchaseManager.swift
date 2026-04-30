import StoreKit
import Foundation

@Observable
final class PurchaseManager {
    static let shared = PurchaseManager()

    var products: [Product] = []
    var purchasedProductIDs: Set<String> = []
    var isProUser = false
    var isLoading = false

    private var transactionListener: Task<Void, Never>?

    private let monthlyID = "com.zzoutuo.Doze.monthly"
    private let yearlyID = "com.zzoutuo.Doze.yearly"
    private let lifetimeID = "com.zzoutuo.Doze.lifetime"

    private init() {
        transactionListener = listenForTransactions()
    }

    deinit {
        transactionListener?.cancel()
    }

    func loadProducts() async {
        do {
            products = try await Product.products(for: [monthlyID, yearlyID, lifetimeID])
        } catch {
            print("Failed to load products: \(error)")
        }
    }

    func purchase(_ product: Product) async -> Bool {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                purchasedProductIDs.insert(transaction.productID)
                isProUser = true
                await transaction.finish()
                return true
            case .userCancelled, .pending:
                return false
            @unknown default:
                return false
            }
        } catch {
            print("Purchase failed: \(error)")
            return false
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
        } catch {
            print("Restore failed: \(error)")
        }
    }

    func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                purchasedProductIDs.insert(transaction.productID)
            }
        }
        isProUser = !purchasedProductIDs.isEmpty
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self = self else { return }
                if case .verified(let transaction) = result {
                    await self.updatePurchasedProducts()
                    await transaction.finish()
                }
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    enum StoreError: Error {
        case failedVerification
    }

    var monthlyProduct: Product? {
        products.first { $0.id == monthlyID }
    }

    var yearlyProduct: Product? {
        products.first { $0.id == yearlyID }
    }

    var lifetimeProduct: Product? {
        products.first { $0.id == lifetimeID }
    }
}
