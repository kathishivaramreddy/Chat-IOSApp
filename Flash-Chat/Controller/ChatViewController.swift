//
//  ChatViewController.swift
//  Flash-Chat
//
//  Created by apple on 4/11/19.
//  Copyright © 2019 shivaapple. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    var messageArray = [Message]()
    let messagesDB = Database.database().reference().child("Messages")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        messageTableView.delegate = self
        messageTableView.dataSource = self
        messageTextField.delegate = self
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)
        configureTableView()
        retrieveMessages()
        
        messageTableView.separatorStyle = .none
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    @IBAction func messageSendPressed(_ sender: UIButton) {
        messageTextField.endEditing(true)
        
        sendButton.isEnabled = false
        
        //database for messages
        let messageDictionary = ["Sender": Auth.auth().currentUser?.email,"MessageBody":messageTextField.text!]
        
        messagesDB.childByAutoId().setValue(messageDictionary) {
            (error, reference ) in
            if error != nil {
                print(error!)
            }else{
                print("message save succesfully")
                self.sendButton.isEnabled = true
                self.messageTextField.text = ""
            }
        }
    }
    
    func retrieveMessages() {
        messagesDB.observe(.childAdded) {
            snapshot in
            let snapshotValue = snapshot.value as! Dictionary<String,String>
            let message = Message()
            message.messageBody = snapshotValue["MessageBody"]!
            message.sender = snapshotValue["Sender"]!
            print(message.messageBody)
            print(message.sender)
            self.messageArray.append(message)
            self.configureTableView()
            self.messageTableView.reloadData()
        }
    }
    
    @IBAction func logOutPressed(_ sender: Any) {
        do{
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        }
        catch{
            print("error")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].sender
        cell.avatarImageView.image = UIImage(named: "egg")
        
        if cell.senderUsername.text ==  Auth.auth().currentUser?.email as String? {
            cell.avatarImageView.backgroundColor = UIColor.flatMint()
            cell.messageBody.backgroundColor = UIColor.flatSkyBlue()
        }else{
            cell.avatarImageView.backgroundColor = UIColor.flatWatermelon()
            cell.messageBody.backgroundColor = UIColor.flatGray()
        }
        return cell
    }
    
    func configureTableView() {
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
       
        UIView.animate(withDuration: 0.5){
            self.heightConstraint.constant = 338
            self.view.layoutIfNeeded()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5){
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func tableViewTapped() {
        messageTextField.endEditing(true)
    }
    
}
