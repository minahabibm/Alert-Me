//
//  zipCodesSettings.swift
//  Alert Me
//
//  Created by Mina Habib on 6/24/19.
//  Copyright © 2019 Mina Habib. All rights reserved.
//

import UIKit

class zipCodesSettings: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var zipCodesTable: UITableView!
    @IBAction func addZipCode(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Add Zip Code", message: "You can add Zip codes to mute notifications from, example, home, work, gym....etc", preferredStyle: .alert)
        
        let addingItem = UIAlertAction(title: "Add", style: .default, handler: { (action) -> Void in
            // Get TextFields text
            let ZipCodeName = alert.textFields![0]
            let ZipCode = alert.textFields![1]
            
            //print("USERNAME: \(ZipCodeName.text!)\nPASSWORD: \(ZipCode.text!)")
            self.ZipCodesToIgnore.append(ZipCodeName.text!)
            self.zipCodesTable.reloadData()
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel , handler: { (action) -> Void in })
        
        alert.addTextField { (textField: UITextField) in
            textField.keyboardType = .default
            textField.autocorrectionType = .default
            textField.placeholder = "Type ZipCode title"
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
    
    var ZipCodesToIgnore = ["10031", "10301"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        zipCodesTable.delegate = self
        zipCodesTable.dataSource = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ZipCodesToIgnore.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addedCells")!
        let text = "hello"
        cell.textLabel!.text = text
        cell.detailTextLabel!.text = text
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            ZipCodesToIgnore.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }/* else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }*/
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
