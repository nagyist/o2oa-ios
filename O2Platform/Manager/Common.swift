//
//  Common.swift
//  o2app
//
//  Created by 刘振兴 on 2017/8/18.
//  Copyright © 2017年 zone. All rights reserved.
//

import UIKit
import SwiftValidator
import SwiftyUserDefaults
import ObjectMapper
import CocoaLumberjack
import Alamofire
import AlamofireImage
import AlamofireObjectMapper

import CoreTelephony



// 屏幕宽度
let kScreenH = UIScreen.main.bounds.height
// 屏幕高度
let kScreenW = UIScreen.main.bounds.width



public class DeviceUtil {
    static let shared: DeviceUtil = {
        return DeviceUtil()
    }()
    private init() {}
    
    
    
    //当前设备名称
    func getDeviceName() -> String {
        return UIDevice.current.name
    }
    //设备uuid
    func getDeviceUUId() -> String {
        return UIDevice.current.identifierForVendor?.uuidString ?? ""
    }
    //设备Model
    func getDeviceModel() -> String {
        return UIDevice.current.model
    }
    // 当前系统版本
    func getSystemVersion() -> String {
        return  UIDevice.current.systemVersion
    }
    //运营商信息
    func getCarrier() -> String {
        let net = CTTelephonyNetworkInfo()
        return net.subscriberCellularProvider?.carrierName ?? ""
    }
    //获取当前网络情况
//    func getNetInfo(callback: @escaping (String)->Void ) {
//        let reachability = Reachability.init(hostName: "www.o2oa.net")
//        let status = reachability?.currentReachabilityStatus()
//        if status != nil {
//            switch status! {
//            case ReachableViaWiFi:
//                callback("wifi")
//            case ReachableViaWWAN:
//                callback(self.getNetType())
//            default:
//                callback("none")
//            }
//        }else {
//            callback("none")
//        }
//    }
    
    func getDeviceInfoForJsApi(callback: @escaping (O2UtilPhoneInfo)->Void ) {
        var info = O2UtilPhoneInfo()
        info.screenWidth = "\(kScreenW)"
        info.screenHeight = "\(kScreenH)"
        info.brand = self.getDeviceName()
        info.model = self.getDeviceModel()
        info.version = self.getSystemVersion()
        info.operatorType = self.getCarrier()
//        getNetInfo { (type) in
//            info.netInfo = type
//            callback(info)
//        }
        //TODO 网络情况
        callback(info)
    }
    
    
   private func getNetType() -> String {
        var netconnType = ""
        let info = CTTelephonyNetworkInfo()
        let status = info.currentRadioAccessTechnology
        if (status == "CTRadioAccessTechnologyGPRS") {
            netconnType = "GPRS"
        }else if (status == "CTRadioAccessTechnologyEdge" ) {
            netconnType = "2.75G EDGE";
        }else if (status == "CTRadioAccessTechnologyWCDMA"){
            netconnType = "3G"
        }else if (status == "CTRadioAccessTechnologyHSDPA"){
            netconnType = "3.5G HSDPA"
        }else if (status == "CTRadioAccessTechnologyHSUPA"){
            netconnType = "3.5G HSUPA"
        }else if (status == "CTRadioAccessTechnologyCDMA1x"){
            netconnType = "2G"
        }else if (status == "CTRadioAccessTechnologyCDMAEVDORev0"){
            netconnType = "3G"
        }else if (status == "CTRadioAccessTechnologyCDMAEVDORevA"){
            netconnType = "3G"
        }else if (status == "CTRadioAccessTechnologyCDMAEVDORevB"){
            netconnType = "3G"
        }else if (status == "CTRadioAccessTechnologyeHRPD"){
            netconnType = "HRPD"
        }else if (status == "CTRadioAccessTechnologyLTE"){
            netconnType = "4G"
        }
        return netconnType
    }
    
    

}


// MARK:- 自定义手机号码检校规则
public class MobileNumberRule: RegexRule {
    
    static let regex = "^\\d{11}$"
    
    convenience init(message : String = "Not a valid Mobile Number"){
        self.init(regex: MobileNumberRule.regex, message : message)
    }
}



// MARK:- 所有配置定义，使用SwiftyUserDefaults实现存储
protocol AppConfigEnable {
    
    //是否第一次使用应用，显示引导页使用
    var isFirstTime:Bool? { get set }
    // IM是否已经登录
    var openIMLoginStatus:Bool? { get set }
    // 跳转用的 从那个页面过来的
    var taskIndex: Int {get set}
    var appBackType: Int {get set}
    var notificationGranted: Bool {get set}
    var firstGranted: Bool {get set}
    // 生物识别登录用户
    var bioAuthUser: String {get set}
    var firstLoad: Bool {get set}
    //服务器 移动端配置hash值 判断是否更新了
    var customStyleHashLocal: String {get set}
    // 主题名称
    var themeName: String {get set}
    //demo服务器提示公告
    var demoAlertTag: Bool {get set}
}


// MARK:- 扩展定义的键
extension DefaultsKeys {
    static let isFirstTime = DefaultsKey<Bool?>("isFirstTime")
    static let openIMLoginStatus = DefaultsKey<Bool?>("openIMLoginStatus")
    static let taskIndex = DefaultsKey<Int>("taskIndex")
    static let appBackType = DefaultsKey<Int>("appBackType")
    static let notificationGranted = DefaultsKey<Bool>("notificationGranted")
    static let firstGranted = DefaultsKey<Bool>("fristGranted")
    
