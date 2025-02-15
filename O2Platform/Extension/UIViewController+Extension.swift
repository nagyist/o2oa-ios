//
//  UIViewController+Extension.swift
//  O2Platform
//
//  Created by 刘振兴 on 2018/4/9.
//  Copyright © 2018年 zoneland. All rights reserved.
//

import UIKit
import Chrysan
import Photos


extension UIViewController {
    // 是否禁用导航栏的左滑手势，默认不禁用
     @objc var isForbidInteractivePopGesture: Bool {
         return false
     }
    
    ///EZSE: Pushes a view controller onto the receiver’s stack and updates the display.
    open func pushVC(_ vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
    
    ///EZSE: Pops the top view controller from the navigation stack and updates the display.
    open func popVC() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    /// EZSE: Added extension for popToRootViewController
    open func popToRootVC() {
        _ = navigationController?.popToRootViewController(animated: true)
    }
    
    ///EZSE: Presents a view controller modally.
    open func presentVC(_ vc: UIViewController) {
        present(vc, animated: true, completion: nil)
    }
    
    ///EZSE: Dismisses the view controller that was presented modally by the view controller.
    open func dismissVC(completion: (() -> Void)? ) {
        dismiss(animated: true, completion: completion)
    }
    
    
    func setNavRightBarItemsTextDefault() {
        if let rightItems = self.navigationItem.rightBarButtonItems {
            for item in rightItems {
                item.setTitleTextAttributes([NSAttributedString.Key.font : UIFont(name: "PingFangTC-Regular", size: 14)!], for: .normal)
            }
        }
    }
    
    func setNavLeftBarItemsTextDefault() {
        if let leftItems = self.navigationItem.leftBarButtonItems {
            for item in leftItems {
                item.setTitleTextAttributes([NSAttributedString.Key.font : UIFont(name: "PingFangTC-Regular", size: 14)!], for: .normal)
            }
        }
    }
    
    func forwardDestVC(_ storyBoardName:String,_ destVCIdentitifer:String?){
        let window = UIApplication.shared.keyWindow
        let storyBoard:UIStoryboard = UIStoryboard.init(name: storyBoardName, bundle: nil)
        var destVC:UIViewController!
        if destVCIdentitifer != nil {
            destVC = storyBoard.instantiateViewController(withIdentifier: destVCIdentitifer!)
        }else{
            destVC = storyBoard.instantiateInitialViewController()
        }
        window?.rootViewController = destVC
        window?.makeKeyAndVisible()
    }
    
    func forwardDestVC(_ targetVC:UIViewController){
        let window = UIApplication.shared.keyWindow
        window?.rootViewController = targetVC
        window?.makeKeyAndVisible()
    }
    
    
    func getDestVC<T>(vcType:T.Type,storyBoardName:String,identitiferController:String?) -> T {
        let storyBoard = UIStoryboard(name: storyBoardName, bundle: nil)
        var destVC:T
        if  let identitifer  = identitiferController {
            destVC = storyBoard.instantiateViewController(withIdentifier: identitifer) as! T
        }else{
            destVC = storyBoard.instantiateInitialViewController() as! T
        }
        return destVC
    }
}

// MARK:- AlertController
extension UIViewController {
    
    
    
