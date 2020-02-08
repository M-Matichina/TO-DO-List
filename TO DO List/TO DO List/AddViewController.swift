//
//  AddViewController.swift
//  TO DO List
//
//  Created by Мария Матичина on 9/15/19.
//  Copyright © 2019 Мария Матичина. All rights reserved.
//

import UIKit

protocol AddViewControllerDelegate {
    func fillTheTableWith(info: String)
    // хотим делегировать этот медот в другой viewcontroller (ListViewController), в тот в которрм будет прописат наш протокол (AddViewControllerDelegate )
}

class AddViewController: UIViewController {
    
    var delegate: AddViewControllerDelegate?
    // что у нашего AddViewController есть сво-во delegate, delegate имеет тип нашего протокола AddViewControllerDelegate, и тот кто подпишется под наш протокол сможет выполнить этот метод func fillTheTableWith(info: String), тем самым передав данные с addViewController на listviewcontroller
    
    @IBOutlet weak var save: UIButton!
    @IBOutlet weak var textView: UITextView! 
    
    override func viewDidLoad() { // Метод, который срабатывает когда вью заканчивает загружаться
        super.viewDidLoad()
        
        title = "Новое напоминание"
        
        // для кнопки save
        // layer - слой, у view есть слой
        save.backgroundColor = .white
        save.layer.cornerRadius = 25
        save.layer.borderWidth = 1
        save.layer.borderColor = UIColor.blue.cgColor
        save.setTitleColor(UIColor.blue, for: .normal) // изменить цвет слова сохранить
        
        // тень для save
        // CGSize Core Graphic - структура, которая содержит значения ширины и высоты
        // save.layer.shadowColor = UIColor.blue.cgColor
        // save.layer.shadowOffset = CGSize(width: 0, height: 0) // offset - смещение, наклон тени
        // save.layer.shadowRadius = 0
        // save.layer.shadowOpacity = 0 // opacity - помутнение
        
        // для кнопки textView
        textView.backgroundColor = .white
        textView.layer.cornerRadius = 25
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.blue.cgColor
        
        // измнеить заголовок
        self.navigationItem.title = "Новое напоминание"
        // изменяет цвет копки back
        self.navigationController?.navigationBar.tintColor = UIColor.blue
    }
    
    // MARK: - Actions
    @IBAction func saveAction(_ sender: Any) {
        //  проверка на ввод пустоты
        if textView.text.count == 0 {
            return
        }
        let textFormatted = textView?.text.trimmingCharacters(in: .whitespacesAndNewlines) // Код на удаление пробела
        delegate?.fillTheTableWith(info: textFormatted ?? "") // функция, которая передаст данные на 1 экран отформатированные без пробела
        navigationController?.popViewController(animated: true) // делает переход на 1 экран после как записали напоминания и нажали сохрнаить
    }
    
    // wilappear срабатывает каждый раз когда переходишь на экран
    // viewdidloda - только когда 1 раз открыла
    // 1 раз открыли экран лист
    // - сработала viewDidLoaпd()
    // - сработала wilappear()
    // нажала + ушла на экран добавления, добавила, нажала сохранить, вернулась на экран лист
    // - сработал wilappear()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

}

