//
//  OOCalendarEventViewController.swift
//  O2Platform
//
//  Created by FancyLou on 2018/7/30.
//  Copyright © 2018 zoneland. All rights reserved.
//

import UIKit
import CocoaLumberjack

import WebKit


struct Options {
    var key: String
    var value: String
    init(_ key: String, _ value: String) {
        self.key = key
        self.value = value
    }
}
class OOCalendarEventViewController: UITableViewController {
    

    //MARK: - arguments
    private let weekOptions = ["MO","TU" ,"WE","TH", "FR" ,"SA","SU"]
    private let colorOptions = ["#428ffc", "#5bcc61",  "#f9bf24",  "#f75f59", "#f180f7", "#9072f1", "#909090", "#1462be"]
    private let remindOptions = [Options("NONE", "不提醒"),
                                 Options("0,0,0,5", "开始时"),
                                 Options("0,0,5,0", "提前5分钟"),
                                 Options("0,0,10,0", "提前10分钟"),
                                 Options("0,0,15,0", "提前15分钟"),
                                 Options("0,0,30,0", "提前30分钟"),
                                 Options("0,1,0,0", "提前1小时"),
                                 Options("0,2,0,0", "提前2小时")]
    private let repeatOptions = [Options("NONE", "不重复"),
                                Options("DAILY", "每天"),
                                Options("WEEKLY", "每周"),
                                Options("MONTHLY", "每月（当日）"),
                                Options("YEARLY", "每年（当日）")]
    
    private var calendarList: [OOCalendarInfo] = []
    private lazy var viewModel: OOCalendarViewModel = {
        return OOCalendarViewModel()
    }()
    
    //event 变量
    var canUpdate = false
    var eventInfo: OOCalendarEventInfo?
    
    
    
    private var calendarId = ""
    private var colorValue = "#428ffc"
    private var weekDayList: [String] = []
    private var remindValue = ""
    private var repeatValue = ""
    
    
    
    //MARK: - IB
    
    @IBAction func tapDeleteBtn(_ sender: UIButton) {
        showDefaultConfirm(title: "删除日程", message: "确定要删除当前日程吗？") { (action) in
            self.startDelete()
        }
    }
    
    @IBAction func tapAllDaySwitch(_ sender: UISwitch) {
        if eventAllDaySwitch.isOn {
            eventStartTime.text = Date().toString("yyyy-MM-dd")
            eventEndTime.text = Date().toString("yyyy-MM-dd")
        }else {
            eventStartTime.text = Date().toString("yyyy-MM-dd HH:mm")
            eventEndTime.text = Date().add(component: .hour, value: 1).toString("yyyy-MM-dd HH:mm")
        }
    }
 
    
    
