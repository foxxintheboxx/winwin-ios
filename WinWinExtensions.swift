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
            return self.deepDeserializeDict(data: data)
        }
    }
    
    private func isJSONPrimitive(data : Any) -> Bool {
        return (data is String) || (data is Int) || (data is Double)
    }
    
    private func deserialize(data : Any) -> String {
        let dataSerial = try! JSONSerialization.data(withJSONObject: data, options: [])
        return String(data: dataSerial, encoding: String.Encoding.utf8)!
    }
    
    private func isJSONArray(_ jsonString : String) -> Bool {
        return jsonString[jsonString.startIndex] == "[" ? true : false
    }
    
    private func makeJsonArray(_ jsonString : String) -> JsonArray {
        return Gson().fromJson(with: jsonString, with: JsonArray_class_()) as! JsonArray
    }
    
    private func makeJsonObject(_ jsonString : String) -> JsonObject {
        return Gson().fromJson(with: jsonString, with: JsonObject_class_()) as! JsonObject
    }
    
    private func deepDeserializeArray(data: [Any]) -> [Any] {
        var dataDeserialize = [Any]()
        for element in data {
            if (!isJSONPrimitive(data: element) && JSONSerialization.isValidJSONObject(element)) {
                let jsonString = deserialize(data: element)
                if isJSONArray(jsonString) {
                    dataDeserialize.append(deepDeserializeArray(data: makeJsonArray(jsonString).array))
                } else {
                    dataDeserialize.append(deepDeserializeDict(data: makeJsonObject(jsonString).dict))
                }
            } else {
                dataDeserialize.append(element)
            }
        }
        return dataDeserialize
    }
    
    private func deepDeserializeDict(data: [String : Any]) -> [String : Any] {
        var dataDeserialize = [String : Any]()
        for key in Array(data.keys) {
            let value = data[key] as Any
            var newValue : Any = value as Any
            if (!isJSONPrimitive(data: value) && JSONSerialization.isValidJSONObject(value)) {
                let jsonString = deserialize(data: value)
                if isJSONArray(jsonString) {
                    newValue = deepDeserializeArray(data: makeJsonArray(jsonString).array)
                } else {
                    newValue = deepDeserializeDict(data: makeJsonObject(jsonString).dict)
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
    func scaleImage(toSize newSize: CGSize) -> UIImage? {
        let newRect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height).integral
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        if let context = UIGraphicsGetCurrentContext() {
            context.interpolationQuality = .high
            let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: newSize.height)
            context.concatenate(flipVertical)
            context.draw(self.cgImage!, in: newRect)
            let newImage = UIImage(cgImage: context.makeImage()!)
            UIGraphicsEndImageContext()
            return newImage
        }
        return nil
    }
    
    class func globe(diameter: CGFloat, color: UIColor) -> UIImage {
        let circle = UIImage.circle(diameter: diameter, color: color)
        let globe = UIImage.init(named: "bubble")
        let size = CGSize.init(width: diameter, height: diameter)
        let magicX = CGFloat(-1 * 0 * diameter)// FIXXX
        let magicY = CGFloat(-1 * 0 * diameter) // FIXXX
        UIGraphicsBeginImageContext(size)
        let areaSize = CGRect(x: 0, y: 0, width: circle.size.width, height: circle.size.height)
        circle.draw(in: areaSize)
        globe?.draw(in: CGRect(x: magicX, y: magicY, width: size.width, height: size.height), blendMode: CGBlendMode.normal, alpha: 0.8)
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        return newImage
    }
}

extension String {
    func image(width: CGFloat, height: CGFloat, fontSize: CGFloat) -> UIImage {
        let size = CGSize(width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        UIColor.clear.set()
        let rect = CGRect(origin: CGPoint.init(x: 0, y: 0), size: size)
        UIRectFill(CGRect(origin: CGPoint.init(x: 0, y: 0), size: size))
        (self as NSString).draw(in: rect, withAttributes: [NSFontAttributeName: UIFont.systemFont(ofSize: fontSize)])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}

extension Array  {
    var indexedDictionary: [String: Element] {
        var result: [String: Element] = [:]
        enumerated().forEach({ result[String(describing: $0.element)] = $0.element })
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

extension CGPoint {
    
    static func calculateQuartileBounds(center: Int) -> BearingViewBound {
        let bounds = BearingViewBound(center: Float(center))
        bounds.q4 = Float((center - 45) % 360)
        bounds.q1 = Float((center + 45) % 360)
        bounds.q2 = Float((Int(bounds.q1) + 90) % 360)
        bounds.q3 = Float((Int(bounds.q2) + 90) % 360)
        bounds.calculateCenters()
        return bounds
    }

    
    static func transform(bearing : Float, frame : CGRect, bounds: BearingViewBound) -> CGPoint {
        let width = Float(frame.size.width)
        let height = Float(frame.size.height)
        let offset = 7
        if ((bearing >= bounds.q4q1center && bearing < bounds.q1) ||
            (bearing <= bounds.q4q1center.complement && bearing > bounds.q4)) {
            
            let widthPerBearing1 = bounds.q4q1center.complement - bounds.q4
            let widthPerBearing2 = 90.0 - widthPerBearing1
            let totalWidthView1 = width * widthPerBearing1 / 90.0
            let totalWidthView2 = width * widthPerBearing2 / 90.0
            
            if ((bearing >= bounds.q4q1center && bearing < bounds.q1)) {
                let percentage = 1 - ((bearing - bounds.q4q1center) / widthPerBearing2)
                return CGPoint(x: Int(width - (totalWidthView2 * percentage)), y: offset)
            } else {
                let normalizeBearing = bearing - bounds.q4
                return CGPoint(x: Int(totalWidthView1 * normalizeBearing / widthPerBearing1), y: offset)
            }
        } else if ((bearing <= bounds.q1q2center && bearing >= bounds.q1) ||
                    (bearing >= bounds.q1q2center.complement && bearing < bounds.q2)) {

            let heightPerBearing1 = bounds.q1q2center - bounds.q1
            let heightPerBearing2 = 90.0 - heightPerBearing1
            let totalHeightView1 = height * heightPerBearing1 / 90.0
            let totalHeightView2 = height * heightPerBearing2 / 90.0
            
            if ((bearing <= bounds.q1q2center && bearing >= bounds.q1)) {
                let normalizeBearing = bearing - bounds.q1
                return CGPoint(x: Int(width) - offset, y: Int(totalHeightView1 * normalizeBearing / heightPerBearing1))
            } else {
                let percentage = 1 - ((bearing - bounds.q1q2center.complement) / heightPerBearing2)
                return CGPoint(x: Int(width) - offset, y: Int(height - (totalHeightView2 * percentage)))
            }
        } else if ((bearing <= bounds.q2q3center && bearing >= bounds.q2) ||
                    (bearing >= bounds.q2q3center.complement && bearing < bounds.q3)) {
            
            let widthPerBearing1 = bounds.q2q3center.complement - bounds.q2
            let widthPerBearing2 = 90.0 - widthPerBearing1
            let totalWidthView1 = width * widthPerBearing1 / 90.0
            let totalWidthView2 = width * widthPerBearing2 / 90.0

            if (bearing <= bounds.q2q3center && bearing >= bounds.q2) {
                let percentage = (bearing - bounds.q2) / widthPerBearing1
                return CGPoint(x: Int(width - (totalWidthView1 * percentage)), y: Int(height) - offset)
            } else {
                let normalizeBearing = bearing - bounds.q2q3center.complement
                return CGPoint(x: Int(totalWidthView2 * (1 - normalizeBearing / widthPerBearing2)), y: Int(height) - offset)
            }
            
        } else {

            let heightPerBearing1 = bounds.q3q4center - bounds.q3
            let heightPerBearing2 = 90.0 - heightPerBearing1
            let totalHeightView1 = height * heightPerBearing1 / 90.0
            let totalHeightView2 = height * heightPerBearing2 / 90.0

            if ((bearing <= bounds.q3q4center && bearing >= bounds.q3)) {
                let percentage = (bearing - bounds.q3) / heightPerBearing1
                return CGPoint(x: offset, y: Int(height - (totalHeightView1 * percentage)))
            } else {
                let normalizeBearing = bearing - bounds.q3q4center.complement
                return CGPoint(x: offset, y: Int(totalHeightView2 * (1 - normalizeBearing / heightPerBearing2)))
            }
            
        }

    }
}

extension Float {
    
    var complement: Float {
        get {
            return (self == 0) ? 360.0 : Float(Int(self) % 360)
        }
    }
}

extension CLLocationCoordinate2D {
    
    func calculateAngle(location: CLLocationCoordinate2D) -> Double {
        
        let userLocationLatitude: Double = degreesToRadians(degrees: Double(self.latitude))
        let userLocationLongitude: Double = degreesToRadians(degrees: Double(self.longitude))
        
        let targetedPointLatitude: Double = degreesToRadians(degrees: Double(location.latitude))
        let targetedPointLongitude: Double = degreesToRadians(degrees: Double(location.longitude))
        
        let longitudeDifference: Double = targetedPointLongitude - userLocationLongitude
        
        let y: Double = sin(longitudeDifference) * cos(targetedPointLatitude)
        let x: Double = cos(userLocationLatitude) * sin(targetedPointLatitude) - sin(userLocationLatitude) * cos(targetedPointLatitude) * cos(longitudeDifference)
        var radiansValue: Double = atan2(y, x)
        if(radiansValue < 0.0)
        {
            radiansValue += 2 * Double(M_PI)
        }
        
        return radiansToDegrees(radians: radiansValue)
    }
    
    func degreesToRadians(degrees: Double) -> Double { return degrees * M_PI / 180.0 }
    func radiansToDegrees(radians: Double) -> Double { return radians * 180.0 / M_PI }
    
}

extension UIView {
    func addBorder(edges: UIRectEdge, color: UIColor = UIColor.darkGray, thickness: CGFloat = 1.0) -> [UIView] {
        
        var borders = [UIView]()
        
        func border() -> UIView {
            let border = UIView(frame: CGRect.zero)
            border.backgroundColor = color
            border.translatesAutoresizingMaskIntoConstraints = false
            return border
        }
        
        if edges.contains(.top) || edges.contains(.all) {
            let top = border()
            addSubview(top)
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[top(==thickness)]",
                                               options: [],
                                               metrics: ["thickness": thickness],
                                               views: ["top": top]))
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[top]-(0)-|",
                                               options: [],
                                               metrics: nil,
                                               views: ["top": top]))
            borders.append(top)
        }
        
        if edges.contains(.left) || edges.contains(.all) {
            let left = border()
            addSubview(left)
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[left(==thickness)]",
                                               options: [],
                                               metrics: ["thickness": thickness],
                                               views: ["left": left]))
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[left]-(0)-|",
                                               options: [],
                                               metrics: nil,
                                               views: ["left": left]))
            borders.append(left)
        }
        
        if edges.contains(.right) || edges.contains(.all) {
            let right = border()
            addSubview(right)
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "H:[right(==thickness)]-(0)-|",
                                               options: [],
                                               metrics: ["thickness": thickness],
                                               views: ["right": right]))
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[right]-(0)-|",
                                               options: [],
                                               metrics: nil,
                                               views: ["right": right]))
            borders.append(right)
        }
        
        if edges.contains(.bottom) || edges.contains(.all) {
            let bottom = border()
            addSubview(bottom)
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "V:[bottom(==thickness)]-(0)-|",
                                               options: [],
                                               metrics: ["thickness": thickness],
                                               views: ["bottom": bottom]))
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[bottom]-(0)-|",
                                               options: [],
                                               metrics: nil,
                                               views: ["bottom": bottom]))
            borders.append(bottom)
        }
        
        return borders
    }
}

extension UIButton{
    func roundedButton(){
        let maskPAth1 = UIBezierPath(roundedRect: self.bounds,
                                     byRoundingCorners: UIRectCorner.allCorners,
                                     cornerRadii:CGSize.init(width: 8.0, height: 8.0)
        )
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = self.bounds
        maskLayer1.path = maskPAth1.cgPath
        self.layer.mask = maskLayer1
        
    }
}
