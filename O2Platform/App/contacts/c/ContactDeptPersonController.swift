//
//  ContactDeptPersonController.swift
//  O2Platform
//
//  Created by 刘振兴 on 16/7/14.
//  Copyright © 2016年 zoneland. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import AlamofireObjectMapper
import ObjectMapper

import CocoaLumberjack

class ContactDeptPersonController: UITableViewController, UITextViewDelegate {
    
    var superOrgUnit : OrgUnit? {
        didSet {
            subUnitURL = AppDelegate.o2Collect.generateURLWithAppContextKey(ContactContext.contactsContextKeyV2, query: ContactContext.subUnitByNameQuery, parameter: ["##name##":(superOrgUnit?.distinguishedName)! as AnyObject])

            subIdentityURL = AppDelegate.o2Collect.generateURLWithAppContextKey(ContactContext.contactsContextKeyV2, query: ContactContext.subIdentityByNameQuery, parameter: ["##name##":(superOrgUnit?.unique)! as AnyObject])
            if self.headBars.count == 0 {
                self.headBars.append(superOrgUnit!)
            }else{
                var tag = true
                for (index,unit) in self.headBars.enumerated() {
                    if unit.distinguishedName! == self.superOrgUnit!.distinguishedName! {
                        tag = false
                        let n = self.headBars.count - index
                        if n>1 {
                            self.headBars.removeLast(n-1)
                        }
                        break
                    }
                }
                if tag {
                    self.headBars.append(superOrgUnit!)
                }
            }
        }
    
    }
    
    var subUnitURL : String?
    var subIdentityURL : String?
    
    var contacts:[Int:[CellViewModel]] = [0:[],1:[],2:[]]
    
