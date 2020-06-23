//
//  ViewController.swift
//  AnimalDetectApp
//
//  Created by NGUYENLONGTIEN on 6/22/20.
//  Copyright © 2020 NGUYENLONGTIEN. All rights reserved.
//

import UIKit
import CoreML
import Vision
class MainVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var classificationLabel: UILabel!
    //Request to Animal classifier
    lazy var classificationRequest: VNCoreMLRequest = {
        do {
            let model = try VNCoreMLModel(for: AnimalClassifier().model)
            let request = VNCoreMLRequest(model: model) { (request, error) in
                //Process classcification
                self.processClassifications(for: request, error: error)
            }
            request.imageCropAndScaleOption = VNImageCropAndScaleOption.centerCrop
            return request
        }catch{
            fatalError("Fail to load vision ML Core")
        }
    }()
    func processClassifications(for request: VNRequest, error: Error?){
        DispatchQueue.main.async {
            guard let results = request.results else {
                self.classificationLabel.text = "Unable to classify image.\n\(error?.localizedDescription)"
                return
            }
            let classifications = results as! [VNClassificationObservation]
            if classifications.isEmpty{
                self.classificationLabel.text = "Nothing recognized"
            }else{
                let topClssifications = classifications.prefix(2)
                var description = ""
                for classification in topClssifications{
                    description = description + String(format: "%.2f", classification.confidence * 100) + "% - " + classification.identifier + "/"
                }
                let components = description.components(separatedBy: "/")
                let descriptionString = components.filter({!$0.isEmpty}).joined(separator: "\n")
                self.classificationLabel.text = "Classification:\n" + descriptionString
            }
        }
    }
    func updateClassification(for image:UIImage){
        classificationLabel.text = "Clssifying..."
        guard let orientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue)), let ciImage = CIImage(image: image) else {
            // print error
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            do {
                try handler.perform([self.classificationRequest])
            } catch {
                /*
                 This handler catches general image processing errors. The `classificationRequest`'s
                 completion handler `processClassifications(_:error:)` catches errors specific
                 to processing that request.
                 */
                print("Failed to perform classification.\n\(error.localizedDescription)")
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func cameraButtonWasPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Notification", message: "Pich photo!", preferredStyle: UIAlertController.Style.alert)
        let btnPhoto = UIAlertAction(title: "Photo", style: UIAlertAction.Style.default) { (photo) in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            self.present(picker, animated: true, completion: nil)
        }
        let btnCamera = UIAlertAction(title: "Camera", style: UIAlertAction.Style.default) { (camera) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera){
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
            }else{
                print("Camera is not available")
            }
        }
        let btnDismiss = UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.cancel, handler: nil)
        alert.addAction(btnPhoto)
        alert.addAction(btnCamera)
        alert.addAction(btnDismiss)
        self.present(alert, animated: true, completion: nil)
    }
    // MARK: - Image Picker Controller
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {fatalError("No image returned")}
        imageView.image = image
        // tien hanh dinh danh
        updateClassification(for: image)
    }
    
}

