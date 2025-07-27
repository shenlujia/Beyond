//
//  DataExtension.swift
//  Beyond
//
//  Created by ZZZ on 2025/6/19.
//  Copyright © 2025 SLJ. All rights reserved.
//

import Foundation

@objc public enum ImageFormat : Int {
    case Unknow
    case JPEG
    case PNG
    case GIF
    case TIFF
    case WebP
    case HEIC
    case HEIF
}

@objc class TestSwiftA : NSObject {
    @objc static func type(data: Data) -> ImageFormat {
        return data.getImageFormat()
    }
}

extension Data {
    func getImageFormat() -> ImageFormat  {
        var buffer = [UInt8](repeating: 0, count: 1)
        self.copyBytes(to: &buffer, count: 1)
        
        switch buffer {
        case [0xFF]: return .JPEG
        case [0x89]: return .PNG
        case [0x47]: return .GIF
        case [0x49],[0x4D]: return .TIFF
        case [0x52] where self.count >= 12:
            if let str = String(data: self[0...11], encoding: .ascii), str.hasPrefix("RIFF"), str.hasSuffix("WEBP") {
                return .WebP
            }
        case [0x00] where self.count >= 12:
            if let str = String(data: self[8...11], encoding: .ascii) {
                let HEICBitMaps = Set(["heic", "heis", "heix", "hevc", "hevx"])
                if HEICBitMaps.contains(str) {
                    return .HEIC
                }
                let HEIFBitMaps = Set(["mif1", "msf1"])
                if HEIFBitMaps.contains(str) {
                    return .HEIF
                }
            }
        default: break;
        }
        return .Unknow
    }
}
