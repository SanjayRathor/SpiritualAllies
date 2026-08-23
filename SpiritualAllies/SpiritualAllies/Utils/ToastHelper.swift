//
//  ToastHelper.swift
//  NoteMindAI
//
//  Created by Sanjay Rathor on 20/01/26.
//

import Foundation
import UIKit
import SwiftUI
import ProgressHUD
import Toast

class ToastHelper {
    static let shared = ToastHelper()
    private init() {}
    
    private var activeWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
    
    // MARK: - Instance Methods (Your current approach)
    
    func hideLoading() {
        DispatchQueue.main.async {
            ProgressHUD.dismiss()
        }
    }
    
    static func showLoading(with message:String = "") {
        DispatchQueue.main.async {
            ProgressHUD.animationType = .horizontalBarScaling
            ProgressHUD.colorHUD = Color(uiColor: UIColor { traits in
                traits.userInterfaceStyle == .dark
                    ? UIColor(red: 22 / 255, green: 31 / 255, blue: 34 / 255, alpha: 1)
                    : .white
            })
            ProgressHUD.colorAnimation = AppColors.accent
            ProgressHUD.colorProgress = AppColors.accent
            guard message.count > 0 else {
                ProgressHUD.animate(interaction: false)
                return
            }
            ProgressHUD.animate(message,interaction: false)
        }
    }
    
    func showToast(_ message: String) {
        ToastHelper.shared.hideLoading()
        if message.isEmpty { return }
        DispatchQueue.main.async { [weak self] in
            guard let window = self?.activeWindow else { return }
            window.makeToast(message, position: .center)
        }
    }
    
    static func loading() {
        showLoading()
    }
    
    static func hideLoading() {
        shared.hideLoading()
    }
    
    static func toast(_ message: String) {
        shared.showToast(message)
    }

    @discardableResult
    static func requireNetwork() -> Bool {
        guard NetworkMonitor.shared.isConnected else {
            shared.showToast(AppStrings.Error.noInternet)
            return false
        }
        return true
    }
    
    static func showNetworkError() {
        DispatchQueue.main.async {
            ProgressHUD.dismiss()
            
            // Show alert dialog instead of toast
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootViewController = windowScene.windows.first?.rootViewController else {
                return
            }
            
            let alert = UIAlertController(
                title: "No Internet Connection",
                message: "Please check your internet connection and try again.",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            
            // Find the topmost view controller to present the alert
            var topController = rootViewController
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            topController.present(alert, animated: true)
        }
    }
}
