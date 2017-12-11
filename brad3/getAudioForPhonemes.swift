//
//  getAudioForPhonemes.swift
//  brad3
//
//  Created by hanhm on 18/11/2017.
//  Copyright © 2017 JiangYifan. All rights reserved.
//

import Foundation
import AVFoundation

var synthVoice: AVAudioPlayer?

let phoneme_dict = PhonemeUtils()

func findFileName(phoneme_name:String) -> String {
    let path: String = Bundle.main.path(forResource: "Model", ofType: "bundle")! + "/hanhm_record/" + phoneme_name.lowercased() + ".wav"
    print("resolved phoneme path:", path)
    return path
}

func playVoice(word: String) -> (){
    var path_array: [NSURL] = []
    let phoneme_name_list = phoneme_dict.findPhoneme(word: word)
    for phoneme_name in phoneme_name_list {
        let path: String = findFileName(phoneme_name: phoneme_name)
        let url = NSURL(fileURLWithPath: path)
        path_array.append(url)
    }
    concatenateFiles(audioFiles: path_array)
}
