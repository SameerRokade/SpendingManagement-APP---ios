


import UIKit
import CoreData



var categoryName: String = ""
var categoryAmount: String = ""
var colorIdx: Int = 0
var categoryNote: String = ""
var selectedId: String = ""//timestamp

class AddCategoryViewController: UIViewController {
    
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var nameTxt: UITextField!
    @IBOutlet weak var amountTxt: UITextField!
    @IBOutlet weak var colorSeg: UISegmentedControl!
    @IBOutlet weak var noteTxt: UITextField!
    
    // MARK: Variables declearations
    let appDelegate = UIApplication.shared.delegate as! AppDelegate //Singlton instance
    var context:NSManagedObjectContext!
    
    let colorArray: [String] = ["#FF0000", "#00FF00", "#800080", "#FFFF00", "#0000FF", "#FFC0CB"]
    var colorIndex: Int = 0
     
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTxt.text = categoryName
        amountTxt.text = categoryAmount
        noteTxt.text = categoryNote
        colorIndex = colorIdx
        colorSeg.selectedSegmentIndex = colorIdx
        
    }
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        // ... save action
        openDatabse()
        //
        dismiss(animated: true, completion: nil)
                
    }
    
    @IBAction func cancelBtnPresssed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func colorSegPressed(_ sender: Any) {
        colorIndex = colorSeg.selectedSegmentIndex
        print("colorSeg.selectedSegmentIndex", colorSeg.selectedSegmentIndex)
    }
    
    
}

extension AddCategoryViewController {
    
    // MARK: Methods to Open, Store and Fetch data
    func openDatabse()
    {
        if !blankValidate() { return }
        context = appDelegate.persistentContainer.viewContext
        if selectedId == "" {
            let entity = NSEntityDescription.entity(forEntityName: "Categories", in: context)
            let newRecord = NSManagedObject(entity: entity!, insertInto: context)
            saveData(UserDBObj:newRecord)
        }
        else
        {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Categories")
            fetchRequest.predicate = NSPredicate(format: "timestamp = %@", selectedId)
            

            let newRecord = try! context.fetch(fetchRequest) as! [NSManagedObject]
            if newRecord.count != 0 {
                newRecord[0].setValue(nameTxt.text, forKey: "name")
                newRecord[0].setValue(Int(amountTxt.text!) ?? 0, forKey: "budget")
                newRecord[0].setValue(colorArray[colorIndex], forKey: "color")
                newRecord[0].setValue(noteTxt.text ?? "", forKey: "note")
            
                print("Updated Data..")
                do {
                    try context.save()
                    NotificationCenter.default.post(name: .SAVEDATA, object: nil)

                } catch {
                    print("storig data failed")
                }
            }
            
            
        }
        
    }

    @objc
    func saveData(UserDBObj:NSManagedObject)
    {
        UserDBObj.setValue(nameTxt.text, forKey: "name")
        UserDBObj.setValue(Int(amountTxt.text!) ?? 0, forKey: "budget")
        UserDBObj.setValue(colorArray[colorIndex], forKey: "color")
        UserDBObj.setValue(noteTxt.text ?? "", forKey: "note")
        
        // Set Date Format
        dateFormatter.dateFormat = "YY/MM/dd-HH:MM:SS"
        UserDBObj.setValue(dateFormatter.string(from: Date()), forKey: "timestamp")
        
        print("Storing Data..")
        do {
            try context.save()
            NotificationCenter.default.post(name: .SAVEDATA, object: nil)

        } catch {
            print("storig data failed")
        }

    }

    func blankValidate() -> Bool {
        
        if nameTxt.text == "" || nameTxt.text == nil { print("Fill the blanks"); return false }
        if amountTxt.text == "" || amountTxt.text == nil { print("Fill the blanks"); return false }
        
        return true
    }
    
}
