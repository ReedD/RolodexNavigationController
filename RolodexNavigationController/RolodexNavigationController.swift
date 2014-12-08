//
//  RolodexNavigationController.swift
//  RolodexNavigationController
//
//  Created by Reed Dadoune on 12/6/14.
//  Copyright (c) 2014 Dadoune. All rights reserved.
//

import UIKit
import Dollar

class RolodexNavigationController: UIViewController {

	@IBOutlet weak var scrollView: UIScrollView!
	
	private var viewTaps = [UIView: UIGestureRecognizer]()
	
	private var _showRolodex = false
	var showRolodex: Bool {
		set {
			if _showRolodex == newValue {
				return
			}
			_showRolodex = newValue
			self.scrollView.scrollEnabled = newValue
			self.scrollView.setContentOffset(self.scrollView.contentOffset, animated: false)
			for controller in self.viewControllers {
				if (_showRolodex) {
					let tapGesture = UITapGestureRecognizer(target: self, action: Selector("handleSingleTap:"))
					controller.view.addGestureRecognizer(tapGesture)
					self.viewTaps[controller.view] = tapGesture
				} else {
					controller.view.removeGestureRecognizer(self.viewTaps[controller.view]!)
					self.viewTaps.removeValueForKey(controller.view)
				}
				
				UIView.animateWithDuration(0.2, animations: {
					self.placeViewController(controller)
				})
			}
			if let controller = self.viewControllers.last   {
				if _showRolodex {
					self.scrollView.contentSize = CGSizeMake(self.view.frame.width, controller.view.frame.maxY)
				}
			}
		}
		get {
			return _showRolodex
		}
	}
	
	private var _viewControllers: [UIViewController]?
	var viewControllers: [UIViewController] {
		get {
			if let viewControllers = self._viewControllers {
				return viewControllers
			}
			var viewControllers: [UIViewController] = []
			for controller in self.childViewControllers {
				if controller.isKindOfClass(UIViewController) {
					viewControllers.append(controller as UIViewController)
				}
			}
			self._viewControllers = viewControllers
			return viewControllers
		}
	}
	
	private var _selectedController: UIViewController!
	var selectedController: UIViewController? {
		get {
			return _selectedController
		}
		set {
			if (newValue != _selectedController) {
				self._selectedController = newValue
				if let controller = newValue {
					if (!$.contains(self.viewControllers, value: controller)) {
							self.addChildViewController(controller)
					}
					self.selectedIndex = $.indexOf(self.viewControllers, value: controller)
				} else {
					self.selectedIndex = nil
				}
			}
		}
	}
	
	private var _selectedIndex: Int?
	var selectedIndex: Int? {
		get {
			return self._selectedIndex
		}
		set {
			self._selectedIndex = newValue
			if let index = newValue {
				if self.viewControllers[index] != self.selectedController {
					self.selectedController = self.viewControllers[index]
				}
			} else {
				if let controller = self.selectedController {
					self.selectedController = nil
				}
			}
		}
	}
	
	func handleSingleTap (recognizer: UITapGestureRecognizer) {
		if !self.showRolodex {
			return
		}
		let location = recognizer.locationInView(recognizer.view?.superview)
		if let view = recognizer.view {
			for controller in self.viewControllers {
				if (view == controller.view) {
					self.selectedController = controller
					self.showRolodex = false
					break
				}
			}
		}
	}
	
	private func placeViewController (viewController: UIViewController) {
		let index = CGFloat($.indexOf(self.viewControllers, value: viewController)!);
		let topPadding = CGFloat(150) // The amout of space above self.viewControllers[0]
		viewController.view.layer.zPosition = index * 1000
		if self.showRolodex  {
			var transform = CATransform3DIdentity;
			transform.m34 = 1.0 / 700;
			transform = CATransform3DRotate(transform, 55.0 * CGFloat(M_PI) / 180.0, 1.0, 0.0, 0.0)
			transform = CATransform3DScale(transform, 0.68, 0.68, 0.68)
			viewController.view.frame.origin.y = index * 100 - topPadding
			viewController.view.layer.transform = transform
		} else {
			let index = $.indexOf(self.viewControllers, value: viewController)
			let yOffset = self.scrollView.contentOffset.y
			viewController.view.layer.transform = CATransform3DIdentity
			if index > self.selectedIndex {
				viewController.view.frame.origin.y = yOffset + self.scrollView.frame.height
			} else if (index > self.selectedIndex) {
				viewController.view.frame.origin.y = yOffset - viewController.view.frame.height
			} else {
				viewController.view.frame.origin.y = yOffset
			}
			
		}
	}
	
	func addStoryboard(storyboard: UIStoryboard) {
		let initialController:AnyObject = storyboard.instantiateInitialViewController()
		if initialController.isKindOfClass(UIViewController) {
			self.addChildViewController(initialController as UIViewController)
		}
	}

	override func addChildViewController(childController: UIViewController) {
		super.addChildViewController(childController)
		childController.didMoveToParentViewController(self)
		
		let view = childController.view
		let layer = view.layer;
		
		// Test code
		layer.borderColor = UIColor.redColor().CGColor
		layer.borderWidth = 3
		// End test code
		
		self.scrollView.addSubview(view)
		self._viewControllers = nil;
		if self.selectedController == nil {
			self.selectedController = childController
		}
		self.placeViewController(childController)
		
		self.scrollView.contentSize = CGSizeMake(self.view.frame.width, childController.view.frame.maxY)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		// Test code
		for index in 1...10 {
			let storyboard = UIStoryboard(name: "StoryboardA", bundle:nil)
			self.addStoryboard(storyboard)
		}
		// End test code
	}

}

