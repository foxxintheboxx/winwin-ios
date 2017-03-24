//
//  WinWinExtensions.swift
//  WinWin
//
//  Created by Ian Fox on 3/24/17.
//  Copyright © 2017 WinWin Inc. All rights reserved.
//

import Foundation

public extension JsonElement {
    
    public var deepDict : [String : Any] {
        get {
            let data = self.dict
            return self.deepSerialize(data: data)
        }
    }
    
    private func deepSerialize(data: [String : Any]) -> [String : Any] {
        var dataDeserialize = [String : Any?]()
        for key in Array(data.keys) {
            let value = data[key]
            var newValue : Any = value
            if (!(value is String) && !(value is Int) && !(value is Double)) {
                if (JSONSerialization.isValidJSONObject(value)) {
                    let dataSerial = try! JSONSerialization.data(withJSONObject: value, options: [])
                    let jsonString = String(data: dataSerial, encoding: String.Encoding.utf8)
                    let jsonObj = Gson().fromJson(with: jsonString, with: JsonObject_class_()) as! JsonObject
                    if (jsonObj.isJsonArray()) {
                        newValue = jsonObj.getAsJsonArray()
                    } else {
                        newValue = deepSerialize(data: jsonObj.dict)
                    }
                }

            }
            dataDeserialize[key] = newValue
        }
        return dataDeserialize
    }
}

extension UIImage {
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    class func circle(diameter: CGFloat, color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: diameter, height: diameter), false, 0)
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.saveGState()
        
        let rect = CGRect(x: 0, y: 0, width: diameter, height: diameter)
        ctx.setFillColor(color.cgColor)
        ctx.fillEllipse(in: rect)
        
        ctx.restoreGState()
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return img
    }
}

extension String {
    func image() -> UIImage {
        let size = CGSize(width: 30, height: 35)
        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        UIColor.clear.set()
        let rect = CGRect(origin: CGPoint.init(x: 0, y: 0), size: size)
        UIRectFill(CGRect(origin: CGPoint.init(x: 0, y: 0), size: size))
        (self as NSString).draw(in: rect, withAttributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 30)])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}

extension Array  {
    var indexedDictionary: [Int: Element] {
        var result: [Int: Element] = [:]
        enumerated().forEach({ result[$0.offset] = $0.element })
        return result
    }
}

extension UIColor {
    convenience init(hexString: String, alpha: Double = 1.0) {
        let hex = hexString.trimmingCharacters(in: NSCharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (r, g, b) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (1, 1, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(255 * alpha) / 255)
    }
}
