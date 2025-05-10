//
//  UILabel+Extensions.swift
//  RefactorTest
//
//  Created by LocNguyen on 9/5/25.
//

import UIKit

extension UILabel {
    static func mapLabel(topOffset: CGFloat, textColor: UIColor) -> UILabel {
        let label = UILabel(frame: CGRect(x: 64, y: topOffset, width: 300, height: 32))
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        label.font = .boldSystemFont(ofSize: 24)
        label.backgroundColor = .white
        label.textColor = textColor
        return label
    }
}
