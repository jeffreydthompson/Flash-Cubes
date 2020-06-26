//
//  IAPService.swift
//  FlashCube_Prototype
//
//  Created by Jeffrey Thompson on 11/28/18.
//  Copyright © 2018 Jeffrey Thompson. All rights reserved.
//

import Foundation
import StoreKit

class IAPService: NSObject {
    
    private override init(){}
    static let shared = IAPService()
    
    var purchasingCall:      (() -> Void)?
    var purchaseFailed:      ((Error?) -> Void)?
    var purchasedCompletion: (() -> Void)?
    var restoredCompletion:  ((String) -> Void)?
    
    var isAuthorizedForPayments: Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    /// Keeps track of all purchases.
    var purchased = [SKPaymentTransaction]()
    
    /// Keeps track of all restored purchases.
    var restored = [SKPaymentTransaction]()
    
    /// Indicates whether there are restorable purchases.
    fileprivate var hasRestorablePurchases = false
    
    var products     = [SKProduct]()
    let paymentQueue = SKPaymentQueue.default()
    
    func getProducts(productIDs: Set<String>) {
        //let products: Set = [IAPProduct.tierOne.rawValue]
        
        let request = SKProductsRequest(productIdentifiers: productIDs)
        request.delegate = self
        request.start()
        paymentQueue.add(self)
    }
    
    func purchase(productId: String) {
        guard let productToPurchase = products.filter({ $0.productIdentifier == productId}).first else {return}
        let payment = SKPayment(product: productToPurchase)
        paymentQueue.add(payment)
    }
    
    /// Restores all previously completed purchases.
    func restore() {
        if !restored.isEmpty {
            restored.removeAll()
        }
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func localizedPrice(forIAPid: String) -> String? {
        var returnString: String? = nil
        products.forEach { (product) in
            if product.productIdentifier == forIAPid {
                let priceFormatter = NumberFormatter()
                priceFormatter.numberStyle = .currency
                priceFormatter.locale = product.priceLocale
                returnString = priceFormatter.string(from: product.price)
                return
            }
        }
        return returnString
    }
}

extension IAPService: SKProductsRequestDelegate {
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("SKProductsRequestDelegate \(#function)")
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("SKProductsRequestDelegate \(#function)")
        
        let priceFormatter = NumberFormatter()
        priceFormatter.numberStyle = .currency
        
        products = response.products
        for product in response.products{
            print("STOREKIT \(product.localizedTitle)")
            priceFormatter.locale = product.priceLocale
            print("         \(product.productIdentifier)")
        }
    }
}

extension IAPService: SKPaymentTransactionObserver {
    
    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        
        queue.transactions.forEach({
            print("SKPaymentTransactionObserver \(#function) \($0.transactionIdentifier ?? "no id")")
        })
        
        return true
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        print("SKPaymentTransactionObserver \(#function)")
        for transaction in transactions {
            print("     \(transaction.transactionState.status()), : \(transaction.payment.productIdentifier)")
            switch transaction.transactionState {
            case .purchasing: break
            case .purchased:
                queue.finishTransaction(transaction)
                purchasedCompletion?()
                break
            case .restored:
                queue.finishTransaction(transaction)
                restoredCompletion?(transaction.payment.productIdentifier)
                break
            case .failed:
                queue.finishTransaction(transaction)
                purchaseFailed?(transaction.error)
                break
            default:
                queue.finishTransaction(transaction)
            }
        }
    }
}

extension SKPaymentTransactionState {
    func status() -> String {
        switch self {
        case .deferred:
            return ("STOREKIT deferred")
        case .failed:
            return ("STOREKIT failed")
        case .purchased:
            return ("STOREKIT purchased")
        case .purchasing:
            return ("STOREKIT purchasing")
        case .restored:
            return ("STOREKIT restored")
        default:
            return "default.  error."
        }
    }
}