    @IBOutlet weak var calendarLabelView: UILabel!
    @IBOutlet weak var calendarStackView: UIStackView!
    @IBOutlet weak var remindLabelView: UILabel!
    @IBOutlet weak var remindStackView: UIStackView!
    @IBOutlet weak var repeatLabelView: UILabel!
    @IBOutlet weak var repeatStackView: UIStackView!
    
    
    @IBOutlet weak var repeatTableViewCell: UITableViewCell!
    @IBOutlet weak var eventTitle: UITextField!
    @IBOutlet weak var eventAllDaySwitch: UISwitch!
    @IBOutlet weak var eventStartTime: UILabel!
    @IBOutlet weak var eventEndTime: UILabel!
    @IBOutlet weak var eventStartTimeStackView: UIStackView!
    @IBOutlet weak var evenEndTimeStackView: UIStackView!
    @IBOutlet weak var eventColorStackView: UIStackView!
    @IBOutlet weak var weekDaysStackView: UIStackView!
//    @IBOutlet weak var eventRemark: UITextField!
    var eventRemark:String = ""
    @IBOutlet weak var untilDateLabel: UILabel!
    @IBOutlet weak var untilDateStackView: UIStackView!
    @IBOutlet weak var deleteBtn: UIButton!
    
    
    @IBOutlet weak var wkWebRemark: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if eventInfo != nil && eventInfo?.id != nil {
            let account = O2AuthSDK.shared.myInfo()
            // 判断是否能修改
            if eventInfo?.createPerson != nil && eventInfo?.createPerson == account?.distinguishedName {
                canUpdate = true
            }else {
                canUpdate = false
            }
            if canUpdate {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "修改", style: .plain, target: self, action: #selector(tapSave))
                self.navigationItem.leftBarButtonItem?.title = ""
                self.navigationItem.title = "修改日程"
            }else {
                self.navigationItem.title = "日程信息"
            }
        }else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "保存", style: .plain, target: self, action: #selector(tapSave))
            self.navigationItem.leftBarButtonItem?.title = ""
            self.navigationItem.title = "新建日程"
        }
        
        //隐藏输入法
        eventTitle.delegate = self
        eventTitle.returnKeyType = .done
 
        
        eventStartTime.text = Date().toString("yyyy-MM-dd HH:mm")
        eventEndTime.text = Date().add(component: .hour, value: 1).toString("yyyy-MM-dd HH:mm")
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        // 修改填充值
        if eventInfo != nil && eventInfo?.id != nil {
            updateStuffValue()
            if "WEEKLY" ==  repeatValue {
                selectRepeatWeekly()
            }else if "NONE" == repeatValue || "" == repeatValue {
                selectRepeatNONE()
            }else {
                selectRepeatOther()
            }
        }else {
            self.repeatLabelView.text  = self.repeatOptions[0].value
            self.repeatValue = self.repeatOptions[0].key
            self.remindLabelView.text = self.remindOptions[0].value
            self.remindValue = self.remindOptions[0].key
        }
        // 添加点击事件
        calendarStackView.addTapGesture { (tap) in
            let calendarNames = self.calendarList.map { (info) -> String in
                info.name ?? ""
            }
            let calendarIds = self.calendarList.map { (info) -> String in
                info.id ?? ""
            }
            var current = calendarIds[0]
            if !self.calendarId.isEmpty {
                current = self.calendarId
            }
            let calendarPicker = O2StringPicker.instance(items: calendarNames, completionHandler: { (result) in
                if let cal = self.calendarList.first(where: { (info) -> Bool in
                    return info.id == result
                }) {
                    self.changeCalendarWithColor(cal)
                    self.calendarLabelView.text = cal.name
                }
            }, values: calendarIds, pickerTitle: "请选择日历", currentValue: current)
            calendarPicker.show()
        }
        remindStackView.addTapGesture { (tap) in
            let remindnames = self.remindOptions.map { (o) -> String in
                o.value
            }
            let remindIds = self.remindOptions.map { (o) -> String in
                o.key
            }
            var current = remindIds[0]
            if !self.remindValue.isEmpty {
                current = self.remindValue
            }
            let remindPicker = O2StringPicker.instance(items: remindnames, completionHandler: { (result) in
                if let op = self.remindOptions.first(where: { (o) -> Bool in
                    return o.key == result
                }) {
                    self.remindValue = op.key
                    self.remindLabelView.text = op.value
                }
               
            }, values: remindIds, pickerTitle: "请选择提醒方式", currentValue: current)
            remindPicker.show()
        }
        repeatStackView.addTapGesture { (tap) in
            let repeatNames = self.repeatOptions.map { (o) -> String in
                o.value
            }
            let repeatIds = self.repeatOptions.map { (o) -> String in
                o.key
            }
            var current = repeatIds[0]
            if !self.repeatValue.isEmpty {
                current = self.repeatValue
            }
            let repeatPicker = O2StringPicker.instance(items: repeatNames, completionHandler: { (result) in
                if let op = self.repeatOptions.first(where: { (o) -> Bool in
                    return o.key == result
                }) {
                     self.repeatValue = op.key
                    self.repeatLabelView.text = op.value
                     if "WEEKLY" ==  self.repeatValue {
                         self.selectRepeatWeekly()
                     }else if "NONE" == self.repeatValue || "" == self.repeatValue {
                         self.selectRepeatNONE()
                     }else {
                         self.selectRepeatOther()
                     }
                }
               
            }, values: repeatIds, pickerTitle: "请选择重复方式", currentValue: current)
            repeatPicker.show()
        }
        eventStartTimeStackView.addTapGesture { (tap) in
            self.showDatePicker(true)
        }
        evenEndTimeStackView.addTapGesture { (tap) in
            self.showDatePicker(false)
        }
        untilDateStackView.addTapGesture { (tap) in
            let datePicker = DatePickerView.datePicker(style: .yearMonthDay, scrollToDate: Date()) { date in
                self.untilDateLabel.text = date?.toString( "yyyy-MM-dd")
            }
            let nowDate = self.untilDateLabel.text != nil ? Date.date(self.untilDateLabel.text!, formatter: "yyyy-MM-dd"): Date()
            datePicker.scrollToDate = nowDate ?? Date()
            datePicker.show()
        }
        eventColorStackView?.subviews.forEach({ (colorView) in
            colorView.isUserInteractionEnabled = true
            colorView.setCornerRadius(radius: CGFloat(12))
            colorView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:#selector(tapColorView)))
        })
        weekDaysStackView?.subviews.forEach({ (btnView) in
            if btnView is UIButton {
                btnView.isUserInteractionEnabled = true
                btnView.addTapGesture(target: self, action: #selector(tapWeekBtnView))
                if !weekDayList.isEmpty {
                    let weekView = (btnView as! UIButton)
                    let tag = weekView.tag
                    let weekDay = weekOptions[tag]
                    if weekDayList.contains(weekDay) {
                        weekView.backgroundColor = base_blue_color
                        weekView.setTitleColor(UIColor.white, for: .normal)
                    }else {
                        weekView.backgroundColor = UIColor.white
                        weekView.setTitleColor(UIColor.darkGray, for: .normal)
                    }
                }
            }
        })
        viewModel.getMyCalendarList().then { (calendars) in
            self.calendarList = (calendars.myCalendars ?? []) + (calendars.unitCalendars ?? [])
            //self.calendarPickerView.reloadAllComponents()
            //初始化颜色
            if !self.calendarList.isEmpty {
                if self.eventInfo != nil {
                    if let index = self.calendarList.firstIndex(where: { (info) -> Bool in
                        return info.id == self.eventInfo?.calendarId
                    }) {
                        self.changeCalendarWithColor(self.calendarList[index], false)
                        self.calendarLabelView.text = self.calendarList[index].name
                        //self.calendarPickerView.selectRow(index, inComponent: 0, animated: true)
                    }else {
                        self.calendarLabelView.text = self.calendarList[0].name
                        self.changeCalendarWithColor(self.calendarList[0])
                    }
                }else {
                    self.calendarLabelView.text = self.calendarList[0].name
                    self.changeCalendarWithColor(self.calendarList[0])
                }
            }
        }.catch { (error) in
            DDLogError(error.localizedDescription)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(registerCompletion), name: Notification.Name(rawValue:"RegisterCompletionNotification"),
                                                             object: nil)

    }

    @objc func registerCompletion(notification:Notification){
        let theData = notification.userInfo!
        if let contentHtml = theData["contentHtml"] as? String {
            print("contentHtml =" , contentHtml)
            self.eventRemark = contentHtml
            self.wkWebRemark.loadHTMLString(contentHtml, baseURL: nil)
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navVC = segue.destination as! ZLNavigationController
        let destVC = navVC.topViewController as! OOCalendarEditRemarkViewController
         print(self.eventRemark)
        destVC.contentHTML = self.eventRemark
    }
    
    
    
    //MARK: - private func
    
    //隐藏输入法
    private func hideKeyboard() {
        self.view.endEditing(true)
    }
    //点击颜色模块
    @objc func tapColorView(_ tap: UITapGestureRecognizer) {
        hideKeyboard()
        if let tag = tap.view?.tag {
            selectColorView(tag: tag)
        }
    }
    //选择颜色模块
    private func selectColorView(tag: Int) {
        colorValue = colorOptions[tag]
        eventColorStackView.subviews.forEach { (colorView) in
            if colorView.tag == tag {
                colorView.subviews[0].isHidden = false
            }else {
                colorView.subviews[0].isHidden = true
            }
        }
    }
    //切换日历的时候颜色变化
    private func changeCalendarWithColor(_ calendar: OOCalendarInfo?, _ isChangeColorValue: Bool = true) {
        calendarId = calendar?.id ?? ""
        if let color = calendar?.color {
            if isChangeColorValue {
                colorValue = color
                if let index = self.colorOptions.firstIndex(where: { (colorString) -> Bool in
                    return color == colorString
                }) {
                    self.selectColorView(tag: index)
                }
            }
        }
    }
    // 点击周按钮
    @objc func tapWeekBtnView(_ tap: UITapGestureRecognizer) {
        let weekView = tap.view
        if weekView is UIButton {
            tapRenderWeekBtn(weekView: weekView as! UIButton)
        }
    }
    private func tapRenderWeekBtn(weekView: UIButton) {
        let tag = weekView.tag
        let weekDay = weekOptions[tag]
        if weekDayList.contains(weekDay) {
            weekDayList.removeFirst(weekDay)
            weekView.backgroundColor = UIColor.white
            weekView.setTitleColor(UIColor.darkGray, for: .normal)
        }else {
            weekDayList.append(weekDay)
            weekView.backgroundColor = base_blue_color
            weekView.setTitleColor(UIColor.white, for: .normal)
        }
    }
    // 日期选择器
    @objc func showDatePicker(_ isStartTime: Bool) {
        hideKeyboard()
        let isAllDay = eventAllDaySwitch.isOn
        var style = DateStyle.yearMonthDayHourMinute
        if isAllDay {
            style = DateStyle.yearMonthDay
        }
        let datePicker = DatePickerView.datePicker(style: style, scrollToDate: Date()) { date in
            guard let date = date else { return }
            var dateString = ""
            if isAllDay {
                dateString = date.toString("yyyy-MM-dd")
            }else {
                dateString = date.toString("yyyy-MM-dd HH:mm")
            }
            if isStartTime {
                self.eventStartTime.text = dateString
            }else {
                self.eventEndTime.text = dateString
            }
        }
        if isStartTime {
            let date = isAllDay ? Date.date(self.eventStartTime.text!, formatter: "yyyy-MM-dd") : Date.date(self.eventStartTime.text!, formatter: "yyyy-MM-dd HH:mm")
            datePicker.scrollToDate = date == nil ? Date() : date!
        }else {
            let date = isAllDay ? Date.date(self.eventEndTime.text!, formatter: "yyyy-MM-dd") : Date.date(self.eventEndTime.text!, formatter: "yyyy-MM-dd HH:mm")
            datePicker.scrollToDate = date == nil ? Date() : date!
        }
        
        datePicker.show()
    }
    
    //保存
    @objc func tapSave() {
        hideKeyboard()
        if eventInfo != nil && eventInfo?.id != nil {
            //修改 如果不是重复的 直接更新
            if eventInfo?.recurrenceRule == nil || eventInfo?.recurrenceRule == "" {
                updateEvent(type: 0)
            }else {
                showSheetAction(title: "修改", message: "请选择重复日程的修改方式", actions: [
                    UIAlertAction(title: "只修改当前日程", style: .default, handler: { (_) in
                        self.updateEvent(type: 0)
                    }),
                    UIAlertAction(title: "修改当前日程和之后的此重复日程", style: .default, handler: { (_) in
                        self.updateEvent(type: 1)
                    }),
                    UIAlertAction(title: "修改所有此重复日程", style: .default, handler: { (_) in
                        self.updateEvent(type: 2)
                    })])
                
            }
        }else {
            guard let title = eventTitle.text else {
                showError(title: "日程标题不能为空！")
                return
            }
            if title == "" {
                showError(title: "日程标题不能为空！")
                return
            }
            if calendarId == "" {
                showError(title: "没有选择日历！")
                return
            }
            let allday = eventAllDaySwitch.isOn
            //let remark = eventRemark.text ?? ""
            let remark = eventRemark
            let startTime = eventStartTime.text ?? ""
            let endTime = eventEndTime.text ?? ""
           
            let start = allday ? Date.date(startTime, formatter: "yyyy-MM-dd") : Date.date(startTime, formatter: "yyyy-MM-dd HH:mm")
            let end = allday ? Date.date(endTime, formatter: "yyyy-MM-dd") : Date.date(endTime, formatter: "yyyy-MM-dd HH:mm")
            if start == nil || end == nil {
                showError(title: "开始日期或结束日期错误！")
                return
            }
            if !(allday && startTime == endTime) && start!.compare(end!) != .orderedAscending {
               showError(title: "开始日期不能大于结束日期！")
               return
           }
             
            self.showLoading()
            let event = OOCalendarEventInfo.init()
            event.title = title
            event.calendarId = calendarId
            event.color = colorValue
            event.isAllDayEvent = allday
            event.startTime = start!.toString("yyyy-MM-dd HH:mm:ss")
            event.endTime = end!.toString("yyyy-MM-dd HH:mm:ss")
            event.recurrenceRule = rruleEncode()
            event.valarmTime_config = remindValue == "NONE" ? "" : remindValue
            event.comment = remark
            viewModel.saveCalendarEvent(event: event).always{
                self.hideLoading()
            }.then { (result)  in
                DDLogInfo("保存结果：\(result)")
                self.closeWindow()
                }.catch { (error) in
                    DDLogError(error.localizedDescription)
                    self.showError(title: "保存日程错误！")
                    
            }
        }
    }
    
    private func updateEvent(type: Int) {
        guard let title = eventTitle.text else {
            showError(title: "日程标题不能为空！")
            return
        }
        if calendarId == "" {
            showError(title: "没有选择日历！")
            return
        }
        let allday = eventAllDaySwitch.isOn
        // remark = eventRemark.text ?? ""
        let remark = eventRemark
        let startTime = eventStartTime.text ?? ""
        let endTime = eventEndTime.text ?? ""
        let start = allday ? Date.date(startTime, formatter: "yyyy-MM-dd") : Date.date(startTime, formatter: "yyyy-MM-dd HH:mm")
        let end = allday ? Date.date(endTime, formatter: "yyyy-MM-dd") : Date.date(endTime, formatter: "yyyy-MM-dd HH:mm")
        if start == nil || end == nil {
            showError(title: "开始日期或结束日期错误！")
            return
        }
        if !(allday && startTime == endTime) && start!.compare(end!) != .orderedAscending {
            showError(title: "开始日期不能大于结束日期！")
            return
        }
        self.showLoading()
        eventInfo?.title = title
        eventInfo?.calendarId = calendarId
        eventInfo?.color = colorValue
        eventInfo?.isAllDayEvent = allday
        eventInfo?.startTime = start!.toString("yyyy-MM-dd HH:mm:ss")
        eventInfo?.endTime = end!.toString("yyyy-MM-dd HH:mm:ss")
        eventInfo?.recurrenceRule = rruleEncode()
        eventInfo?.valarmTime_config = remindValue == "NONE" ? "" : remindValue
        eventInfo?.comment = remark
        switch type {
        case 0:
            updateSingle()
        case 1:
            updateAfter()
        case 2:
            updateAll()
        default:
            DDLogError("更新类型不正确。。。。。。。")
            self.showError(title: "更新类型不正确！！！")
        }
    }
    
    private func updateSingle() {
        viewModel.updateCalendarEventSingle(id: (eventInfo?.id!)!, event: eventInfo!).always {
            self.hideLoading()
        }.then { (result)  in
            DDLogInfo("保存结果：\(result)")
            self.closeWindow()
            }.catch { (error) in
                DDLogError(error.localizedDescription)
                self.showError(title: "更新单个日程错误！")
        }
    }
    private func updateAfter() {
        viewModel.updateCalendarEventAfter(id: (eventInfo?.id!)!, event: eventInfo!).always {
            self.hideLoading()
        }.then { (result)  in
            DDLogInfo("保存结果：\(result)")
            self.closeWindow()
            }.catch { (error) in
                DDLogError(error.localizedDescription)
                self.showError(title: "更新after日程错误！")
        }
    }
    private func updateAll() {
        viewModel.updateCalendarEventAll(id: (eventInfo?.id!)!, event: eventInfo!).always {
            self.hideLoading()
        }.then { (result)  in
            DDLogInfo("保存结果：\(result)")
            self.closeWindow()
            }.catch { (error) in
                DDLogError(error.localizedDescription)
                self.showError(title: "更新all日程错误！")
        }
    }
    
    private func startDelete() {
        if eventInfo?.recurrenceRule == nil || eventInfo?.recurrenceRule == "" {
            deleteEvent(type: 0)
        }else {
            showSheetAction(title: "删除", message: "请选择重复日程的删除方式", actions: [
                UIAlertAction(title: "只删除当前日程", style: .default, handler: { (_) in
                    self.deleteEvent(type: 0)
                }),
                UIAlertAction(title: "删除当前日程和之后的此重复日程", style: .default, handler: { (_) in
                    self.deleteEvent(type: 1)
                }),
                UIAlertAction(title: "删除所有此重复日程", style: .default, handler: { (_) in
                    self.deleteEvent(type: 2)
                })])
            
        }
    }
    
    private func deleteEvent(type: Int) {
        self.showLoading()
        switch type {
        case 0:
            viewModel.deleteCalendarEventSingle(id: (eventInfo?.id!)!).always{
                self.hideLoading()
            }.then { (result)  in
                DDLogInfo("删除结果：\(result)")
                self.closeWindow()
                }.catch { (error) in
                    DDLogError(error.localizedDescription)
                    self.showError(title: "删除Single日程错误！")
            }
        case 1:
            viewModel.deleteCalendarEventAfter(id: (eventInfo?.id!)!).always{
                self.hideLoading()
            }.then { (result)  in
                DDLogInfo("删除结果：\(result)")
                self.closeWindow()
                }.catch { (error) in
                    DDLogError(error.localizedDescription)
                    self.showError(title: "删除After日程错误！")
            }
        case 2:
            viewModel.deleteCalendarEventAll(id: (eventInfo?.id!)!).always {
                self.hideLoading()
            }.then { (result)  in
                DDLogInfo("删除结果：\(result)")
                self.closeWindow()
                }.catch { (error) in
                    DDLogError(error.localizedDescription)
                    self.showError(title: "删除All日程错误！")
            }
        default:
            DDLogError("删除类型不正确。。。。。。。")
            self.showError(title: "删除类型不正确！！！")
        }
    }
    
    
    private func updateStuffValue() {
        eventTitle.text = eventInfo?.title
        if eventInfo?.isAllDayEvent == true {
            eventAllDaySwitch.setOn(true, animated: false)
            eventStartTime.text = eventInfo?.startTime?.subString(from: 0, to: 10)
            eventEndTime.text = eventInfo?.endTime?.subString(from: 0, to: 10)
        }else {
            eventAllDaySwitch.setOn(false, animated: false)
            eventStartTime.text = eventInfo?.startTime?.subString(from: 0, to: 16)
            eventEndTime.text = eventInfo?.endTime?.subString(from: 0, to: 16)
        }
        if let color = eventInfo?.color {
            colorValue = color
            if let index = self.colorOptions.firstIndex(where: { (colorString) -> Bool in
                return color == colorString
            }) {
                self.selectColorView(tag: index)
            }
        }
        if let remind = eventInfo?.valarmTime_config {
            if remind != "" {
                remindValue = remind
                if let index = self.remindOptions.firstIndex(where: { (r) -> Bool in
                    return remind == r.key
                }) {
//                    self.remindPickerView.selectRow(index, inComponent: 0, animated: true)
                    self.remindLabelView.text = self.remindOptions[index].value
                }else {
                    self.remindLabelView.text = self.remindOptions[0].value
                }
            }
        }
        if let repeatupdate = eventInfo?.recurrenceRule {
            rruleDecode(rrule: repeatupdate)
            DDLogInfo("freq:\(self.repeatValue)")
            if let index = self.repeatOptions.firstIndex(where: { (re) -> Bool in
                return  self.repeatValue != "" && re.key == self.repeatValue
            }){
//                self.repeatPickerView.selectRow(index, inComponent: 0, animated: true)
                self.repeatLabelView.text  = self.repeatOptions[index].value
            }else {
                self.repeatLabelView.text  = self.repeatOptions[0].value
            }
        }
        // eventRemark.text = eventInfo?.comment
         eventRemark = eventInfo?.comment ?? ""
         self.wkWebRemark.loadHTMLString(eventRemark, baseURL: nil)

    }
    
    private func rruleDecode(rrule: String) {
        let array = rrule.split(";")
        array.forEach { (rruleItem) in
            if rruleItem.contains("FREQ") {
                DDLogInfo("freq:\(rruleItem)")
                self.repeatValue = rruleItem.split("=")[1]
            }
            if rruleItem.contains("UNTIL") {
                DDLogInfo("UNTIL:\(rruleItem)")
                let untilDate = rruleItem.split("=")[1]
                let date = untilDate.subString(from:0, to: 8)
                untilDateLabel.text = Date.date(date, formatter: "yyyyMMdd")?.toString("yyyy-MM-dd")
            }
            if rruleItem.contains("BYDAY") {
                DDLogInfo("BYDAY:\(rruleItem)")
                let wd = rruleItem.split("=")[1]
                self.weekDayList = wd.split(",")
            }
        }
        
        
    }
    
    private func closeWindow() {
        self.navigationController?.popViewController(animated: true)
    }
    
    //重复规则编码
    private func rruleEncode() -> String {
        if repeatValue == "" || repeatValue == "NONE" {
            return ""
        }
        var reft = "FREQ=\(repeatValue)"
        let untilDate = untilDateLabel.text
        if untilDate != nil && untilDate != "" {
            if let date = Date.date(untilDate!, formatter: "yyyy-MM-dd") {
                reft = reft+";UNTIL="+date.toString("yyyyMMdd")+"T000000Z"
            }
        }
        if repeatValue == "WEEKLY" && !weekDayList.isEmpty {
            let weekDays = weekDayList.joined(separator: ",")
            reft = reft+";BYDAY="+weekDays
        }
        return reft
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //取消tableview选中状态
        tableView.deselectRow(at: indexPath, animated: false)
        // 隐藏输入法
        self.view.endEditing(true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 1:
            return CGFloat(120)
        case 2, 4:
            return CGFloat(60)
        case 5:
            if "WEEKLY" ==  repeatValue {
                return CGFloat(120)
            }else if "NONE" == repeatValue || "" == repeatValue {
                return CGFloat(60)
            }else {
                return CGFloat(90)
            }
        case 6:
//            if eventInfo != nil && eventInfo?.id != nil {
//                if canUpdate {
//                    deleteBtn.isHidden = false
//                    return CGFloat(140)
//                }else {
//                    deleteBtn.isHidden = true
//                    return CGFloat(100)
//                }
//            }else {
//                deleteBtn.isHidden = true
//                return CGFloat(100)
//            }
            return CGFloat(160)
        default:
            return CGFloat(45)
        }
    }

    private func selectRepeatWeekly() {
        self.tableView.beginUpdates()
        self.repeatTableViewCell.frame.size.height = CGFloat(120)
        weekDaysStackView.isHidden = false
        untilDateStackView.isHidden = false
        self.tableView.endUpdates()
    }
    private func selectRepeatNONE() {
        self.tableView.beginUpdates()
        self.repeatTableViewCell.frame.size.height = CGFloat(60)
        weekDaysStackView.isHidden = true
        untilDateStackView.isHidden = true
        self.tableView.endUpdates()
    }
    private func selectRepeatOther() {
        self.tableView.beginUpdates()
        self.repeatTableViewCell.frame.size.height = CGFloat(90)
        weekDaysStackView.isHidden = true
        untilDateStackView.isHidden = false
        self.tableView.endUpdates()
    }
    
}

