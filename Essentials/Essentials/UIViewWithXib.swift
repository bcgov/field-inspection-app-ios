//
//  UIViewWithXib.swift
//  WineInsider
//
//  Created by Micha Volin on 2017-01-14.
//  Copyright © 2017 Spencer Mandrusiak. All rights reserved.
//



open class UIViewWithXib: UIControl{
   
    public var view: UIView!
    
    public func xibSetup() {
        view = loadFromNib()
        view.frame = bounds
        view.backgroundColor = UIColor.clear
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
    
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
}




