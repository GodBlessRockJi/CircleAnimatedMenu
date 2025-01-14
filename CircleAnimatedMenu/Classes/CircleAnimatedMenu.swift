//
//  CircleAnimatedMenu.swift
//  Pods
//
//  Created by Alexandr Honcharenko on 2/2/17.
//
//

import Foundation
import ChameleonFramework

@IBDesignable open class CircleAnimatedMenu: UIControl ,UIGestureRecognizerDelegate {
    
    // MARK: - Public properties
    
    // Inner radius of menu
    @IBInspectable public var innerRadius: CGFloat = 30 {
        didSet {
            let maxInnerRadius = self.frame.size.height > self.frame.size.width - secLabelSize ?
            self.frame.size.width / 2  - 20 : self.frame.size.height / 2 - 20
            innerRadius = innerRadius > maxInnerRadius ? maxInnerRadius : innerRadius
            update()
        }
    }
    
    // Outer radius of menu
    @IBInspectable public var outerRadius: CGFloat = 75 {
        didSet {
            let maxOuterRadius = self.frame.size.height > self.frame.size.width ? self.frame.size.width / 2 : self.frame.size.height / 2
            outerRadius = outerRadius > maxOuterRadius ? maxOuterRadius : outerRadius
            update()
        }
    }
    
    // Width of line between sections and central circle
    @IBInspectable public var closerBorderWidth: CGFloat = 2 {
        didSet {
            update()
        }
    }
    
    // Width of border menu
    @IBInspectable public var farBorderWidth: CGFloat = 0 {
        didSet {
            update()
        }
    }
    
    // Menu fill color
    @IBInspectable public var menuFillColor: UIColor = .darkGray {
        didSet {
            update()
        }
    }
    
    // Menu background color - color of layer that lies under section layers and inner circle layer
    @IBInspectable public var menuBackgroundColor: UIColor = .white {
        didSet {
            update()
        }
    }
    
    // Inner circle color
    @IBInspectable public var innerCircleColor: UIColor = .darkGray {
        didSet {
            update()
        }
    }
    
    // Color of section after selection
    @IBInspectable public var highlightedColor: UIColor = .blue {
        didSet {
            update()
        }
    }
    
    // Color of line between slices and central circle
    @IBInspectable public var closerBorderColor: UIColor = .white {
        didSet {
            update()
        }
    }
    
    // Border menu color
    @IBInspectable public var farBorderColor: UIColor = .white {
        didSet {
            update()
        }
    }
    
    // Sections stroke color
    @IBInspectable public var sectionsStrokeColor: UIColor = .white {
        didSet {
            update()
        }
    }
    
    // Text color
    @IBInspectable public var textColor: UIColor = .white {
        didSet {
            update()
        }
    }
    
    // Shadow color
    @IBInspectable public var shadowColor: UIColor = .lightGray {
        didSet {
            update()
        }
    }
    
    // Shadow radius
    @IBInspectable public var menuShadowRadius: CGFloat = 15 {
        didSet {
            update()
        }
    }
    
    // Duration it takes to sections to expand
    public var animDuration: Double = 1.0 {
        didSet {
            update()
        }
    }
    
    // Menu width line
    @IBInspectable public var menuWidthLine: CGFloat = 0 {
        didSet {
            update()
        }
    }
    
    // Text font - to set font and font size of text
    @IBInspectable public var titleFont: UIFont = UIFont.systemFont(ofSize: 13) {
        didSet {
            update()
        }
    }
    
    // Image size value
    public var secLabelSize: CGFloat = 30 {
        didSet {
            update()
        }
    }
    
    // Default highlighted section index. Set it if you want to highlight some section at start
    @IBInspectable public var defaulHighlightedtSectionIndex: Int = -1 {
        didSet {
            update()
        }
    }
    
    // Delegate
    public weak var delegate: CircleAnimatedMenuDelegate?
    
    // set animation state. Default - true
    public var animated: Bool = true {
        didSet {
            update()
        }
    }
    
    // Data
    public var tuplesArray: [(String, String, String)] = [] {
        didSet {
            update()
        }
    }
    
    // You can set highlighted colors array if you want to highlight each section separately
    public var highlightedColors: [UIColor] = [] {
        didSet {
            update()
        }
    }
    
    // MARK: - Privete properties
    
