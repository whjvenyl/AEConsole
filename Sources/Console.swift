/**
 *  https://github.com/tadija/AEConsole
 *  Copyright (c) Marko Tadić 2016-2018
 *  Licensed under the MIT license. See LICENSE file.
 */

import UIKit
import AELog

/// Facade for displaying log generated by `aelog` in Console UI overlay on top of your app.
open class Console: LogDelegate {
    
    // MARK: - Properties
    
    static let shared = Console()
    
    let brain = Brain()
    
    public let settings = Settings.shared
    private var window: UIWindow?
    
    // MARK: - API

    /// Enable Console UI by calling this method in your AppDelegate's `didFinishLaunchingWithOptions:`
    ///
    /// - Parameter window: Main window for the app (AppDelegate's window).
    open class func launch(in window: UIWindow?) {
        Log.shared.delegate = shared
        shared.window = window
        shared.brain.configureConsole(in: window)
    }
    
    /// Current state of Console UI visibility
    open class var isHidden: Bool {
        return !shared.brain.console.isOnScreen
    }
    
    /// Toggle Console UI
    open class func toggle() {
        guard let view = shared.brain.console else { return }
        
        if !view.isOnScreen {
            shared.activateConsoleUI()
        }
        
        view.toggleUI()
    }
    
    // MARK: - Init
    
    fileprivate init() {
        let center = NotificationCenter.default
        let notification = NSNotification.Name.UIApplicationDidBecomeActive
        center.addObserver(self, selector: #selector(activateConsoleUI), name: notification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc fileprivate func activateConsoleUI() {
        guard let window = window else { return }
        window.bringSubview(toFront: brain.console)
        if settings.isShakeGestureEnabled {
            brain.console.becomeFirstResponder()
        }
    }
    
    // MARK: - LogDelegate

    open func didLog(line: Line, mode: Log.Mode) {
        DispatchQueue.main.async(execute: {
            self.brain.addLogLine(line)
            self.activateConsoleUI()
        })
    }
    
}
