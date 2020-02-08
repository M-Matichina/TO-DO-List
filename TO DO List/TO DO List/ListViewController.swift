//
//  ListViewController.swift
//  TO DO List
//
//  Created by Мария Матичина on 9/10/19.
//  Copyright © 2019 Мария Матичина. All rights reserved.
//

import UIKit
// Создание и управление графическим пользовательским интерфейсом, управляемым событиями, для вашего приложения для iOS или tvOS.


// КОД ДЛЯ ХРАНЕНИЯ ДАННЫХ создаееых самостоятельно В USERDEFAULTS
// Мы делаем класс напоминания, в котором у нас есть два поля, это описание напоминания и поле, которое показывает, выполнено состояние или нет
class Reminder: NSObject, NSCoding { // Мы делаем кнопку чек у напоминания - Для этого, нам нужно, чтоб наше напоминание хранило это состояние
    var desc = "" // description - описание напоминания
    var isCheck = false // Изначально поле isCheck = false, т.к напоминание не выполнено
    
    init(desc: String, isCheck: Bool) { // для стр. 106 чтобы инициализировать созданные объекты
        self.desc = desc // self - в твоие классе в Reminder
        self.isCheck = isCheck
    }
    required init(coder decoder: NSCoder) { // инициализирует объект при декодировании
        self.desc = decoder.decodeObject(forKey: "desc") as? String ?? ""
        self.isCheck = decoder.decodeBool(forKey: "isCheck")
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(desc, forKey: "desc")
        coder.encode(isCheck, forKey: "isCheck")
        
        // Я создала объект Reminder у него несколько полей (desc и ischeck). Надо хранить массив объектов Reminder в UserDefaults. Так как этоm объект создан мной (Reminder) то его нельзя сохранить в UserDefaults. Чтобы их сохранить там их нужно кодировать. Кодируем и сохраняем в UserDefaults. В момент, когда нужно получить данные из локального хранилища, то обращаемся в UserDefaults по ключу (ReminderData) и получаем данные в закодированном виде и затем из декодируем.
        // Алгоритм:
        // 1.мы нажимаем на ячейку (это фильтрованный массив)
        // 2.берем фильтрованное напоминание и ищем его в основном массиве где у нас нефильтрованные данные
        // 3.нашли индекс этого элемента в data
        // 4.изменяем значение isCheck
        // 5.кодируем data
        // 6.сохраняем в userdefaults
    }
}

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddViewControllerDelegate {
    //  AddViewControllerDelegate - подписан под наш протокол
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addBtn: UIBarButtonItem! // Кнопка, предназначенная для размещения на панели инструментов или панели вкладок
    @IBOutlet weak var mySegmentedControl: UISegmentedControl!
    
    var data: [Reminder] = [] // данные в виде массива Reminder
    var filteredReminder: [Reminder] = [] // фильтрованное напоминание в виде массива Reminder
    
    
    override func viewDidLoad() { // Метод, который срабатывает когда вью заканчивает загружаться
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: .zero)
        // скрывает пустые ячейки снизу
        
        // а во viewDidLoad вытаскивай значения из UserDefaults.standard.set(data, forKey: "NotificationData") для того чтобы когда ты открыла приложение, метод на экране ListViewController запустился один раз и проинициализировал твой массив данных
        
        // Код для получения данных из хранилища
        // Здесь я получаю данные в виде закодированных данных
        if let encodeStoreData = UserDefaults.standard.data(forKey: "ReminderData"), let decodeStoreData = NSKeyedUnarchiver.unarchiveObject(with: encodeStoreData) as? [Reminder] {
            // storeData - хранимые закодированные данные в нее записываю данные из лакольного хранилща по ключу ReminderData
            // decodeStoreData - декодируемые (раскадируемын) хранимые данные в них передаю закодированные данные и в виде объекта массива Reminder
            data = decodeStoreData // раскодированыне данные и в виде объекта массива Reminder
            // tableView.reloData НЕ НАДО ПИСАТЬ так как вызываем функцию, в которой есть перезагрузка
            // UserDefaults.standard.value(forKey: "NotificationData") получение значения из локального хранилища, тип будет Any т.е там может быть объект любого типа
            // as? [Reminder] - указываешь (проверяешь), что объект типа Any будет в виде массива Reminder, т.е [Reminder]
            
            // измнеить заголовок
            self.navigationItem.title = "Напоминание"
            filterDataWithSelectedSegement() // Вызываем функцию во viewdidload именно тут потому что ты можешь не получить данные из локального хранилища (например при первом запуске приложения, т.к оно пустое) поэтому лишний раз вызывать нет смысла
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // меняет цвет кнопки
        addBtn.tintColor = UIColor.blue
        //  navigationController? - может быть или не быть, изменяет цвет заголовка сразу для всего navigationBar (для 1 и 2 экрана)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.blue]
    }
    
    // нужна, чтобы задать, сколько ячеек будут в таблице
    // когда я буду вызывать функцию, то я не буду писать названия парметра
    // row -  строка
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredReminder.count // кол-во отфильтрованных напоминаний. отфильтрованных имеется ввиду на "ТЕКУЩЕЕ" и "ВЫПОЛНЕННЫЕ"
    }
    
    // нужна для того чтобы задать, какие ячейки будут в твоей таблице
    // cell - ячейка
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "noteCell", for: indexPath) as! TableViewCell
        cell.titleLabel.text = filteredReminder[indexPath.row].desc // установка данных в ячейку // data[indexPath.row] - берешь по индексу indexPath.row из массива data - напоминание. desc - у этого напоминания берешь описание. // data[indexPath.row].desc - т.е. это описание каждой строчки, например: покушать, погулять, теперь меняет на filteredReminder[indexPath.row].desc
        if filteredReminder[indexPath.row].isCheck == true { // берем напоминание из массива фильтрованных напоминаний по индексу у этого напоминания проверяем значение в поле isCheck. тут ты берешь фильтрованное напоминание и в зависимости isCheck устанавливаешь картинку в cell
            cell.checkEmpty.image = UIImage(named: "checkFull")
        } else {
            cell.checkEmpty.image = UIImage(named: "checkEmpty")
        }
        return cell
    }
    
    // теперь тебе нужно сделать динамическую высоту ячейки
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
        // CGFloat - это специализированная форма Float, которая содержит 32-битные или 64-битные данные в зависимости от платформы. CG сообщает вам, что это часть Core Graphics, и она встречается в UIKit,
    }
    
    // когда происходит переход с 1 экрана на другой для передачи данных
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { // автоматически вызывается в момоент переключения с 1 экрана на дургой
        if segue.identifier == "addSegue" {
            // segue - переход
            let destinationVC = segue.destination as! AddViewController // при переходе сохранили AddViewController в нашу let destinationVC
            destinationVC.delegate = self // указываем на то что  destinationVC.delegate находится в классе AddViewControllerDelegate
        }
    }
    
    // Здесь я сохраняю данные. Код для записи данных в хранилеще UserDefaults
    // код на сохранение текста на 1 экране код для table data
    func fillTheTableWith(info: String) { // string - потому что в эту функцию придет твой текст с экрана add. // параметр - info. параметр может менять имя
        let reminder = Reminder(desc: info, isCheck: false) // desc - параметр при инициализации объекта Reminder
        // константа напоминания
        data.append(reminder) // добалвения нового напоминания в массив данных
        let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: data) // кодируем данные
        // константа закодированных данных
        UserDefaults.standard.set(encodedData, forKey: "ReminderData") // Сохраняем закодированные данные, записывает закодированные данные по ключу ReminderData
        
        // UserDefaults.standard.set(data, forKey: "ReminderData") код для хранения небольших значений
        // !!! в UserDefaults нельзя сохранять свои созданные объекты их сначала нужно кодировать и сохранять в кодированом виде, а потом декодировать, чтобы отобразить
        // UserDefaults - Интерфейс к пользовательской базе данных, где вы постоянно храните пары ключ-значение при каждом запуске приложения
        // NotificationData - Данные уведомления
        filterDataWithSelectedSegement()
    }
    
    // Код для удаления
    // потому что ты сейчас работала только со списком текущий, где количество элементов = количеству элементов в data но в data у тебя также будут и завершенные простой пример
    //    DATA
    //    0. зав
    //    1. зав
    //    2. зав
    //    3. тек
    //    4. зав
    // на сегменте текущий у тебя indexPath.row = 0 (только 1 элемент) ты удалишь из data элемент по индексу 0, а нужно удалить по индексу 3
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let removeReminder = filteredReminder[indexPath.row] // берешь элемент из фильтрованного списка по индексу (элемент, который будешь удалять)
            // дальше, тебе нужно взять индекс этого элемента в массиве data, для этого сначала ищем этот элемент в data
            if let indexRemove = data.firstIndex(where: { $0.desc == removeReminder.desc }) {
                filteredReminder.remove(at: indexPath.row) // удаляем из filteredReminder
                data.remove(at:indexRemove) // удаляем из data
                let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: data) // кодируем данные
                UserDefaults.standard.set(encodedData, forKey: "ReminderData") // Сохраняем закодированные данные
                tableView.deleteRows(at: [indexPath], with: .none) // удаляем ячейку из таблички (только отображение на экране)
            }
        }
    }
    
    // Массив это набор, количество ячеек равно количеству элементов в наборе, каждой ячейке соответствует один индекс, чтобы взять элемент из набора, нужно взять его по индекс
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // если картика в ячейке равна (ноучек), то ставим картинку чек, иначе картинку ноучек
        if let cell = tableView.cellForRow(at: indexPath) as? TableViewCell {
            if cell.checkEmpty.image == UIImage(named: "checkEmpty") {
                cell.checkEmpty.image = UIImage(named: "checkFull")
                filteredReminder[indexPath.row].isCheck = true // indexPath.row - это индекс этой ячейки, берём индекс и получаем данные из массива для этой ячейки
            }else{
                cell.checkEmpty.image = UIImage(named: "checkEmpty")
                filteredReminder[indexPath.row].isCheck = false
            }
            let selectedReminder = filteredReminder[indexPath.row] // из отфильтрованных напоминаний берем то, на которое нажали в табличке
            if let indexData = data.firstIndex(where: { $0.desc == selectedReminder.desc }) { // нашли индекс этого элемента в data
                // $0.desc == filteredData[indexPath.row].desc
                // filteredData[indexPath.row] - элемент в ячейке на которую нажали
                // $0 - а это, по очереди каждый элемент из data
             data[indexData].isCheck = selectedReminder.isCheck// изменяем значение isCheck
                // Здесь я сохраняю данные. Код для записи данных в хранлеще UserDefaults
                // код на сохранение ЗЕЛЕНОЙ картинки
                let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: data) // кодируем данные. где идет сохранение, нужно опять искать по desc в data напоминание и изменить значение у data и сохранить т.е.НЕ менять на filteredReminder[indexPath.row].isCheck
                UserDefaults.standard.set(encodedData, forKey: "ReminderData") // Сохраняем закодированные данные
                filterDataWithSelectedSegement()
                // у тебя изначально два массива
                // data - там где ВСЕ напоминания
                // ilteredData - там где напоминания под твой сегмент (или Текущие или Выполненные)
                // когда нажали, то изменили статус с текущего на выполненное или наоборот
                // чтобы отобразить на экране, нужно перезагрузить таблицу
                // и также filteredData, т.к в ней только напоминания одного конкретного статуса
        }
    }
}
    
    @IBAction func indexChanged(_ sender: Any) { // когда @IBAction то в параметре обычно (_ sender: Any). @IBAction это действие срабатывает, когда ты нажимаешь на другой сегмент
        
        // valueChanged - тип действия (системно)
        // indexChanged - названия действия (мы сами назвали так)
        // Мы на сториборде добавили сегментед контрол, в котором два состояния, чтобы нам понять, что мы нажали на другой сегмент и сделать что-то в этом случае, мы создаем действие indexChanged - точно также как нажатие на кнопку. Мы нажали и у нас внутри сегмента изменилось значение с 0 на 1 и наоборот. На изменение мы ставим тип действия valueChanged (выбираем из списка на сториборде), а функция indexChanged у нас выполняется как раз в случае, когда изменилось значение в сегменте, т.е 1. нажали на сегмент 2.изменилось значение в сегменте 3. выполнилась функция indexChanged
        
        
       filterDataWithSelectedSegement()
    }
    
    // Код на проверку какой сегмент у тебя сейчас выбран.
    func filterDataWithSelectedSegement() { // Задача функции заключается в том, чтобы в filteredReminder записать данные, в зависимости от сегмента, который выбран. Без (_ sender: Any) т.к у нас функция без параметров, мы в нее не будем ничего передавать. Вызываем ее во viewdidload
        if(mySegmentedControl.selectedSegmentIndex==0) {
            filteredReminder = data.filter({ $0.isCheck == false })
        }
        else if(mySegmentedControl.selectedSegmentIndex==1) {
            filteredReminder = data.filter({ $0.isCheck == true })
        }
        tableView.reloadData()
    }
    
}
