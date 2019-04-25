//
//  main.swift
//  MP3DurationFixer
//
//  Created by Jay on 4/16/19.
//  Copyright © 2019 Andrzej Baruk. All rights reserved.
//

import Foundation



let mp3FilesArray = FileNavigator.getMP3FileArray()
let first10Songs = Array(mp3FilesArray[450...mp3FilesArray.count-1])

var currentFileNumber = 1
var songTitlesArray = [String]()

let methodStart = NSDate()

for mp3FileURL in mp3FilesArray {

    let loopStart = NSDate()
    print("analyzing \(mp3FileURL.lastPathComponent)... \(currentFileNumber)/\(mp3FilesArray.count)")
    
    let fixer = MP3FileFixer(url: mp3FileURL)
    let wasFileFixed = fixer.FixMP3File()
    
    if (wasFileFixed) {
        print("\(mp3FileURL.lastPathComponent) was fixed \n")
        songTitlesArray.append("\(currentFileNumber). \(mp3FileURL.lastPathComponent) - FIXED")
    } else {
        print ("\(mp3FileURL.lastPathComponent) is not broken \n")
        songTitlesArray.append("\(currentFileNumber). \(mp3FileURL.lastPathComponent)")
    }
    currentFileNumber = currentFileNumber + 1
    
    let loopEnd = NSDate()
    let loopExecutionTime = loopEnd.timeIntervalSince(loopStart as Date)
    print("Loop time: \(String(format: "%.2f", loopExecutionTime))")
}
print("complete")

let methodFinish = NSDate()
let executionTime = methodFinish.timeIntervalSince(methodStart as Date)
print("Execution time: \(executionTime)")

let textFileURL = URL.init(fileURLWithPath: "/Users/Jay/Desktop/songs.txt")

try songTitlesArray.map{ String(format: "%@ \n", $0) }.joined().write(to: textFileURL, atomically: false, encoding: .utf8)
