//
//  ChildViewController.swift
//  RolodexNavigationController
//
//  Created by Reed Dadoune on 12/7/14.
//  Copyright (c) 2014 Dadoune. All rights reserved.
//

import UIKit

class ChildViewController: UIViewController {
	
	@IBOutlet weak var previousController: UIButton!
	@IBOutlet weak var nextController: UIButton!
	
	enum ControllerNavigation: Int {
		case Previous, Next
	}
	
	var rolodexController: RolodexNavigationController? {
		get {
			if let controller = self.navigationController?.parentViewController as? RolodexNavigationController {
				return controller
			}
			return nil
		}
	}

	@IBAction func showRolodexTouched(sender: AnyObject) {
		self.rolodexController?.showRolodex = true;
	}
	
	@IBAction func goToController(sender: UIButton) {
		if let rolodexController = self.rolodexController {
			let button = ControllerNavigation(rawValue: sender.tag)
			var index = 0
			if let button = ControllerNavigation(rawValue: sender.tag) {
				switch button {
				case .Next:
					index = rolodexController.selectedIndex! + 1
				case .Previous:
					index = rolodexController.selectedIndex! - 1
				}
			}
			let viewController = rolodexController.viewControllers[index]
			rolodexController.goToViewController(viewController, animated: true)
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		var randomRed   = CGFloat(drand48())
		var randomGreen = CGFloat(drand48())
		var randomBlue  = CGFloat(drand48())
		self.view.backgroundColor = UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		self.previousController?.enabled = true
		self.previousController?.enabled = true
		if self.rolodexController?.viewControllers.first == self.navigationController {
			self.previousController?.enabled = false
		} else if self.rolodexController?.viewControllers.last == self.navigationController {
			self.nextController?.enabled = false
		}
	}

}
