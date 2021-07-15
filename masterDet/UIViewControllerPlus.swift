

import UIKit

extension UIViewController {
    
    //MARK:- Design, Style
    
    /// NavigationBar shadow
    func navigationBarStyler() {
        navigationController?.navigationBar.layer.masksToBounds = false
        navigationController?.navigationBar.layer.shadowColor = UIColor.lightGray.cgColor
        navigationController?.navigationBar.layer.shadowOpacity = 0.8
        navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        navigationController?.navigationBar.layer.shadowRadius = 2
    }
        
    func setBackgroundColor(colorTop: UIColor, colorBottom: UIColor) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop.cgColor, colorBottom.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at:0)
    }
    
    //MARK:- Navigation

    func setUPNavigationBarColor(isClearColor: Bool = false) {
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        if isClearColor {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            navigationController?.view.backgroundColor = UIColor.clear
        } else {
            navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        }
    }
    
    func push(_ controller: UIViewController, _ animated: Bool = true) {
        navigationController?.pushViewController(controller, animated: animated)
    }
    
    @objc func backButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
        
    // ... view controller to uiview
    func embed(_ viewController:UIViewController, inView view: UIView){
       viewController.willMove(toParent: self)
       viewController.view.frame = view.bounds
       view.addSubview(viewController.view)
       self.addChild(viewController)
       viewController.didMove(toParent: self)
    }

    
    
    //MARK:- Loading

    
    
    //MARK:- Toast & Alert

        
    func showToast(message : String) {
        let toastLabel = UILabel(frame: CGRect(x: 30, y: view.frame.size.height-100, width: UIScreen.main.bounds.width - 60, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        toastLabel.layer.position.y = UIScreen.main.bounds.size.height - 150
        view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.5, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in

        }))
        present(alert, animated: true, completion: nil)
    }
    
    func showWarningAlert(title: String, message: String) -> Void {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
        
    }

}


extension DispatchQueue {

    static func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }
}

