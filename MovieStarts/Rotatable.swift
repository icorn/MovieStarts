import UIKit


/*
 This is an update to an example found on
 http://www.jairobjunior.com/blog/2016/03/05/how-to-rotate-only-one-view-controller-to-landscape-in-ios-slash-swift/
 
 The code there works, with some updating to the latest Swift, but the pattern isn't very Swifty.
 The following is what I found to be more helpful.

 First, create a protocol that UIViewController's can conform to.
 This is in opposition to using `Selector()` and checking for the presence of an empty function.
*/

/// UIViewControllers adopting this protocol will automatically be opted into rotating to all but bottom rotation.
///
/// - Important:
/// You must call resetToPortrait as the view controller is removed from view. Example:
///
/// ```
/// override func viewWillDisappear(_ animated: Bool) {
///   super.viewWillDisappear(animated)
///
///   if isMovingFromParentViewController {
///     resetToPortrait()
///   }
/// }
/// ```
protocol Rotatable: AnyObject
{
    func resetToPortrait()
}

extension Rotatable where Self: UIViewController
{
    func resetToPortrait()
    {
        UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
    }
}
