//
//  ShadowedButton.swift
//  Essentials
//
//  Created by Micha Volin on 2017-04-11.
//  Copyright © 2017 Vmee. All rights reserved.
//

@IBDesignable
public class Button: UIButton {
	var accessoryImageView: UIImageView?
	 
	@IBInspectable var color: UIColor = UIColor.blue
	@IBInspectable var image: UIImage?
	
	override public func draw(_ rect: CGRect) {
		guard let context = UIGraphicsGetCurrentContext() else { return }
		context.setFillColor(color.cgColor)
		UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).fill()
		layer.shadowColor   = (shadowColor ?? UIColor.clear).cgColor
		layer.shadowOffset  = CGSize(width: shadowOffsetX, height: shadowOffsetY)
		layer.shadowOpacity = shadowOpacity
		layer.shadowRadius  = shadowRadius
		backgroundColor = UIColor.clear
	}
	
	override public func prepareForInterfaceBuilder() {
		setAccessoryImageView()
	}
	
	override public func awakeFromNib() {
		super.awakeFromNib()
	}
	
	public func setAccessoryImageView() {
		if let image = image {
			accessoryImageView = UIImageView()
			accessoryImageView?.frame.size = CGSize(width: frame.height/2, height: frame.height/2)
			accessoryImageView?.center.y = frame.height/2
			accessoryImageView?.frame.origin.x = frame.width-frame.height/2-10
			accessoryImageView?.image = image
			accessoryImageView?.contentMode = .scaleAspectFit
			accessoryImageView?.clipsToBounds = true
			accessoryImageView?.circle()
			addSubview(accessoryImageView!)
			titleEdgeInsets.right = frame.height/2 - 20
		}
	}
	
	override public init(frame: CGRect) {
		super.init(frame: frame)
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
}

