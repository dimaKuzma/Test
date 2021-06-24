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
    let vectorImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Vector")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    let unionImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Union")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    let locationsLabel: UILabel = {
        let label = UILabel()
        label.text = "ЛОКАЦИИ"
        label.textAlignment = .center
        label.font = UIFont(descriptor: UIFontDescriptor(name: "Thin", size: 33.0), size: 33.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let nameTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .lightGray
        textField.layer.cornerRadius = 10
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    let deleteButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dictionary.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
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

// MARK: -
// MARK: Delegate
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let heightOfItem = (tableView.frame.width - 40) / 3 + 10
        let keys: [String] = Array(dictionary.keys) as! [String]
        let key = keys[indexPath.row]
        let dict = dictionary[key]
        if let images = dict!["images"] as? [String] {
            let count = images.count
            let countOfRows = CGFloat(ceil(Double(count) / 3.0))
            let height = 89 + (countOfRows * heightOfItem)
            return height
        } else {
            return 200
        }
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
        setupVectorImageView()
        setupUnionImageView()
        setupLocationLabel()
        setupNameTextField()
        setupTableView()
        setupDeleteButton()
        setupAddButton()
    }
    
    func setupVectorImageView() {
        view.addSubview(vectorImage)
        vectorImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 50).isActive = true
        vectorImage.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 50).isActive = true
        vectorImage.widthAnchor.constraint(equalToConstant: view.frame.width - 100).isActive = true
        vectorImage.heightAnchor.constraint(equalToConstant: 75).isActive = true
    }
    
    func setupUnionImageView() {
        view.addSubview(unionImage)
        unionImage.topAnchor.constraint(equalTo: vectorImage.bottomAnchor, constant: -50).isActive = true
        unionImage.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 50).isActive = true
        unionImage.widthAnchor.constraint(equalToConstant: view.frame.width - 100).isActive = true
        unionImage.heightAnchor.constraint(equalToConstant: 75).isActive = true
    }
    
    func setupLocationLabel() {
        view.addSubview(locationsLabel)
        locationsLabel.topAnchor.constraint(equalTo: vectorImage.topAnchor).isActive = true
        locationsLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 50).isActive = true
        locationsLabel.widthAnchor.constraint(equalToConstant: view.frame.width - 100).isActive = true
        locationsLabel.bottomAnchor.constraint(equalTo: unionImage.bottomAnchor).isActive = true
    }
    
    func setupNameTextField() {
        view.addSubview(nameTextField)
        nameTextField.topAnchor.constraint(equalTo: unionImage.bottomAnchor, constant: 10).isActive = true
        nameTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 35).isActive = true
        nameTextField.widthAnchor.constraint(equalToConstant: view.frame.width - 70).isActive = true
        nameTextField.heightAnchor.constraint(equalToConstant: 34).isActive = true
    }
    
    func setupDeleteButton() {
        deleteButton.addTarget(self, action: #selector(deleteButtonAction), for: .touchUpInside)
        view.addSubview(deleteButton)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 100).isActive = true
        deleteButton.widthAnchor.constraint(equalToConstant: view.frame.width - 200).isActive = true
        deleteButton.centerYAnchor.constraint(equalToSystemSpacingBelow: view.centerYAnchor, multiplier: 1.5).isActive = true
        deleteButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
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
                self!.configureUI()
                self!.tableView.reloadData()
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
                tableView.reloadData()
            }
        }
    }
    
    func setupTableView() {
        view.addSubview(tableView)
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 10).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}

