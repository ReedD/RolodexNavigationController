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
	
	/// Dictionary to save tap gestures
	private var viewTaps = [UIView: UIGestureRecognizer]()
	
	/// Transition speed between tabs
	private var animationSpeed = 0.3
	
	private var _showRolodex = false
	/// The presentation mode of the rolodex
	var showRolodex: Bool {
		set {
			// If we're setting to the same value then ignore
			if self._showRolodex == newValue {
				return
			}
			self._showRolodex = newValue
			// Stop and disable scrolling
			self.scrollView.scrollEnabled = newValue
			self.scrollView.setContentOffset(self.scrollView.contentOffset, animated: false)
			for controller in self.viewControllers {
				if (self._showRolodex) {
					// Add tap gesture and store in dictionary
					let tapGesture = UITapGestureRecognizer(target: self, action: Selector("handleSingleTap:"))
					controller.view.addGestureRecognizer(tapGesture)
					self.viewTaps[controller.view] = tapGesture
				} else {
					// Remove tap gesture and clean up dictionary
					if let gesture = self.viewTaps[controller.view] {
						controller.view.removeGestureRecognizer(gesture)
						self.viewTaps.removeValueForKey(controller.view)
					}
				}
				
				// Animate controller to it's new placement
				UIView.animateWithDuration(self.animationSpeed, animations: {
					self.placeViewController(controller)
				})
			}
			if let controller = self.viewControllers.last   {
				if self._showRolodex {
					// Adjust content size
					let height = controller.view.frame.maxY - controller.view.frame.height / 2;
					self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: height)
				}
			}
		}
		get {
			return self._showRolodex
		}
	}
	
	private var _viewControllers: [UIViewController]?
	/// An array of all the child UIViewControllers
	var viewControllers: [UIViewController] {
		get {
			// If we've already cached our view controllers
			// then return it. _viewControllers is reset on
			// addChildViewController(childController:)
			if let viewControllers = self._viewControllers {
				return viewControllers
			}
			// Build array of UIViewControllers and cache
			var viewControllers: [UIViewController] = []
			for controller in self.childViewControllers {
				if controller is UIViewController {
					viewControllers.append(controller as UIViewController)
				}
			}
			self._viewControllers = viewControllers
			return viewControllers
		}
	}
	
	private var _selectedController: UIViewController!
	/// The selected UIViewController of the rolodex
	var selectedController: UIViewController? {
		get {
			return _selectedController
		}
		set {
			if (newValue != _selectedController) {
				self._selectedController = newValue
				if let controller = newValue {
					// Add the selected controller isn't in our view controllers
					if (!$.contains(self.viewControllers, value: controller)) {
							self.addChildViewController(controller)
					}
					// Set the selected index
					self.selectedIndex = $.indexOf(self.viewControllers, value: controller)
				} else {
					self.selectedIndex = nil
				}
			}
		}
	}
	
	private var _selectedIndex: Int?
	/// The selected index of the rolodex
	var selectedIndex: Int? {
		get {
			return self._selectedIndex
		}
		set {
			self._selectedIndex = newValue
			if let index = newValue {
				// Ensure that if the controller at the selected index doesn't
				// match the currently selected controller that it's set properly
				if self.viewControllers[index] != self.selectedController {
					self.selectedController = self.viewControllers[index]
				}
			} else {
				// Unset selected controller
				if let controller = self.selectedController {
					self.selectedController = nil
				}
			}
		}
	}
	
	/// Handles a tap on a childController view
	///
	/// :param UITapGestureRecognizer representing the tap
	/// :return nil
	func handleSingleTap(recognizer: UITapGestureRecognizer) {
		// Determine selected controller
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
	
	/// Places a controller view in the scroll view based on presentation mode
	///
	/// :param UIViewController a controller to place
	/// :return nil
	private func placeViewController(viewController: UIViewController) {
		// Get the index of the controller we're placing
		let index = $.indexOf(self.viewControllers, value: viewController)!
		// The amout of space above self.viewControllers[0]
		let topPadding: CGFloat = 150
		viewController.view.layer.zPosition = CGFloat(index) * 1000
		if self.showRolodex  {
			// 3D Transform
			var transform = CATransform3DIdentity;
			transform.m34 = 1.0 / 700;
			transform = CATransform3DRotate(transform, 55.0 * CGFloat(M_PI) / 180.0, 1.0, 0.0, 0.0)
			transform = CATransform3DScale(transform, 0.68, 0.68, 0.68)
			viewController.view.frame.origin.y = CGFloat(index) * 100 - topPadding
			viewController.view.layer.transform = transform

			// Add shadow
			let shadowPath = UIBezierPath(rect: viewController.view.bounds)
			viewController.view.layer.masksToBounds = false
			viewController.view.layer.shadowColor = UIColor.blackColor().CGColor
			viewController.view.layer.shadowOffset = CGSize(width:0.0, height:-20.0)
			viewController.view.layer.shadowRadius = 20.0
			viewController.view.layer.shadowOpacity = 0.5
			viewController.view.layer.shadowPath = shadowPath.CGPath
		} else {
			// Hide shadow
			viewController.view.layer.shadowOpacity = 0.0
			// Slide views of lesser index up and greater down
			// Focus in on the selected index
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
	
	/// Navigate to another controller
	///
	/// :param UIViewController to navigate to
	/// :param Bool animate to new controller
	/// :return nil
	func goToViewController(viewController: UIViewController, animated: Bool) {
		if self.showRolodex {
			self.selectedController = viewController
			self.showRolodex = false
		} else {
			self._showRolodex = animated
			for controller in self.viewControllers {
				// Animate controller to it's new placement
				if (animated) {
					UIView.animateWithDuration(self.animationSpeed, animations: {
						self.placeViewController(controller)
						self.scrollView.scrollRectToVisible(viewController.view.frame, animated: false);
					}, completion: { (complete) -> Void in
							self.selectedController = viewController
							self.showRolodex = false
					})
				} else {
					self.selectedController = viewController
					self.placeViewController(controller)
				}
			}
		}
	}
	
	/// Add the initial controller of a UIStoryboard to the rolodex
	///
	/// :param UIStoryboard a storyboard to add
	/// :return nil
	func addStoryboard(storyboard: UIStoryboard) {
		let initialController: AnyObject = storyboard.instantiateInitialViewController()
		if let controller = initialController as? UIViewController {
			self.addChildViewController(controller)
		}
	}

	/// Add a UIViewController to the rolodex.
	///
	/// :param UIViewController a controller to add
	/// :return nil
	override func addChildViewController(childController: UIViewController) {
		// Properly set the UIViewController hierarchy
		super.addChildViewController(childController)
		childController.didMoveToParentViewController(self)
		self.scrollView.addSubview(childController.view)
		
		// Reset internal _viewControllers array
		self._viewControllers = nil;
		
		// If no selected controller select this first one inserted
		if self.selectedController == nil {
			self.selectedController = childController
		}
		
		// Place controller properly into the scrollView
		self.placeViewController(childController)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		/// FIXME:
		// Test code
		for index in 1...10 {
			let storyboard = UIStoryboard(name: "StoryboardA", bundle: nil)
			self.addStoryboard(storyboard)
		}
	}

}

