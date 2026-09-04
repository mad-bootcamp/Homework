// ============================================================
// MODULE 4: Swift Programming Fundamentals
// LAB — PNC Banking Domain Model
// Enterprise Mobile Application Development Bootcamp
// ============================================================
//
// OVERVIEW
// You are building the Swift data model layer for the PNC Mobile
// Banking application. This layer will be carried forward into
// Modules 6, 7, and 8 as the foundation of the real application.
//
// Every type you define here uses the Swift features from all
// three days of this module. Take time to read the full spec
// before writing any code.
//
// ESTIMATED TIME: 90–120 minutes
//
// ============================================================
// LAB SPEC
// ============================================================
//
// You will build five interconnected Swift types:
//
//   1. TransactionType enum
//   2. TransactionStatus enum
//   3. Transaction struct
//   4. Account class
//   5. AccountAnalytics struct
//
// And three protocols:
//
//   A. Summarizable       — any type that can produce a summary string
//   B. AccountOperations  — deposit, withdraw, transfer
//   C. AnalyticsProvider  — compute basic financial metrics
//
// The lab ends with an error handling system and a generic
// result reporting function that ties everything together.
//
// Read each section completely before implementing it.
// ============================================================

import Foundation


// ============================================================
// SECTION 1: Enumerations
// ============================================================

// TODO 1A: TransactionType
// Conform to: String, CaseIterable, Codable
// Cases:     credit, debit, transfer, fee
// Add computed property: isExpense: Bool
//   → true for .debit and .fee, false otherwise

enum TransactionType: String, CaseIterable, Codable {
    case credit
    case debit
    case transfer
    case fee 

    var isExpense: Bool {
        guard self == .debit || self == .fee else {
            return false
        }
        return true
    }   
}


// TODO 1B: TransactionStatus
// Conform to: String, Codable
// Cases:     pending, completed, failed, cancelled
// Add computed property: isTerminal: Bool
//   → true for .completed, .failed, .cancelled
//   → false for .pending (can still change)
enum TransactionStatus: String, Codable {
    case pending
    case completed
    case failed
    case cancelled 

    var isTerminal: Bool {
        guard self == .completed, self == .failed, self == .cancelled else  {
            return false
        }
        return true
    }
}

// ============================================================
// SECTION 2: Transaction Struct
// ============================================================

// TODO 2: Define struct Transaction conforming to:
//   Identifiable, Codable, Equatable, Hashable, Summarizable (see Section 4A)
//
// Stored properties:
//   id: String                (unique identifier, default to UUID().uuidString)
//   date: Date
//   amount: Double            (always positive — type determines direction)
//   description: String
//   type: TransactionType
//   status: TransactionStatus (default: .completed)
//   category: String?
//   merchantName: String?
//
// Computed properties:
//   formattedAmount: String
//     → "-$X.XX" for expenses (type.isExpense == true)
//     → "+$X.XX" for income/credit
//
//   formattedDate: String
//     → Use DateFormatter with dateStyle: .medium, timeStyle: .short
//
//   resolvedCategory: String
//     → Returns category if non-nil, "Uncategorized" otherwise
//
// Custom initializer (all params except id, status, category, merchantName
// should be required; the rest should have defaults):
//   init(date:amount:description:type:status:category:merchantName:)
struct Transaction: Identifiable, Codable, Equatable, Hashable, Summarizable {
    let id: String //= UUID().uuidString
    let date: Date
    let amount: Double
    var description: String
    let type: TransactionType
    let status: TransactionStatus
    let category: String?
    let merchantName: String?

    var summary: String {
        return "\(formattedDate) \(description): \(formattedAmount)"
    }

    var formattedAmount: String{
        guard type.isExpense == true else {
            return String(format: "+$%.2f", abs(amount))
        }
        return String(format: "-$%.2f", abs(amount))
    }

    var formattedDate: String{
        let newDateFormat = DateFormatter()
        newDateFormat.dateStyle = .medium
        newDateFormat.timeStyle = .short
        return newDateFormat.string(from: date)
    }