    var sectionLayers: [CAShapeLayer] = []
    var secLabelLayers: [CALayer] = []
    var mainCircleLayer = CAShapeLayer()
    var borderCircleLayer = CAShapeLayer()
    var imageCircleLayer = CAShapeLayer()
    var imageLayer = CALayer()
    var selectedSectionIndex: Int = 0
    var previousIndexes: [Int] = []
    var previousIndex: Int = -1
    var startAngle:CGFloat = 0.0
    var endAngle:CGFloat = 0.0
    var isInCircle = 0
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public init(menuFrame: CGRect, dataArray: [(String, String , String)]) {
        
        tuplesArray = dataArray
        super.init(frame: menuFrame)
        let longPressedRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture))
        self.addGestureRecognizer(longPressedRecognizer)
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(gestureRecognized(gesture:)))
        self.addGestureRecognizer(panGestureRecognizer)
        let tapGestureReconizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.addGestureRecognizer(tapGestureReconizer)
        // 设置手势的代理
        longPressedRecognizer.delegate = self
        panGestureRecognizer.delegate = self
        update()
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(gestureRecognized(gesture:)))
        self.addGestureRecognizer(gestureRecognizer)
        update()
        
    }
    
    // MARK: - UpdatingUI
    
    func updateUI() {
        
        setInitialValues()
        
        sectionLayers.removeAll()
        let center: CGPoint = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        
        // init mainCircleLayer
        mainCircleLayer = CAShapeLayer()
        let mainCirclePath = UIBezierPath(ovalIn: CGRect(x: center.x - outerRadius, y: center.y - outerRadius,
                                                     width: 2 * outerRadius, height: 2 * outerRadius))
        mainCircleLayer.fillColor = UIColor.clear.cgColor
        mainCircleLayer.lineWidth = farBorderWidth
        mainCircleLayer.strokeColor = UIColor.clear.cgColor
        mainCircleLayer.path = mainCirclePath.cgPath
        self.layer.addSublayer(mainCircleLayer)
        
        // init borderCircleLayer - mask layer to draw border
        borderCircleLayer = CAShapeLayer()
        let borderCirclePath = UIBezierPath(ovalIn: CGRect(x: center.x - outerRadius, y: center.y - outerRadius,
                                                          width: 2 * outerRadius, height: 2 * outerRadius))
        borderCircleLayer.fillColor = UIColor.clear.cgColor
        borderCircleLayer.lineWidth = farBorderWidth
        borderCircleLayer.strokeColor = UIColor.clear.cgColor
        borderCircleLayer.path = borderCirclePath.cgPath
        
        let width : CGFloat =  1 / CGFloat(tuplesArray.count)
        let imageRadius = ((outerRadius - innerRadius) / 2) + innerRadius
        for (index, value) in tuplesArray.enumerated() {

            // init sectionLayer
            let sectionLayer = CAShapeLayer()
            sectionLayer.fillColor = CGColor.fromHex(value.2)//menuFillColor.cgColor
            sectionLayer.strokeColor = sectionsStrokeColor.cgColor
            sectionLayer.lineWidth = menuWidthLine
            let path = UIBezierPath()
            path.move(to: center)
            endAngle = startAngle + width * CGFloat.pi * 2.0
            path.addArc(withCenter: center, radius: outerRadius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            path.addLine(to: center)
            path.close()
            sectionLayer.path = path.cgPath
            
            // init imageLayer - layer inside sectionLayer which contains image
            let middleEndAngle:CGFloat = startAngle + width / 2 * CGFloat.pi * 2.0
            let secLabelLayer = CATextLayer()
//            let secLabel = UILabel()//UIImage(named: value.0)
            secLabelLayer.string = value.1
//            imageLayer.frame = CGRect(x: center.x - innerRadius + 4, y: center.y - titleFont.pointSize /
//                                  2, width: 2 * innerRadius - 8, height: titleFont.pointSize + 4)
//            imageLayer.contents = secLabel

            secLabelLayer.fontSize = fontSize(forLineHeight: secLabelSize, font: UIFont.systemFont(ofSize: 16)) * 0.8
            var textWidth = calculateTextLayerWidth(for: value.1, font: UIFont.systemFont(ofSize: secLabelLayer.fontSize))
            var textHeight = secLabelSize
            

            if textWidth >= imageRadius * 0.9{
                textWidth = textWidth * 0.7
                textHeight = secLabelSize * 2
            }
            while textWidth >= imageRadius * 0.9{
                textWidth = textWidth * 0.9
                secLabelLayer.fontSize = secLabelLayer.fontSize * 0.95
            }
            
            let imageX = (imageRadius * cos(middleEndAngle)) + center.x - textWidth / 2
            let imageY = (imageRadius * sin(middleEndAngle)) + center.y - textHeight / 2
            secLabelLayer.frame = CGRect(x: imageX, y: imageY, width: textWidth, height:textHeight)
            secLabelLayer.contentsScale = UIScreen.main.scale
            secLabelLayer.foregroundColor = UIColor.black.cgColor//textColor.cgColor
            secLabelLayer.backgroundColor = UIColor.clear.cgColor
//            secLabelLayer.position = CGPoint(x: secLabelLayer.position.x, y: secLabelLayer.frame.midY)
            secLabelLayer.alignmentMode = .center
            secLabelLayer.isWrapped = true
            secLabelLayer.truncationMode = .end
            secLabelLayer.font = UIFont.systemFont(ofSize: 16)//CTFontCreateWithName((titleFont.fontName as CFString?)!, titleFont.pointSize,  nil)
//            secLabelLayer.fontSize = titleFont.pointSize
            sectionLayer.contentsGravity = .resizeAspect
            secLabelLayer.mask = sectionLayer
            secLabelLayers.append(secLabelLayer)
            
            // add sectionLayer to array
            sectionLayers.append(sectionLayer)
            
            // add animation to sectionLayer
            let animation = CABasicAnimation(keyPath: "path")
            animation.duration = animDuration
            let initialPath = UIBezierPath()
            initialPath.move(to: center)
            initialPath.addArc(withCenter: center, radius: 1, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            initialPath.addLine(to: center)
            initialPath.close()
            animation.fromValue = initialPath.cgPath
            animation.toValue = sectionLayer.path
            animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
            animation.setValue(index, forKey: "id")
            animation.fillMode = .forwards
            animation.isRemovedOnCompletion = false
            if animated {
                animation.delegate = self
                sectionLayer.add(animation, forKey: String(index))
            }

            // change start angle
            startAngle = endAngle
        }
        
        // init textCircleLayer - circle layer which shows title of each section
        imageCircleLayer = CAShapeLayer()
        let circlePath = UIBezierPath(ovalIn: CGRect(x: center.x - innerRadius, y: center.y - innerRadius,
                                                             width: 2 * innerRadius, height: 2 * innerRadius))
        imageCircleLayer.fillColor = innerCircleColor.cgColor
        imageCircleLayer.strokeColor = closerBorderColor.cgColor
        imageCircleLayer.lineWidth = closerBorderWidth
        imageCircleLayer.path = circlePath.cgPath
        
        // init textLayer - special layer to show text
        imageLayer = CALayer()
        imageLayer.frame = CGRect(x: center.x - innerRadius * 0.7, y: center.y - innerRadius * 0.7,
                                  width: 2 * innerRadius * 0.7, height: 2 * innerRadius * 0.7)
        //CGRect(x: center.x - innerRadius + 4, y: center.y - titleFont.pointSize /
          //                2, width: 2 * innerRadius - 8, height: titleFont.pointSize + 4)
        imageLayer.contentsScale = UIScreen.main.scale
        imageLayer.backgroundColor = UIColor.clear.cgColor
        let image = UIImage()
        imageLayer.contents = image.cgImage
        
        
        self.setNeedsLayout()
    }
    
    fileprivate func highlightDefaultSection() {
        let highlightedSecttion = sectionLayers[defaulHighlightedtSectionIndex]
        highlightedSecttion.fillColor = highlightedColor.cgColor
        imageLayer.contents = UIImage(named: tuplesArray[defaulHighlightedtSectionIndex].0)?.cgImage
    }
    
    fileprivate func showSlices() {
        for sectionLayer in sectionLayers {
            self.layer.addSublayer(sectionLayer)
            if !animated {
                let secLabelLayerIndex = sectionLayers.firstIndex(of: sectionLayer)
                sectionLayer.addSublayer(secLabelLayers[secLabelLayerIndex!])
            }
        }
        if (!animated) {
            setStateAfterAnimation()
        }
    }
    
    // MARK: - Handle Touches
    
    override open func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.beginTracking(touch, with: event)
        
        let touchPoint = touch.location(in: self)
        for shapeLayer in sectionLayers {
            let currentIndex = sectionLayers.index(of: shapeLayer)!
            if ((shapeLayer.path?.contains(touchPoint))! && !(imageCircleLayer.path?.contains(touchPoint))!) {
                if highlightedColors.isEmpty {
                    shapeLayer.fillColor = CGColor.fromHex(darkenHexColor(tuplesArray[currentIndex].2)!)//highlightedColor.cgColor
                } else {
                    shapeLayer.fillColor = CGColor.fromHex(darkenHexColor(tuplesArray[currentIndex].2)!)//highlightedColors[0].cgColor
                }
                selectedSectionIndex = currentIndex
                let currentImage = UIImage(named: tuplesArray[selectedSectionIndex].0)?.cgImage
                imageLayer.contents = currentImage
            }
        }
        
        return true
    }
    
    override open func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        
        clearData()
        delegate?.sectionSelected(text: tuplesArray[selectedSectionIndex].1, index: selectedSectionIndex)
    }
    
    // MARK: - UIPanGestureRecognizer methods
    
    @objc func gestureRecognized(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            let location = gesture.location(in: self)
            fillSectionIn(location: location)
            
        case .changed:
            let location = gesture.location(in: self)
            fillSectionIn(location: location)
            
        case .ended:
//            clearData()
            delegate?.sectionSelected(text: tuplesArray[selectedSectionIndex].1, index: selectedSectionIndex)
            // 模拟延迟触发动画移除
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.removeViewWithAnimation(self)
                    }
        default:
            break
        }
        
    }
    @objc func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
        guard let longPressedView = gesture.view?.superview else { return }
            switch gesture.state {
            case .began:
                let location = gesture.location(in: self)
                fillSectionIn(location: location)
            case .ended, .cancelled:
//                clearData()
                delegate?.sectionSelected(text: tuplesArray[selectedSectionIndex].1, index: selectedSectionIndex)
                // 模拟延迟触发动画移除
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.removeViewWithAnimation(self)
                        }
            default:
                break
            }
        }
    
    // MARK: - UIPanGestureRecognizer methods
    
    @objc func handleTap(gesture: UITapGestureRecognizer) {
        
        let location = gesture.location(in: self)
        fillSectionIn(location: location)
//        clearData()
        delegate?.sectionSelected(text: tuplesArray[selectedSectionIndex].1, index: selectedSectionIndex)
    // 模拟延迟触发动画移除
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.removeViewWithAnimation(self)
            }
        
    }
    // 允许多个手势同时工作
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }
    
    func removeViewWithAnimation(_ view: UIView) {
            UIView.animate(withDuration: 0.2, // 动画持续时间
                           delay: 0, // 无延迟
                           options: [.curveEaseInOut], // 动画选项
                           animations: {
                view.alpha = 0 // 渐隐动画
                view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1) // 缩小动画
            }, completion: { _ in
                view.removeFromSuperview() // 动画结束后移除视图
            })
        }
    
    // MARK: - Helpers
    
    func fillSectionIn(location: CGPoint) {
        
        for shapeLayer in sectionLayers {
            let currentIndex = sectionLayers.index(of: shapeLayer)!
            if ((shapeLayer.path?.contains(location))! && !(imageCircleLayer.path?.contains(location))!) {
                let inCircle = 1
                isInCircle = isInCircle + inCircle
                if previousIndex != currentIndex{
                    // 创建震动反馈生成器（点击时通常使用 .medium 或 .light）
                        let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
                        
                        // 准备震动反馈
                        feedbackGenerator.prepare()
                        
                        // 触发震动反馈
                        feedbackGenerator.impactOccurred()
                    previousIndex = currentIndex
                }
                selectedSectionIndex = currentIndex
                let currentImage = UIImage(named: tuplesArray[selectedSectionIndex].0)?.cgImage
                imageLayer.contents = currentImage
                if highlightedColors.isEmpty {
                    shapeLayer.fillColor = CGColor.fromHex(darkenHexColor(tuplesArray[selectedSectionIndex].2)!)
                } else {
                    shapeLayer.fillColor = CGColor.fromHex(darkenHexColor(tuplesArray[selectedSectionIndex].2)!)
                }
                
            } else {
                shapeLayer.fillColor = CGColor.fromHex(tuplesArray[currentIndex].2)
                
            }
            
        }
        if isInCircle != 0 {
            isInCircle = 0
        } else {
            previousIndex = -1
        }
    }
    
    func clearData() {
//        for shapeLayer in sectionLayers {
//            shapeLayer.fillColor = menuFillColor.cgColor
//        }
//        if highlightedColors.isEmpty {
//            sectionLayers[selectedSectionIndex].fillColor = CGColor.fromHex(darkenHexColor(tuplesArray[selectedSectionIndex].2)!)//highlightedColor.cgColor
//        } else {
//            sectionLayers[selectedSectionIndex].fillColor = CGColor.fromHex(darkenHexColor(tuplesArray[selectedSectionIndex].2)!)//highlightedColors[0].cgColor
//        }
        previousIndexes.removeAll()
    }
    
    func update() {
        updateUI()
        showSlices()
    }
    
    func setInitialValues() {
        
        sectionLayers = [CAShapeLayer]()
        secLabelLayers = [CALayer]()
        mainCircleLayer.fillColor = UIColor.clear.cgColor
        borderCircleLayer.fillColor = UIColor.clear.cgColor
        borderCircleLayer.strokeColor = UIColor.clear.cgColor
        imageCircleLayer.fillColor = UIColor.clear.cgColor
//        imageLayer.foregroundColor = UIColor.clear.cgColor
        previousIndexes = []
        startAngle = 0.0
        endAngle = 0.0
    }
    
    func setStateAfterAnimation() {
        mainCircleLayer.strokeColor = farBorderColor.cgColor
        mainCircleLayer.fillColor = menuBackgroundColor.cgColor
        borderCircleLayer.strokeColor = farBorderColor.cgColor
        self.layer.addSublayer(imageCircleLayer)
        imageCircleLayer.addSublayer(borderCircleLayer)
        imageCircleLayer.addSublayer(imageLayer)
        mainCircleLayer.shadowRadius = menuShadowRadius
        mainCircleLayer.shadowOffset = CGSize(width: 0, height: 0)
        mainCircleLayer.shadowColor = shadowColor.cgColor
        mainCircleLayer.shadowOpacity = 0.8
        if defaulHighlightedtSectionIndex > 0 {
            highlightDefaultSection()
        }
    }
    // 函数：调整颜色亮度
    func darkenHexColor(_ hex: String) -> String? {
        // 确保百分比在 [0, 1] 范围内
        let percentage = 0.3//max(min(percentage, 1), 0)
        
        // 检查合法性
        guard hex.count == 6 || hex.count == 8 else { return nil }
        
        // 提取 RGB 分量
        var rgbValue: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgbValue)
        
        let hasAlpha = hex.count == 8
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
        let alpha = hasAlpha ? CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0 : 1.0
        
        // 调整亮度
        let darkenedRed = max(red * (1 - percentage), 0)
        let darkenedGreen = max(green * (1 - percentage), 0)
        let darkenedBlue = max(blue * (1 - percentage), 0)
        
        // 将调整后的颜色重新编码为 Hex
        let darkenedRGB = (hasAlpha ? Int(alpha * 255) << 24 : 0) |
                          (Int(darkenedRed * 255) << 16) |
                          (Int(darkenedGreen * 255) << 8) |
                          Int(darkenedBlue * 255)

        let format = hasAlpha ? "%08X" : "%06X"
        return String(format: format, darkenedRGB)
    }
    
    
    func fontSize(forLineHeight targetLineHeight: CGFloat, font: UIFont) -> CGFloat {
        let currentLineHeight = font.lineHeight
        let fontSize = font.pointSize
        return targetLineHeight / (currentLineHeight / fontSize)
    }
    func calculateTextLayerWidth(for text: String, font: UIFont) -> CGFloat {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font
        ]
        let size = (text as NSString).size(withAttributes: attributes)
        return size.width
    }
    
}

