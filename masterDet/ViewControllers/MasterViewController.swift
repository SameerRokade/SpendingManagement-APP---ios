

import UIKit
import CoreData
import UIColor_Hex_Swift


var addedDate: String = ""//NSDate!

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate, UIPopoverPresentationControllerDelegate {

    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationBarStyler()
        let sortButton =  UIBarButtonItem(image: #imageLiteral(resourceName: "sorting"),  style: .plain, target: self, action: #selector(sortBtnPressed(_:)))
        navigationItem.leftBarButtonItem = sortButton

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableData(_:)), name: .SAVEDATA, object: nil)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        getData(sort: isSorting)
        super.viewWillAppear(animated)
    }

    @objc
    func insertNewObject(_ sender: Any) {
        
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "AddCategoryViewController") else { return }

        popVC.modalPresentationStyle = .popover

        let popOverVC = popVC.popoverPresentationController
        popOverVC?.delegate = self
        popOverVC?.sourceView = self.view

        let button = sender as! UIBarButtonItem
        if let originView = (button.value(forKey: "view") as? UIView) {
            let frame = originView.frame  //it's a UIBarButtonItem
            let actualPointOnWindow = originView.convert(originView.frame.origin, to: nil)
            popOverVC?.sourceRect = CGRect(x: actualPointOnWindow.x + frame.midX, y: -frame.midY, width: 0, height: 0)
        }

        popVC.preferredContentSize = CGSize(width: 500, height: 500)
        
        categoryName = ""
        categoryAmount = ""
        colorIdx = 0
        categoryNote = ""
        selectedId = ""
        
        present(popVC, animated: true)
        
    }
    
    var isSorting: Bool = true
    
    @objc
    func sortBtnPressed(_ sender: Any) {
        isSorting = !isSorting
        getData(sort: isSorting)
    }
    
    func getData(sort: Bool = false) {

        let fetchRequest: NSFetchRequest<Categories> = Categories.fetchRequest()
        
        // Set the batch size.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key.
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: sort)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
            NotificationCenter.default.post(name: .SAVEDATA, object: nil)
        } catch {
             
             let nserror = error as NSError
             fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }

    @objc
    func reloadTableData(_ sender: Any) {
        tableView.reloadData()
        print("reloadtable data")
        
        
    }
    
    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail2" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = _fetchedResultsController!.object(at: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                detailViewController = controller
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return _fetchedResultsController?.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = _fetchedResultsController?.sections![section]
        return sectionInfo!.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let event = _fetchedResultsController!.object(at: indexPath)
        configureCell(cell, withEvent: event)
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    let colorArray: [String] = ["#FF0000", "#00FF00", "#800080", "#FFFF00", "#0000FF", "#FFC0CB"]
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = UIContextualAction(style: .normal, title: "Edit", handler: { [self] (action, view, complete) in
            
            guard let popVC = storyboard?.instantiateViewController(withIdentifier: "AddCategoryViewController") else { return }

            popVC.modalPresentationStyle = .popover

            let popOverVC = popVC.popoverPresentationController
            popOverVC?.delegate = self
            popOverVC?.sourceView = self.view
            popOverVC?.sourceRect = CGRect(x: 350, y: -20, width: 0, height: 0)

            popVC.preferredContentSize = CGSize(width: 500, height: 500)
            
            let object = _fetchedResultsController!.object(at: indexPath)
            dateFormatter.dateFormat = "YY/MM/dd-HH:MM:SS"

            selectedId = object.timestamp?.description ?? dateFormatter.string(from: Date())
            
            categoryName = object.name!.description
            categoryAmount = object.budget!.description
            colorIdx = colorArray.index(of: object.color!.description) ?? 0
            categoryNote = object.note?.description ?? ""
            
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

    func configureCell(_ cell: UITableViewCell, withEvent event: Categories) {
//        cell.textLabel!.text = event.timestamp!.description
        cell.removeFromSuperview()
        let containerView = UIView()
        cell.addSubview(containerView)
        containerView.frame = cell.contentView.frame
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.leftAnchor.constraint(equalTo: cell.leftAnchor, constant: 5).isActive = true
        containerView.rightAnchor.constraint(equalTo: cell.rightAnchor, constant: -5).isActive = true
        containerView.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -5).isActive = true
        containerView.topAnchor.constraint(equalTo: cell.topAnchor, constant: 5).isActive = true
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.lightGray.cgColor
        containerView.backgroundColor = UIColor(event.color?.description ?? "#00FF00")
        let nameLbl = UILabel()
        let amountLbl = UILabel()
        containerView.addSubview(nameLbl)
        containerView.addSubview(amountLbl)
        
        nameLbl.translatesAutoresizingMaskIntoConstraints = false
        nameLbl.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10).isActive = true
        nameLbl.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 15).isActive = true
        nameLbl.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -15).isActive = true
        nameLbl.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        amountLbl.translatesAutoresizingMaskIntoConstraints = false
        amountLbl.topAnchor.constraint(equalTo: nameLbl.bottomAnchor, constant: 5).isActive = true
        amountLbl.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 15).isActive = true
        amountLbl.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -15).isActive = true
        amountLbl.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        nameLbl.text = event.name?.description ?? ""
        amountLbl.text = "Budget: £ " + (event.budget ?? 0).description
        
        if event.note?.description != nil {
            let noteLbl = UILabel()
            containerView.addSubview(noteLbl)
            noteLbl.translatesAutoresizingMaskIntoConstraints = false
            noteLbl.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 15).isActive = true
            noteLbl.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -15).isActive = true
            noteLbl.topAnchor.constraint(equalTo: amountLbl.bottomAnchor, constant: 5).isActive = true
            noteLbl.heightAnchor.constraint(equalToConstant: 20).isActive = true
            noteLbl.text = event.note?.description
        }
            
        containerView.backgroundColor = UIColor(event.color?.description ?? "#00ff00")

    }

    // MARK: - Fetched results controller
    
    var _fetchedResultsController: NSFetchedResultsController<Categories>? = nil

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
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
        switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                configureCell(tableView.cellForRow(at: indexPath!)!, withEvent: anObject as! Categories)
            case .move:
                configureCell(tableView.cellForRow(at: indexPath!)!, withEvent: anObject as! Categories)
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
            default:
                return
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

    
     
    func controllerDidChangeContent(controller: NSFetchedResultsController<NSFetchRequestResult>) {
         // reload the table view.
         tableView.reloadData()
    }
//

}

