//
//  InAppPurchaseManager.swift
//  TallhaSarwar_iOS
//
//  Created by Tallha Sarwar on 30/04/2020.
//  Copyright © 2020 C100-138. All rights reserved.
//

import Foundation
import StoreKit

class InAppPurchaseManager: NSObject {
    
    static let shared = InAppPurchaseManager()
    
    private override init() {
        super.init()
    }

    fileprivate var productIds = [String]()
    fileprivate var productsRequest = SKProductsRequest()
    fileprivate var fetchProductComplition: (([SKProduct])->Void)?
    
    fileprivate var productToPurchase: SKProduct?
    fileprivate var purchaseProductComplition: ((InAppPurchaseStatus, SKProduct?, SKPaymentTransaction?)->Void)?
    
    func canMakePurchases() -> Bool {  return SKPaymentQueue.canMakePayments()  }
    
    func purchaseProductWithID(productIdentifier: String, complition: @escaping ((InAppPurchaseStatus, SKProduct?, SKPaymentTransaction?)->Void)) {
        
        fetchSingleProduct(productID: [productIdentifier]) { (products) in
            
            let product = products.first
            
            self.purchaseProductComplition = complition
            self.productToPurchase = product
            
            if self.canMakePurchases() {
                let payment = SKPayment(product: product!)
                SKPaymentQueue.default().add(self)
                SKPaymentQueue.default().add(payment)
            }
            else {
                complition(InAppPurchaseStatus.disabled, nil, nil)
            }
        }
    }
    
    func purchase(product: SKProduct, complition: @escaping ((InAppPurchaseStatus, SKProduct?, SKPaymentTransaction?)->Void)) {
        
        self.purchaseProductComplition = complition
        self.productToPurchase = product
        
        if self.canMakePurchases() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
        }
        else {
            complition(InAppPurchaseStatus.disabled, nil, nil)
        }
    }
    
    
    func restorePurchase(){
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func fetchProductsList(productIDsList: [String], complition: @escaping (([SKProduct])->Void)){
        
        self.productIds = productIDsList
        self.fetchProductComplition = complition
        if self.productIds.isEmpty {
            fatalError(InAppPurchaseStatus.setProductIds.message)
        }
        else {
            productsRequest = SKProductsRequest(productIdentifiers: Set(self.productIds))
            productsRequest.delegate = self
            productsRequest.start()
        }
    }
    
    func fetchSingleProduct(productID: [String], complition: @escaping (([SKProduct])->Void)){
        
        self.productIds = productID
        self.fetchProductComplition = complition
        if self.productIds.isEmpty {
            fatalError(InAppPurchaseStatus.setProductIds.message)
        }
        else {
            productsRequest = SKProductsRequest(productIdentifiers: Set(self.productIds))
            productsRequest.delegate = self
            productsRequest.start()
        }
    }
    
}

//MARK:- Product Request Delegate and Payment Transaction Methods
extension InAppPurchaseManager: SKProductsRequestDelegate, SKPaymentTransactionObserver{
    
    func productsRequest (_ request:SKProductsRequest, didReceive response:SKProductsResponse) {
        
        if (response.products.count > 0) {
            if let complition = self.fetchProductComplition {
                complition(response.products)
            }
        }
        else {
            print(response.products)
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        if let complition = self.purchaseProductComplition {
            complition(InAppPurchaseStatus.restored, nil, nil)
        }
    }
    
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction:AnyObject in transactions {
            
            if let trans = transaction as? SKPaymentTransaction {
                
                switch trans.transactionState {
                case .purchasing:
                    if let complition = self.purchaseProductComplition {
                        complition(InAppPurchaseStatus.purchasing, nil, nil)
                    }
                    
                case .purchased:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    if let complition = self.purchaseProductComplition {
                        complition(InAppPurchaseStatus.purchased, self.productToPurchase, trans)
                    }
                    
                case .failed:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    if let complition = self.purchaseProductComplition {
                        complition(InAppPurchaseStatus.purchaseFailed, nil, nil)
                    }
                    
                case .restored:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    if let complition = self.purchaseProductComplition {
                        complition(InAppPurchaseStatus.restored, nil, nil)
                    }
                    
                case .deferred:
                    if let complition = self.purchaseProductComplition {
                        complition(InAppPurchaseStatus.purchaseFailed, nil, nil)
                    }
                @unknown default:
                    if let complition = self.purchaseProductComplition {
                        complition(InAppPurchaseStatus.unknown, nil, nil)
                    }
                }
            }
            else {
                if let complition = self.purchaseProductComplition {
                    complition(InAppPurchaseStatus.purchaseFailed, nil, nil)
                }
            }
        }
    }
}

enum InAppPurchaseStatus {
    case purchasing
    case purchased
    case setProductIds
    case purchaseFailed
    case disabled
    case restored
    case deferred
    case unknown
    
    var message: String{
        switch self {
        case .setProductIds: return "Product ids not set, call setProductIds method!"
        case .purchaseFailed: return "Product purchase failed!"
        case .purchasing: return "Product purchasing in process!"
        case .disabled: return "Purchases are disabled in your device!"
        case .restored: return "You've successfully restored your purchase!"
        case .purchased: return "You've successfully bought this purchase!"
        case .deferred: return "The transaction is in the queue, but its final status is pending external action."
        case .unknown: return "The transaction may have additional unknown values which is not known"
        }
    }
}
