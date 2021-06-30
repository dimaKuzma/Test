//
//  ViewController.swift
//  Test
//
//  Created by Дмитрий on 6/7/21.
//  Copyright © 2021 DK. All rights reserved.
//

import UIKit
import Firebase
import ImagePicker

class ViewController: UIViewController {
    // - UI
    let deleteButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .red
        button.layer.cornerRadius = 17
        button.tintColor = .orange
        button.setTitle("Удалить", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let addButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "plus"), for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 25
        button.tintColor = .orange
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    
    // - ImagePicker
    let imagePicker = ImagePickerController()
    
    // - Cell
    var selectedCell = "Название"
    
    // - Data
    var dictionary = [String: Dictionary<String, Any>]()
    var imagesAfterAdding = [String]()
    var checkBox = true
    var cellsToDelete = [Int]()
    
    // - Database
    var time = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureData { [weak self](value) in
            self!.dictionary = (value as? [String : Dictionary<String, Any>])! ?? [:]
            DispatchQueue.main.async {
                self!.configureUI()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
}

// MARK: -
// MARK: Configure
extension ViewController {
    func configureData(completion: @escaping ((_ value: Any) -> Void)) {
        Database.database(url: Constants.reference).reference().observe(.value) { (snapshot) in
            guard let value = snapshot.value, snapshot.exists() else {
                print ("error")
                return
            }
            completion(value)
        }
    }
    
    func configureUI() {
        configureAnchors()
        configureTableView()
        configureImagePicker()
        configureDeleteButton()
    }
    
    func configureTableView() {
        tableView.register(TableViewCell.self, forCellReuseIdentifier: "TableViewCell")
        tableView.register(MainTableViewCell.self, forCellReuseIdentifier: "MainTableViewCell")
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func configureImagePicker() {
        self.imagePicker.delegate = self
        self.imagePicker.modalPresentationStyle = .fullScreen
        self.imagePicker.imageLimit = 10
    }
    
    func configureDeleteButton() {
        if checkBox {
            deleteButton.isHidden = true
            
        }else {
            deleteButton.isHidden = false
        }
    }
    
    func presentImagePicker() {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func configureUID() -> String {
        let date = Date()
        let id = String(Int(date.timeIntervalSince1970))
        return id
    }
}

// MARK: -
// MARK: DataSource
extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return dictionary.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MainTableViewCell", for: indexPath) as! MainTableViewCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
            cell.makeShadow()
            cell.vc = self
            let keys: [String] = Array(dictionary.keys) as! [String]
            let key = keys[indexPath.row]
            let dict = dictionary[key]
            if let name = dict!["name"], let place = (dict!["place"]) {
                cell.nameTextField.text = name as! String
                cell.addressTextField.text = place as! String
            }
            if let images = dict!["images"] {
                cell.images = images as! [String]
            }
            cell.id = key
            return cell
        }
    }
}

// MARK: -
// MARK: Delegate
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 154
        } else {
            var heightOfItem = (tableView.frame.width - 40) / 3 + 10
            let keys: [String] = Array(dictionary.keys) as! [String]
            let key = keys[indexPath.row]
            let dict = dictionary[key]
            if let images = dict!["images"] as? [String] {
                let count = images.count
                let countOfRows = CGFloat(ceil(Double(count) / 3.0))
                if countOfRows == 1 {
                    heightOfItem += 10
                }
                let height = 89 + (countOfRows * heightOfItem)
                return height
            } else {
                return 100
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
}

// MARK: -
// MARK: ImagePickerDelegate
extension ViewController: ImagePickerDelegate {
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        var array = [Data]()
        for image in images {
            array.append(image.pngData()!)
        }
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        var array = [Data]()
        for image in images {
            array.append(image.pngData()!)
        }
        for index in 0...array.count - 1 {
            createCell(name: "\(selectedCell)_\(index)", image: array[index])
        }
        Database.database(url: Constants.reference).reference().child(self.selectedCell).child("images").setValue(self.imagesAfterAdding)
        tableView.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}

// MARK: -
// MARK: Firebase
extension ViewController {
    func upload(name: String, image: Data, completion: @escaping (Result <URL, Error>) -> Void) {
        let refStorage = Storage.storage().reference().child("images").child(name)
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        refStorage.putData(image, metadata: metadata) { (metadata, error) in
            guard let _ = metadata else {
                completion(.failure(error!))
                return
            }
            refStorage.downloadURL { (url, error) in
                guard let url = url else {
                    completion(.failure(error!))
                    return
                }
                completion(.success(url))
            }
        }
    }
    
    func createCell(name: String, image: Data) {
        upload(name: name, image: image) { (result) in
            switch result{
            case .success(let url):
                self.imagesAfterAdding.append(url.absoluteString)
                DispatchQueue.main.async {
                    Database.database(url: Constants.reference).reference().child(self.selectedCell).child("images").setValue(self.imagesAfterAdding)
                    self.configureUI()
                }
            case .failure(let error):
                print("errorCreate")
            }
        }
    }
}

// MARK: -
// MARK: ConfigureAnchors
extension ViewController {
    func configureAnchors() {
        setupTableView()
        setupDeleteButton()
        setupAddButton()
    }
    
    func setupDeleteButton() {
        deleteButton.addTarget(self, action: #selector(deleteButtonAction), for: .touchUpInside)
        view.addSubview(deleteButton)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 100).isActive = true
        deleteButton.widthAnchor.constraint(equalToConstant: view.frame.width - 200).isActive = true
        deleteButton.centerYAnchor.constraint(equalToSystemSpacingBelow: view.centerYAnchor, multiplier: 1.5).isActive = true
        deleteButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        deleteButton.makeShadow()
    }
    
    @objc func deleteButtonAction() {
        let ref = Database.database(url: Constants.reference).reference().child(selectedCell).child("images")
        let tableCell = dictionary[selectedCell]
        var array = tableCell!["images"] as! [String]
        for i in cellsToDelete {
            array.remove(at: i)
        }
        ref.setValue(array)
        cellsToDelete.removeAll()
        configureData { [weak self](value) in
            self!.dictionary = (value as? [String : Dictionary<String, Any>])! ?? [:]
            DispatchQueue.main.async {
                self!.checkBox = true
                self!.cellsToDelete.removeAll()
                self!.tableView.reloadData()
                self!.configureUI()
            }
        }
    }
    
    func setupAddButton() {
        view.addSubview(addButton)
        addButton.addTarget(self, action: #selector(addButtonAction), for: .touchUpInside)
        addButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -35).isActive = true
        addButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        addButton.makeShadow()
    }
    
    @objc func addButtonAction() {
        let id = configureUID()
        let ref = Database.database(url: Constants.reference).reference()
        ref.child(id).child("name").setValue("Название")
        ref.child(id).child("place").setValue("Местоположение")
        configureData { [weak self](value) in
            self!.dictionary = (value as? [String : Dictionary<String, Any>])! ?? [:]
            DispatchQueue.main.async {
                self!.configureUI()
                self!.tableView.reloadData()
            }
        }
    }
    
    func setupTableView() {
        view.addSubview(tableView)
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}

