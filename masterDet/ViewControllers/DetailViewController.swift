

import UIKit
import CoreData

class DetailViewController: UIViewController, NSFetchedResultsControllerDelegate, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var noteLbl: UILabel!
    @IBOutlet weak var totalLbl: UILabel!
    @IBOutlet weak var spentLbl: UILabel!
    @IBOutlet weak var remainLbl: UILabel!
    
    @IBOutlet weak var pieChart: PieChartView!
    
    @IBOutlet weak var firstLbl: UILabel!
    @IBOutlet weak var secondLbl: UILabel!
    @IBOutlet weak var thirdLbl: UILabel!
    @IBOutlet weak var forthLbl: UILabel!
    @IBOutlet weak var fifthLbl: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var managedObjectContext: NSManagedObjectContext? = nil

    let occurenceStrings: [String] = ["One off", "Daily", "Weekly", "Monthly"]
    var wholeBudget: CGFloat = 0
    var budgetForCell: CGFloat = 0
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            
//            initialize
            if let label = detailDescriptionLabel {
                detailDescriptionLabel.text = "No expenses added for this category!"
            }
            if let label = spentLbl {
                spentLbl.text = "£ 0.0"
            }
            if let label = remainLbl {
                remainLbl.text = "£ 0.0"
            }
            if let label = totalLbl {
                totalLbl.text = "£ 0.0"
            }
            if let label = firstLbl {
                firstLbl.text = "None"
            }
            if let label = secondLbl {
                secondLbl.text = "None"
            }
            if let label = thirdLbl {
                thirdLbl.text = "None"
            }
            if let label = forthLbl {
                forthLbl.text = "None"
            }
            if let label = fifthLbl {
                fifthLbl.text = "None"
            }

