//
//  ImageCollectionViewController.swift
//  Tagsy
//
//  Created by Denis M on 2020-03-09.
//  Copyright © 2020 Denis M. All rights reserved.
//

import UIKit
var imageLoaderViewController: ImageLoaderViewController?

private let reuseIdentifier = "imageCell"
var uploadedImages: [UploadedImage] = []
let imagePicker = UIImagePickerController()
var selectedRow: Int = 0

class ImageCollectionViewController: UICollectionViewController {
  
  @IBAction func tappedPlusButton(_ sender: UIBarButtonItem) {
    imagePicker.sourceType = .photoLibrary
    present(imagePicker, animated: true, completion: nil)
  }
  
  override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    
        imagePicker.delegate = self

        // Do any additional setup after loading the view.
    }

    // MARK: - Navigation

    // MARK: UICollectionViewDataSource

    // Showing the Image Collection
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    // Showing the Image Collection
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return uploadedImages.count
    }
    // Showing the Image Collection
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)

        let imageview: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100));
        imageview.image = uploadedImages[indexPath.row].image

        cell.contentView.addSubview(imageview)

        return cell
    }
  
  // Showing the Image Detail
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      selectedRow = indexPath.row

      performSegue(withIdentifier: "showImageDetail", sender: self)
  }
  
  
    // we  pass the image to our ImageLoaderViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // check if we are segueing to the image detail or the image loader
        // and if we are, get a reference
        guard let imageDetailVC = segue.destination as? ImageDetailViewController else {
            // our segue is technically to the ImageLoaderViewController's navigation controller
            // so we need to check for that first and then access the image loader
            // through the navigation controller's topViewController property
            guard let imageLoaderNC = segue.destination as? UINavigationController,
                  let imageLoaderVC = imageLoaderNC.topViewController as? ImageLoaderViewController else {
                return
            }

            // set up the ImageLoaderViewController with the data it needs
            // prior to segueing
            imageLoaderViewController = imageLoaderVC
            imageLoaderViewController?.delegate = self
            imageLoaderVC.uploadedImage = uploadedImages.last
            return
        }

        imageDetailVC.uploadedImage = uploadedImages[selectedRow]
    }
  

    // MARK: UICollectionViewDelegate

}

extension ImageCollectionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // this method is called when the user has selected an image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        // get the image that the user selected
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            // create an UploadedImage initialized with the chosen image
            let uploaded = UploadedImage(tags: [], colors: [], id: nil, image: image)

            // add new UploadedImage to the images array
            uploadedImages.append(uploaded)

            // dismiss the image picker
            imagePicker.dismiss(animated: false, completion: nil)

            // present the imageLoaderVC
            performSegue(withIdentifier: "showImageLoader", sender: self)

            // reload the collection view with the new data
            collectionView.reloadData()
        }
    }

}


protocol ImageLoaderViewControllerDelegate {
    func dismiss()
    func addUploadedImage(uploadedImage: UploadedImage)
}

// ImageCollectionViewController conforms to the protocol
// we created above, which means it needs to implement
// the dismiss() and addUploadedImage(...) methods
extension ImageCollectionViewController: ImageLoaderViewControllerDelegate {

    func dismiss() {
        guard let imageLoaderVC =  imageLoaderViewController else { return }
        imageLoaderVC.dismiss(animated: true, completion: nil)
    }

    func addUploadedImage(uploadedImage: UploadedImage) {
        // get the index of the uploaded image that matches the one
        // we received from the ImageLoaderViewController
        let index = uploadedImages.firstIndex { uploaded -> Bool in
            uploaded.image == uploadedImage.image
        }

        // if we find an index
        if let i = index {
            // save the uploaded image to our uploadedImages array
            // at the index we found
            uploadedImages[i] = uploadedImage
        }
    }

}
