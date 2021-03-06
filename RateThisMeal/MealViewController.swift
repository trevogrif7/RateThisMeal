//
//  MealViewController.swift
//  RateThisMeal
//
//  Created by Trevor Griffin on 2/7/16.
//  Copyright © 2016 TREVOR E GRIFFIN. All rights reserved.
//

import UIKit
import MobileCoreServices

class MealViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {

    
    // MARK: Properties
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var commentTextView: UITextView!
    
    // This value is either passed by `MealTableViewController` in `prepareForSegue(_:sender:)`
    // or constructed as part of adding a new meal.
    var meal: Meal?
    
    // MARK: Types    
    enum ImageCaptureType: Int {
        case Camera
        case PhotoLibrary
        case SavedPhotosAlbum
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Sign up to be notified when the keyboard is displayed
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil)

        // Add done button to keyboard
        self.addDoneButtonOnKeyboard()
        
        // Add border to UITextView
        commentTextView.layer.borderColor = UIColor(red: 0.79, green: 0.79, blue: 0.79, alpha: 1.0).CGColor
        commentTextView.layer.borderWidth = 0.5
        commentTextView.layer.cornerRadius = 5
        
        // Handle the text field’s user input through delegate callbacks.
        nameTextField.delegate = self
        

        // Handle the text field’s user input through delegate callbacks.
        commentTextView.delegate = self
        
        // Set up views if editing an existing Meal.
        if let meal = meal {
            navigationItem.title = meal.name
            nameTextField.text   = meal.name
            photoImageView.image = meal.photo
            ratingControl.rating = meal.rating
            commentTextView.text = meal.comment
        }
        
        // Enable the Save button only if the text field has a valid Meal name.
        checkValidMealName()
    }

    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: self.view.window)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: self.view.window)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Keyboard handling
    func keyboardWillShow(sender: NSNotification) {

        // Only shift keyboard for comment text view
        if commentTextView.isFirstResponder() {

            let userInfo: [NSObject : AnyObject] = sender.userInfo!
            let keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
            let offset: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue.size
        
            if keyboardSize.height == offset.height {
                if self.view.frame.origin.y == 0 {
                    UIView.animateWithDuration(0.1, animations: { () -> Void in self.view.frame.origin.y -= keyboardSize.height})}
            } else {
                UIView.animateWithDuration(0.1, animations: { () -> Void in
                    self.view.frame.origin.y += keyboardSize.height - offset.height})
            }
        }
    }
    
    func keyboardWillHide(sender: NSNotification) {
        // Only shift keyboard for comment text view
        if commentTextView.isFirstResponder() {

            let userInfo: [NSObject : AnyObject] = sender.userInfo!
            let keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
            self.view.frame.origin.y += keyboardSize.height
        }
    }

    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 50))
        doneToolbar.barStyle = UIBarStyle.Default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: Selector("doneButtonAction"))
        
        var items: [AnyObject] = []
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items as? [UIBarButtonItem]
        doneToolbar.sizeToFit()
        
        self.commentTextView.inputAccessoryView = doneToolbar
        
    }
    
    func doneButtonAction()
    {
        self.commentTextView.resignFirstResponder()
    }
    
    // MARK: UITextViewDelegate
//    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
//        if(text == "\n") {
//            textView.resignFirstResponder()
//            return false
//        }
//        return true
//    }

    // MARK: UITextFieldDelegate
    func textFieldDidBeginEditing(textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.enabled = false
    }
    
    func checkValidMealName() {
        // Disable the Save button if the text field is empty.
        let text = nameTextField.text ?? ""
        saveButton.enabled = !text.isEmpty
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Close keyboard
        nameTextField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        checkValidMealName()
        navigationItem.title = textField.text
    }

    // MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // The info dictionary contains multiple representations of the image, and this uses the original.
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // Set photoImageView to display the selected image.
        photoImageView.image = selectedImage
        
        // Dismiss the picker.
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Navigation
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        let isPresentingInAddMealMode = presentingViewController is UINavigationController
        
        if isPresentingInAddMealMode {
            dismissViewControllerAnimated(true, completion: nil)
        }
        else {
            navigationController!.popViewControllerAnimated(true)
        }
    }
    
    // This method lets you configure a view controller before it's presented.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if saveButton === sender {
            let name = nameTextField.text ?? ""
            let photo = photoImageView.image
            let rating = ratingControl.rating
            let comment = commentTextView.text ?? ""
            
            // Set the meal to be passed to MealTableViewController after the unwind segue.
            meal = Meal(name: name, photo: photo, rating: rating, comment: comment)
        }
    }

    
    // MARK: Actions
    @IBAction func selectImageFromPhotoLibrary(sender: UITapGestureRecognizer) {
        // Hide the keyboard.
        nameTextField.resignFirstResponder()
        

        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) &&
            !(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)) {
                
                captureImage(ImageCaptureType.Camera)
                
        } else if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) &&
            !(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
                
                captureImage(ImageCaptureType.PhotoLibrary)
                
        } else if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) &&
            UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
                
                let alertController = UIAlertController(title: "Please Select", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
                
                let libraryAction = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.Default, handler: {UIAlertAction in self.captureImage(ImageCaptureType.PhotoLibrary)})
                let cameraAction = UIAlertAction(title: "Take Photo", style: UIAlertActionStyle.Default, handler: {UIAlertAction in self.captureImage(ImageCaptureType.Camera)})
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
                
                alertController.addAction(libraryAction)
                alertController.addAction(cameraAction)
                alertController.addAction(cancelAction)
                
                self.presentViewController(alertController, animated: true, completion: nil)
                
        } else {
            let alertController = UIAlertController(title: "Alert", message: "Your device does not support the camera or photo library", preferredStyle: UIAlertControllerStyle.Alert)
            
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }

    }
    
    // MARK: Helper Functions
    func captureImage(captureimage: ImageCaptureType) {
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()

        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self

        switch captureimage {
        case .Camera:
            // Select Camera as the source
            imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
            
        case .PhotoLibrary:
            // Select Camera as the source
            imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        case .SavedPhotosAlbum:
            // Select Camera as the source
            imagePickerController.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
        }

        imagePickerController.mediaTypes = [kUTTypeImage as String]
        imagePickerController.allowsEditing = true
        self.presentViewController(imagePickerController, animated: true, completion: nil)
        
    }
    
}

