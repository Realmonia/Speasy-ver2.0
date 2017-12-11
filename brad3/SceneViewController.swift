//
//  SceneViewController.swift
//  brad3
//
//  Created by XiaNingwei on 10/8/17.
//  Copyright © 2017 JiangYifan. All rights reserved.
//

import UIKit
import Speech

class SceneViewController: UIViewController, SFSpeechRecognizerDelegate, AVSpeechSynthesizerDelegate, AVAudioPlayerDelegate {
    
    static let confidenceThreshold = 0.5

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var predictedSentence: UITextView!
    
    @IBOutlet weak var startTextField: UITextView!
    
    @IBOutlet weak var word1Button: UIButton!
    
    @IBOutlet weak var word2Button: UIButton!
    
    @IBOutlet weak var word3Button: UIButton!
    
    @IBOutlet weak var word4Button: UIButton!
    
    @IBOutlet weak var startButton: UIButton!
    
    @IBAction func backButton(_ sender: Any) {
    performSegue(withIdentifier: "backConnector", sender: self)
    }
    @IBOutlet weak var startButtonObject: UIButton!
    @IBOutlet weak var nextWordButton: UIButton!
    @IBOutlet weak var nextWordButton2: UIButton!
    @IBOutlet weak var nextWordButton3: UIButton!
    @IBOutlet weak var nextWordButton4: UIButton!
    @IBOutlet weak var bradsVoiceSwitch: UISwitch!
    @IBAction func onBradsVoiceSwitch(_ sender: UISwitch) {
    }
    
    @IBAction func onNextWord1(_ sender: UIButton) {
        chooseNextWord(word: sender.currentTitle!)
    }
    @IBAction func onNextWord2(_ sender: UIButton) {
        chooseNextWord(word: sender.currentTitle!)
    }
    @IBAction func onNextWord3(_ sender: UIButton) {
        chooseNextWord(word: sender.currentTitle!)
    }
    @IBAction func onNextWord4(_ sender: UIButton) {
        chooseNextWord(word: sender.currentTitle!)
    }
    let synth = AVSpeechSynthesizer();
    var myUtterance = AVSpeechUtterance();
    
    func speak(word:String) {
        if !synth.isSpeaking{
            print("-------speaking-------")
        }
        myUtterance = AVSpeechUtterance(string: word);
//        myUtterance.rate = 0.3
        myUtterance.volume = 10
        synth.speak(myUtterance);
    }
    
    var ongoingUtterance : [String:Int] = [String:Int]()
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        let word = utterance.speechString;
//        ongoingUtterance[word]!-=1;
//        if ongoingUtterance[word] == 0 {
//            ongoingUtterance.removeValue(forKey: word);
//        }
//        if !synth.isSpeaking && ongoingUtterance.isEmpty {
//            shouldUpdate = true;
//            print("---------ends---------")
//            startRecording()
//        }
        audioCount -= 1;
        if audioCount == 0 && !synth.isSpeaking {
            shouldUpdate = true;
            print("---------ends---------")
            startRecording()
        }
    }
    
    var audioCount = 0;
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("++++++++++++++++++")
        audioCount -= 1;
        if audioCount == 0 && !synth.isSpeaking {
            shouldUpdate = true;
            print("---------ends---------")
            startRecording()
        }
    }
    
    func chooseNextWord(word:String) {
        shouldUpdate = false;
        if predictedSentence.text.count != 0 && predictedSentence.text.last != " " {
            predictedSentence.text.append(" ");
        }
        predictedSentence.text.append(word);
        scrollToFit()
        fillButton(sentence: predictedSentence.text)
        if bradsVoiceSwitch.isOn {
            playVoice(word: word, delegate: self)
            audioCount += 1
        }else{
            self.speak(word: word);
            audioCount += 1;
//            if ongoingUtterance.keys.contains(word) {
//                ongoingUtterance[word]!+=1;
//            }else{
//                ongoingUtterance[word]=1;
//            }
        }
        if (predictedSentence.text.count>0) {
            predictedSentence.text.append(" ")
        }
        stopRecording()
    }
    
    func fillButton(sentence:String) {
        var predicts = predictor.nextWord(sentence: sentence)
        if predicts.count>=1 {(
            nextWordButton.setTitle(predicts[0], for: .normal),
            print("first button:", phoneme_dict.findPhoneme(word: predicts[0]))
        )}
        if predicts.count>=2 {(
            nextWordButton2.setTitle(predicts[1], for: .normal),
            print("second button:", phoneme_dict.findPhoneme(word: predicts[1]))
        )}
        if predicts.count>=3 {(
            nextWordButton3.setTitle(predicts[2], for: .normal),
            print("third button:", phoneme_dict.findPhoneme(word: predicts[2]))
        )}
        if predicts.count>=4 {(
            nextWordButton4.setTitle(predicts[3], for: .normal),
            print("fourth button:", phoneme_dict.findPhoneme(word: predicts[3]))
        )}
    }
    
    var predictor = EnsemblePredictor(names: ["MODEL"])
