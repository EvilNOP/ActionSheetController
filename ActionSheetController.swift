//
//  ActionSheetController.swift
//  ActionSheetController
//
//  Created by Matthew on 04/11/2016.
//  Copyright © 2016 Matthew. All rights reserved.
//

import UIKit

class AlertAction {
    
    private(set) var handler: (() -> Void)?
    
    fileprivate var tintColor: UIColor {
        get {
            switch style {
            case .cancel:
                fallthrough
            case .default:
                return UIColor.black
            case .destructive:
                return UIColor.red
            }
        }
    }
    
    var title: String?
    var style: UIAlertActionStyle
    
    init(title: String?, style: UIAlertActionStyle, handler: (() -> Void)?) {
        self.title = title
        self.style = style
        self.handler = handler
    }
}

class ActionSheetController: UIViewController {
    
    // Constants.
    private let minorPadding: CGFloat = 0.5
    private let padding: CGFloat = 8.0
    private let actionSheetItemHeight: CGFloat = 49.0
    private let screenSize: CGSize = UIScreen.main.bounds.size
    
    private let underLayerView = UIView()
    private let actionSheet = UIView()
    
    private var screenShotImage: UIImage?
    private(set) var actions: [AlertAction] = []
    private var actionSheetTotalHeight: CGFloat = 0.0

    convenience init() {
        self.init(title: nil)
    }
    
    convenience init(title: String?) {
        self.init(nibName: nil, bundle: nil)
        
        self.title = title
        
        // Display the content over the previous view controller’s content
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up a under layer view.
        underLayerView.frame = view.frame
        underLayerView.alpha = 0.5
        underLayerView.backgroundColor = UIColor(
            red: 46.0 / 255.0, green: 49.0 / 255.0, blue: 50.0 / 255.0, alpha: 0.5
        )
        
        view.addSubview(underLayerView)
        
        // Dismiss the action sheet controller when detects a tap.
        let tapGestureRecognizer = UITapGestureRecognizer(
            target: self, action: #selector(ActionSheetController.dismiss(tap:))
        )
        
        underLayerView.addGestureRecognizer(tapGestureRecognizer)
        
        setUpActionSheet()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        UIView.animate(withDuration: 0.3) {
            self.actionSheet.frame.origin.y -= self.actionSheetTotalHeight
        }
        
        if screenShotImage != nil {
            let operationQueue = OperationQueue()
            
            operationQueue.addOperation(applyBlurEffect)
        }
    }
    
    // MARK: - Internal Methods
    func addAction(alertAction: AlertAction) {
        actions.append(alertAction)
    }
    
    // MARK: - Private Methods
    private func setUpActionSheet() {
        var actionSheetTitleItemHeight: CGFloat = 0.0
        var actionSheetTitleItemHeightWithPadding: CGFloat = 0.0
        
        // Create a title label at the top of the action sheet if title is available.
        if title != nil {
            // Calculate the bounding rect for the title.
            let titleBoundingRect = (title! as NSString).boundingRect(
                with: CGSize(width: screenSize.width, height: CGFloat(MAXFLOAT)),
                options: .usesLineFragmentOrigin,
                attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 13.0)],
                context: nil
            )
            
            let titleHeight = titleBoundingRect.size.height
            
            let titleLabel = UILabel()
                
            // Configure the title label.
            titleLabel.text = title
            titleLabel.numberOfLines = 0
            titleLabel.lineBreakMode = .byWordWrapping
            titleLabel.textAlignment = .center
            titleLabel.font = UIFont.systemFont(ofSize: 13.0)
            titleLabel.textColor = UIColor.lightGray
            titleLabel.backgroundColor = UIColor.white.withAlphaComponent(0.8)
            
            actionSheetTitleItemHeight = titleHeight + padding * 6.0
            actionSheetTitleItemHeightWithPadding = actionSheetTitleItemHeight + minorPadding
            
            titleLabel.frame = CGRect(
                x: 0.0,
                y: 0.0,
                width: screenSize.width,
                height: actionSheetTitleItemHeight
            )
            
