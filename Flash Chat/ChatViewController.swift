//
//  ViewController.swift
//  Flash Chat
//
//  Created by Angela Yu on 29/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import ChameleonFramework

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // Declare instance variables here
    var messageArray: [Message] = [Message]()
    
    // We've pre-linked the IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set yourself as the delegate and datasource here:
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        //Set yourself as the delegate of the text field here:
        messageTextfield.delegate = self
        
        //Set the tapGesture here:
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)
        
        //Register your MessageCell.xib file here:
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell") //Register A with B ==》 用B注册A
        
        //Adjust the height of cells in the tableView
        configureTableView()
        
        //Retrieve messages from Firebase
        retrieveMessages()
        
        //Set the style of the table view (eliminate the line between the cells)
        messageTableView.separatorStyle = .none
    }
    
    //////////////////////////////////////////////////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods
    
    //Declare cellForRowAtIndexPath here:
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].sender
        cell.avatarImageView.image = UIImage(named: "egg")
        
        if cell.senderUsername.text == Auth.auth().currentUser?.email as String! {
            cell.messageBackground.backgroundColor = UIColor.flatSkyBlue()
            cell.avatarImageView.backgroundColor = UIColor.flatMint()
        } else {
            cell.messageBackground.backgroundColor = UIColor.flatGray()
            cell.avatarImageView.backgroundColor = UIColor.flatWatermelon()
        }
        
        return cell
    }
    
    //Declare numberOfRowsInSection here:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    //Declare tableViewTapped here:
    @objc func tableViewTapped() -> Void {
        messageTextfield.endEditing(true)
    }
    
    //Declare configureTableView here:
    func configureTableView() -> Void {
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }
    
    //////////////////////////////////////////////////////////////////////////////////////
    
    //MARK:- TextField Delegate Methods
    
    //Declare textFieldDidBeginEditing here:
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
    }

    //Declare textFieldDidEndEditing here:
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.4) {
            self.heightConstraint.constant = 50.0
            self.view.layoutIfNeeded()
        }
    }
    
    //Get Keyboard Height and Animation When Keyboard Shows Up
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            //iPhone X has Safe Area Insets
            if #available(iOS 11.0, *) {
                heightConstraint.constant = keyboardHeight - view.safeAreaInsets.bottom + 50
            } else {
                // Fallback on earlier versions
                heightConstraint.constant = keyboardHeight + 50
            }
            view.layoutIfNeeded()
        }
        
    }
    
    //////////////////////////////////////////////////////////////////////////////////////
    
    //MARK: - Send & Recieve from Firebase
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        
        //Dismiss the keyboard
        messageTextfield.endEditing(true)
        
        //Send the message to Firebase and save it in our database
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        
        let messageDB = Database.database().reference().child("Messages")
        let messageDictionary = ["Sender": Auth.auth().currentUser?.email, "MessageBody": messageTextfield.text]
        
        messageDB.childByAutoId().setValue(messageDictionary) {
            (error, reference) in
            
            if error != nil {
                print(error!)
            } else {
                print("\nSuccessfully uploaded the message...\n")
                
                self.messageTextfield.isEnabled = true
                self.sendButton.isEnabled = true
                self.messageTextfield.text = ""
            }
        }
    }
    
    //TODO: Create the retrieveMessages method here:
    func retrieveMessages() -> Void {
        
        let messageDB = Database.database().reference().child("Messages")
        messageDB.observe(.childAdded) { (snapshot) in
            
            let snapshotValue = snapshot.value as! Dictionary<String,String>
            
            let text = snapshotValue["MessageBody"]!
            let sender = snapshotValue["Sender"]!
            
            //print(text, sender)
            
            //Cast the values into a Message object
            let newMessage = Message()
            newMessage.messageBody = text
            newMessage.sender = sender
            
            //Add the new data into messageArray
            self.messageArray.append(newMessage)
            
            //Reset the configuration of the cells (Height may change)
            self.configureTableView()
            
            //Table view should reload the data
            self.messageTableView.reloadData()
        }
    }
    
    
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        //Log out the user and send them back to WelcomeViewController
        do {
           try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true) //Go back to the root screen...
        } catch {
            print("\nSomething wrong with the network...")
        }
    }
}




