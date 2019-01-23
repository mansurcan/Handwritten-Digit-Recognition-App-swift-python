//
//  ViewController.swift
//  MScProject
//
//  Created by Mansur Can on 22/08/2018.
//  Copyright © 2018 Mansur Can. All rights reserved.
//

import UIKit
import Vision
import CoreML

class ViewController: UIViewController {
    
    @IBOutlet weak var drawView: DrawView!
    @IBOutlet weak var digitLabel: UILabel!
    
    var requests = [VNRequest]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVision()
        // Do any additional setup after loading the view, typically from a nib.
    }

    func setupVision() {
        guard let visionModel = try? VNCoreMLModel(for: MansurCanMNISTClassifier().model) else {fatalError("Vision ML Model can not be loaded")}
        
        let classificationRequest = VNCoreMLRequest(model: visionModel, completionHandler: self.handleClassification)
        
         self.requests = [classificationRequest]
    }
    
    func handleClassification(request:VNRequest, error:Error?) {
        guard let observations = request.results else {print("There is no results!"); return}
        
        let classifications = observations
        .compactMap({$0 as? VNClassificationObservation})
        .filter({$0.confidence > 0.8})
        .map({$0.identifier})
        
        DispatchQueue.main.async {
            self.digitLabel.text = classifications.first
        }
    }
    
    @IBAction func clearDraw(_ sender: Any) {
        
        drawView.clearDraw()
    }
    
    @IBAction func predictDigit(_ sender: Any) {
        
        let image = UIImage(view: drawView)
        let scaledImage = scaleImage(image: image, toSize: CGSize(width: 28, height: 28))
        
        let imageRequestHandler = VNImageRequestHandler(cgImage: scaledImage.cgImage!, options: [:])
        
        do{
            try imageRequestHandler.perform(self.requests)
        }catch{
            print(error)
        }
    }
    
    func scaleImage (image:UIImage, toSize size:CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        image.draw(in: CGRect (x: 0, y: 0, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