    /// 系统弹出框确认
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - message: 提示消息
    ///   - okHandler: 确定行为
    func showDefaultConfirm(title: String, message: String, okHandler: @escaping ((UIAlertAction) -> Void)) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "确定", style: .default, handler: okHandler)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showDefaultConfirm(title: String, message: String, okAction: UIAlertAction, cancelAction: UIAlertAction) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    /// 系统弹出框提示
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - message: 提示消息
    ///   - okHandler: 确定行为
    func showSystemAlert(title: String, message: String, okHandler: @escaping ((UIAlertAction) -> Void)) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "确定", style: .default, handler: okHandler)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showSystemAlertWithButtonName(title: String, message: String, buttonName: String, okHandler: @escaping ((UIAlertAction) -> Void)) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: buttonName, style: .default, handler: okHandler)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    ///
    ///系统弹出窗 可以输入文字
    ///
    func showPromptAlert(title: String, message: String, inputText: String, okHandler: @escaping ((UIAlertAction, String) -> Void))  {
        self.showPromptAlert(title: title, message: message, inputText: inputText, placeholder: "请输入...", okHandler: okHandler)
    }
 
    func showPromptAlert(title: String, message: String, inputText: String, placeholder:String = "请输入...",  okHandler: @escaping ((UIAlertAction, String) -> Void))  {
        let promptController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        promptController.addTextField { (textField) in
            textField.placeholder = placeholder
            textField.text = inputText
        }
        let okAction = UIAlertAction(title: "确定", style: .default) { (ok) in
            let value = promptController.textFields?.first?.text ?? ""
            okHandler(ok, value)
        }
        let cancelAction = UIAlertAction(title:"取消", style: .cancel,  handler: nil)
        promptController.addAction(okAction)
        promptController.addAction(cancelAction)
        self.present(promptController, animated: true, completion: nil)
    }
    
    
    // actionSheet 形式的弹出提示框  可以传入多个Action 已经有取消Action了
    func showSheetAction(title: String?, message: String?, actions: [UIAlertAction]) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        actions.forEach { (action) in
            alertController.addAction(action)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    //actionSheet 传入的actions需要包含取消Action
    func showActionSheetIncludeCancelBtn(title: String?, message: String?, actions: [UIAlertAction]) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        actions.forEach { (action) in
            alertController.addAction(action)
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    //通讯录选择器
    func showContactPicker(modes: [ContactPickerType],
                           callback: @escaping (O2BizContactPickerResult) -> Void,
        topUnitList: [String] = [],
        maxNumber: Int = 0,
        multiple: Bool = true,
        initDeptPickedArray:[String] = [],
        initIdPickedArray:[String] = [],
        initGroupPickedArray:[String] = [],
        initUserPickedArray:[String] = []) {
        if let v = ContactPickerViewController.providePickerVC(
            pickerModes:modes,
            topUnitList: topUnitList,
            unitType: "",
            maxNumber: maxNumber,
            multiple: multiple,
            dutyList: [],
            initDeptPickedArray: initDeptPickedArray,
            initIdPickedArray: initIdPickedArray,
            initGroupPickedArray: initGroupPickedArray,
            initUserPickedArray: initUserPickedArray,
            pickedDelegate: callback
            ) {
            self.navigationController?.pushViewController(v, animated: true)
        }
    }
    
    
}

// MARK:- ProgressHUD
extension UIViewController {
    
    func showMessage(msg: String) {
        DispatchQueue.main.async {
            if self.navigationController != nil {
                self.navigationController?.chrysan.show(.plain, message: msg, hideDelay: 1)
            }else {
                self.chrysan.show(.plain, message: msg, hideDelay: 1)
            }
        }
    }
    
    func showSuccess(title:String) {
        DispatchQueue.main.async {
            if self.navigationController != nil {
                self.navigationController?.chrysan.show(.succeed, message: title, hideDelay: 1)
            }else {
                self.chrysan.show(.succeed, message: title, hideDelay: 1)
            }
        }
    }
    
    func showError(title:String){
        DispatchQueue.main.async {
            if self.navigationController != nil {
                self.navigationController?.chrysan.show(.error, message: title, hideDelay: 1)
            }else {
                self.chrysan.show(.error, message: title, hideDelay: 1)
            }
        }
    }
    
    func showLoading(title:String){
        DispatchQueue.main.async {
            if self.navigationController != nil {
                self.navigationController?.chrysan.show(.running, message: title)
            }else {
                self.chrysan.show(.running, message: title)
            }
        }
    }
    
    func showLoading()  {
        DispatchQueue.main.async {
            if self.navigationController != nil {
                self.navigationController?.chrysan.show()
            }else {
                self.chrysan.show()
            }
        }
    }
    
    func hideLoading() {
        DispatchQueue.main.async {
            if self.navigationController != nil {
                self.navigationController?.chrysan.hide()
            }else {
                self.chrysan.hide()
            }
        }
    }
    
}

// MARK:- 加动画退出app
extension UIViewController {
    func exitAPP() {
        let appDelegate = UIApplication.shared.delegate!
        let window = appDelegate.window!
        UIView.animate(withDuration: 0.4, animations: {
            UIView.animate(withDuration: 0.4) {
                window?.alpha = 0
                let y = window?.bounds.size.height
                let x = (window?.bounds.size.width)! / 2
                window?.frame = CGRect(x: x, y: y!, width: 0, height: 0)
            }
        }) { (completed) in
            exit(0)
        }
    }
}

// MARK: - 业务工具
extension UIViewController {
    
    // 拍照
    func takePhoto(delegate: (UIImagePickerControllerDelegate & UINavigationControllerDelegate)?) {
        var sourceType = UIImagePickerController.SourceType.camera
        if !UIImagePickerController.isSourceTypeAvailable(sourceType) {
            sourceType = .photoLibrary
        }
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.sourceType = sourceType
        picker.delegate = delegate
        self.present(picker, animated:true, completion:nil)//进入照相界面
    }
    
    //照片选择器
    func choosePhotoWithImagePicker(callback: @escaping (String, Data)-> Void) {
        let vc = FileBSImagePickerViewController().bsImagePicker()
        vc.settings.fetch.assets.supportedMediaTypes = [.image]
        presentImagePicker(vc, select: { (asset: PHAsset) -> Void in
            //选中一个
            }, deselect: { (asset: PHAsset) -> Void in
                //取消选中一个
            }, cancel: { (assets: [PHAsset]) -> Void in
                //取消
            }, finish: { (arr) in
            let count = arr.count
            print("选择了照片数量：\(count)")
            if count > 0 {
                //获取照片
                let asset = arr[0]
                switch asset.mediaType {
                case .image:
                    let options = PHImageRequestOptions()
                    options.isSynchronous = true
                    options.deliveryMode = .fastFormat
                    options.resizeMode = .fast // .none
                    var fName = (asset.value(forKey: "filename") as? String) ?? "untitle.png"
                    // 判断是否是heif
                    var isHEIF = false
                    if #available(iOS 9.0, *) {
                        let resList = PHAssetResource.assetResources(for: asset)
                        resList.forEachEnumerated { (idx, res) in
                            let uti = res.uniformTypeIdentifier
                            if uti == "public.heif" || uti == "public.heic" {
                                isHEIF = true
                            }
                        }
                    } else {
                        if let uti = asset.value(forKey: "uniformTypeIdentifier") as? String {
                            if uti == "public.heif" || uti == "public.heic" {
                                isHEIF = true
                            }
                        }
                    }
                    PHImageManager.default().requestImageData(for: asset, options: options) { (imageData, result, imageOrientation, dict) in
                        guard let data = imageData else {
                            return
                        }
                        var newData = data
                        if isHEIF {
                            let image: UIImage = UIImage(data: data)!
                            newData = image.jpegData(compressionQuality: 1.0)!
                            fName += ".jpg"
                        }
                        //处理图片旋转的问题
                        if imageOrientation != UIImage.Orientation.up {
                            let newImage = UIImage(data: data)?.fixOrientation()
                            if newImage != nil {
                                newData = newImage!.pngData()!
                            }
                        }
                        //处理图片旋转的问题
                        if imageOrientation != UIImage.Orientation.up {
                            let newImage = UIImage(data: data)?.fixOrientation()
                            if newImage != nil {
                                newData = newImage!.pngData()!
                            }
                        }
                        callback(fName, newData)
                    }
                     
                    break
                case .video:
                     print("视频文件。还不支持。。。。。")
                    break
                default :
                    print("未知类型的文件。。。。。。")
                    break
                }
            }
            
            
        }, completion: nil)
    }
}


