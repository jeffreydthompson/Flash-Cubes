//
//  FirebaseMainFolderVC.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 6/4/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import UIKit

class FirebaseMainFolderVC: UIViewController {
    
    var mainFolder: DatabaseMainFolder!
    
    var backgroundImgView: UIImageView = {
        var img = UIImage(named: "imgBackgroundNoLogo")
        let imgView = UIImageView(image: img)
        imgView.contentMode = .scaleAspectFill
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.register(DLCTableCell.self, forCellReuseIdentifier: DLCTableCell.reuseIdentifier)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupViews()
    }
    
    func setupViews(){
        view.addAndConstraintToExtents(view: backgroundImgView)
        
        NSLayoutConstraint.activate([
            backgroundImgView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImgView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImgView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImgView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ])
    }
    
}

extension FirebaseMainFolderVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = DLCTableHeader(frame: .zero)
        
        view.titleLabel.text = mainFolder?.name ?? ""
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return DLCTableCell.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let subFolder = mainFolder.subFolders?[indexPath.row] {
            
            let subFolderVC = FirebaseSubFolderVC()
            subFolderVC.subFolder = subFolder
            self.navigationController?.pushViewController(subFolderVC, animated: true)
            
        }
    }
}

extension FirebaseMainFolderVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mainFolder.subFolders?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DLCTableCell.reuseIdentifier, for: indexPath) as! DLCTableCell
        
        if let title = mainFolder.subFolders?[indexPath.row].name {
            cell.titleLabel.text = title
        }
        
        return cell
    }
}
