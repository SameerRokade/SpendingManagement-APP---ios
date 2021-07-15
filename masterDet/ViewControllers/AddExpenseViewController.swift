


import UIKit
import CoreData
import EventKit

var expenseName: String = ""
var expenseAmount: String = ""
var expenseNote: String = ""
var selectedDate = Date()
var isReminder: Bool = false
var expenseOccurence: Int = 0
var expenseId: String = "" 


class AddExpenseViewController: UIViewController {

    @IBOutlet weak var nameTxt: UITextField!
    @IBOutlet weak var amountTxt: UITextField!
    @IBOutlet weak var addnoteTxt: UITextField!
    @IBOutlet weak var datetimePicker: UIDatePicker!
    
    @IBOutlet weak var calendarSwitch: UISwitch!
    @IBOutlet weak var occurenceSeg: UISegmentedControl!
        
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    
    // MARK: Variables declearations
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var context:NSManagedObjectContext!
    
    let eventStore = EKEventStore()

    
    var occurenceIdx: Int = 0
    let occurenceStrings: [String] = ["One off", "Daily", "Weekly", "Monthly"]

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTxt.text = expenseName
        amountTxt.text = expenseAmount
        addnoteTxt.text = expenseNote
        datetimePicker.setDate(selectedDate, animated: false)
        calendarSwitch.isOn = isReminder
        occurenceSeg.selectedSegmentIndex = expenseOccurence
        
        calcendarSwitchAction()
        occurenceIdx = expenseOccurence
    }

    @IBAction func calendarSwitchPressed(_ sender: Any) {
        calcendarSwitchAction()
    }
    
    func calcendarSwitchAction() {
        if calendarSwitch.isOn
        {
            requestAccess()
        }
    }
    
    func requestAccess() {
        eventStore.requestAccess(to: .event) { [self] (granted, error) in
            if granted {
                // save event.
                guard let calendar = eventStore.defaultCalendarForNewEvents else { return }
                let event = EKEvent(eventStore: eventStore)
                event.title = nameTxt.text ?? "Event"//"This is my test event"
                event.startDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
                event.isAllDay = true
                event.endDate = event.startDate
                event.calendar = calendar
                try! eventStore.save(event, span: .thisEvent, commit: true)

            }
        }
    }
    
    @IBAction func occurenceSegPressed(_ sender: Any) {
        occurenceIdx = occurenceSeg.selectedSegmentIndex
    }
        
    @IBAction func saveBtnPressed(_ sender: Any) {
        
        openDatabse()
        //
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
}

extension AddExpenseViewController {
    
    // MARK: Methods to Open, Store and Fetch data
    func openDatabse()
    {
        
        if !blankValidate() { return }
        context = appDelegate.persistentContainer.viewContext
        if expenseId == "" {
            let entity = NSEntityDescription.entity(forEntityName: "Expense", in: context)
            let newRecord = NSManagedObject(entity: entity!, insertInto: context)
            saveData(UserDBObj:newRecord)
        }
        else
        {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Expense")
            fetchRequest.predicate = NSPredicate(format: "genDate = %@", expenseId)
            
            let newRecord = try! context.fetch(fetchRequest) as! [NSManagedObject]
            if newRecord.count != 0 {
             
                newRecord[0].setValue(Int(amountTxt.text!) ?? 0, forKey: "amount")
                newRecord[0].setValue(dateFormatter.string(from: datetimePicker.date), forKey: "date")
                newRecord[0].setValue(addnoteTxt.text ?? "", forKey: "note")
                newRecord[0].setValue(occurenceStrings[occurenceIdx], forKey: "occurence")
                newRecord[0].setValue(calendarSwitch.isOn, forKey: "reminderFlag")
                newRecord[0].setValue(nameTxt.text!, forKey: "title")

                
                print("Updated Data..")
                do {
                    try context.save()
                } catch {
                    print("storig data failed")
                }
            }
        }
   }
    
    @objc
    func saveData(UserDBObj:NSManagedObject)
    {
        UserDBObj.setValue(Int(amountTxt.text!) ?? 0, forKey: "amount")
        UserDBObj.setValue(dateFormatter.string(from: datetimePicker.date), forKey: "date")
        UserDBObj.setValue(addnoteTxt.text ?? "", forKey: "note")
        UserDBObj.setValue(occurenceStrings[occurenceIdx], forKey: "occurence")
        UserDBObj.setValue(calendarSwitch.isOn, forKey: "reminderFlag")
        UserDBObj.setValue(nameTxt.text!, forKey: "title")
        UserDBObj.setValue(addedDate, forKey: "timestamp")
        // Set Date Format
        dateFormatter.dateFormat = "YY/MM/dd-HH:MM:SS"
        UserDBObj.setValue(dateFormatter.string(from: Date()), forKey: "genDate")
        
        print("Storing Data..")
        do {
            try context.save()
            NotificationCenter.default.post(name: .SAVEEXPENSE, object: nil)
        } catch {
            print("storig data failed")
        }

    }
    
    func blankValidate() -> Bool {
        
        if nameTxt.text == "" || nameTxt.text == nil { print("Enter all the values"); return false }
        if amountTxt.text == "" || amountTxt.text == nil { print("Enter all the values"); return false }
        
        return true
    }
    
    
}
