//
//  TestRecordsTblVC.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 5/1/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import UIKit

class TestRecordsTblVC: UITableViewController {
    
    var cube: FlashCube!
    var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        return df
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return cube.reviewRecordDatabase?.database.keys.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if let keys = cube.reviewRecordDatabase?.database.keys.sorted(by: {$0.fromPrompt < $1.fromPrompt}) {
            let key = keys[section]
            return cube.reviewRecordDatabase?.database[key]?.count ?? 0
        }

        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

//        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
//        // Configure the cell...
//
//        if let keys = cube.reviewRecordDatabase?.database.keys.sorted(by: {$0.fromPrompt < $1.fromPrompt}) {
//            let key = keys[indexPath.section]
//
//            if let record = cube.reviewRecordDatabase?.database[key]?[indexPath.row] {
//
//                if let date = record.date {cell.textLabel?.text = dateFormatter.string(from: date)}
//
//                if let proficiency = record.proficiency {
//                    cell.detailTextLabel?.text = "\(proficiency)"
//                }
//
//            }
//        }
//
//        if let record = cube.recordHistory?[indexPath.row] {
//
//            if let valid = record.validReviewTime {
//                if valid {
//                    cell.detailTextLabel?.textColor = .blue
//                } else {
//                    cell.detailTextLabel?.textColor = .red
//                }
//            }
//        }
        
        return UITableViewCell()
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
