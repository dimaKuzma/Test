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
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var deleteButton: UIButton!
    
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
    
    @IBAction func addCellButtonAction(_ sender: Any) {
        let id = configureUID()
        let ref = Database.database(url: Constants.reference).reference()
        ref.child(id).child("name").setValue("Название")
        ref.child(id).child("place").setValue("Местоположение")
        configureData { [weak self](value) in
            self!.dictionary = (value as? [String : Dictionary<String, Any>])! ?? [:]
            DispatchQueue.main.async {
                self!.configureUI()
            }
        }
    }
    
    @IBAction func deleteButtonAction(_ sender: Any) {
        checkBox = true
        let ref = Database.database(url: Constants.reference).reference().child(selectedCell).child("images")
        let tableCell = dictionary[selectedCell]
        var array = tableCell!["images"] as! [String]
        for i in cellsToDelete {
            array.remove(at: i)
        }
        ref.setValue(array)
        
        configureData { [weak self](value) in
            self!.dictionary = (value as? [String : Dictionary<String, Any>])! ?? [:]
            self!.checkBox = true
            DispatchQueue.main.async {
                self!.configureUI()
            }
        }
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
        configureTableView()
        configureImagePicker()
        configureDeleteButton()
    }
    
    func configureTableView() {
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
        let heightOfItem = (tableView.frame.width - 40) / 3
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