    var resolvedCategory: String{
        if let category = self.category {
            return category
        } else {
            return "Uncategorized"
        }
    }

    init(id: String = UUID().uuidString ,date: Date, amount: Double, description: String, type: TransactionType, status: TransactionStatus = .completed, category: String? = nil, merchantName: String? = nil) {
        self.id = id
        self.date = date
        self.amount = amount
        self.description = description
        self.type = type
        self.status = status
        self.category = category
        self.merchantName = merchantName
    }
}



// ============================================================
// SECTION 3: Account Class
// ============================================================

// TODO 3A: Define protocol AccountOperations (see Section 4B)
// before defining Account, because Account will conform to it.
// (Define the protocol in Section 4B, then add conformance to Account here)


// TODO 3B: Define class BankAccount conforming to:
//   Identifiable, AccountOperations, Summarizable
//
// Stored properties:
//   id: String
//   accountNumber: String
//   accountType: String          (e.g., "CHECKING", "SAVINGS")
//   nickname: String?
//   var balance: Double
//   var availableBalance: Double
//   let currency: String         (default "USD")
//   let isActive: Bool           (default true)
//   var transactions: [Transaction]
//
// Computed properties:
//   displayName: String          → nickname if non-nil, else accountType.capitalized
//   maskedAccountNumber: String  → "****" + last 4 digits
//   formattedBalance: String     → "$X.XX"
//   recentTransactions: [Transaction]  → last 5, sorted by date descending
//   pendingCount: Int            → count of transactions with status .pending
//
// Designated initializer:
//   init(id:accountNumber:accountType:nickname:initialBalance:currency:isActive:)
//
// Implement AccountOperations (see Section 4B for the protocol requirements).
// Use the AccountError enum from Section 4C.
//
// Also add:
//   func addTransaction(_ transaction: Transaction)
//     → appends to transactions AND updates balance:
//       if transaction.type.isExpense: balance -= transaction.amount
//       else:                          balance += transaction.amount
//       Update availableBalance to match balance.
class BankAccount: Identifiable, AccountOperations, Summarizable {
    let id: String
    let accountNumber: String
    let accountType: String          
    var nickname: String?
    var balance: Double
    var availableBalance: Double
    let currency: String         
    let isActive: Bool           
    var transactions: [Transaction]

    var summary: String {
        return "\(displayName) \(maskedAccountNumber): \(formattedBalace)"
    }

    var displayName: String {
        return nickname ?? accountType.uppercased()
    }

    var maskedAccountNumber: String { 
        return "****\(String(accountNumber.suffix(4)))"
    }

    var formattedBalace: String { 
        return "\(String(format: "$%.2f", balance))"
    }

    var recentTransactons: [Transaction] {
        return Array(transactions.sorted {$0.date > $1.date}.prefix(5))
    }

    var pendingCount: Int {
        //longer version
        // var count = 0
        // for transaction in transactions{
        //     if transaction.status == .pending {
        //         count += 1
        //     }
        // }
        // return count
        return transactions.filter{$0.status == .pending}.count
    }

    init(id: String, accountNumber: String, accountType: String, nickname:String?, balance: Double, availableBalance: Double = 0.0, currency: String = "USD", isActive: Bool = true, transactions: [Transaction] = []) {
        self.id = id
        self.accountNumber = accountNumber
        self.accountType = accountType
        self.nickname = nickname
        self.balance = balance
        self.availableBalance = availableBalance
        self.currency = currency
        self.isActive = isActive
        self.transactions = transactions
    }

    func deposit(amount: Double) throws {
        guard isActive else {
            throw(AccountOperationsError.accountInactive)
        }

        guard amount > 0 else {
            throw (AccountOperationsError.invalidAmount)
        }
        balance += amount
    }

