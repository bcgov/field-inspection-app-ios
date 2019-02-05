//
//  LoginController.swift
//  EAO
//
//  Created by Micha Volin on 2017-04-07.
//  Copyright © 2017 FreshWorks. All rights reserved.
//
import Parse
import Alamofire

// This enum represents errors that might occur during log in
enum LoginError: Error {
    case noUsername
    case noPassword
    var message: String {
        switch self {
        case .noUsername:
            return "Please enter registered username"
        case .noPassword:
            return "Please enter password"
        }
    }
}

// MARK: -
final class LoginController: UIViewController {
    
    @IBOutlet fileprivate var usernameField: UITextField!
    @IBOutlet fileprivate var passwordField: UITextField!
    @IBOutlet fileprivate var scrollView: UIScrollView!
    @IBOutlet fileprivate var indicator: UIActivityIndicatorView!
    @IBOutlet weak var loginButton: UIButton!
    
    static let segueShowInspector = "showInspector"
    
    // MARK: Initialization
    override func viewDidLoad() {
        style()
        addDismissKeyboardOnTapRecognizer(on: scrollView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        presentMainScreen()
    }
    
    func style() {
        self.loginButton.layer.cornerRadius = 5
        self.loginButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.loginButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        self.loginButton.layer.shadowOpacity = 0.7
        self.loginButton.layer.shadowRadius = 4
    }

    @IBAction fileprivate func loginTapped(_ sender: UIButton) {
        do {
            let credentials = try validateCredentials()
            
            guard Reachability.isConnectedToNetwork() else {
                presentAlert(controller: UIAlertController.noInternet)
                return
            }
            
            sender.isEnabled = false
            indicator.startAnimating()
            
            PFUser.logInWithUsername(inBackground: credentials.0, password: credentials.1) { (user, error) in
                guard let _ = user, error == nil else {
                    let code = (error! as NSError).code
                    switch code {
                    case 101:
                        self.presentAlert(title: "Couldn't log in", message: "Entered credentials are not valid")
                    default:
                        self.presentAlert(title: "Couldn't log in", message: "Error code is \(code)")
                    }
                    
                    sender.isEnabled = true
                    self.indicator.stopAnimating()
                    return
                }
                
                DataServices.isUserMobileAccessEnabled(completion: { (enabled) in
                    if enabled {
                        let user: User =  PFUser.current() as! User
                        DataServices.getUserTeams(user: user, completion: { (done, downloaded) in
                            print("ended \(done)")
                        })
                        
                        DataServices.shared.reloadReferenceData(completion: { (_) in
                            self.showInspectionsController()
                            sender.isEnabled = true
                        })
                    } else {
                        self.presentAlert(title: "Couldn't log in", message: "Mobile access is disabled")
                        PFUser.logOut()
                        self.indicator.stopAnimating()
                        sender.isEnabled = true
                    }
                })
                
                DataServices.shared.reloadReferenceData(completion: { (_) in
                    self.showInspectionsController()
                    sender.isEnabled = true
                })
            }
        } catch {
            self.presentAlert(title: "Couldn't log in", message: (error as? LoginError)?.message)
        }
    }
    
    @IBAction fileprivate func forgotPasswordTapped(_ sender: UIButton) {
        presentAlert(title: "Please contact Geoff McDonald to change your user credentials.", message: nil)
    }
    
    @objc func presentMainScreen() {
        
        guard let _ = PFUser.current() else {
            return
        }
        
        indicator.startAnimating()
        DataServices.shared.reloadReferenceData { (_) in }
        
        showInspectionsController()
    }
    
    fileprivate func clearTextFields() {
        self.usernameField.text = ""
        self.passwordField.text = ""
    }
    
    // MARK: - Validation
    ///Return: (Username, Password)
    func validateCredentials() throws -> (String,String) {
        guard let username = usernameField.text?.trimWhiteSpace(), !username.isEmpty() else {
            throw LoginError.noUsername
        }
        
        guard let password = passwordField.text?.trimWhiteSpace(), !password.isEmpty() else {
            throw LoginError.noPassword
        }
        return (username, password)
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return true
    }
    
    private func showInspectionsController() {
        self.clearTextFields()
        self.indicator.stopAnimating()
        self.performSegue(withIdentifier: LoginController.segueShowInspector, sender: nil)
    }
}

