//
//  LogTextView.swift
//  wutest
//
//  Created by Dmitriy Borovikov on 08.07.17.
//  Copyright © 2017 Dmitriy Borovikov. All rights reserved.
//

import Cocoa

class Logger: NSTextView {
    
    static let attributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font: NSFont(name: "Menlo", size: 12) as Any,
                             NSAttributedString.Key.foregroundColor: NSColor.controlTextColor]

    static var shared: Logger?
    
    override init(frame frameRect: NSRect, textContainer container: NSTextContainer?) {
        super.init(frame: frameRect, textContainer: container)
        self.isAutomaticQuoteSubstitutionEnabled = false
        self.isAutomaticDashSubstitutionEnabled = false
        self.isAutomaticTextReplacementEnabled = false
        
        self.enclosingScrollView?.hasHorizontalScroller = true
        self.isHorizontallyResizable = true
        self.autoresizingMask = [NSView.AutoresizingMask.width, NSView.AutoresizingMask.height]
        self.textContainer?.containerSize = NSMakeSize(CGFloat.greatestFiniteMagnitude, CGFloat.greatestFiniteMagnitude)
        self.textContainer?.widthTracksTextView = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.isAutomaticQuoteSubstitutionEnabled = false
        self.isAutomaticDashSubstitutionEnabled = false
        self.isAutomaticTextReplacementEnabled = false

        self.enclosingScrollView?.hasHorizontalScroller = true
        self.isHorizontallyResizable = true
        self.autoresizingMask = [NSView.AutoresizingMask.width, NSView.AutoresizingMask.height]
        self.textContainer?.containerSize = NSMakeSize(CGFloat.greatestFiniteMagnitude, CGFloat.greatestFiniteMagnitude)
        self.textContainer?.widthTracksTextView = false
        setTabStops()
        Logger.shared = self
    }
    
    internal func setTabStops() {
        let numStops = 10
        let tabInterval = 40
        
        //attributes for attributed String of TextView
        let paragraphStyle = NSMutableParagraphStyle()
        
        // This first clears all tab stops, then adds tab stops, at desired intervals...
        paragraphStyle.tabStops = []
        for cnt in 1...numStops {
            let tabStop = NSTextTab(type: .leftTabStopType, location: CGFloat(tabInterval * cnt))
            paragraphStyle.addTabStop(tabStop)
        }
        
        self.defaultParagraphStyle = paragraphStyle
    }
    
    fileprivate func printString(_ s: String) {
        self.string = self.string + s + "\n"
    }
    
    func append(string: String, color: NSColor?) {
        var attributes = Logger.attributes
        if let color = color { attributes[NSAttributedString.Key.foregroundColor] = color }
        
        self.textStorage?.append(NSAttributedString.init(string: string + "\n", attributes: attributes))
        self.scrollToEndOfDocument(nil)
    }
    
}

// Mark: public func
public func log(_ s: String, color: NSColor? = nil) {
    DispatchQueue.main.async {
        if let logView = Logger.shared {
            logView.append(string: s, color: color)
        } else {
            Swift.print(s)
        }
    }
}

public func log(format: String, _ arguments: Any...) {
    log(String(format: format, arguments: arguments as! [CVarArg]))
}

public func log(error: Error, code: Int? = nil) {
    var message = "Error: "
    print(error, to: &message)
    log(message, color: NSColor.red)
}