    var headBars:[OrgUnit] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = superOrgUnit?.name
        self.tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(loadMyDeptData(_:)))
        self.tableView.separatorStyle = .none
        loadMyDeptData(nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.contacts.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contacts[section]!.count
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 3
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellName = ""
        if indexPath.section == 0 {
            cellName = "addressBarCell"
        }else if indexPath.section == 1 {
            cellName = "addressUnitCell"
        }else {
            cellName = "addressPersonCell"
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: cellName, for: indexPath) as! ContactItemCell
        let cellMod = self.contacts[indexPath.section]![indexPath.row]
        if !cellMod.openFlag {
            cell.accessoryType = UITableViewCell.AccessoryType.none
        } else {
            cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        }
        
        cell.cellViewModel = cellMod
        if indexPath.section == 0 {
            cell.delegate = self
        }
        return cell
    }
    
    /// Cell 圆角背景计算
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //圆率
        let cornerRadius:CGFloat = 10.0
        //大小
        let bounds:CGRect  = cell.bounds
        //行数
        let numberOfRows = tableView.numberOfRows(inSection: indexPath.section)
        //绘制曲线
        var bezierPath: UIBezierPath? = nil
        if (indexPath.row == 0 && numberOfRows == 1) {
            //一个为一组时,四个角都为圆角
            bezierPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        } else if (indexPath.row == 0) {
            //为组的第一行时,左上、右上角为圆角
            bezierPath = UIBezierPath(roundedRect: bounds, byRoundingCorners:  [.topLeft, .topRight], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        } else if (indexPath.row == numberOfRows - 1) {
            //为组的最后一行,左下、右下角为圆角
            bezierPath = UIBezierPath(roundedRect: bounds, byRoundingCorners:  [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        } else {
            //中间的都为矩形
            bezierPath = UIBezierPath(rect: bounds)
        }
        //cell的背景色透明
        cell.backgroundColor = .clear
        //新建一个图层
        let layer = CAShapeLayer()
        //图层边框路径
        layer.path = bezierPath?.cgPath
        //图层填充色,也就是cell的底色
        layer.fillColor = UIColor.white.cgColor
        //图层边框线条颜色
        /*
         如果self.tableView.style = UITableViewStyleGrouped时,每一组的首尾都会有一根分割线,目前我还没找到去掉每组首尾分割线,保留cell分割线的办法。
         所以这里取巧,用带颜色的图层边框替代分割线。
         这里为了美观,最好设为和tableView的底色一致。
         设为透明,好像不起作用。
         */
        layer.strokeColor = UIColor.white.cgColor
        //将图层添加到cell的图层中,并插到最底层
        cell.layer.insertSublayer(layer, at: 0)
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.tableView.deselectRow(at: indexPath, animated: false)
        
        let viewModel = self.contacts[indexPath.section]![indexPath.row]
        switch viewModel.dataType {
        case .depart(let d):
            if viewModel.openFlag {
                self.superOrgUnit = d as? OrgUnit
                self.reloadView()
            }
        case .identity(let i):
            self.performSegue(withIdentifier: "showIdentityPersonSegueV2", sender: i)
            
        default:
            self.tableView.deselectRow(at: indexPath, animated: false)
            //DDLogDebug(viewModel.name!)
        }
    }
    
    func reloadView() {
        for i in 0..<self.contacts.count {
            self.contacts[i]?.removeAll()
        }
        self.tableView.reloadData()
        self.title = superOrgUnit?.name
        loadMyDeptData(nil)
    }
    
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        if let scheme = URL.scheme {
            switch scheme {
            case "reloadto" :
                let distinguishedName = (URL.description as NSString).substring(from: 9)
                for unit in self.headBars {
                    if distinguishedName == unit.distinguishedName! {
                        self.superOrgUnit = unit
                        self.reloadView()
                        break;
                    }
                }
            default:
                break
            }
        }
        return true
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showIdentityPersonSegueV2" {
            let destVC = segue.destination as! ContactPersonInfoV2ViewController
            destVC.identity = sender as? IdentityV2
        }
    }
    
    
    @objc func loadMyDeptData(_ sender:AnyObject?){
        let urls = [0:"111",1:subUnitURL,2:subIdentityURL]
        self.showLoading()
        var num = 0
        for (tag,url) in urls {
            num += 1
            if tag == 0 {
                self.contacts[tag]?.removeAll()
                if headBars.count > 0 {
                    var barText: [OrgUnit] = []
                    if headBars.count == 1 {
                        barText.append(headBars[0])
                    }else {
                        barText.append(headBars[headBars.count-2])
                        barText.append(headBars[headBars.count-1])
                    }
                    let head = HeadTitle(name: "bar", barText: barText)
                    let vm = CellViewModel(name: "bar",sourceObject: head)
                    self.contacts[tag]?.append(vm)
                }
                continue
            }
            AF.request(url!).responseJSON {
                response in
                self.contacts[tag]?.removeAll()
                switch response.result {
                case .success(let val):
                    let objects = JSON(val)["data"]
                    DDLogDebug(objects.description)
                    self.contacts[tag]?.removeAll()
                    switch tag {
                    case 1:
                        if let units = Mapper<OrgUnit>().mapArray(JSONString:objects.description) {
                            for unit in units{
                                // 权限排除
                                if !OrganizationPermissionManager.shared.isExcludeUnit(unit: unit.distinguishedName ?? "") {
                                    let name = "\(unit.name!)(" + String(unit.subDirectIdentityCount+unit.subDirectUnitCount) + ")"
                                    let vm = CellViewModel(name: name,sourceObject: unit)
                                    self.contacts[tag]?.append(vm)
                                }
                            }
                        }
                    case 2:
                        if let identitys = Mapper<IdentityV2>().mapArray(JSONString:objects.description) {
                            for identity in identitys{
                                // 权限排除
                                if !OrganizationPermissionManager.shared.isExcludePerson(person: identity.distinguishedName ?? "") {
                                    let vm = CellViewModel(name: identity.name,sourceObject: identity)
                                    self.contacts[tag]?.append(vm)
                                }
                            }
                        }
                    default:
                        break
                    }
                case .failure(let err):
                    DDLogError(err.localizedDescription)
                }
                if num == urls.count {
                    DispatchQueue.main.async {
                        self.hideLoading()
                        if self.tableView.mj_header.isRefreshing() {
                            self.tableView.mj_header.endRefreshing()
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }

}


extension ContactDeptPersonController: ContactItemCellBreadcrumbClickDelegate {
    func breadcrumbTap(name: String, distinguished: String) {
        for unit in self.headBars {
            if distinguished == unit.distinguishedName! {
                self.superOrgUnit = unit
                self.reloadView()
                break;
            }
        }
    }
    
    
}