    func withdraw(amount: Double) throws {
        guard isActive else {
            throw(AccountOperationsError.accountInactive)
        }

        guard amount > 0 else {
            throw (AccountOperationsError.invalidAmount)
        }

        guard amount <= balance else {
            throw (AccountOperationsError.insufficientFunds(available: balance, requested: amount ))
        }


        balance -= amount
    }

    func transfer(amount: Double, to destination: BankAccount) throws {
        guard isActive else {
            throw(AccountOperationsError.accountInactive)
        }

        guard amount > 0 else {
            throw (AccountOperationsError.invalidAmount)
        }

        guard amount <= balance else {
            throw (AccountOperationsError.insufficientFunds(available: balance, requested: amount ))
        }

        guard self !== destination else {
            throw (AccountOperationsError.transferToSameAccount)
        }

        balance -= amount
        destination.balance += amount

    }

    func addTransaction(_ transaction: Transaction) {

        transactions.append(transaction)

        guard transaction.type.isExpense == true else {
            balance += transaction.amount
            return
        }

        balance -= transaction.amount
        availableBalance = balance
    }

}


// ============================================================
// SECTION 4: Protocols
// ============================================================

// TODO 4A: Summarizable protocol
//   Required: var summary: String { get }
//   Default implementation via extension: func printSummary() — prints summary
protocol Summarizable {
    var summary: String {get}
    func printSummary()
}

extension Summarizable {
    func printSummary() {
        print(summary)
    }
}

// TODO 4B: AccountOperations protocol
//   func deposit(amount: Double) throws
//   func withdraw(amount: Double) throws
//   func transfer(amount: Double, to destination: BankAccount) throws
//
// These methods throw AccountOperationsError (define in Section 4C).
protocol AccountOperations {
    func deposit(amount: Double) throws
    func withdraw(amount: Double) throws
    func transfer(amount: Double, to destination: BankAccount) throws
}


// TODO 4C: AccountOperationsError enum conforming to LocalizedError
// Cases:
//   invalidAmount
//   insufficientFunds(available: Double, required: Double)
//   accountInactive
//   transferToSameAccount
//   dailyLimitExceeded(limit: Double)
//
// Each case should have a meaningful errorDescription.
enum AccountOperationsError: LocalizedError{
    case invalidAmount
    case insufficientFunds(available: Double, requested: Double)
    case accountInactive
    case transferToSameAccount
    case dailyLimitExceeded(limit: Double)
    
    
    var errorDescription: String? {
        switch self {
        case .invalidAmount:
            return "The amount must be greater than zero"
        case .insufficientFunds(let a, let r):
            return "Insufficient funds. Available: $\(String(format:"%.2f", a)) Requested, $\(String(format:"%.2f", r))"
        case .accountInactive:
            return "Account is inactive."
        case .transferToSameAccount:
            return "The transfer can't be to the same account"
        case .dailyLimitExceeded(let l):
            return "Daily limit exceeded. Limit: $\(String(format:"%.2f", l))"
        }
    }
}


// ============================================================
// SECTION 5: Analytics
// ============================================================

// TODO 5A: AnalyticsProvider protocol
//   var totalCredits: Double { get }
//   var totalDebits: Double { get }
//   var netFlow: Double { get }         // credits - debits
//   var largestTransaction: Transaction? { get }
//   func monthlyTotal(month: Int, year: Int) -> Double
//   func transactionsByCategory() -> [String: [Transaction]]
protocol AnalyticsProvider {
    var totalCredits: Double { get }
    var totalDebits: Double { get }
    var netFlow: Double { get }         
    var largestTransaction: Transaction? { get }

    func monthlyTotal(month: Int, year: Int) -> Double
    func transactionsByCategory() -> [String: [Transaction]]
}

// TODO 5B: AccountAnalytics struct
// Stored property: transactions: [Transaction]
// Conform to AnalyticsProvider.
// Implement each requirement.
//
// Tips:
//   totalCredits: use .filter { !$0.type.isExpense }.reduce(0) { $0 + $1.amount }
//   transactionsByCategory: group by resolvedCategory using a Dictionary
//     (hint: use Dictionary(grouping:by:))
//   monthlyTotal: filter by Calendar.current month/year components and sum expense amounts
struct AccountAnalytics: AnalyticsProvider{
    var transactions: [Transaction]

