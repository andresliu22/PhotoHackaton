//
//  TextViewController.swift
//  PhotoChallenge
//
//  Created by Andres Liu on 9/15/21.
//

import UIKit

class TextViewController: UIViewController {

    private let textField: UITextField = {
        let field = UITextField()
        field.placeholder = "Add text..."
        field.layer.masksToBounds = true
        field.layer.cornerRadius = 5.0
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.secondarySystemBackground.cgColor
        field.autocorrectionType = .no
        field.leftViewMode = .always
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        return field
    }()
    
    private let colorPickerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Set Text Color", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.backgroundColor = UIColor.systemBlue.cgColor
        button.layer.cornerRadius = 10
        return button
    }()
    
    var completion: ((String, UIColor) -> Void)?
    
    var textColor: UIColor = .label
    
    let picker = UIColorPickerViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "New Text"
        
        view.backgroundColor = .systemBackground
        view.addSubview(textField)
        textField.delegate = self

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSave))
        
        
        picker.selectedColor = .label
        picker.delegate = self
        
        colorPickerButton.addTarget(self, action: #selector(didTapColorPicker), for: .touchUpInside)
        view.addSubview(colorPickerButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        textField.frame = CGRect(x: 10, y: view.safeAreaInsets.top + 10, width: view.frame.size.width - 20, height: 50)
        
        colorPickerButton.frame = CGRect(x: 10, y: textField.bottom + 10, width: 150, height: 50)
    }
    
    // Save text added to image
    @objc private func didTapSave() {
        guard let text = textField.text, !text.isEmpty else { return }
        completion?(text, textColor)
        navigationController?.popViewController(animated: true)
        
    }

    // Presenting Color Picker
    @objc private func didTapColorPicker() {
        self.present(picker, animated: true, completion: nil)
    }
    
}

extension TextViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        didTapSave()
        return true
    }
}

extension TextViewController: UIColorPickerViewControllerDelegate {
    
    //  Called once you have finished picking the color
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        textColor = viewController.selectedColor
        
    }
    
//    //  Called on every color selection done in the picker
//    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
//        textColor = viewController.selectedColor
//    }
}
