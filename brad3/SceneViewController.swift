//
//  SceneViewController.swift
//  brad3
//
//  Created by XiaNingwei on 10/8/17.
//  Copyright © 2017 JiangYifan. All rights reserved.
//

import UIKit

class SceneViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var predictedSentence: UITextView!
    
    @IBAction func backButton(_ sender: Any) {
    performSegue(withIdentifier: "backConnector", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = scene
        predictedSentence.isUserInteractionEnabled = false
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
