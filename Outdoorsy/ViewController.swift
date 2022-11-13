//
//  ViewController.swift
//  Outdoorsy
//
//  Created by Guest on 12.11.22.
//

import UIKit

class ViewController: UIViewController {
    
    var service: DataRetrieving?

    @IBOutlet private weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        textField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
    }

    @objc private func textFieldEditingChanged(_ textField: UITextField) {
        guard let filter = textField.text else {
            return
        }
        print(filter)
        service?.get(filter: filter) { [weak self] result in
            switch result {
            case .success(let rentals):
                print(rentals)
            case .failure(let error):
                print(error)
            }
        }
    }
}

