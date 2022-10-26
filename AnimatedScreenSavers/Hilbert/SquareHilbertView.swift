//
//  SquareHilbertView.swift
//  AnimatedScreenSavers
//
//  Created by Liam Rosenfeld on 10/25/22.
//

import AppKit

class SquareHilbertView: NSView {
    let hilbert: HilbertView
    
    override init(frame: NSRect) {
        hilbert = HilbertView(frame: frame.centerSquare())
        super.init(frame: frame)
        self.addSubview(hilbert)
        
        self.wantsLayer = true
        self.layer?.backgroundColor = .black
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layout() {
        super.layout()
        hilbert.frame = self.frame.centerSquare()
    }
}

extension NSRect {
    func centerSquare() -> NSRect {
        if width > height {
            let shift = (width - height) / 2
            return NSRect(
                x: self.origin.x + shift,
                y: self.origin.y,
                width: height,
                height: height
            )
        } else if width < height {
            let shift = (height - width) / 2
            return NSRect(
                x: self.origin.x,
                y: self.origin.y + shift,
                width: width,
                height: width
            )
        } else {
            return self
        }
    }
}