//MARK: - extension

//extension OOCalendarEventViewController: UIPickerViewDelegate, UIPickerViewDataSource {
//    // 几级选项器
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//
//        return 1
//    }
//    // 多少行数据
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        switch pickerView.tag {
//        case 110://日历选项
//            return calendarList.count
//        case 111: // 提醒选项
//            return remindOptions.count
//        case 112: // 重复选项
//            return repeatOptions.count
//        default:
//            return 0
//        }
//    }
//    // 选项显示名称
////    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
////        switch pickerView.tag {
////        case 110://日历选项
////            return calendarList[row].name
////        case 111: // 提醒选项
////            return remindOptions[row].value
////        case 112: // 重复选项
////            return repeatOptions[row].value
////        default:
////            return ""
////        }
////    }
//    // 选项 view
//    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
//        var title = ""
//        switch pickerView.tag {
//        case 110://日历选项
//            title =  calendarList[row].name ?? ""
//        case 111: // 提醒选项
//            title = remindOptions[row].value
//        case 112: // 重复选项
//            title = repeatOptions[row].value
//        default:
//            title = ""
//        }
//
//        if view == nil {
//            let titleLabel = UILabel.init()
//            titleLabel.adjustsFontSizeToFitWidth  = true
//            titleLabel.textAlignment = NSTextAlignment.center
//            titleLabel.textColor = UIColor.darkGray
//            titleLabel.font = setting_item_textFont
//            titleLabel.text = title
//            return titleLabel
//        }else {
//            let titleLabel = view as! UILabel
//            titleLabel.text = title
//            return titleLabel
//        }
//    }
//    // 选中
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        switch pickerView.tag {
//        case 110://日历选项
//
//            self.changeCalendarWithColor(calendarList[row])
//        case 111: // 提醒选项
//
//            remindValue = remindOptions[row].key
//        case 112: // 重复选项
//
//            repeatValue = repeatOptions[row].key
//            if "WEEKLY" ==  repeatValue {
//                selectRepeatWeekly()
//            }else if "NONE" == repeatValue || "" == repeatValue {
//                selectRepeatNONE()
//            }else {
//                selectRepeatOther()
//            }
//        default:
//            DDLogError("啥pickerView？？？？")
//        }
//    }
//
//
//}

extension OOCalendarEventViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
}

