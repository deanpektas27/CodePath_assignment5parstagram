//
//  FeedViewController.swift
//  CodePath_assignment5parstagram
//
//  Created by Dean Pektas on 3/24/19.
//  Copyright © 2019 Dean Pektas. All rights reserved.
//

import UIKit
import Parse
import AlamofireImage
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {

    //@IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableView: UITableView!
    let commentBar = MessageInputBar()
    var showsCommentBar = false
    
    var posts = [PFObject]()
    var selectedPost: PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        commentBar.inputTextView.placeholder = "Add a comment..."
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.keyboardDismissMode = .interactive
        // Do any additional setup after loading the view.
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillBeHidden(note: Notification) {
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
    }
    
    override var inputAccessoryView: UIView? {
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool {
        return showsCommentBar
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated) //pulls in post that was just posted
        
        let query = PFQuery(className:"Posts")
        query.includeKeys(["author", "comments", "comments.author"])
        query.limit = 20
        
        query.findObjectsInBackground { (posts, error) in
            if posts != nil { //if able to find stuff
                self.posts = posts!//stores post data
                self.tableView.reloadData()//reloads data so it can be shown
                
            }
        }
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        //create the comment
        let comment = PFObject(className: "Comments")
        comment["text"] = text
        comment["post"] = selectedPost
        comment["author"] = PFUser.current()!
        
        selectedPost.add(comment, forKey: "comments")
        
        selectedPost.saveInBackground { (success, error) in
            if success {
                print("Comment saved")
            } else {
                print("Error saving comment")
            }
        }
        
        tableView.reloadData()
        
        //clear and dismiss the input bar
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //want to return number of comments + 1, one for post row caption and one for each comment
        let post = posts[section]//first, must get posts and comments
        let comments = (post["comments"] as? [PFObject]) ?? [] //if the left side of the ?? is equal to nil (empty) then set the def value to whats in the square brackets on the right side
        
        return comments.count + 2
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count//there are as many sections as there are posts, put each post into a section. then refer to above func
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell

            let user = post["author"] as! PFUser
            cell.usernameLabel.text = user.username
            
            cell.captionLabel.text = post["caption"] as! String
            
            let imageFile = post["image"] as! PFFileObject
            let urlString = imageFile.url!
            let url = URL(string: urlString)!
            
            cell.photoView.af_setImage(withURL: url)
            
            return cell
        } else if indexPath.row <= comments.count {
            let cell  = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            
            
            let comment = comments[indexPath.row - 1]
            cell.commentLabel.text = comment["text"] as? String
            
            let user = comment["author"] as! PFUser
            cell.nameLabel.text = user.username
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            //11:40 mark on 6th youtube video WHAT IS THIS ERROR
            
            return cell
        }
    }
    
    @IBAction func onLogoutButton(_ sender: Any) {
        PFUser.logOut()//clears pfuser cache so user becomes nil
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")//creates var with instance of login view controller (main screen)
        
        let delegate = UIApplication.shared.delegate as! AppDelegate //allows access to the shared delegate in appdelegate
        
        delegate.window?.rootViewController = loginViewController//uses the shared delegate to change current view controller to login once logged out
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {//every time row is selected we plan on making something happen (making a comment)
        let post = posts[indexPath.section]//need to have the ability to choose a post to make a comment with
        let comments = (post["comments"] as? [PFObject]) ?? []//creating comments table in database
     
        if indexPath.row == comments.count + 1 {
            showsCommentBar = true
            becomeFirstResponder()
            commentBar.inputTextView.becomeFirstResponder()
            
            selectedPost = post
            
        }
        
        
//code for fake comments
//        comment["text"] = "Test comment heyhey"
//        comment["post"] = post//want to know which post the comment belongs to
//        comment["author"] = PFUser.current()!//the person who created the comment is the currently logged in user
//
//        post.add(comment, forKey: "comments")//creates array called comments and is adding the comment object into it
//
//        post.saveInBackground { (success, error) in
//            if success {
//                print("comment saved")
//            } else {
//                print("error saving comment")
//            }
//        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
