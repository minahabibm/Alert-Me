//
//  zipCodesSettings.swift
//  Alert Me
//
//  Created by Mina Habib on 6/24/19.
//  Copyright © 2019 Mina Habib. All rights reserved.
//

import UIKit
import CoreData

class zipCodesSettings: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var zipCodesSettingsCode: UINavigationItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var zipCodesTable: UITableView!
    @IBAction func addZipCode(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Add Zip Code", message: "You can add Zip codes to mute notifications from, example, home, work, gym....etc", preferredStyle: .alert)
        
        let addingItem = UIAlertAction(title: "Add", style: .default, handler: { (action) -> Void in
            // Get TextFields text
            let zipCodeNameAdd = alert.textFields![0]
            let zipCodeAdd = alert.textFields![1]
            
            self.save(zipName: zipCodeNameAdd.text!, zipNumber: zipCodeAdd.text!)
            self.zipCodesTable.reloadData()
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel , handler: { (action) -> Void in })
        
        alert.addTextField { (textField: UITextField) in
            textField.keyboardType = .default
            textField.autocorrectionType = .default
            textField.placeholder = "Type ZipCode Identifier"
        }
        alert.addTextField { (textField: UITextField) in
            textField.keyboardType = .default
            textField.autocorrectionType = .default
            textField.placeholder = "Type ZipCode"
        }
        
        alert.addAction(addingItem)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
        
    }
    
    var zipCodesToIgnore: [NSManagedObject] = []
    var completionHandler:((Array<Any>) -> Array<Any>)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        zipCodesTable.delegate = self
        zipCodesTable.dataSource = self
        fetchZipCodes()
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return zipCodesToIgnore.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addedCells")!
        let values = zipCodesToIgnore[indexPath.row]
        cell.textLabel!.text = values.value(forKeyPath: "zipCodeName") as? String
        cell.detailTextLabel!.text = values.value(forKeyPath: "zipCode") as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                    return
            }
            let managedContext = appDelegate.persistentContainer.viewContext
            let deleteItems = zipCodesToIgnore[indexPath.row]
            managedContext.delete(deleteItems)
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            zipCodesToIgnore.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        }/* else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }*/
    }
    
    func save(zipName: String, zipNumber: String) {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "ZipCodesToIgnore", in: managedContext)!
        
        let ZipCodeToIgnore = NSManagedObject(entity: entity, insertInto: managedContext)
        
        ZipCodeToIgnore.setValue(zipName, forKeyPath: "zipCodeName")
        ZipCodeToIgnore.setValue(zipNumber, forKeyPath: "zipCode")
        
        do {
            try managedContext.save()
            zipCodesToIgnore.append(ZipCodeToIgnore)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func fetchZipCodes(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ZipCodesToIgnore")
        
        do {
            zipCodesToIgnore = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
}