extension CircleAnimatedMenu: CAAnimationDelegate {
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
        if anim.value(forKey: "id") as! Int == sectionLayers.count - 1 {
            for sectionLayer in sectionLayers {
                let secLabelLayerIndex = sectionLayers.firstIndex(of: sectionLayer)
                secLabelLayers[secLabelLayerIndex!].removeFromSuperlayer()
                sectionLayer.addSublayer(secLabelLayers[secLabelLayerIndex!])
            }
            setStateAfterAnimation()
        }
    }
    
}
extension CGColor {
    /// 通过16进制字符串生成CGColor
    /// - Parameters:
    ///   - hex: 16进制颜色字符串（支持格式：#RRGGBB 或 #RRGGBBAA）
    ///   - alpha: 透明度（当字符串中不包含透明度时使用）
    /// - Returns: 可选CGColor对象
    static func fromHex(_ hex: String, alpha: CGFloat = 1.0) -> CGColor? {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        // 检查是否有前缀#
        if hexString.hasPrefix("#") {
            hexString.removeFirst()
        }
        
        // 检查字符串长度是否有效
        guard hexString.count == 6 || hexString.count == 8 else {
            return nil
        }
        
        // 转换16进制字符串为RGB(A)值
        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)
        
        let red, green, blue, alphaValue: CGFloat
        if hexString.count == 6 {
            // RRGGBB
            red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
            green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
            blue = CGFloat(rgbValue & 0x0000FF) / 255.0
            alphaValue = alpha
        } else {
            // RRGGBBAA
            red = CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0
            green = CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0
            blue = CGFloat((rgbValue & 0x0000FF00) >> 8) / 255.0
            alphaValue = CGFloat(rgbValue & 0x000000FF) / 255.0
        }
        
        return CGColor(red: red, green: green, blue: blue, alpha: alphaValue)
    }
}
