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
    
    var fileEndingBytesStartPosition = -1
    var tagOccurencePosition = -1
    
    let filePath = "/Users/Jay/Desktop/bewar.mp3"
    //let url = URL.init(fileURLWithPath: filePath)
    
    init(url: URL) {
        //filePathUrl = url
        filePathUrl = URL.init(fileURLWithPath: filePath)
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
    
    func FixMP3File_TEST() -> Bool {
        
        if let data = NSData(contentsOf: filePathUrl) {
            self.data = data
            
            var buffer = [UInt8].init(repeating: 0, count: data.length)
            data.getBytes(&buffer, length: data.length)
            fileBytes = buffer
            fileSize = fileBytes.count
            
            guard let fileEndBytes = getFileEnding(bytes: fileBytes) else {
                return false
            }
            
            guard let _ = findFirstOccurenceOf(fileEndingBytes: fileEndBytes, in: fileBytes) else {
                return false
            }
        }
        
        return true
    }
    
    private func getFileEnding (bytes: [UInt8]) -> [UInt8]? {
        
        let reversedBytes = Array(bytes.reversed())
        
        var reveresedPosition = 0
        var fileEndingFound = false
        var matchFound = false
        var fileEndingBytes = [UInt8]()
        
        for byte in reversedBytes {
            
            if (!fileEndingFound && byte.description == LettersInByteValues.G_Letter
                && reversedBytes.count >= reveresedPosition + 2
                && reversedBytes[reveresedPosition+1].description == LettersInByteValues.A_Letter
                && reversedBytes[reveresedPosition+2].description == LettersInByteValues.T_Letter) {
                
                fileEndingBytesStartPosition = bytes.count - reveresedPosition - 3
                fileEndingBytes = Array(bytes[fileEndingBytesStartPosition...bytes.count-1])
                fileEndingFound = true
                
            } else if (fileEndingFound && byte.description == LettersInByteValues.G_Letter
                && reversedBytes.count >= reveresedPosition + 2
                && reversedBytes[reveresedPosition+1].description == LettersInByteValues.A_Letter
                && reversedBytes[reveresedPosition+2].description == LettersInByteValues.T_Letter
                && reversedBytes[reveresedPosition-1].description == fileEndingBytes[3].description
                && reversedBytes[reveresedPosition-2].description == fileEndingBytes[4].description
                && reversedBytes[reveresedPosition-3].description == fileEndingBytes[5].description) {
                
                tagOccurencePosition = bytes.count - reveresedPosition - 3
                matchFound = true
                break
            }
            reveresedPosition = reveresedPosition + 1
        }
        
        if (fileEndingFound && matchFound) {
            return fileEndingBytes
        } else {
            return nil
        }
    }
    
    private func findFirstOccurenceOf(fileEndingBytes: [UInt8], in fileByteArray: [UInt8]) -> Int? {
        
        var position = 0
        var properFileEndPosition = -1
        let slicedArray = Array(fileByteArray[tagOccurencePosition...fileEndingBytesStartPosition])
        
        for byte in slicedArray {
            
            position = tagOccurencePosition
            if (byte.description == LettersInByteValues.T_Letter && position == 1001349) {
                
                let subBytesToCompare = Array(fileByteArray[position...(position + fileEndingBytes.count - 1)])
                
                if (subBytesToCompare == fileEndingBytes) {
                    
                    properFileEndPosition = (position + fileEndingBytes.count) < fileSize ? position + fileEndingBytes.count - 1 : properFileEndPosition
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
