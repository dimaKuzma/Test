//
//  TabBarController.swift
//  Test
//
//  Created by Дмитрий on 6/30/21.
//  Copyright © 2021 DK. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
}

// MARK: -
// MARK: - Configure
private extension TabBarController {
    func configure() {
        configureTabBar()
    }
    
    func configureTabBar() {
        let firstTabBarItem = UITabBarItem()
        firstTabBarItem.image = UIImage(named: "settings")?.withRenderingMode(.alwaysOriginal)
        firstTabBarItem.selectedImage = UIImage(named: "settingsSelected")?.withRenderingMode(.alwaysOriginal)
        let settingsVC = UIStoryboard(name: "Settings", bundle: nil).instantiateInitialViewController() as! SettingsViewController
        settingsVC.tabBarItem = firstTabBarItem
        let secondTabBarItem = UITabBarItem()
        secondTabBarItem.image = UIImage(named: "change")?.withRenderingMode(.alwaysOriginal)
        secondTabBarItem.selectedImage = UIImage(named: "changeSelected")?.withRenderingMode(.alwaysOriginal)
        let changeVC = UIStoryboard(name: "Change", bundle: nil).instantiateInitialViewController() as! ChangeViewController
        changeVC.tabBarItem = secondTabBarItem
        let thirdTabBarItem = UITabBarItem()
        thirdTabBarItem.image = UIImage(named: "menu")?.withRenderingMode(.alwaysOriginal)
        thirdTabBarItem.selectedImage = UIImage(named: "menuSelected")?.withRenderingMode(.alwaysOriginal)
        let menuVC = UIStoryboard(name: "Menu", bundle: nil).instantiateInitialViewController() as! MenuViewController
        menuVC.tabBarItem = thirdTabBarItem
        let fourthTabBarItem = UITabBarItem()
        fourthTabBarItem.image = UIImage(named: "place")?.withRenderingMode(.alwaysOriginal)
        fourthTabBarItem.selectedImage = UIImage(named: "placeSelected")?.withRenderingMode(.alwaysOriginal)
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as! ViewController
        vc.tabBarItem = fourthTabBarItem
        viewControllers = [settingsVC, changeVC, menuVC, vc]
    }
}
