//
//  CurvyText.swift
//  AnimationStudy
//
//  Created by I_MT on 2017/4/5.
//  Copyright © 2017年 I_MT. All rights reserved.
//
// GitHub : https://github.com/Stitch-Taotao
// 简书 :  http://www.jianshu.com/u/59df4965d888

import UIKit


class MtTextView: UIView {
    
    
    var attributeString :NSAttributedString {
        set{
            self.textStorage.setAttributedString(newValue)
            self.caculatePoints()
           // setNeedsDisplay() //心急
        }
        get{
          return self.textStorage
        }
    }
    
    let layoutManager = NSLayoutManager()
    let textStorage = NSTextStorage()
    let textContainer = NSTextContainer()
    
    
    let startView = UIView()
    let endView = UIView()
    let controlView = UIView()
    
    var p0 = CGPoint()
    var p1 = CGPoint()
    var p2 = CGPoint()
    
    
    var middleTextPoint = CGPoint()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        startView.bounds = CGRect.init(x: 0, y: 0, width: 5, height: 5)
        endView.bounds = CGRect.init(x: 0, y: 0, width: 5, height: 5)
        controlView.bounds = CGRect.init(x: 0, y: 0, width: 5, height: 5)
        self.addSubview(startView)
        self.addSubview(endView)
        self.addSubview(controlView)
        if isDebug {
            startView.backgroundColor = UIColor.red
            controlView.backgroundColor = UIColor.yellow
            endView.backgroundColor = UIColor.green
        }
        textContainer.lineFragmentPadding = 0.0
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        caculatePoints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func caculatePoints()  {
       let suggestSize = sizeForText(mutableStr: attributeString)
       //高度设置为40  距离底部15
       startView.center.x = bounds.size.width/2.0-suggestSize.width/2.0
       startView.center.y = bounds.size.height - 15
       //由于计算的不太准确，多加了10
       endView.center.x = bounds.size.width/2.0 + suggestSize.width/2.0
       endView.center.y = bounds.size.height - 15
       
       controlView.center = CGPoint.init(x: bounds.size.width/2.0, y: bounds.size.height - 15)
       p0 = startView.center
       p1 = controlView.center
       p2 = endView.center
       updatePoints()
    }
    
    func sizeForText(mutableStr:NSAttributedString) -> CGSize {
        //创建CTFramesetterRef实例
        let frameSetter = CTFramesetterCreateWithAttributedString(mutableStr)
        
        //获得要绘制区域的高度
        let restricSize = CGSize.init(width:bounds.size.width, height:10000)
        let coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter,CFRangeMake(0, 0), nil, restricSize, nil)
        return coreTextSize
    }

    func updatePoints()  {
        if let layer1 = startView.layer.presentation() {p0 = layer1.position}
        if let layer2 = controlView.layer.presentation() { p1 = layer2.position}
        if let layer3 = endView.layer.presentation(){p2 = layer3.position}
    
    }
    lazy var  displayLink:CADisplayLink = {
        let link =  CADisplayLink(target:self, selector: #selector(displayAction))
        link.add(to: .main, forMode:.commonModes)
        return link
    }()
    func displayAction()  {
        let oldPoint = p1;
        updatePoints()
        if oldPoint.y != p1.y {
            setNeedsDisplay()
        }
    }
    func startLink(){
        displayLink.isPaused = false
    }
    func stopLink()  {
        displayLink.isPaused = true
    }
    deinit {
        displayLink.invalidate()
    }
    func animate() {
       startLink()
       
       let moveAniamtion = CAKeyframeAnimation(keyPath: "position.y")
       moveAniamtion.values = [0,15,0,-10,0];
       moveAniamtion.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
       moveAniamtion.isAdditive = true
       moveAniamtion.duration = TextBounceDuration
       moveAniamtion.beginTime =  BallDownTime * 0.85
//       moveAniamtion.repeatCount = Float.greatestFiniteMagnitude

       let groupAnimation = CAAnimationGroup()
       groupAnimation.duration = 2 * BallDownTime + TextBounceDuration
       groupAnimation.animations = [moveAniamtion]
       groupAnimation.repeatCount = Float.infinity
       controlView.layer.add(groupAnimation, forKey: "move")
    }
    
    func stopAnimate() {
        controlView.layer.removeAllAnimations()
        setNeedsDisplay()
        displayLink.invalidate()
    }

}


