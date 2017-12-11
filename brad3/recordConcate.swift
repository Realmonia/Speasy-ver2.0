//
//  recordConcate.swift
//  brad3
//
//  Created by hanhm on 02/11/2017.
//  Copyright © 2017 JiangYifan. All rights reserved.
//
//  Reference: https://stackoverflow.com/questions/29378472/append-or-concatenate-audio-files-in-swift


import Foundation
import AVFoundation

// parameters: array of urls of audio files, and optional returned resulting audio (url or nil)
// effect: put resulting temp audio to ./temp_path.wav
// TODO: check completion nil or some url: if nil, do machine voice; else, do playback
// possible optimization: check if resulting audio is recognizable by speech recog API: if so then return else use machine
// possible optimization: after a new word has been selected, prompted next time when open if Brad thinks he need to record the word one time
func concatenateFiles(audioFiles: [NSURL], delegate: AVAudioPlayerDelegate) -> String {
    
    // check if there is more than on target audio files
    guard audioFiles.count > 0 else {
        return ""
    }
    
    if audioFiles.count == 1 {
        let fileURL = audioFiles[0]
        do {
            synthVoice = try AVAudioPlayer(contentsOf: fileURL as URL)
            synthVoice?.volume = 10
            synthVoice?.delegate = delegate
            synthVoice?.play()
        }
        catch{}
        return fileURL.path!
    }
    
    // Concatenate audio files into one file: first line set time, other two lines don't know what they are doing for now
    // Track is actually those pieces of audio, and mutable track editing and composition is the way to edit existing audios
    var nextClipStartTime = kCMTimeZero
    let composition = AVMutableComposition()
    let track = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)
    
    // Add each track
    for recording in audioFiles {
        let asset = AVURLAsset(url: NSURL(fileURLWithPath: recording.path!) as URL, options: nil)
        if let assetTrack = asset.tracks(withMediaType: AVMediaType.audio).first {
            let timeRange = CMTimeRange(start: kCMTimeZero, duration: asset.duration)
            do {
                // append audio and edit time range
                try track!.insertTimeRange(timeRange, of: assetTrack, at: nextClipStartTime)
                nextClipStartTime = CMTimeAdd(nextClipStartTime, timeRange.duration)
            } catch {
                // if track doesn't exist then report error
                print("Error concatenating file - \(error)")
                return ""
            }
        }
    }
    
//    let temp_path: String = Bundle.main.path(forResource: "Model", ofType: "bundle")! + "/hanhm_record/tempPath.wav"
    let fileURL = try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("tempPath.wav")

    // Export the new file
    if let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetPassthrough) {
//        print(temp_path)
//        let fileURL = URL(fileURLWithPath: temp_path)
        // Remove existing file (to override if name conflict)
        print("wtf??",fileURL.path)
        do {
            try FileManager.default.removeItem(atPath: fileURL.path)
            print("Removed \(fileURL.path)")
        } catch {
            print("Could not remove file - \(error)")
        }
        
        // Configure export session output
        exportSession.outputURL = NSURL.fileURL(withPath: fileURL.path)
        exportSession.outputFileType = AVFileType.wav
        
        // Perform the export
        exportSession.exportAsynchronously() { () -> Void in
            if exportSession.status == .completed {
                print("Export complete")
                do {
                    synthVoice = try AVAudioPlayer(contentsOf: fileURL)
                    synthVoice?.volume = 10
                    synthVoice?.delegate = delegate
                    synthVoice?.play()
                }
                catch{}
                return
            } else if exportSession.status == .failed {
                print("Export failed -   \(exportSession.error)")
            }
            
            return
        }
    }
    return fileURL.path
}