    var totalCredits: Double {
        return transactions.filter{!$0.type.isExpense}.reduce(0) {$0 + $1.amount}
    }
    var totalDebits: Double {
        return transactions.filter{$0.type.isExpense}.reduce(0) {$0 + $1.amount}
    }
    var netFlow: Double {
        return totalCredits - totalDebits
    }         

    var largestTransaction: Transaction? {
        //longer version
        var largest = 0.0
        var currTransaction = transactions.first
        for t in transactions {
            if largest < t.amount{
                largest = t.amount
                currTransaction = t
            }
        }  
        return currTransaction     
    }

    
    func monthlyTotal(month: Int, year: Int) -> Double {
        //longer version
        var total = 0.0
        let calendar = Calendar(identifier: .gregorian)
        for t in transactions{
            let transactionMonth = calendar.component(.month, from: t.date)
            let transactionYear = calendar.component(.year, from: t.date)
            if transactionMonth == month && transactionYear == year && t.type == .debit {
                total += t.amount
            }
        }

        return total

    }


    func transactionsByCategory() -> [String: [Transaction]] {
        return Dictionary(grouping: transactions) {transaction in return transaction.resolvedCategory}

    }


}


// ============================================================
// SECTION 6: Generic Result Reporter
// ============================================================

// TODO 6: Write a generic function:
//   func reportResults<T: Summarizable>(_ items: [T], title: String)
//
// It should:
//   1. Print a header line: "=== [title] ==="
//   2. Print the item count: "[N] items"
//   3. Call printSummary() on each item
//   4. Print a footer: "=== End of [title] ==="
//
// The function must work for any type conforming to Summarizable —
// including both Transaction and BankAccount.
func reportResults<T: Summarizable>(_ items: [T], title: String){
    print("\n================================ \(title) ================================\n")
    print("\(items.count) items")
    for i in items {
        i.printSummary()
    }
    print("\n================================ End of \(title) ================================\n")
}


// ============================================================
// SECTION 7: INTEGRATION TEST — Tie it all together
// ============================================================

// TODO 7: Write a function named runlabDemo() that does the following:

