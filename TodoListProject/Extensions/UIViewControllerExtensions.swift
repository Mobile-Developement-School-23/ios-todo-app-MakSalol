import UIKit

extension UIViewController {
    func setupKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapOutsideOfKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func didTapOutsideOfKeyboard() {
        view.endEditing(true)
    }
}