            actionSheet.addSubview(titleLabel)
        }
        
        let buttonHighlightedImage = UIImage.image(withColor:
            UIColor(colorLiteralRed: 242.0 / 255.0, green: 242.0 / 255.0, blue: 242.0 / 255.0, alpha: 1.0)
        )
        
        // Append buttons to action sheet.
        for index in 0..<actions.count {
            let alertAction = actions[index]
            
            var buttonOriginY: CGFloat = 0.0
            
            if index == actions.count - 1 {
                buttonOriginY = actionSheetTitleItemHeightWithPadding +
                    actionSheetItemHeight * CGFloat(index) + minorPadding * CGFloat(index - 1) + padding
                
                // In the last iteration, we can determine the height of the action sheet.
                actionSheetTotalHeight += (buttonOriginY + actionSheetItemHeight)
            } else {
                buttonOriginY = actionSheetTitleItemHeightWithPadding +
                    actionSheetItemHeight * CGFloat(index) + minorPadding * CGFloat(index)
            }
            
            let button = UIButton(
                frame: CGRect(
                    x: 0.0,
                    y: buttonOriginY,
                    width: screenSize.width,
                    height: actionSheetItemHeight
                )
            )
            
            button.tag = index
            button.backgroundColor = UIColor.white.withAlphaComponent(0.8)
            button.setTitle(alertAction.title, for: .normal)
            button.setTitleColor(alertAction.tintColor, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 18.0)
            button.titleLabel?.textAlignment = .center
            button.setBackgroundImage(buttonHighlightedImage, for: .highlighted)
            button.addTarget(
                self, action: #selector(ActionSheetController.toggleActionSheetButton), for: .touchUpInside
            )
            
            actionSheet.addSubview(button)
        }
        
        // Capture the bottom of the screen with the exact height of the action sheet, blur it when the view did appear.
        captureBottomScreen()
        
        // First put the action sheet at the bottom the screen bounds.
        actionSheet.frame = CGRect(
            x: 0.0, y: screenSize.height, width: screenSize.width, height: actionSheetTotalHeight
        )
        actionSheet.backgroundColor = UIColor(
            red: 238.0 / 255.0, green: 238.0 / 255.0, blue: 238.0 / 255.0, alpha: 1.0
        )
        
        UIApplication.shared.keyWindow?.addSubview(actionSheet)
    }
    
    private func captureBottomScreen() {
        // Take a snapshot of screen and draw it.
        UIGraphicsBeginImageContextWithOptions(
            CGSize(width: screenSize.width, height: actionSheetTotalHeight),
            true,
            0.0
        )
        
        // Renders a snapshot of the complete view hierarchy.
        // Notice the parameter y, this will only draw the bottom view hierarchy with the exact height of the action sheet.
        let result = presentingViewController?.view.drawHierarchy(
            in: CGRect(
                x: 0.0,
                y: -(screenSize.height - actionSheetTotalHeight),
                width: screenSize.width,
                height: screenSize.height
            ),
            afterScreenUpdates: true
        )
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        if let _ = result, result! {
            screenShotImage = image
        }
    }
    
    private func applyBlurEffect() {
        let blurImageView = UIImageView(
            frame: CGRect(x: 0.0, y: 0.0, width: screenSize.width, height: actionSheetTotalHeight)
        )
        
        blurImageView.contentMode = .scaleAspectFill
        blurImageView.clipsToBounds = true
        blurImageView.image = screenShotImage
        
        // Insert the blur image view at index 0.
        DispatchQueue.main.async {
            self.actionSheet.insertSubview(blurImageView, at: 0)
            
            let blurEffect = UIBlurEffect(style: .light)
            
            let visualEffectView = UIVisualEffectView(effect: blurEffect)
            
            visualEffectView.frame = blurImageView.frame
            
            self.actionSheet.insertSubview(visualEffectView, at: 1)
        }
    }
    
    // MARK: - Callback Methods
    @objc private func dismiss(tap: UITapGestureRecognizer) {
        var completionHandler: (() -> Void)?
        
        // Check whether the last alert action is of style cancel.
        // If so, pass the handler to completion handler.
        if actions.last?.style == .cancel {
            completionHandler = actions.last!.handler
        }
        
        // Hide the action sheet first before dismiss self.
        UIView.animate(withDuration: 0.1, animations: {
            self.actionSheet.frame.origin.y += self.actionSheetTotalHeight
            }, completion: {
                _ in
                
                self.dismiss(animated: true, completion: nil)
                
                // Perform the completion handler associated with the last alert action after dismiss.
                completionHandler?()
        })
    }
    
    @objc private func toggleActionSheetButton(button: UIButton) {
        self.dismiss(animated: false, completion: nil)
        
        // Trigger the handler.
        actions[button.tag].handler?()
        
        // Hide the action sheet first before dismiss self.
        UIView.animate(withDuration: 0.1, animations: {
            self.actionSheet.frame.origin.y += self.actionSheetTotalHeight
        }, completion: nil)
    }
}
