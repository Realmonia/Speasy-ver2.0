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
    static let toTrimSet:CharacterSet = CharacterSet.whitespacesAndNewlines.union(CharacterSet.punctuationCharacters).union(CharacterSet.symbols);
    
    init(name:String) {
        DBname = name
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
        let words = sentence.lowercased().components(separatedBy: Predictor.toTrimSet)
//        if words.count < 2 {return ["word1","word2","word3","word4"]}
        var word1="", word2="";
        if words.count >= 2{word1 = words[words.endIndex-2]}
        if words.count >= 1{word2 = words.last!}
        var visited = Set<String>()
        do {
            try dbQueue.inDatabase({ db in
//                print([words[words.endIndex-2], words.last])
                var prevWords = [[word1,word2],["",word2],["",""]];
                var i = 0, j = 0;
                while i < 4{
                    let rows = try Row.fetchCursor(db, "SELECT word_3, count FROM markov_model WHERE word_1 = ? AND word_2 = ? ORDER BY count DESC LIMIT 1000", arguments:[prevWords[j][0], prevWords[j][1]])
                    while let row = try rows.next(){
                        if (i>=4) {break;}
                        if let word = row["word_3"] as? String{
                            if (word=="") {continue;}
                            if (visited.contains(word)) {continue;}
                            ret.append(word)
                            visited.insert(word)
                            print(word,(row["count"] as Int?)!)
                        }
                        i+=1
                    }
                    j+=1
                }
            })
        } catch {
            print("query ended with "+String(ret.count)+" results")
        }
        return ret;
    }
}

class EnsemblePredictor {
    var predictors : [Predictor];
    
    init(names:[String]) {
        predictors = [];
        for name in names {
            predictors.append(Predictor(name: name));
        }
    }
    
    convenience init() {
        self.init(names: ["MODEL"]);
    }
    
    func nextWord(sentence:String) -> [String] {
        var ret:[String] = []
        let words = sentence.lowercased().components(separatedBy: Predictor.toTrimSet)
        var word1="", word2="";
        if words.count >= 2{word1 = words[words.endIndex-2]}
        if words.count >= 1{word2 = words.last!}
        var visited = Set<String>()
        do {
            var prevWords = [[word1,word2],["",word2],["",""]];
            for j in 0..<3 {
                while ret.count < 4{
                    for predictor in predictors{
                        try predictor.dbQueue.inDatabase({ db in
                            let rows = try Row.fetchCursor(db, "SELECT word_3, count FROM markov_model WHERE word_1 = ? AND word_2 = ? ORDER BY count DESC LIMIT 1000", arguments:[prevWords[j][0], prevWords[j][1]])
                            while let row = try rows.next(){
                                if (ret.count >= 4){ break}
                                if let word = row["word_3"] as? String{
                                    if (word == "") {continue;}
                                    if (visited.contains(word)) {continue;}
                                    ret.append(word);
                                    visited.insert(word)
                                    print(word, predictor.DBname, (row["count"] as  Int?)!)
                                }
                            }
                        })
                    }
                }
            }
        } catch {
            print("query ended with "+String(ret.count)+" results")
        }
        return ret
    }
}

func testPredictor() {
    let p = Predictor();
    print(p.nextWord(sentence: "you will"))
}

