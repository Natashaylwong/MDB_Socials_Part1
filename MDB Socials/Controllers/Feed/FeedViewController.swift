//
//  FeedViewController.swift
//  MDB Socials
//
//  Created by Natasha Wong on 2/20/18.
//  Copyright © 2018 Natasha Wong. All rights reserved.
//

import UIKit
import Firebase

class FeedViewController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
    }

    var newPostView: UITextField!
    var newPostButton: UIButton!
    var postCollectionView: UICollectionView!
    var posts: [Post] = []
    var auth = Auth.auth()
    var postsRef: DatabaseReference = Database.database().reference().child("Posts")
    var storage: StorageReference = Storage.storage().reference()
    var currentUser: Users?
    var navBar: UINavigationBar!
    
    
//    //For sample post
//    let samplePost = Post()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.startAnimating()
 //       posts.append(samplePost)
        self.setupNavBar()
//        self.setupNewPostView()
//        self.setupButton()
//        self.setupCollectionView()
        Users.getCurrentUser(withId: (Auth.auth().currentUser?.uid)!, block: {(cUser) in
            self.currentUser = cUser
        })
        FirebaseSocialAPIClient.fetchPosts(withBlock: { (posts) in
            self.posts.append(contentsOf: posts)
            print("the contents of posts are now... \(self.posts)")
            self.postCollectionView.reloadData()



//            activityIndicator.stopAnimating()

        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    func setupNavBar() {
        navigationController?.navigationBar.tintColor = UIColor.white;
        navigationController?.navigationBar.barTintColor = UIColor(red: 0.5882, green: 0.8157, blue: 0.9686, alpha: 1.0)
        let addButton = UIBarButtonItem(image: UIImage(named: "adds"), style: .plain, target: self, action: #selector(addButtonPressed))
        self.navigationItem.rightBarButtonItem  = addButton
        let logOutButton = UIBarButtonItem(image: UIImage(named: "logout"), style: .plain, target: self, action: #selector(FeedViewController.logOut))
        self.navigationItem.leftBarButtonItem  = logOutButton
        self.navigationItem.title = "MDB Socials: Feed"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "Strawberry Blossom", size: 40)]

    }
    @objc func addButtonPressed() {
        self.performSegue(withIdentifier: "toNewPost", sender: self)
    }
    @objc func logOut() {
        print("this thing was clicked on")
        UserAuthHelper.logOut {
            print("logged out")
            self.dismiss(animated: true, completion: nil)
            self.navigationController!.popToRootViewController(animated: true)
        }
    }


    
    func setupCollectionView() {
        let frame = CGRect(x: 10, y: newPostButton.frame.maxY + 10, width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.height - newPostButton.frame.maxY - 20)
        let cvLayout = UICollectionViewFlowLayout()
        postCollectionView = UICollectionView(frame: frame, collectionViewLayout: cvLayout)
        postCollectionView.delegate = self
        postCollectionView.dataSource = self
        postCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "post")

        postCollectionView.backgroundColor = UIColor.lightGray
        view.addSubview(postCollectionView)


    }
    
    @objc func addNewPost(sender: UIButton!) {
        self.performSegue(withIdentifier: "toNewPost", sender: self)
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension FeedViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = postCollectionView.dequeueReusableCell(withReuseIdentifier: "post", for: indexPath) as! PostCollectionViewCell
        cell.awakeFromNib()
        let postInQuestion = posts[indexPath.row]
        cell.postText.text = postInQuestion.text
        cell.posterText.text = postInQuestion.poster
        
        if indexPath.row == 0 {
            cell.profileImage.image = #imageLiteral(resourceName: "yeezy")
        }
        else {
            postInQuestion.getEventPic {
                cell.profileImage.image = postInQuestion.image
            }
        }
    
        return cell
    }

    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        return CGSize(width: postCollectionView.bounds.width - 20, height: 100)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width - 20, height: 200)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
    }
}