//    let predictor = Predictor()
    var shouldUpdate : Bool = true;
    let speechRecognizer = SFSpeechRecognizer();
    var recognitionRequest = SFSpeechAudioBufferRecognitionRequest();
    var recognitionTask = SFSpeechRecognitionTask();
    let audioEngine = AVAudioEngine();
    var startIndex = 0
    @IBAction func startButton(_ sender: UIButton) {
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            OperationQueue.main.addOperation {
                switch authStatus {
                    case .authorized:
                        self.startButtonObject.isEnabled = true
                    case .denied:
                        self.startButtonObject.isEnabled = false
                        self.startButtonObject.setTitle("User denied access to speech recognition", for: .disabled)
                    case .restricted:
                        self.startButtonObject.isEnabled = false
                        self.startButtonObject.setTitle("Speech recognition restricted on this device", for: .disabled)
                    case .notDetermined:
                        self.startButtonObject.isEnabled = false
                        self.startButtonObject.setTitle("Speech recognition not yet authorized", for: .disabled)
                }
            }
        }
        predictedSentence.text = "";
        toggleRecording();
    }
    
    func stopRecording() {
        if self.audioEngine.isRunning {
            print("running")
            let node = self.audioEngine.inputNode
            node.removeTap(onBus: 0)
            self.audioEngine.stop()
            self.recognitionTask.finish()
            self.recognitionRequest.endAudio()
        }
        startIndex = predictedSentence.text.count
    }
    
    func toggleRecording() {
        if (predictedSentence.text.count>0) {
            predictedSentence.text.append(" ")
        }
        stopRecording()
        self.startRecording()
    }
    
    func scrollToFit() {
        let stringLength = self.predictedSentence.text.characters.count
        self.predictedSentence.scrollRangeToVisible(NSRange(location:stringLength-1,length:0))
    }
    
    func startRecording() {
        if audioEngine.isRunning {
            print("running inside")
            return;
        }
        let audioSession = AVAudioSession.sharedInstance()
        do {
//            try audioSession.setCategory(AVAudioSessionCategoryRecord)
//            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with:AVAudioSessionCategoryOptions.defaultToSpeaker)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        
        recognitionRequest.shouldReportPartialResults = true
        recognitionTask = speechRecognizer!.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            if(!self.shouldUpdate) {
                return;
            }
            var isFinal = false
            if result != nil {
                var sum:Double = 0, count:Double = 0;
                for segment in result!.bestTranscription.segments{
                    sum += Double(segment.confidence)
                    count += 1
                }
                print("confidence: "+String(sum/count))
                
                if sum/count < SceneViewController.confidenceThreshold{
//                    return;
                }
                
                self.predictedSentence.text = String(self.predictedSentence.text.prefix(self.startIndex)) + result!.bestTranscription.formattedString
                self.scrollToFit()
                self.fillButton(sentence: self.predictedSentence.text)
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
//                self.audioEngine.stop()
//                inputNode.removeTap(onBus: 0)
//                self.recognitionRequest.endAudio()
//                self.audioEngine.stop()
//                self.recognitionTask.finish()
                print("final")
            }
            
            if isFinal {
                self.startButtonObject.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
            print("audioEngine started")
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
//        predictedSentence.text = "Say something, I'm listening!"
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = scene
        
        word1Button.layer.borderWidth = 1;
        
        word2Button.layer.borderWidth = 1;
        
        word3Button.layer.borderWidth = 1;
        
        word4Button.layer.borderWidth = 1;
        
        startButton.layer.borderWidth = 1;
        
        startTextField.layer.borderWidth = 1;
        predictedSentence.isUserInteractionEnabled = false
        let audioSession = AVAudioSession.sharedInstance()
        synth.delegate = self
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with:AVAudioSessionCategoryOptions.defaultToSpeaker)
            try audioSession.setActive(false, with: .notifyOthersOnDeactivation)
        } catch {
            // handle errors
        }

        nextWordButton.titleLabel!.adjustsFontSizeToFitWidth = true
        nextWordButton.titleLabel!.numberOfLines = 1
        nextWordButton.titleLabel!.minimumScaleFactor = 0.1
        nextWordButton.clipsToBounds = true
        nextWordButton2.titleLabel!.adjustsFontSizeToFitWidth = true
        nextWordButton2.titleLabel!.numberOfLines = 1
        nextWordButton2.titleLabel!.minimumScaleFactor = 0.1
        nextWordButton2.clipsToBounds = true
        nextWordButton3.titleLabel!.adjustsFontSizeToFitWidth = true
        nextWordButton3.titleLabel!.numberOfLines = 1
        nextWordButton3.titleLabel!.minimumScaleFactor = 0.1
        nextWordButton3.clipsToBounds = true
        nextWordButton4.titleLabel!.adjustsFontSizeToFitWidth = true
        nextWordButton4.titleLabel!.numberOfLines = 1
        nextWordButton4.titleLabel!.minimumScaleFactor = 0.1
        nextWordButton4.clipsToBounds = true
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
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            startButtonObject.isEnabled = true;
        }else{
            startButtonObject.isEnabled = false;
        }
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
