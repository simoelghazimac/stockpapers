//
//  IAPService.swift
//  Stockpapers
//
//  Created by Federico Vitale on 23/08/18.
//  Copyright © 2018 Federico Vitale. All rights reserved.
//

import Foundation
import StoreKit
import Firebase

/**
 Manage In App Purchases
 */
class IAPService: NSObject {
    private override init() {}
    
    static  let shared = IAPService()
    private let hapticNotification = UINotificationFeedbackGenerator()
    
    let paymentQueue = SKPaymentQueue.default()
    var products = [SKProduct]()
    
    /// Fetch remote products
    public func getProducts()
    {
        let products: Set = [
            IAPProduct.removeWatermark.rawValue
        ]
        
        let request = SKProductsRequest(productIdentifiers: products)
        request.delegate = self
        request.start()
        
        paymentQueue.add(self)
    }
    
    /// Purchase a IAPProduct
    public func purchaseProduct(product: IAPProduct) {
        guard let productToPurchase = products.filter({ $0.productIdentifier == product.rawValue }).first else { return }
        let payment = SKPayment(product: productToPurchase)
        paymentQueue.add(payment)
    }
    
    /// Restore purchases
    public func restorePurchases()
    {
        print("IAP: Restoring Purchases")
        paymentQueue.restoreCompletedTransactions()
    }
}

// ???
extension IAPService: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("IAP: Retriving Products")
        self.products = response.products
        print("IAP: \(response.products.count) products fetched.")
    }
}

/*
 * ----------------------------
 * MARK: - Transaction Observer
 * ----------------------------
 */
extension IAPService: SKPaymentTransactionObserver {
    //  What's going on with transaction?
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions
        {
            // Print transaction status for a product.
            printIfSimulator(
                "IAP State: \(transaction.transactionState.status().capitalized) - \(transaction.payment.productIdentifier)"
            )
            
            Analytics.logEvent("transaction_status", parameters: [
                "purchase_id": transaction.payment.productIdentifier,
                "status": transaction.transactionState.status(),
            ])
            
            // if purchased end the transition
            switch transaction.transactionState {
            case .purchasing:
                break
            case .restored:
                print("IAP: Restored")
                queue.finishTransaction(transaction)
                self.deliverRestoredNotification(with: transaction.payment.productIdentifier)
            case .purchased:
                print("IAP: Transaction Completed")
                queue.finishTransaction(transaction)
                self.deliverCompleteNotification(with: transaction.payment.productIdentifier)
                
            // if fails notify the app
            case .failed:
                print("IAP: Transaction failed")
                queue.finishTransaction(transaction)
                self.deliverFailNotification(with: transaction.payment.productIdentifier)
            default:
                print("IAP: Finishing transaction")
                queue.finishTransaction(transaction)
                self.deliverCompleteNotification(with: transaction.payment.productIdentifier)
            }
        }
    }
    
    private func deliverRestoredNotification(with identifier: String?) {
        print("DELIVERING...")
        guard let identifier = identifier else { return }
        
        self.hapticNotification.notificationOccurred(.success)
        NotificationCenter.default.post(name: .purchaseRestored, object: identifier)
    }
    
    private func deliverCompleteNotification(with identifier: String?)
    {
        print("DELIVERING...")
        guard let identifier = identifier else { return }
        
        self.hapticNotification.notificationOccurred(.success)
        NotificationCenter.default.post(name: .purchaseCompleted, object: identifier)
    }
    
    private func deliverFailNotification(with identifier: String?)
    {
        print("DELIVERING...")
        guard let identifier = identifier else { return }
        
        self.hapticNotification.notificationOccurred(.error)
        NotificationCenter.default.post(name: .purchaseFailed, object: identifier)
    }
}

/*
 * ----------------------------------
 * MARK: - TransactionStatus Decoding
 * ----------------------------------
 */
extension SKPaymentTransactionState {
    func status() -> String
    {
        switch self {
        case .deferred:
            return "deferred"
        case .failed:
            return "failed"
        case .purchased:
            return "purchased"
        case .purchasing:
            return "purchasing"
        case .restored:
            return "restored"
        }
    }
}




