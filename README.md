# InAppPurchaseManager
Very simple InAppPurchaseManager to purchase single item with ProductID or to get list of product to select and then purchase selected product in native swift

you can get the status of purchase with purchase product and transaction information
# Ho to use
To use just download and include InAppPurchaseManager.swift into your project

# Buy single product with product ID
To buy single product with Bundle Identifier call the method purchaseProductWithID and pass your product ID which you set on AppStoreConnect:

      InAppPurchaseManager.shared.purchaseProductWithID(productIdentifier: "Your Product ID here") { (status, product, transaction) in
          switch status {
            case .purchasing:
                print(status.message)
            case .purchased:
                if let tran = transaction, let prod = product {
                    print("Transaction:\(tran.transactionIdentifier ?? "") \nProduct:\(prod.localizedTitle)")
                }
                else {
                    print("Unable to get purchase information")
                }
            case .setProductIds:
                print(status.message)
            case .purchaseFailed:
                print(status.message)
            case .disabled:
                print(status.message)
            case .restored:
                print(status.message)
            case .unknown:
                print(status.message)
            case .deferred:
                print(status.message)
          }
      }
# Get list of products with product IDs
To get a list of products from app store with array of Bundle Identifier call the method fetchProductsList and pass array with product IDs which you set on AppStoreConnect:

        let listOfID = ["Your 1st product ID here","Your 2nd product ID here","Your 3rd product ID here"]
        
        InAppPurchaseManager.shared.fetchProductsList(productIDsList: listID) { (productsList) in 
        
                //You can show the productList in tableview and get the selected product
                let selectedProduct = productsList.first // chose from didselectrow function
                
        }
        

                
# Purchase selected product 
You can pass the selectedProduct to purchase method
            
          InAppPurchaseManager.shared.purchase(product: product!) { (status, product, transaction) in

              switch status {
                case .purchasing:
                    print(status.message)
                case .purchased:
                    if let tran = transaction, let prod = product {
                        SwiftOverlays.removeAllBlockingOverlays()
                        print("Transaction:\(tran.transactionIdentifier ?? "") \nProduct:\(prod.localizedTitle)")
                    }
                    else {
                        print("Unable to get purchase information")
                    }
                case .setProductIds:
                    print(status.message)
                case .purchaseFailed:
                    print(status.message)
                case .disabled:
                    print(status.message)
                case .restored:
                    print(status.message)
                case .deferred:
                    print(status.message)
                case .unknown:
                    print(status.message)
              }
          }
