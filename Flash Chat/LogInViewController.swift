//
//  LogInViewController.swift
//  Flash Chat
//
//  This is the view controller where users login


import UIKit
import Firebase
import SVProgressHUD

class LogInViewController: UIViewController {

    //Textfields pre-linked with IBOutlets
    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextfield.text = "oscar@teng.com"
        passwordTextfield.text = "000000"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

   
    @IBAction func logInPressed(_ sender: AnyObject) {

        SVProgressHUD.show()   //Show a progress indicator
        
        Auth.auth().signIn(withEmail: emailTextfield.text!, password: passwordTextfield.text!) { (user, error) in   //Log in the user
            if error == nil {
                print("\nSuccessfully login...")
                SVProgressHUD.dismiss()   //Dismiss the progress indicator
                self.performSegue(withIdentifier: "goToChat", sender: self)
            } else {
                print("\nCannot login ==> \(error!)")
            }
        }
        
    }
    


    
}  
