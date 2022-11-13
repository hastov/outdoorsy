//
//  ViewController.swift
//  Outdoorsy
//
//  Created by hristoathristov
//

import SDWebImage

class ViewController: UIViewController {
    
    var service: DataRetrieving?
    private var searching: Cancellable?
    private var rentals: [Rental]? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
        tableView.dataSource = self
    }

    @objc private func textFieldEditingChanged(_ textField: UITextField) {
        searching?.cancel()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.getRentails(with: textField.text)
        }
    }
    
    private func getRentails(with filter: String?) {
        guard let filter = filter else {
            return
        }
        searching = service?.get(filter: filter) { [weak self] result in
            self?.searching = nil
            switch result {
            case .success(let rentals):
                self?.rentals = rentals
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rentals?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listing", for: indexPath) as! ListingTableViewCell
        let rental = rentals?[some: indexPath.item]
        cell.label.text = rental?.name
        cell.leftImageView.sd_setImage(with: rental?.imageURL, placeholderImage: UIImage(systemName: "slowmo"))
        return cell
    }
}

