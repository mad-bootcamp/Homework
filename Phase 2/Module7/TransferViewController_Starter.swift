//
//  TransferViewController_Starter.swift
//  PNCMobileApp
//
//  Module 7 — iOS Application Architecture
//  Lab Exercise: Refactor TransferViewController
//
//  SCENARIO
//  The view controller below is a Massive View Controller: it mixes
//  networking, validation, and UI update logic in one class. Your task is
//  to refactor it using the patterns from this module.
//
//  REQUIREMENTS
//  1. Extract a TransferViewModel with ZERO UIKit imports.
//  2. Extract transfer eligibility rules into a TransferEligibilityService.
//  3. Inject an AccountsRepository protocol via the ViewModel's
//     initializer — no singletons.
//  4. The refactored ViewModel must be unit-testable using a fake
//     repository, with no real network call.
//
//  Read through BEFORE_ExistingMassiveViewController below first — really
//  read it, don't skim. Naming what's wrong with it is part of the
//  exercise. Then fill in the TODOs in the scaffolding beneath it.
//

import UIKit

// MARK: - BEFORE: the Massive View Controller (do not edit — refactor FROM this)

class BEFORE_ExistingMassiveViewController: UIViewController {
    var fromAccount: Account!
    var toAccount: Account!
    @IBOutlet weak var amountField: UITextField!

    @IBAction func transferButtonTapped() {
        guard let text = amountField.text,
              let amount = Decimal(string: text) else {
            showAlert(message: "Please enter a valid amount")
            return
        }
        guard amount > 0 else {
            showAlert(message: "Amount must be greater than zero")
            return
        }
        guard fromAccount.balance >= amount else {
            showAlert(message: "Insufficient funds")
            return
        }

        var request = URLRequest(url: URL(string: "https://api.pncmobile.com/transfer")!)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode([
            "from": fromAccount.id.uuidString,
            "to": toAccount.id.uuidString,
            "amount": "\(amount)",
        ])
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if error != nil {
                    self?.showAlert(message: "Transfer failed. Please try again.")
                } else {
                    self?.navigationController?.popToRootViewController(animated: true)
                }
            }
        }.resume()
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Transfer", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Model (complete — no changes needed)

struct Account: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let maskedNumber: String
    let balance: Decimal
}

// MARK: - TODO 1: AccountsRepository protocol

protocol AccountsRepository {
    // TODO: declare an async throws method to perform a transfer between
    // two accounts for a given amount. Think about what parameters and
    // return type make sense given how it will be called from the
    // ViewModel.
    func transfer(amount: Decimal, from account1: Account, to account2: Account) async throws
    
}

// MARK: - TODO 2: TransferEligibilityService

enum TransferError: Error, Equatable {
    case invalidAmount
    case insufficientFunds
}

struct TransferEligibilityService {
    // TODO: implement canTransfer(amount:from:) -> Result<Void, TransferError>
    // covering the same two rules as the BEFORE version above: amount must
    // be greater than zero, and the source account must have sufficient
    // balance.
    func canTransfer(amount: Decimal, from account: Account) -> Result<Void, TransferError> {
        guard amount > 0 else {
            return .failure(.invalidAmount)
        }
        guard account.balance >= amount else {
            return .failure(.insufficientFunds)
        }
        return .success(())
    }
}

// MARK: - TODO 3: TransferViewModel

final class TransferViewModel {
    // TODO: no UIKit import anywhere in this file below this point.
    // Store an AccountsRepository and a TransferEligibilityService,
    // injected via the initializer. Expose onError and onSuccess
    // closures the View can observe. Implement
    // attemptTransfer(amount:from:to:) that checks eligibility first,
    // then calls the repository if eligible.
    
    private let repository: AccountsRepository
    private let eligibilityService: TransferEligibilityService
    
    init(repository: AccountsRepository, eligibilityService: TransferEligibilityService) {
        self.repository = repository
        self.eligibilityService = eligibilityService
    }
    
    var onError: (Error) -> Void = {_ in }
    var onSuccess: () -> Void = { }
    
    func attemptTransfer(amount: Decimal, from account1: Account, to account2: Account) async {
        let result = eligibilityService.canTransfer(amount: amount, from: account1)
        
        switch result {
        case .success():
            do {
                try await repository.transfer(amount: amount, from: account1, to: account2)
                onSuccess()
            } catch{
                onError(error)
            }
        case .failure(let error):
            onError(error)
        }
        
    }
    
}