//MARK: - Notification
extension UIViewController {
    
    ///EZSE: Adds an NotificationCenter with name and Selector
    open func addNotificationObserver(_ name: String, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: NSNotification.Name(rawValue: name), object: nil)
    }
    
    ///EZSE: Removes an NSNotificationCenter for name
    open func removeNotificationObserver(_ name: String) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: name), object: nil)
    }
    
    ///EZSE: Removes NotificationCenter'd observer
    open func removeNotificationObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    ///EZSE: Adds a NotificationCenter Observer for keyboardWillShowNotification()
    ///
    /// ⚠️ You also need to implement ```keyboardWillShowNotification(_ notification: Notification)```
    open func addKeyboardWillShowNotification() {
        
        self.addNotificationObserver(UIResponder.keyboardWillShowNotification.rawValue, selector: #selector(UIViewController.keyboardWillShowNotification(_:)))
    }
    
    ///EZSE:  Adds a NotificationCenter Observer for keyboardDidShowNotification()
    ///
    /// ⚠️ You also need to implement ```keyboardDidShowNotification(_ notification: Notification)```
    public func addKeyboardDidShowNotification() {
        self.addNotificationObserver(UIResponder.keyboardDidShowNotification.rawValue, selector: #selector(UIViewController.keyboardDidShowNotification(_:)))
    }
    
    ///EZSE:  Adds a NotificationCenter Observer for keyboardWillHideNotification()
    ///
    /// ⚠️ You also need to implement ```keyboardWillHideNotification(_ notification: Notification)```
    open func addKeyboardWillHideNotification() {
        self.addNotificationObserver(UIResponder.keyboardWillHideNotification.rawValue, selector: #selector(UIViewController.keyboardWillHideNotification(_:)))
    }
    
    ///EZSE:  Adds a NotificationCenter Observer for keyboardDidHideNotification()
    ///
    /// ⚠️ You also need to implement ```keyboardDidHideNotification(_ notification: Notification)```
    open func addKeyboardDidHideNotification() {
        self.addNotificationObserver(UIResponder.keyboardDidHideNotification.rawValue, selector: #selector(UIViewController.keyboardDidHideNotification(_:)))
    }
    
    ///EZSE: Removes keyboardWillShowNotification()'s NotificationCenter Observer
    open func removeKeyboardWillShowNotification() {
        self.removeNotificationObserver(UIResponder.keyboardWillShowNotification.rawValue)
    }
    
    ///EZSE: Removes keyboardDidShowNotification()'s NotificationCenter Observer
    open func removeKeyboardDidShowNotification() {
        self.removeNotificationObserver(UIResponder.keyboardDidShowNotification.rawValue)
    }
    
    ///EZSE: Removes keyboardWillHideNotification()'s NotificationCenter Observer
    open func removeKeyboardWillHideNotification() {
        self.removeNotificationObserver(UIResponder.keyboardWillHideNotification.rawValue)
    }
    
    ///EZSE: Removes keyboardDidHideNotification()'s NotificationCenter Observer
    open func removeKeyboardDidHideNotification() {
        self.removeNotificationObserver(UIResponder.keyboardDidHideNotification.rawValue)
    }
    
    @objc open func keyboardDidShowNotification(_ notification: Notification) {
        if let nInfo = (notification as NSNotification).userInfo, let value = nInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            
            let frame = value.cgRectValue
            keyboardDidShowWithFrame(frame)
        }
    }
    
    @objc open func keyboardWillShowNotification(_ notification: Notification) {
        if let nInfo = (notification as NSNotification).userInfo, let value = nInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            
            let frame = value.cgRectValue
            keyboardWillShowWithFrame(frame)
        }
    }
    
    @objc open func keyboardWillHideNotification(_ notification: Notification) {
        if let nInfo = (notification as NSNotification).userInfo, let value = nInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            
            let frame = value.cgRectValue
            keyboardWillHideWithFrame(frame)
        }
    }
    
    @objc open func keyboardDidHideNotification(_ notification: Notification) {
        if let nInfo = (notification as NSNotification).userInfo, let value = nInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            
            let frame = value.cgRectValue
            keyboardDidHideWithFrame(frame)
        }
    }
    
    @objc open func keyboardWillShowWithFrame(_ frame: CGRect) {
        
    }
    
    @objc open func keyboardDidShowWithFrame(_ frame: CGRect) {
        
    }
    
    @objc open func keyboardWillHideWithFrame(_ frame: CGRect) {
        
    }
    
    @objc open func keyboardDidHideWithFrame(_ frame: CGRect) {
        
    }
    //EZSE: Makes the UIViewController register tap events and hides keyboard when clicked somewhere in the ViewController.
    open func hideKeyboardWhenTappedAround(cancelTouches: Bool = false) {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = cancelTouches
        view.addGestureRecognizer(tap)
    }


    //EZSE: Dismisses keyboard
    @objc open func dismissKeyboard() {
        view.endEditing(true)
    }
    
    ///跳转到应用设置页面
    ///
    /// - Parameter alertMessage: 确认提示消息，如果是nil就直接跳转
    func gotoApplicationSettings(alertMessage:String? = nil) {
        if alertMessage != nil {
            showDefaultConfirm(title: "提示", message: alertMessage!, okHandler: { (okAction) in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
            })
        }else {
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }
    }
}
