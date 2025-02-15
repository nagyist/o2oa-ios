//
//  Notification+Extension.swift
//  O2Platform
//
//  Created by 刘振兴 on 2018/4/18.
//  Copyright © 2018年 zoneland. All rights reserved.
//

import UIKit

enum OONotification:String {
    //登录相关
    case login
    case logout
    case bindCompleted
    
    // 考勤管理相关
    case location
    case newWorkPlace
    case staticsTotal
    case reloadAttendance
    
    //重载门户webview
    case reloadPortal
    
    //websocket使用
    case websocket
    // im消息发送
    case imCreate
    // im消息撤回
    case imRevoke
    // 会话更新
    case imConvUpdate
    // 会话删除
    case imConvDelete
    
    //日程管理Main中使用
    case calendarIds
    
    
    
    var stringValue:String {
        return "OOK" + rawValue
    }
    
    var notificationName:Notification.Name {
        return Notification.Name(stringValue)
    }
}

extension NotificationCenter {
    static func post(customeNotification name: OONotification, object: Any? = nil) {
        NotificationCenter.default.post(name: name.notificationName, object: object)
    }
}
