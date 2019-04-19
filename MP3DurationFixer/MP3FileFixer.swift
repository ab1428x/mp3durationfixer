//
//  MP3FileFixer.swift
//  MP3DurationFixer
//
//  Created by Jay on 4/16/19.
//  Copyright © 2019 Andrzej Baruk. All rights reserved.
//

import Foundation

class MP3FileFixer {
    
    struct LettersInByteValues {
        static let T_Letter = "84"
        static let A_Letter = "65"
        static let G_Letter = "71"
    }
    
    var filePathUrl: URL
    var fileBytes = [UInt8]()
    var data: NSData!
    var fileSize = 0
    
    init(url: URL) {
        filePathUrl = url
    }
    
    func FixMP3File() -> Bool {
        
        if let data = NSData(contentsOf: filePathUrl) {
            self.data = data
            
            var buffer = [UInt8].init(repeating: 0, count: data.length)
            data.getBytes(&buffer, length: data.length)
            fileBytes = buffer
            fileSize = fileBytes.count
            
                guard let fileEndBytes = getFileEnding(bytes: fileBytes) else {
                    return false
                }
                
                guard let properSongEndPosition = findFirstOccurenceOf(fileEndingBytes: fileEndBytes, in: fileBytes) else {
                    return false
                }
            
            do {
                    let newSongBytes = Array(fileBytes[0...properSongEndPosition])
                _ = try createAndOverwriteNewFixedMP3File(newSongBytes: newSongBytes)
            } catch {
                return false
            }
        }
        
        return true
    }
    
    private func getFileEnding (bytes: [UInt8]) -> [UInt8]? {
        
        var foundValues = 0
        var reveresedPosition = 0
        
        for byte in bytes.reversed() {
            
            switch foundValues {
            case 0:
                if (byte.description == LettersInByteValues.G_Letter) {
                    foundValues = 1
                }
                break
                
            case 1:
                if (byte.description == LettersInByteValues.A_Letter) {
                    foundValues = 2
                }
                break
                
            case 2:
                if (byte.description == LettersInByteValues.T_Letter) {
                    foundValues = 3
                }
            default:
                break
            }
            
            reveresedPosition = reveresedPosition + 1
        }
        
        if (foundValues == 3) {
            let fileEndingBytes = Array(bytes[(bytes.count - reveresedPosition - 1)...bytes.count-1])
            
            return fileEndingBytes
        } else {
            return nil
        }
    }
    
    private func findFirstOccurenceOf(fileEndingBytes: [UInt8], in fileByteArray: [UInt8]) -> Int? {
        
        var position = 0
        var properFileEndPosition = -1
        
        for byte in fileByteArray {
            
            if (byte.description == LettersInByteValues.T_Letter) {
                
                let subBytesToCompare = Array(fileByteArray[position...(position + fileEndingBytes.count - 1)])
                
                if (subBytesToCompare == fileEndingBytes) {
                    
                    properFileEndPosition = (position + fileEndingBytes.count - 1) > fileSize ? position + fileEndingBytes.count - 1 : properFileEndPosition
                    break
                }
                
            }
            position = position + 1
        }
        return properFileEndPosition >= 0 ? properFileEndPosition : nil
    }
    
    private func createAndOverwriteNewFixedMP3File(newSongBytes: [UInt8]) throws -> Bool {
        
        let pointer = UnsafeBufferPointer(start: newSongBytes, count: newSongBytes.count)
        let newFile = Data(buffer: pointer)
        
        do {
            try newFile.write(to: filePathUrl)
            print (" \(filePathUrl.lastPathComponent) Fixed and saved.")
            return true
        } catch {
            print("File overwriting failed!")
            return false
        }
    }
    
}
