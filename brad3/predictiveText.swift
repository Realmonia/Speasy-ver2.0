//
//  predictiveText.swift
//  brad3
//
//  Created by James on 10/4/17.
//  Copyright © 2017 JiangYifan. All rights reserved.
//

import Foundation
import GRDB

func getPathtoDB(name:String) -> String {
    let path: String = Bundle.main.path(forResource: "Model", ofType: "bundle")! + "/" + name + ".db"
//    let path: String = Bundle.main.path(forResource: "MODEL", ofType: "db")!
    return path
}

class Predictor {
    var DBname:String
    var dbQueue:DatabaseQueue;
    var toTrimSet:CharacterSet
    
    init(name:String) {
        DBname = name
        toTrimSet = CharacterSet.whitespacesAndNewlines.union(CharacterSet.punctuationCharacters).union(CharacterSet.symbols);
        do{dbQueue = try DatabaseQueue(path:getPathtoDB(name: DBname))}
        catch{
            print("database not found!!!!!")
            dbQueue = DatabaseQueue()
        }
    }
    
    convenience init() {
        self.init(name:"MODEL")
    }
    
    func nextWord(sentence:String) -> [String] {
        var ret:[String]=[]
        let words = sentence.lowercased().components(separatedBy: toTrimSet)
        if words.count < 2 {return ["word1","word2","word3","word4"]}
        do {
            try dbQueue.inDatabase({ db in
//                print([words[words.endIndex-2], words.last])
                let rows = try Row.fetchCursor(db, "SELECT word_3, count FROM markov_model WHERE word_1 = ? AND word_2 = ? ORDER BY count DESC LIMIT 1000", arguments:[words[words.endIndex-2], words.last])
                var i = 0
                while let row = try rows.next(){
                    if (i>4) {break;}
                    if let word = row["word_3"] as? String{
                        if (word=="") {continue;}
                        ret.append(word)
                        print(word,(row["count"] as Int?)!)
                    }
                    i+=1
                }
            })
        } catch {
            print("query ended with "+String(ret.count)+" results")
        }
        return ret;
    }
}

func testPredictor() {
    let p = Predictor();
    print(p.nextWord(sentence: "you will"))
}