//            insert value
            if let label = nameLbl {
                nameLbl.text = detail.name!.description
            }
            if let label = totalLbl {
                totalLbl.text = "£ " + detail.budget!.description
            }
            wholeBudget = CGFloat(NSString(string: detail.budget!.description).floatValue)
            
            // Set Date Format
            dateFormatter.dateFormat = "YY/MM/dd-HH:MM:SS"
            
            addedDate = detail.timestamp?.description ?? dateFormatter.string(from: Date())

            
           
            let fetchRequest: NSFetchRequest<Expense> = Expense.fetchRequest()
            
            // Set the batch size to a suitable number.
            fetchRequest.fetchBatchSize = 20
            
            // Edit the sort key as appropriate.
            let sortDescriptor = NSSortDescriptor(key: "genDate", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            let predicate = NSPredicate(format: "timestamp = %@", addedDate)
            fetchRequest.predicate = predicate
            
           
            managedObjectContext = appDelegate.persistentContainer.viewContext
            let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
            aFetchedResultsController.delegate = self
            _fetchedResultsController = aFetchedResultsController
            
            do {
                try _fetchedResultsController!.performFetch()
                // ...
                if let tableView = tableView {
                    tableView.reloadData()
                }
            } catch {
                 let nserror = error as NSError
                 fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
            
            // ... chart
            var tmp = try! managedObjectContext!.fetch(fetchRequest) as [Expense]
                
            if tmp != nil && !tmp.isEmpty {

                if let label = detailDescriptionLabel {
                    detailDescriptionLabel.isHidden = true
                }

                var chartItemArray: [Segment] = []
                var spentVal: Float = 0
                // find 4 big spend
                for i in 0..<tmp.count
                {
                    for j in 0..<tmp.count
                    {
                        if Float(tmp[i].amount!) > Float(tmp[j].amount!)
                        {
                            tmp.swapAt(i, j)
                        }
                    }
                }

                /// ... this is for calculate spent_sum
                for i in tmp {
                    spentVal += Float(i.amount!)
                }

                if let label = fifthLbl {
                    spentLbl.text = "£ " + String(format: "%.f", spentVal)
                }

                if let label = remainLbl {
                    remainLbl.text = "£ " + String(format: "%.f", Float(wholeBudget) - spentVal)
                }

                let firstItem: Segment = Segment(color: #colorLiteral(red: 0.2925844789, green: 0.4938524961, blue: 0.7900626063, alpha: 1), value: CGFloat(tmp[0].amount!))
                if let label = firstLbl {
                    firstLbl.text = tmp[0].title
                }
                chartItemArray.append(firstItem)
                if tmp.count>1
                {
                    let secondItem: Segment = Segment(color: #colorLiteral(red: 0.9547323585, green: 0.7862508893, blue: 0.1429322958, alpha: 1), value: CGFloat(tmp[1].amount!))
                    if let label = secondLbl {
                        secondLbl.text = tmp[1].title
                    }
                    chartItemArray.append(secondItem)

                    if tmp.count>2
                    {
                        let thirdItem: Segment = Segment(color: #colorLiteral(red: 0.8733522296, green: 0.5389423966, blue: 0.3181962073, alpha: 1), value: CGFloat(tmp[2].amount!))

                        if let label = thirdLbl {
                            thirdLbl.text = tmp[2].title
                        }
                        chartItemArray.append(thirdItem)
                        if tmp.count>3
                        {
                            let forthItem: Segment = Segment(color: #colorLiteral(red: 0.4107291698, green: 0.6074920297, blue: 0.7789242864, alpha: 1), value: CGFloat(tmp[3].amount!))
                            if let label = forthLbl {
                                forthLbl.text = tmp[3].title
                            }
                            chartItemArray.append(forthItem)

                            if tmp.count>4
                            {
                                var tmpSum: Float = 0
                                for i in 5...tmp.count
                                {
                                    tmpSum += Float(tmp[1].amount!)
                                }
                                let fifthItem: Segment = Segment(color: #colorLiteral(red: 0.6665948629, green: 0.6667092443, blue: 0.6665787697, alpha: 1), value:CGFloat(tmp[1].amount!))
                                if let label = fifthLbl {
                                    fifthLbl.text = "Other"//tmp[4].ExpenseName
                                }
                                chartItemArray.append(fifthItem)
                            }
                        }
                    }
                }
                let sixthItem: Segment = Segment(color: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1), value: (wholeBudget - CGFloat(spentVal)))
                chartItemArray.append(sixthItem)
                if let chart = pieChart {
                    pieChart.segments = chartItemArray
                }
            }
            
                
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationBarStyler()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton

        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableData), name: .SAVEEXPENSE, object: nil)
        
        configureView()
    }

    var detailItem: Categories? {
        didSet {
            // Update the view.
            configureView()
        }
    }

    @objc
    func insertNewObject(_ sender: Any) {
        
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "AddExpenseViewController") else { return }
        
        popVC.modalPresentationStyle = .popover

        let popOverVC = popVC.popoverPresentationController
        popOverVC?.delegate = self
        popOverVC?.sourceView = self.view

        let button = sender as! UIBarButtonItem
        if let originView = (button.value(forKey: "view") as? UIView) {
            let frame = originView.frame  //it's a UIBarButtonItem
            let actualPointOnWindow = originView.convert(originView.frame.origin, to: nil)
            let screenSize = UIScreen.main.bounds.size
            if screenSize.width > screenSize.height {
                popOverVC?.sourceRect = CGRect(x: screenSize.width - 400, y: actualPointOnWindow.y + frame.midY, width: 0, height: 0)
            }
            else
            {
                popOverVC?.sourceRect = CGRect(x: screenSize.width - frame.width, y: actualPointOnWindow.y + frame.midY, width: 0, height: 0)
            }
        }

        popVC.preferredContentSize = CGSize(width: 500, height: 570)
        
        expenseName = ""
        expenseAmount = ""
        expenseNote = ""
        selectedDate = Date()
        isReminder = false
        expenseOccurence = 0
        expenseId = ""
        
        //...
        present(popVC, animated: true)
        

    }
    
    @objc
    func reloadTableData() {
        tableView.reloadData()

    }

    // MARK: - Fetched results controller

    var _fetchedResultsController: NSFetchedResultsController<Expense>? = nil

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
        print("1")
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        print("2")
        switch type {
            case .insert:
                tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            case .delete:
                tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            default:
                return
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        print("3")
        switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                configureCell(tableView.cellForRow(at: indexPath!)! as! ExpenseCell, withEvent: anObject as! Expense)
            case .move:
                configureCell(tableView.cellForRow(at: indexPath!)! as! ExpenseCell, withEvent: anObject as! Expense)
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
            default:
                return
        }


    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        print("4")
        
    }
 

    
}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return _fetchedResultsController?.sections?.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = _fetchedResultsController?.sections![section]
        return sectionInfo!.numberOfObjects //selectedExpenses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = Bundle.main.loadNibNamed("ExpenseCell", owner: self, options: nil)?.first as! ExpenseCell
        
        let event = _fetchedResultsController!.object(at: indexPath)
        configureCell(cell, withEvent: event)
       
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = UIContextualAction(style: .normal, title: "Edit", handler: { [self] (action, view, complete) in
            
            guard let popVC = storyboard?.instantiateViewController(withIdentifier: "AddExpenseViewController") else { return }

            popVC.modalPresentationStyle = .popover

            let popOverVC = popVC.popoverPresentationController
            popOverVC?.delegate = self
            popOverVC?.sourceView = self.view
            
            popOverVC?.sourceRect = CGRect(x: UIScreen.main.bounds.width - 400, y: 50, width: 0, height: 0)

            popVC.preferredContentSize = CGSize(width: 500, height: 570)
            
            let object = _fetchedResultsController!.object(at: indexPath)
            dateFormatter.dateFormat = "YY/MM/dd-HH:MM:SS"
            expenseId = object.genDate?.description ?? dateFormatter.string(from: Date())
            
            expenseName = object.title!.description
            expenseAmount = object.amount!.description
            expenseNote = object.note?.description ?? ""
            selectedDate = dateFormatter.date(from: object.genDate!.description)!
            isReminder = object.reminderFlag
            expenseOccurence = occurenceStrings.index(of: object.occurence!.description) ?? 0
            
            present(popVC, animated: true)
            complete(true)
        })
        edit.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1)
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [self] (action, view, complete) in
            print("delete")
            
            let context = _fetchedResultsController!.managedObjectContext
            context.delete(_fetchedResultsController!.object(at: indexPath))
                
            do {
                try context.save()
            } catch {
                
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
            
            complete(true)
            
        }
        let config = UISwipeActionsConfiguration(actions: [delete, edit])
        config.performsFirstActionWithFullSwipe = true
        
        return config
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80//115
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = _fetchedResultsController!.managedObjectContext
            context.delete(_fetchedResultsController!.object(at: indexPath))
                
            do {
                try context.save()
            } catch {
                
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func configureCell(_ cell: ExpenseCell, withEvent event: Expense) {
        
        cell.containerView.layer.borderWidth = 1.0
        cell.containerView.layer.borderColor = UIColor.lightGray.cgColor
        
        cell.nameLbl.text = event.title!
        
        cell.amountLbl.text = "£ " + (event.amount ?? 0).description
        cell.frequentLbl.text = event.occurence
        cell.descriptionLbl.text = event.note
        cell.reminderLbl.isHidden = !event.reminderFlag
        // calc values.
        budgetForCell = CGFloat(event.amount!)
        cell.progress.animateProgress(duration: 0.5, progressValue: budgetForCell/wholeBudget)
    }
    
}
