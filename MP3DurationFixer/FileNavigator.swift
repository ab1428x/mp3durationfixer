//
//  FileNavigator.swift
//  MP3DurationFixer
//
//  Created by Jay on 4/19/19.
//  Copyright © 2019 Andrzej Baruk. All rights reserved.
//

import Foundation

class FileNavigator {
    
    static let shared = FileNavigator()
    
    private let MusicFolderPath = "/Users/Jay/Music/iTunes/iTunes Media/Music/"
    
    let musicURL: URL
    let fileManager: FileManager
    let enumerator: FileManager.DirectoryEnumerator
    
    private init() {
        fileManager = FileManager.default
        musicURL = URL.init(fileURLWithPath: MusicFolderPath)
        enumerator = FileManager.default.enumerator(at: musicURL,
                                                    includingPropertiesForKeys: [URLResourceKey](),
                                                    options: [.skipsHiddenFiles], errorHandler: nil)!

    }
    
    static func getMP3FileArray() -> Array<URL> {
        
        var mp3List = Array<URL>()
        for case let fileURL as URL in shared.enumerator {
            
            if (fileURL.pathExtension == "mp3") {
                mp3List.append(fileURL)
            }
        }
        
        return mp3List
        
    }
    
}
