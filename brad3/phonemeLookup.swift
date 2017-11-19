//
//  phonemeLookup.swift
//  brad3
//
//  Created by hanhm on 13/11/2017.
//  Copyright © 2017 JiangYifan. All rights reserved.
//

import Foundation
import GRDB

class PhonemeUtils {
    var DBname:String
    var dbQueue:DatabaseQueue;
    
    init(name:String) {
        DBname = name
        do{dbQueue = try DatabaseQueue(path:getPathtoDB(name: DBname))}
        catch{
            print("database not found!!!!!")
            dbQueue = DatabaseQueue()
        }
    }
    
    convenience init() {
        self.init(name:"phoneme")
    }
    
    func findPhoneme(word:String) -> [String] {
        var ret:[String]=[]
        let word_handled = word.uppercased()
        print("word after handled is",word_handled)
        do {
            try dbQueue.inDatabase({ db in
                let rows = try Row.fetchCursor(db, "SELECT phoneme_list FROM phoneme WHERE word = ?", arguments:[word_handled])
                while let row = try rows.next(){
                    let temp = row["phoneme_list"] as String
                    let temp_splited = temp.split(separator: " ")
                    for temp_s in temp_splited {
                        ret.append(String(temp_s))
                    }
                }
            })
        } catch {
            print("get phoneme query ended with unexpected behavior")
        }
        return ret;
    }
}

func testGetPhoneme() {
    let p = PhonemeUtils();
    print(p.findPhoneme(word:"this"))
}

