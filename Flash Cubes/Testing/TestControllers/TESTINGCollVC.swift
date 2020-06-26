//
//  TESTINGCollVC.swift
//  Flash Cubes
//
//  Created by Jeffrey Thompson on 6/1/19.
//  Copyright © 2019 Jeffrey Thompson. All rights reserved.
//

import UIKit

class TESTINGCollVC: UIViewController {
    
    var data = "😀🥶💀👀🧶☘️🌎❄️🍉🥝🥨🍺"
    
    struct TableData {
        
        var cellData: [CellData]
        
        var cells: [String] {
            get {
                var names = cellData.map({ $0.folder })
                names.removeDuplicates()
                return names
            }
        }
    }
    
    struct CellData {
        var text: String
        var inFolder: String?
        var fileName: String
        var folder: String {
            get {
                return inFolder ?? fileName
            }
        }
    }

    var tableData: TableData!
    var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initTableData()
        initCollectionView()
        setupViews()
    }
    
    func initTableData(){
        
        let texts = Array(data)
        var cellData = [CellData]()
        texts.forEach({
            let cell = CellData(text: "\($0)", inFolder: nil, fileName: UniqueString.timeStamp.generate)
            cellData.append(cell)
        })
        
        cellData[3].inFolder = "test"
        cellData[6].inFolder = "test"
        
        tableData = TableData(cellData: cellData)
    }
    
    func initCollectionView(){
        
        
        let flowLayout = UICollectionViewFlowLayout()
        //flowLayout.minimumLineSpacing = 20
        //flowLayout.minimumInteritemSpacing = 20
        flowLayout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        let itemSize: CGFloat = (view.safeAreaLayoutGuide.layoutFrame.width-16) * 0.485
        // multiplier for iPhone 2 column: 0.485
        // multiplier for iPad 3 column: 0.31
        
        
        flowLayout.estimatedItemSize = CGSize(width: itemSize, height: itemSize)
        flowLayout.scrollDirection = .vertical
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        //collectionView = UICollectionView(frame: .zero)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .darkGray
        
        collectionView.register(TestCollCell.self, forCellWithReuseIdentifier: TestCollCell.reuseIdentifier)
        collectionView.register(TestCollTitleCell.self, forCellWithReuseIdentifier: TestCollTitleCell.reuseIdentifier)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressHandler(gesture:)))
        collectionView.addGestureRecognizer(longPressGesture)
    }
    
    func setupViews(){
        view.addSubview(collectionView)
        view.constrainToExtents(view: collectionView)
    }

    @objc func longPressHandler(gesture: UILongPressGestureRecognizer) {
        
        switch gesture.state {
        case .possible:
            break
        case .began:
            print("\(#function) began")
            
            guard let indexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else {
                break
            }
            
            print("\(#function) indexPath: section \(indexPath.section), row \(indexPath.row)")
            
            collectionView.beginInteractiveMovementForItem(at: indexPath)
            
            break
        case .changed:
            //print("\(#function) changed")
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
            break
        case .cancelled:
            print("\(#function) cancelled")
            
            collectionView.cancelInteractiveMovement()
            break
        case .ended:
            collectionView.endInteractiveMovement()
            print("\(#function) ended")
            break
        case .failed:
            print("\(#function) failed")
            break
        @unknown default:
            break
        }
    }
}

extension TESTINGCollVC: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return 1
        default:
            return tableData.cells.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TestCollTitleCell.reuseIdentifier, for: indexPath) as! TestCollTitleCell
            
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TestCollCell.reuseIdentifier, for: indexPath) as! TestCollCell
            
            cell.label.text = tableData.cells[indexPath.row]
            
            return cell
        }
    }
}

extension TESTINGCollVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        if indexPath.section != 0 {
            return true
        }
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        print("Starting Index: \(sourceIndexPath.item)")
        print("Ending Index: \(destinationIndexPath.item)")
        
        var editableData = Array(data)
        let swapFrom = editableData[sourceIndexPath.item]
        let swapTo = editableData[destinationIndexPath.item]
        editableData[sourceIndexPath.item] = swapTo
        editableData[destinationIndexPath.item] = swapFrom
        
        data = String(editableData)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            self.navigationItem.title = "TITLE VIEW"
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            self.navigationItem.title = ""
        }
    }
}

extension TESTINGCollVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        print("\(#function)")
        
        switch indexPath.section {
        case 0:
            let height = view.safeAreaLayoutGuide.layoutFrame.height * 0.2
            let width = view.safeAreaLayoutGuide.layoutFrame.width * 0.95
            return CGSize(width: width, height: height)
        default:
            var itemSize: CGFloat = 0
//            if Bool.random() {
//                itemSize = (view.safeAreaLayoutGuide.layoutFrame.width-16) * 0.485
//            } else {
//                itemSize = (view.safeAreaLayoutGuide.layoutFrame.width-16) * 0.235
//            }
            // multiplier for iPhone 2 column: 0.485
            // multiplier for iPad 3 column: 0.31
            if UIDevice.current.model == "iPad" {
                itemSize = (view.safeAreaLayoutGuide.layoutFrame.width-16) * 0.31
            } else {
                itemSize = (view.safeAreaLayoutGuide.layoutFrame.width-16) * 0.485
            }
            return CGSize(width: itemSize, height: itemSize)
        }
    }
}


class TestCollCell: UICollectionViewCell {
    
    static let reuseIdentifier = "testCollCell"
    
    var label: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    var container: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //translatesAutoresizingMaskIntoConstraints = false
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupViews(){
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(container)
        contentView.constrain(withConstant: 8, view: container)
        
        container.backgroundColor = .underlay
        
        container.addSubview(label)
        //container.constrain(withConstant: 8, view: label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor)
            ])
    }
}

class TestCollTitleCell: UICollectionViewCell {
    
    static let reuseIdentifier = "testCollTitleCell"
    
    var container: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //translatesAutoresizingMaskIntoConstraints = false
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(){
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(container)
        contentView.constrain(withConstant: 8, view: container)
        
        container.backgroundColor = .red
    }
}