extension MtTextView{
    override func draw(_ rect: CGRect) {
      super.draw(rect)
       if isDebug { drawPath()}
        drawText()
    }

    func drawPath()  {
        let path = UIBezierPath()
        path.move(to: p0)
        path.addQuadCurve(to: p2, controlPoint: p1)
        UIColor.blue.setStroke()
        path.stroke()
    }
    
    func drawText()  {
        if self.attributeString.length == 0 {return}
        
        let context = UIGraphicsGetCurrentContext()
        var glyphRange = NSRange()
        let lineRect = layoutManager.lineFragmentRect(forGlyphAt: 0, effectiveRange: &glyphRange)
        
        var offset:CGFloat = 0
        var lastGlyphPoint = startView.center
        var lastX:CGFloat = 0
        
        for glyphIndex in glyphRange.location..<NSMaxRange(glyphRange) {
            context?.saveGState()
            let location = layoutManager.location(forGlyphAt: glyphIndex)
            let distance = location.x - lastX
            
            offset = self.offset(atDistance: distance, fromPoint: lastGlyphPoint, offset: offset)
            let glphyPoint  = self.point(forOffset: offset)
            let angle = self.angle(forOffset: offset)
            
            lastGlyphPoint = glphyPoint
            lastX = location.x
            
            context?.translateBy(x: glphyPoint.x, y: glphyPoint.y)
            context?.rotate(by: angle)
            
            layoutManager .drawGlyphs(forGlyphRange: NSRange.init(location:glyphIndex, length: 1), at: CGPoint.init(x: -(lineRect.origin.x + location.x), y: -(lineRect.origin.y + location.y)))
            context?.restoreGState()
        }
        
        
    }
    
    class func Bezier(startP p0:CGFloat,control p1:CGFloat,endP p2:CGFloat,offset t:CGFloat)->CGFloat{
        let loop1 =  (1.0 - t) * (1.0-t) * p0
        let loop2 = 2 * (1.0 - t) * t * p1
        let loop3 = t * t * p2
        return loop1+loop2+loop3
    }
    class func BezierPrime(startP p0:CGFloat,control p1:CGFloat,endP p2:CGFloat,offset t:CGFloat)->CGFloat{
        let loop1 = (2 * t - 2) * p0
        let loop2 = 2.0 * (1.0 - 2.0 * t) * p1
        let loop3 = 2.0 * t * p2
        return loop1+loop2+loop3
    }
    class func distance(p1:CGPoint,p2:CGPoint)->CGFloat{
        let dx = p1.x - p2.x
        let dy = p1.y - p2.y
        return hypot(dx,dy)
    }
    
    func point(forOffset offset:CGFloat) -> CGPoint {
        let x = MtTextView.Bezier(startP:p0.x, control:p1.x, endP: p2.x, offset: offset)
        let y = MtTextView.Bezier(startP:p0.y, control:p1.y, endP: p2.y, offset: offset)
        return CGPoint.init(x: x, y: y)
    }
    func angle(forOffset offset:CGFloat)-> CGFloat{
        let dx = MtTextView.BezierPrime(startP:p0.x, control:p1.x, endP:p2.x, offset: offset)
        let dy = MtTextView.BezierPrime(startP:p0.y, control:p1.y, endP: p2.y, offset: offset)
        return atan2(dy, dx)
    }
    
    func offset(atDistance distance:CGFloat ,fromPoint:CGPoint ,offset:CGFloat) -> CGFloat {
        let kStep:CGFloat = 0.001
        var newDistance :CGFloat = 0.0
        var newOffset = offset + kStep
        
        while newDistance <= distance && newOffset < 1.0{
            newOffset += kStep
            newDistance = MtTextView.distance(p1: fromPoint, p2: self.point(forOffset: newOffset))
        }
        return  newOffset
    }
}
