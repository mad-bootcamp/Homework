//
//  ProductList.swift.swift
//  Module06HW
//
//  Created by user303027 on 9/8/26.
//

import SwiftUI

struct ProductList: View {
    
    @State private var products: [Product] = []
    
    var body: some View {
        NavigationStack {
            List(products){ product in
                NavigationLink(value: product){
                    VStack {
                        Text(product.name)
                        Text(product.color)
                    }
                }
            }
            .navigationTitle("Products")
            .navigationDestination(for: Product.self) {
                selectedItem in
                ProductDetails(product: selectedItem)
            }
            
            
        }
        .task{
            loadData()
        }
    }
        
        func loadData() {
            products = [
                Product(id: 1001, name: "Apple", productNumber: "12345", color: "red", listPrice: 10.00),
                Product(id: 1002, name: "Banana", productNumber: "23456", color: "yellow", listPrice: 4.00),
                Product(id: 1003, name: "Pear", productNumber: "34567", color: "green", listPrice: 6.00),
                Product(id: 1004, name: "Grape", productNumber: "45678", color: "purple", listPrice: 15.00),
                Product(id: 1005, name: "Melon", productNumber: "56789", color: "green", listPrice: 20.00)
            ]
        }
    }

    
    #Preview {
        ProductList()
    }
