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
    @IBOutlet weak var currentSentence: UITextView!
    
    
    @IBAction func backButton(_ sender: Any) {
    performSegue(withIdentifier: "backConnector", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentSentence.isUserInteractionEnabled = false
        label.text = scene
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
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