func runlabDemo(){
    //7A
    let account1 = BankAccount(id: "ACC123", accountNumber: "987654321", accountType: "CHECKING" , nickname: "bills", balance: 3_500.00, availableBalance: 3_500.00)
    let account2 = BankAccount(id: "ACC456", accountNumber: "123456789", accountType: "SAVINGS" , nickname: "concerts", balance: 12_000.00, availableBalance: 12_000.00, isActive: false)

    //7B
    let transactions = [Transaction(date: Date(), amount: 500.00, description: "thrift store purchase", type: TransactionType.debit, category: "Expense"), 
    Transaction(date: Date(), amount: 100.00, description: "venmo payment", type: TransactionType.credit, category: "Income", merchantName: "Etsy"),
    Transaction(date: Date(), amount: 1_000.00, description: "rent", type: TransactionType.debit, category: "Expense"),
    Transaction(id: "0456", date: Date(), amount: 20.00, description: "Monthly fee", type: TransactionType.fee, category: "Expense", merchantName: "Bank"),
    Transaction(date: Date(), amount: 50.00, description: "to savings", type: TransactionType.transfer, category: "Transfer")]

    reportResults(transactions, title: "Transaction Summary")

    print("\n== Transaction results for checking account1 ==\n")
    for t in transactions {
        account1.addTransaction(t)
        account1.printSummary()
    }

    //7C

    print("\n== Error Handling ==\n")

    do {
        try account1.withdraw(amount: 3_000.00)
        try account1.deposit(amount: -30.00)
    } catch let e as AccountOperationsError {
        print(e.localizedDescription)
    } catch {
        print("Unexpected Error")
    }

    do {
        try account1.deposit(amount: -30.00)
    } catch let e as AccountOperationsError {
        print(e.localizedDescription)
    } catch {
        print("Unexpected Error")
    }

    do {
        try account1.transfer(amount: 148.00, to: account1)
    } catch let e as AccountOperationsError {
        print(e.localizedDescription)
    } catch {
        print("Unexpected Error")
    }

    do {
        try account2.withdraw(amount: 10.00)
    } catch let e as AccountOperationsError {
        print(e.localizedDescription)
    } catch {
        print("Unexpected Error")
    }


     //7D
     print("\n== Account Analytics ==\n")
     let accountAnalytics = AccountAnalytics(transactions: account1.transactions)
     print("Total credits: \(accountAnalytics.totalCredits)")
     print("Total debits: \(accountAnalytics.totalDebits)")
     print("Net flow: \(accountAnalytics.netFlow)")
     print(accountAnalytics.largestTransaction ?? "No transactions")
     print(accountAnalytics.transactionsByCategory())
     
     //7E
    reportResults(account1.transactions, title: "Checking Transactions")
    reportResults([account1, account2], title: "All Accounts")

    //7F
    print("\n== Value vs. Reference semantics ==\n")
    //value type
    let transactionTest = Transaction(date: Date(), amount: 500.00, description: "to Marnie", type: TransactionType.transfer)
    var newTransactionVar = transactionTest
    newTransactionVar.description = "to Shane"
    print(transactionTest.description)
    print(newTransactionVar.description)

    //reference type
    let accountTest = account1
    do {
        try accountTest.deposit(amount: 100.00)
        print(account1.balance)
        print(accountTest.balance)
    } catch let e as AccountOperationsError {
        print(e.localizedDescription)
    } catch {
        print("Unexpected Error")
    }
}


// 7A: Create at least two BankAccount instances:
//   - A checking account with $3,500 initial balance
//   - A savings account with $12,000 initial balance

// 7B: Create at least five Transaction instances across different types
//   and add them to the checking account using addTransaction(_:)
//   Include: one credit, two debits, one fee, one transfer
//   Verify the balance updates correctly after each addition.

// 7C: Demonstrate error handling:
//   - Try to withdraw more than the available balance → catch insufficientFunds
//   - Try to deposit a negative amount → catch invalidAmount
//   - Try to transfer to the same account → catch transferToSameAccount
//   Print the localized error description for each caught error.

// 7D: Create an AccountAnalytics instance with the checking account's transactions.
//   Print:
//   - Total credits
//   - Total debits
//   - Net flow
//   - The description and amount of the largest transaction
//   - The transactions grouped by category (print each category and count)

// 7E: Call reportResults with the checking account's transactions, title: "Checking Transactions"
//   Call reportResults with [checkingAccount, savingsAccount], title: "All Accounts"


// 7F: Demonstrate value vs. reference semantics:
//   Copy one Transaction (struct) into a new variable. Modify the copy's description.
//   Show the original is unchanged.
//   Assign the checking account (class) to a new variable. Deposit $100 through the alias.
//   Show both variables reflect the updated balance.

// TODO: Call runlabDemo() at the bottom of the file.

runlabDemo()


// ============================================================
// END OF LAB
// ============================================================
//
// SELF-ASSESSMENT CHECKLIST
// Before submitting, verify:
//   [ ] All five types compile without warnings
//   [ ] runlabDemo() runs to completion with no crashes
//   [ ] Each error case in 7C is handled and prints a clear message
//   [ ] Struct copy semantics are correctly demonstrated in 7F
//   [ ] Class reference semantics are correctly demonstrated in 7F
//   [ ] reportResults works for both Transaction and BankAccount
//   [ ] Analytics produce correct totals matching your transactions
// ============================================================


//MORNING TO DO 
//GO OVER PRINT RESULTS 
//APPLY DAILYLIMIT TO BANKACCOUNT 
//MAKE SURE CALCULATIONS ARE CORRECT
//REDO CATEGORY PROPERTY? 
