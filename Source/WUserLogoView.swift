//
//  WUserLogoView.swift
//  WMobileKit
//
//  Copyright 2016 Workiva Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import Foundation
import UIKit
import CryptoSwift

public class WUserLogoView: UIView {
    public var initialsLimit = 3 {
        didSet {
            setupUI()
        }
    }
    public var initialsLabel = UILabel()
    internal var circleLayer = CAShapeLayer()

    // Overrides the mapped color
    public var color: UIColor? {
        didSet {
            setupUI()
        }
    }

    public var name: String? {
        didSet {
            initials = name?.initials(initialsLimit)
        }
    }
    
    public var initials: String? {
        didSet {
            setupUI()
        }
    }
    
    public var lineWidth: CGFloat = 1.0 {
        didSet {
            setupUI()
        }
    }
    
    public override var bounds: CGRect {
        didSet {
            if (!subviews.contains(initialsLabel)) {
                commonInit()
            }
            
            setupUI()
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    public convenience init(_ name: String) {
        self.init(frame: CGRectZero)
        
        self.name = name
    }
    
    public func commonInit() {
        addSubview(initialsLabel)
    }
    
    public func setupUI() {
        initialsLabel.snp_remakeConstraints { (make) in
            make.centerX.equalTo(self)
            make.centerY.equalTo(self)
            make.width.equalTo(self).multipliedBy(0.8)
            make.height.equalTo(self).multipliedBy(0.8)
        }

        var mappedColor: UIColor

        if name != nil && name != "" {
            // Use user provided color if populated. Otherwise use mapped color for name
            mappedColor = (color != nil) ? color! : WUserLogoView.mapNameToColor(name!)

            // Use user provided initials if populated
            if initials == nil {
                initials = name!.initials(initialsLimit)
            }
        } else {
            // Use "?" if name is not set
            if initials != "?" {
                initials = "?"
            }
            mappedColor = .grayColor()
        }

        circleLayer.strokeColor = mappedColor.CGColor

        let spacing = max(frame.size.width, 30) / 30 - 1
        let attributedString = NSMutableAttributedString(string: initials!)
        attributedString.addAttribute(NSKernAttributeName, value: CGFloat(spacing), range: NSRange(location: 0, length: max(initials!.characters.count - 1, 0)))

        initialsLabel.attributedText = attributedString
        initialsLabel.textAlignment = NSTextAlignment.Center
        initialsLabel.font = UIFont.systemFontOfSize(frame.width / 2.5)
        initialsLabel.adjustsFontSizeToFitWidth = true
        initialsLabel.textColor = mappedColor

        let center = CGPoint(x: frame.width / 2, y: frame.height / 2)

        let path = UIBezierPath(arcCenter: center, radius: frame.width / 2 - 1, startAngle: 0, endAngle: CGFloat(M_PI * 2), clockwise: true)
        circleLayer.path = path.CGPath
        circleLayer.fillColor = UIColor.clearColor().CGColor
        circleLayer.lineWidth = lineWidth

        layer.addSublayer(circleLayer)
    }

    // Can be overridden for differnt mappings
    public class func mapNameToColor(name: String) -> UIColor {
        // CRC32 decimal
        let colorMapValue = name.crc32int() % 5

        switch colorMapValue {
        case 0:
            return UIColor(hex: 0x42AD48) // Green
        case 1:
            return UIColor(hex: 0xA71B19) // Red
        case 2:
            return UIColor(hex: 0x026DCE) // Blue
        case 3:
            return UIColor(hex: 0x813296) // Purple
        default:
            return UIColor(hex: 0xF26C21) // Orange
        }
    }
}
