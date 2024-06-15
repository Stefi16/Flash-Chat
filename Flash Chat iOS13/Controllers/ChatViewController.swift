import UIKit
import FirebaseAuth
import FirebaseFirestore

class ChatViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    var messages = [Message(sender: "1@2.com", body: "Hey"),Message(sender: "a@b.com", body: "Yello"),Message(sender: "1@2.com", body: "What's up")]
    
    
    let database = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        
        navigationItem.hidesBackButton = true
        navigationItem.title = K.appTitle
        
        loadMessages()
        
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        let message = messageTextfield.text
        
        if let email = Auth.auth().currentUser?.email, let safeMessage = message {
            let newMessage = Message(sender: email, body: safeMessage)
            database.collection(K.FStore.collectionName).addDocument(data: [K.FStore.senderField: newMessage.sender, K.FStore.bodyField: newMessage.body, K.FStore.dateField: Date().timeIntervalSince1970]) { error in
                if let er = error {
                    print(er)
                }
            }
        }
        
        messageTextfield.text = ""
    }
    
    @IBAction func logoutPressed(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    private func loadMessages() {
        database
            .collection(K.FStore.collectionName)
            .order(by: K.FStore.dateField)
            .addSnapshotListener { querySnapshot, err in
                self.messages = []
                
                if let error = err {
                    print(error)
                } else {
                    if let snapshotDoc = querySnapshot?.documents {
                        for doc in snapshotDoc {
                            let data = doc.data()
                            if let messageSender = data[K.FStore.senderField] as? String, let messageBody = data[K.FStore.bodyField] as? String {
                                let newMessage = Message(sender: messageSender, body: messageBody)
                                self.messages.append(newMessage)
                                
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                    
                                    let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                                    self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                                }
                            }
                        }
                    }
                }
            }
    }
    
}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
        cell.messageLabel?.text = message.body
        
        if message.sender == Auth.auth().currentUser?.email {
            cell.leftMessageImage.isHidden = true
            cell.rightMessageImage.isHidden = false
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.lightPurple)
            cell.messageLabel.textColor = UIColor(named: K.BrandColors.purple)
        } else {
            cell.leftMessageImage.isHidden = false
            cell.rightMessageImage.isHidden = true
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.purple)
            cell.messageLabel.textColor = UIColor(named: K.BrandColors.lightPurple)
        }
        
        return cell
    }
}