    static let bioAuthUser = DefaultsKey<String>("bioAuthUser")
    static let firstLoad = DefaultsKey<Bool>("firstLoad")
    static let customStyleHashLocal = DefaultsKey<String>("customStyleHashLocal")
    static let themeName = DefaultsKey<String>("themeName")
    static let demoAlertTag = DefaultsKey<Bool>("demoAlertTag")
}

// MARK:- Default App Config
public class AppConfigSettings: AppConfigEnable {
    
    var customStyleHashLocal: String {
        get {
            return Defaults[.customStyleHashLocal]
        }
        set {
            Defaults[.customStyleHashLocal] = newValue
        }
    }
    
    var themeName: String {
        get {
            return Defaults[.themeName]
        }
        set {
            Defaults[.themeName] = newValue
        }
    }
  
    var openIMLoginStatus: Bool?{
        get  {
            guard let openIMLoginStatus = Defaults[.openIMLoginStatus] else {
                return false
            }
            return openIMLoginStatus
        }
        set {
            Defaults[.openIMLoginStatus] = newValue
        }
    }
    
    var isFirstTime: Bool? {
        get {
            guard let firstTime = Defaults[.isFirstTime] else {
                return true
            }
            return firstTime
        }
        
        set {
            Defaults[.isFirstTime] = newValue
        }
    }
    
    var notificationGranted: Bool {
        get {
            return Defaults[.notificationGranted]
        }
        
        set {
            Defaults[.notificationGranted] = newValue
        }
    }
    var firstGranted: Bool {
        get {
            
            return Defaults[.firstGranted]
        }
        
        set {
            Defaults[.firstGranted] = newValue
        }
    }
    
    var bioAuthUser: String {
        get {
            return Defaults[.bioAuthUser]
        }
        set {
            Defaults[.bioAuthUser] = newValue
        }
    }
    
    var firstLoad: Bool {
        get {
            return Defaults[.firstLoad]
        }
        
        set {
            Defaults[.firstLoad] = newValue
        }
    }
    
    var taskIndex: Int {
        get {
            return Defaults[.taskIndex]
        }
        
        set {
            Defaults[.taskIndex] = newValue
        }
    }
    
    var appBackType: Int {
        get {
            return Defaults[.appBackType]
        }
        
        set {
            Defaults[.appBackType] = newValue
        }
    }
    
    var demoAlertTag: Bool {
        get {
            return Defaults[.demoAlertTag]
        }
        set {
            Defaults[.demoAlertTag] = newValue
        }
    }
    
    
    
    public func removeAllConfig() {
        Defaults.removeAll()
    }
    
    static let shared:AppConfigSettings = {
        return AppConfigSettings()
    }()
}

// MARK:- OOCustomImageManager

enum OOCustomImageKey:NSString {
    case launch_logo = "launch_logo"
    case login_avatar = "login_avatar"
    case index_bottom_menu_logo_blur = "index_bottom_menu_logo_blur"
    case index_bottom_menu_logo_focus = "index_bottom_menu_logo_focus"
    case people_avatar_default = "people_avatar_default"
    case process_default = "process_default"
    case setup_about_logo = "setup_about_logo"
    case application_top = "application_top"
}

class OOCustomImageManager {
    
    static let `default`:OOCustomImageManager = {
        return OOCustomImageManager()
    }()
    
    private var imageCache = NSCache<NSString,UIImage>()
    
    private init() {
        self.loadCache()
    }
    
    func loadCache(_ block:  (()->Void)? = nil) {
        if let configInfo = O2AuthSDK.shared.customStyle() {
            let group = DispatchGroup()
            configInfo.images?.forEach({ (ooImage) in
                if let path = ooImage.path { // url
                    group.enter()
                    self.loadImageFromUrl(path: path, name: ooImage.name!, group: group)
                } else if let value = ooImage.value { // base64
                    let data = Data(base64Encoded: value)
                    let image = UIImage(data: data!)
                    let scaleImage = image?.scaledImageFrom3x()
                    imageCache.setObject(scaleImage!, forKey: ooImage.name! as NSString)
                }
            })
            group.notify(queue: DispatchQueue.main) {
                block?()
            }
        }
        
    }
    
    func loadImage(_ key:OOCustomImageKey) -> UIImage? {
        if let image = imageCache.object(forKey: key.rawValue) {
            return image
        }
        return nil
    }
    
   
    
    // 下图片 缓存
    private func loadImageFromUrl(path: String, name:String, group: DispatchGroup) {
        // 图片地址
        if let url = AppDelegate.o2Collect.genrateURLWithWebContextKey2( path,  parameter: nil, covertd:false) {
            DDLogDebug("图片地址：\(url)")
            AF.download(url).responseData { resData in
                if let data = resData.value, let image = UIImage(data: data) {
                    let scaleImage = image.scaledImageFrom3x()
                    self.imageCache.setObject(scaleImage, forKey: name as NSString)
                    DDLogInfo("图片缓存成功 \(name)")
                }
                group.leave()
            }
        } else {
            group.leave()
        }
        
    }
    
   
    
    
    
}

