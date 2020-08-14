//
//  ActionMenu.swift
//  iSimulator
//
//  Created by 靳朋 on 2017/8/24.
//  Copyright © 2017年 niels.jin. All rights reserved.
//

//  FileInfo DirectoryWatcher CancelBlocks

import Cocoa

class AppMenu: NSMenu {

    let app: Application
    
    init(_ app: Application) {
        self.app = app
        super.init(title: "")
        addCustomItem()
    }
    
    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addCustomItem() {
        let actionTypes: [AppActionable.Type] = [AppShowInFinderAction.self,
                                                 AppLaunchAction.self,
                                                 AppResetAction.self,
                                                 AppTerminateAction.self,
                                                 AppUninstallAction.self]
        actionTypes.forEach { (ActionType) in
            let action = ActionType.init(app)
            if !action.isAvailable {
                return
            }
            let item = NSMenuItem.init(title: action.title, action: #selector(AppShowInFinderAction.perform), keyEquivalent: "")
            item.target = action as AnyObject
            item.image = action.icon
            item.representedObject = action
            self.addItem(item)
        }
        self.insertItem(createOtherSimLunchAppItem(), at: 2)
        if let item = createRealmAppItem() {
            self.insertItem(item, at: 3)
        }
//        let item = NSMenuItem()
//        item.view = AppInfoView(application: app)
//        item.isEnabled = true
//        self.addItem(item)
    }
    
    func createOtherSimLunchAppItem() -> NSMenuItem {
        let otherSimLunchAppItem = NSMenuItem.init(title: "Launch From Other Simulator", action: nil, keyEquivalent: "")
        let submenu = NSMenu()
        let runtimes: [Runtime] = TotalModel.default.runtimes(osType: app.device.runtime.osType)
        var appDeviceItemDic: [String: [NSMenuItem]] = [:]
        runtimes.forEach { (r) in
            var appDeviceItems: [NSMenuItem] = []
            r.devices.forEach({ (device) in
                if device === app.device {
                    return
                }
                let action = DeviceLaunchOtherAppAction.init(app: app, device: device)
                let item = NSMenuItem.init(title: device.name, action: #selector(action.perform), keyEquivalent: "")
                item.target = action as AnyObject
                item.representedObject = action
                appDeviceItems.append(item)
            })
            if !appDeviceItems.isEmpty {
                let titleItem = NSMenuItem(title: r.name, action: nil, keyEquivalent: "")
                titleItem.isEnabled = false
                appDeviceItems.insert(titleItem, at: 0)
                appDeviceItemDic[r.name] = appDeviceItems
            }
        }
        appDeviceItemDic.forEach { (_, deviceItems) in
            deviceItems.forEach({ (item) in
                submenu.addItem(item)
            })
        }
        otherSimLunchAppItem.submenu = submenu
        return otherSimLunchAppItem
    }
    
    func createRealmAppItem() -> NSMenuItem? {
        let all = FileManager.default.enumerator(at: app.sandboxDirUrl, includingPropertiesForKeys: nil)
        var realmFilePaths: [String] = []
        while let fileUrl = all?.nextObject() as? URL {
            if fileUrl.pathExtension.lowercased() == "realm" {
                realmFilePaths.append(fileUrl.path)
            }
        }
        guard !realmFilePaths.isEmpty else {
            return nil
        }
        if realmFilePaths.count == 1 {
            let action = AppRealmAction.init("Open Realm Database", path: realmFilePaths[0])
            let item = NSMenuItem.init(title: action.title, action: #selector(action.perform), keyEquivalent: "")
            item.target = action as AnyObject
            item.image = action.icon
            item.representedObject = action
            return item
        } else {
            let item = NSMenuItem.init(title: "Open Realm Database", action: nil, keyEquivalent: "")
            item.image = #imageLiteral(resourceName: "realmAppActionIcon")
            let submenu = NSMenu()
            realmFilePaths.forEach { (path) in
                let action = AppRealmAction.init(URL.init(fileURLWithPath: path).lastPathComponent, path: path)
                let item = NSMenuItem.init(title: action.title, action: #selector(action.perform), keyEquivalent: "")
                item.target = action as AnyObject
                item.representedObject = action
                submenu.addItem(item)
            }
            item.submenu = submenu
            return item
        }
    }
}

protocol AppActionable {
    init(_ app: Application)
    var app: Application { set get }
    var title: String { get }
    var icon: NSImage? { get }
    var isAvailable: Bool { get }
    func perform()
}

class AppShowInFinderAction: AppActionable {
    var app: Application
    required init(_ app: Application) {
        self.app = app
    }
    var title: String = "Show in Finder"
    @objc func perform() {
        if let url = app.linkURL{
            NSWorkspace.shared.open(url)
        }
    }
    var isAvailable: Bool = true
    var icon: NSImage?
}

class DeviceLaunchOtherAppAction: AppActionable {
    required init(_ app: Application) {
        fatalError("init(coder:) has not been implemented")
    }
    var app: Application
    var device: Device
    var title: String
    required init(app: Application, device: Device) {
        self.app = app
        self.device = device
        self.title = device.name
    }
    @objc func perform() {
        device.installApp(app)
        device.launch(appBundleId: app.bundleID)
    }
    var isAvailable: Bool = true
    var icon: NSImage?
}

class AppLaunchAction: AppActionable {
    var app: Application
    required init(_ app: Application) {
        self.app = app
    }
    var title: String = "Launch"
    @objc func perform() {
        app.launch()
    }
    var isAvailable: Bool = true
    var icon: NSImage?
}

class AppTerminateAction: AppActionable {
    var app: Application
    required init(_ app: Application) {
        self.app = app
    }
    var title: String = "Terminate"
    @objc func perform() {
        app.terminate()
    }
    var isAvailable: Bool {
        return app.device.state == .booted
    }
    var icon: NSImage?
}

class AppResetAction: AppActionable {
    var app: Application
    required init(_ app: Application) {
        self.app = app
    }
    var title: String = "Reset Content..."
    @objc func perform() {
        let alert: NSAlert = NSAlert()
        alert.messageText = String(format: "Are you sure you want to Reset Content %@ from %@?", app.bundleDisplayName, app.device.name)
        alert.informativeText = "All of sandbox data in this application will be remove."
        alert.alertStyle = .critical
        alert.addButton(withTitle: "Reset")
        alert.addButton(withTitle: "Cancel")
        NSApp.activate(ignoringOtherApps: true)
        let response = alert.runModal()
        if response == NSApplication.ModalResponse.alertFirstButtonReturn {
            app.resetContent()
        }
        
    }
    var isAvailable: Bool {
        return true
    }
    var icon: NSImage?
}

class AppUninstallAction: AppActionable {
    var app: Application
    required init(_ app: Application) {
        self.app = app
    }
    var title: String = "Uninstall..."
    @objc func perform() {
        let alert: NSAlert = NSAlert()
        alert.messageText = String(format: "Are you sure you want to uninstall %@ from %@?", app.bundleDisplayName, app.device.name)
        alert.informativeText = "All of data(sandbox/bundle) in this application will be deleted."
        alert.alertStyle = .critical
        alert.addButton(withTitle: "Uninstall")
        alert.addButton(withTitle: "Cancel")
        NSApp.activate(ignoringOtherApps: true)
        let response = alert.runModal()
        if response == NSApplication.ModalResponse.alertFirstButtonReturn {
            app.uninstall()
        }
        
    }
    var isAvailable: Bool {
        return app.device.state == .booted
    }
    var icon: NSImage?
}

protocol AppActionableExt: AppActionable {
    var appBundleIdentifier: String { get }
}

extension AppActionableExt {
    
    var appPath: String? {
        return self.path(forBundleIdentifier: appBundleIdentifier)
    }
    
    var icon: NSImage? {
        if let path = appPath {
            let image = NSWorkspace.shared.icon(forFile: path)
            image.size = NSSize(width: 16, height: 16)
            return image
        }
        return nil
    }
    
    var isAvailable: Bool {
        return appPath != nil
    }
    
    func path(forBundleIdentifier bundleIdentifier: String) -> String? {
        return NSWorkspace.shared.absolutePathForApplication(withBundleIdentifier: bundleIdentifier)
    }
    
}

class AppRealmAction {
    
    var icon: NSImage? {
        return #imageLiteral(resourceName: "realmAppActionIcon")
    }
    let title: String
    let realmPath: String
    
    init(_ title: String, path: String) {
        self.title = title
        self.realmPath = path
    }
    
    @objc func perform() {
        NSWorkspace.shared.openFile(realmPath)
    }
}

final class AppInfoView: NSView {
    
    var application: Application
    var textField: NSTextField!
    
    static let width: CGFloat = 250
    static let edgeInsets = NSEdgeInsets(top: 0, left: 20, bottom: 5, right: 0)
    static let leftMargin: CGFloat = 20
    
    init(application: Application) {
        self.application = application
        super.init(frame: NSRect.zero)
        
        setupViews()
        update(sandboxSize: 0, bundleSize: 0)
        
        let size = textField.sizeThatFits(NSSize(width: CGFloat.infinity, height: CGFloat.infinity))
        textField.frame = NSRect(x: AppInfoView.leftMargin, y: AppInfoView.edgeInsets.bottom, width: AppInfoView.width - AppInfoView.edgeInsets.left, height: size.height)
        frame = NSRect(x: 0, y: 0, width: AppInfoView.width, height: size.height + AppInfoView.edgeInsets.bottom)
        
        application.size { (sandboxSize, bundleSize) in
            self.update(sandboxSize: sandboxSize, bundleSize: bundleSize)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        textField = NSTextField(frame: NSRect(x: 20, y: 0, width: 230, height: 100))
        textField.isBezeled = false
        textField.drawsBackground = false
        textField.isEditable = false
        textField.isSelectable = false
        textField.cell?.wraps = false
        textField.textColor = NSColor.disabledControlTextColor
        addSubview(textField)
    }
    
    private func update(sandboxSize: UInt64, bundleSize: UInt64) {
        var sandboxSizeDes = "---"
        var bundleSizeDes = "---"
        if sandboxSize != 0 {
            sandboxSizeDes = ByteCountFormatter.string(fromByteCount: Int64(sandboxSize), countStyle: .file)
        }
        if bundleSize != 0 {
            bundleSizeDes = ByteCountFormatter.string(fromByteCount: Int64(bundleSize), countStyle: .file)
        }
        let string = "\(application.bundleID)\n" +
            "Version: \(application.bundleVersion) (\(application.bundleShortVersion))\n" +
            "SandboxSize: \(sandboxSizeDes)\n" +
        "BundleSize: \(bundleSizeDes)"
        
        textField.stringValue = string
    }
    
}

