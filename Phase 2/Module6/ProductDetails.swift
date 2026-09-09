//
//  ProductDetails.swift
//  Module06HW
//
//  Created by user303027 on 9/8/26.
//

import SwiftUI

struct ProductDetails: View {
    
    @State var product: Product
    
    var body: some View {
        @Bindable var prodBinding = product
        
        VStack {
            Text("\(product.id)")
                .font(.largeTitle)
                .fontWeight(.bold)
                .font(.title)
            Text("\(product.name)")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("Product Number: \(product.productNumber)")
                .font(.title2)
            Text("Product Color: \(product.color)")
                .font(.title2)
            Text("Product Price: \(product.listPrice, format: .currency(code: "USD"))")
                .font(.title2)
            }
        .padding()
        }
        
    }

#Preview {
    ContentView()
}
