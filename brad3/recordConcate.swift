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
// effect: put resulting temp audio to ./temp_voice.caf
// TODO: check completion nil or some url: if nil, do machine voice; else, do playback
// possible optimization: check if resulting audio is recognizable by speech recog API: if so then return else use machine
// possible optimization: after a new word has been selected, prompted next time when open if Brad thinks he need to record the word one time
func concatenateFiles(audioFiles: [NSURL], completion: @escaping (NSURL?) -> ()) {
    
    // check if there is one or more target audio files
    guard audioFiles.count > 0 else {
        completion(nil)
        return
    }
    
    // don't need to concatenate
    if audioFiles.count == 1 {
        completion(audioFiles.first)
        return
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
                completion(nil)
                return
            }
        }
    }
    
    // Export the new file
    if let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetPassthrough) {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) // export path
        let documents = NSURL(string: paths.first!)
        
        if let fileURL = documents?.appendingPathComponent("temp_voice.caf") {
            // Remove existing file (to override if name conflict)
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
                print("Removed \(fileURL)")
            } catch {
                print("Could not remove file - \(error)")
            }
            
            // Configure export session output
            exportSession.outputURL = NSURL.fileURL(withPath: fileURL.path)
            exportSession.outputFileType = AVFileType.caf
            
            // Perform the export
            exportSession.exportAsynchronously() { () -> Void in
                if exportSession.status == .completed {
                    print("Export complete")
                    DispatchQueue.main.async {
                        completion(fileURL as NSURL)
                    }
                    return
                } else if exportSession.status == .failed {
                    print("Export failed -   \(exportSession.error)")
                }
                
                completion(nil)
                return
            }
        }
    }
}
