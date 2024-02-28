//
//  FlutterQQSwiftPlugin.swift
//  flutter_qq
//
//  Created by Benster on 2021/11/3.
//

import Flutter
import UIKit
import TencentOpenApi

public class SwiftFlutterQQPlugin: NSObject, FlutterPlugin, FlutterApplicationLifeCycleDelegate {
    
    private var result: FlutterResult? = nil
    private var oauth: TencentOAuth? = nil
    private static let sharedManager: SwiftFlutterQQPlugin = {
        let sharedInstance = SwiftFlutterQQPlugin()
        NotificationCenter.default.addObserver(
            sharedInstance,
            selector: #selector(handleOpenURL(_:delegate:)),
            name: NSNotification.Name("QQ"),
            object: nil
        )
        return sharedInstance
    }()
    
    @objc public static func sharedInstance() -> SwiftFlutterQQPlugin {
        return .sharedManager
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_qq", binaryMessenger: registrar.messenger())
        let instance = sharedManager
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addApplicationDelegate(instance)
    }
    
    private override init() {}
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        self.result = result
        let arguments: [String: Any?]? = call.arguments as? [String: Any]
        switch call.method {
        case "registerQQ":  // 初始化
            TencentOAuth.setIsUserAgreedAuthorization(true)
            let appId: String = arguments?["appId"] as? String ?? ""
            let univeralLink: String = arguments?["univeralLink"] as? String ?? ""
            self.oauth = TencentOAuth.init(appId: appId, andUniversalLink: univeralLink, andDelegate: self)
        case "isQQInstalled" :  // 判断是否安装QQ
            result(QQApiInterface.isQQInstalled)
        case "login": // 登录
            var scopeArray: Array = Array<Any>.init()
            let scopes: String = arguments?["scopes"] as? String ?? ""
            if !scopes.isEmpty {
                scopeArray = scopes.components(separatedBy: ",")
            }
            if scopeArray.isEmpty {
                scopeArray = [ "get_user_info", "get_simple_userinfo", "add_t" ]
            }
            if !(self.oauth?.authorize(scopeArray) ?? false) {
                let body: [String : Any?] = ["type": "QQAuthorizeResponse", "Code": 1, "Message": "login failed" ]
                result(body)
            }
        case "getUserInfo": // 获取用户信息
            if !(self.oauth?.getUserInfo() ?? false) {
                let body: [String : Any?] = ["type": "QQGetUserInfoResponse", "Code": 1, "Message": "get userInfo faild" ]
                result(body)
            }
        default:
            result("iOS " + UIDevice.current.systemVersion)
        }
    }
    
    @objc public func handleOpenURL(_ aNotification: NSNotification, delegate: QQApiInterfaceDelegate?) -> Bool {
        let aURLString: String? = aNotification.userInfo?["url"] as? String
        let url: URL? = URL.init(string: aURLString ?? "")
        QQApiInterface.handleOpen(url, delegate: self)
        if TencentOAuth.canHandleOpen(url) {
            return TencentOAuth.handleOpen(url)
        }

        return true
    }
    
    public func application(_ application: UIApplication, open url: URL, sourceApplication: String, annotation: Any) -> Bool {
        return TencentOAuth.handleOpen(url)
    }
}

extension SwiftFlutterQQPlugin: QQApiInterfaceDelegate, TencentSessionDelegate {

    // MARK: - QQApiInterfaceDelegate

    public func isOnlineResponse(_ response: [AnyHashable : Any]!) { }

    public func onReq(_ req: QQBaseReq!) { }

    public func onResp(_ resp: QQBaseResp!) {
        if resp.isKind(of: SendMessageToQQResp.self) {
            var body: [String: Any?] = [ "type": "QQShareResponse", "Message": resp.result ]
            if (resp.errorDescription ?? "").isEmpty {
                body.updateValue(1, forKey: "Code")
            } else {
                body.updateValue(0, forKey: "Code")
            }
            self.result?(body)
        }
    }

    // MARK: - TencentSessionDelegate

    /// 登录成功
    public func tencentDidLogin() {
        var body: [String: Any?] = [ "type": "QQAuthorizeResponse" ]
        body["Code"] = 0
        body["Message"] = "Ok"

        var response:[String: Any?] = Dictionary()
        response.updateValue(self.oauth?.openId, forKey: "openid")
        response.updateValue(self.oauth?.accessToken, forKey: "accessToken")
        response.updateValue((self.oauth?.expirationDate?.timeIntervalSince1970 ?? 0) * 1000, forKey: "expiresAt")
        response.updateValue(self.oauth?.appId, forKey: "appId")

        body.updateValue(response, forKey: "Response")
        self.result?(body)
    }

    /// 登录失败
    public func tencentDidNotLogin(_ cancelled: Bool) {
        var body: [String: Any?] = [ "type": "QQAuthorizeResponse" ]
        body["Message"] = "Ok"
        body.merge(cancelled ? ["Code": 2, "Message": "login canceled"] : ["Code": 1, "Message": "login failed"]) { $1 }
        self.result?(body)
    }

    /// 登录网络异常
    public func tencentDidNotNetWork() {
        var body: [String: Any?] = [ "type": "QQAuthorizeResponse" ]
        body["Code"] = 3
        body["Message"] = "login did notNetWork"
        self.result?(body)
    }

    /// 获取用户信息
    public func getUserInfoResponse(_ response: APIResponse!) {
        var body: [String: Any?] = [ "type": "QQGetUserInfoResponse" ]
        body["Code"] = 0
        body["Message"] = "Ok"
        self.result?(body)
    }
}

