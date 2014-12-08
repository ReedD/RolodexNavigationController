//
//  ChildViewController.swift
//  RolodexNavigationController
//
//  Created by Reed Dadoune on 12/7/14.
//  Copyright (c) 2014 Dadoune. All rights reserved.
//

import UIKit

class ChildViewController: UIViewController {

	@IBAction func showRolodexTouched(sender: AnyObject) {
		if let navigationController = self.navigationController {
			if let viewController = navigationController.parentViewController {
				var rolodexContoller = viewController as RolodexNavigationController
				rolodexContoller.showRolodex = true;
			}
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
