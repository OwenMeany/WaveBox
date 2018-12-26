//
//  ViewController.swift
//  WaveBox
//
//  Created by Harri on 28/11/18.
//  Copyright © 2018 Harri. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var timestepLabel: UILabel!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var bigWaveButton: UIButton!
    
    @IBAction func OnClick(_ sender: UIButton, forEvent event: UIEvent) {
        simulator!.Reset()
    }
    
    
    @IBAction func OnBigWaveClick(_ sender: UIButton, forEvent event: UIEvent) {
        simulator!.SetBigWave()
    }
    
    
    var simulator: LeapFrogSimulator?
    var screenWidth: CGFloat?
    var screenHeight: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
      
        let screenSize: CGRect = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
        mainImage.frame = CGRect(x: 0, y: 0, width: screenWidth!, height: screenHeight!)
        mainImage.contentMode = .scaleAspectFill
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        mainImage.isUserInteractionEnabled = true
        mainImage.addGestureRecognizer(tapGestureRecognizer)
        
        timestepLabel.text = "0"
        timestepLabel.textColor = UIColor.gray
        timestepLabel.isHidden = true
        
        resetButton.setTitle("Reset", for: .normal)
        resetButton.setTitleColor(UIColor.gray, for: .normal)
        resetButton.layer.borderColor = UIColor.gray.cgColor
        resetButton.layer.borderWidth = 1

        bigWaveButton.setTitle("Tsunami", for: .normal)
        bigWaveButton.setTitleColor(UIColor.gray, for: .normal)
        bigWaveButton.layer.borderColor = UIColor.gray.cgColor
        bigWaveButton.layer.borderWidth = 1
        
        simulator = LeapFrogSimulator(Nx: 64, Ny: 64, Lx: 1.0, Ly: 1.0, C: 1.0, dt: 0.005)
        
        mainImage.image = simulator!.UpdateImage()
        
        _ = Timer.scheduledTimer(timeInterval: 0.0, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
    }
    
    func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        let loc = tapGestureRecognizer.location(in: tappedImage)
        
        let width = tappedImage.bounds.width
        let height = tappedImage.bounds.height
        
        let y = Int((loc.x)/width*CGFloat(simulator!.Ny))
        let x = Int((loc.y)/height*CGFloat(simulator!.Nx))
        debugPrint(x, y)
        
        simulator!.SetWave(x: x, y: y)
    }
    
    @objc func update() {
        simulator!.Evolve()
        mainImage.image = simulator!.UpdateImage()
        timestepLabel.text = String(simulator!.currentimestep)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

