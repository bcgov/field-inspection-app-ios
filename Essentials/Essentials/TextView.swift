//
//  TextView.swift
//  Essentials
//
//  Created by Micha Volin on 2017-05-28.
//  Copyright © 2017 Vmee. All rights reserved.
//

@IBDesignable
public class TextView: UITextView{
	fileprivate var _delegate: TextViewDelegate?{
		return text_delegate as? TextViewDelegate
	}
	//MARK: Properties
	fileprivate lazy var counterLabel     = UILabel()
	fileprivate lazy var placeholderLabel = UILabel()
	fileprivate lazy var titleLabel       = UILabel()
	//MARK: IB Outlets
	@IBOutlet public var text_delegate: NSObject?
	//MARK: IB Designables
	@IBInspectable public var showCounter : Bool = true
	@IBInspectable public var scrollLimit : Int = 0
	@IBInspectable public var placeholder : String?
	@IBInspectable public var title		  : String?
	@IBInspectable public var maximum     : Int = 0
	@IBInspectable public var lines       : Int = 0
	
	//MARK: -
	override public func awakeFromNib() {
		delegate = self
		isScrollEnabled = false
		setCounterLabel()
		setPlaceholderLabel()
		setTitleLabel()
	}
	
	//MARK: -
	public override func prepareForInterfaceBuilder() {
		setCounterLabel()
		setPlaceholderLabel()
	}
	
	//MARK: -
	fileprivate func setPlaceholderLabel(){
		if let placeholder = placeholder{
			addSubview(placeholderLabel)
			let padding = textContainer.lineFragmentPadding
			placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
			placeholderLabel.topAnchor.constraint(equalTo: topAnchor, constant: textContainerInset.top).isActive = true
			placeholderLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: textContainerInset.left+padding+2).isActive = true
			placeholderLabel.textColor = UIColor(hexadecimal: 0xC7C7CD)
			placeholderLabel.font = font
			placeholderLabel.text = placeholder
		}
	}
 
	fileprivate func setCounterLabel(){
		if maximum != 0 && showCounter{
			addSubview(counterLabel)
			counterLabel.translatesAutoresizingMaskIntoConstraints = false
			counterLabel.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor, constant: 0).isActive = true
			counterLabel.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: 0).isActive = true
			counterLabel.heightAnchor.constraint(equalToConstant: 20)
			counterLabel.text = "\(maximum)"
			counterLabel.textColor = textColor
			counterLabel.font = UIFont(name: "Arial Rounded MT Bold", size: 16)
			if textContainerInset.bottom < 30{
				textContainerInset.bottom = 30
			}
		}
	}
	
	fileprivate func setTitleLabel(){
		if let title = title{
			clipsToBounds = false
			layer.masksToBounds = false
			addSubview(titleLabel)
			titleLabel.translatesAutoresizingMaskIntoConstraints = false
			titleLabel.bottomAnchor.constraint(equalTo: topAnchor).isActive = true
			titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
			titleLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
			titleLabel.text = title
			titleLabel.font = UIFont(name: "Arial Rounded MT Bold", size: 16)
			titleLabel.textColor = UIColor(white: 0.25, alpha: 1)
		}
	}

	public func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let offsetY = scrollView.contentOffset.y
		counterLabel.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: offsetY).isActive = true
		layoutIfNeeded()
	}
}

//MARK: -
extension TextView: UITextViewDelegate{
	public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
		return _delegate?.textShouldBeginEditing?(textView: self) ?? true
	}
	
	public func textViewDidEndEditing(_ textView: UITextView) {
		_delegate?.textDidFinishEditing?(textView: self)
	}
	
	public func textViewDidChange(_ textView: UITextView) {
		if let str = textView.text, str != ""{
			placeholderLabel.isHidden = true
		} else {
			placeholderLabel.isHidden = false
		}
		_delegate?.textDidChange?(textView: self)
	}
	
	public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		if text == "\n" && textView.text.characters.last == "\n"{
			return false
		}
		if text == "\n" && textView.text == ""{
			return false
		}
		let length = textView.text.characters.count + text.characters.count - range.length
		let count = maximum - length
		if showCounter{
			counterLabel.text = "\(count)"
		}
		let numberOfLines = textView.numberOfLines()
		if lines > 0 {
			return numberOfLines < lines
		}
		if scrollLimit > 0{
			textView.isScrollEnabled = (numberOfLines > scrollLimit) ? true : false
		}
		if maximum == 0{
			return _delegate?.text?(textView:self,range: range, replacement: text) ?? true 
		}
		return _delegate?.text?(textView:self,range: range, replacement: text) ?? (length < maximum)
	}
}






