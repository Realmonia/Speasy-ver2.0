//
//  ViewController.swift
//  brad3
//
//  Created by James on 10/4/17.
//  Copyright © 2017 JiangYifan. All rights reserved.
//

import UIKit

var scene = ""

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBAction func SchoolButton(_ sender: Any) {
        scene = "School"
    }
    
    @IBAction func RestaurantButton(_ sender: Any) {
        scene = "Restaurant"
    }
    
    @IBAction func MarketButton(_ sender: Any) {
        scene = "Market"
    }
    
    @IBAction func TransportationButton(_ sender: Any) {
        scene = "Transportation"
    }

    
    @IBAction func GeneralButton(_ sender: Any) {
        scene = "General"
    }
    
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!

    @IBAction func helpButton(_ sender: Any) {
        performSegue(withIdentifier: "HelpSegue", sender: self)
    }
    let scenes = ["General", "Restaurant", "Library", "Bus Stop", "Airport"]

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return scenes[row]
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return scenes.count
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        label.text = scenes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "Helvetica", size: 28)
            pickerLabel?.textAlignment = .center
        }
        pickerLabel?.text = scenes[row]
        pickerLabel?.textColor = UIColor.black
        
        return pickerLabel!
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 36
    }
    
    @IBAction func action(_ sender: Any) {
//        scene = label.text!
        performSegue(withIdentifier: "connector", sender: scene)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier  {
            if identifier == "connector" {
                print("aaa")
                if let destination = segue.destination as? SceneViewController{
                    print("bbb")
                    
                    if let button = sender as? UIButton{
                        print("ccc")
                        if let scene = button.currentTitle{
                            if scene != "General"{
                                //                            print([scene.uppercased(), "MODEL"])
                                destination.predictor = EnsemblePredictor(names: [scene.uppercased(), "MODEL"])
                            }else{
                                destination.predictor = EnsemblePredictor(names:["MODEL"])
                            }
                        }
                    }
                    
                    if let scene = sender as? String{
                        print("ccc")
                        if scene != "General"{
//                            print([scene.uppercased(), "MODEL"])
                            destination.predictor = EnsemblePredictor(names: [scene.uppercased(), "MODEL"])
                        }else{
                            destination.predictor = EnsemblePredictor(names:["MODEL"])
                        }
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        testPredictor()

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AppUtility.lockOrientation(.portrait)
        // Or to rotate and lock
        // AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Don't forget to reset when view is being removed
        AppUtility.lockOrientation(.all)
    }
}

