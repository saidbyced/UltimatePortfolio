//
//  UnlockManager.swift
//  UltimatePortfolio
//
//  Created by Christopher Eadie on 29/03/2022.
//

import Combine
import StoreKit

class UnlockManager: NSObject, ObservableObject, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    enum RequestState {
        case loading // About to start request, no response yet
        case loaded(SKProduct) // Apple has responded with available IAP
        case failed(Error?) // Something went wrong
        case purchased // User has successfully purchased or restored IAP
        case deferred // User doesn't have permission to purchase IAP
    }
    
    private enum StoreError: Error {
        case invalidIdentifiers, missingProduct
    }
    
    @Published var requestState: RequestState = .loading
    
    private let dataController: DataController
    private let request: SKProductsRequest
    private var loadedProducts = [SKProduct]()
    
    var canMakePayments: Bool {
        SKPaymentQueue.canMakePayments()
    }
    
    init(dataController: DataController) {
        self.dataController = dataController
        
        let productIDs = Set([
            IAPProductIdentifier.unlock.id
        ])
        request = SKProductsRequest(productIdentifiers: productIDs)
        
        super.init()
        
        SKPaymentQueue.default().add(self)
        
        guard dataController.fullVersionUnlocked == false else { return }
        request.delegate = self
        request.start()
    }
    
    deinit {
        SKPaymentQueue.default().remove(self)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        DispatchQueue.main.async { [self] in
            for transaction in transactions {
                switch transaction.transactionState {
                case .purchased, .restored:
                    self.dataController.fullVersionUnlocked = true
                    self.requestState = .purchased
                case .failed:
                    if let product = loadedProducts.first {
                        self.requestState = .loaded(product)
                    } else {
                        self.requestState = .failed(transaction.error)
                    }
                    queue.finishTransaction(transaction)
                case .deferred:
                    self.requestState = .deferred
                case .purchasing:
                    break
                @unknown default:
                    break
                }
            }
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.loadedProducts = response.products
            
            guard let unlock = self.loadedProducts.first else {
                self.requestState = .failed(StoreError.missingProduct)
                return
            }
            
            guard response.invalidProductIdentifiers.isEmpty == false else {
                print("ALERT: Received invalid product identifiers: \(response.invalidProductIdentifiers)")
                self.requestState = .failed(StoreError.invalidIdentifiers)
                return
            }
            
            self.requestState = .loaded(unlock)
        }
    }
    
    func buy(product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    func restore() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}
