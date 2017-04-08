//
//  ElasticSpringLoading.swift
//  AnimationStudy
//
//  Created by I_MT on 2017/4/5.
//  Copyright © 2017年 I_MT. All rights reserved.

// GitHub : https://github.com/Stitch-Taotao
// 简书 :  http://www.jianshu.com/u/59df4965d888

import UIKit

let BallDownTime = 0.35
let TextBounceDuration = 0.16
let BallSize = CGSize.init(width: 30, height: 30)

let isDebug:Bool = false

class ElasticSpringLoading: UIView ,CAAnimationDelegate{
    private let textView : MtTextView!
    
    var  attriString:NSAttributedString!{
        didSet{
            textView.attributeString = attriString
        }
    }
    
    var shapeLayers = [CAShapeLayer]()
    let backView  = UIView()
    
    var w:CGFloat!
    var h:CGFloat!
    override init(frame: CGRect) {
        textView = MtTextView(frame: CGRect.init(x: 0, y: frame.size.height-40, width: frame.size.width, height: 40))
        w = frame.size.width
        h = frame.size.height
        super.init(frame: frame)
        setupView()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setupBallLayers()  {
        backView.bounds = CGRect.init(origin: CGPoint.zero, size: BallSize)
        backView.center = CGPoint.init(x: 1/2.0 * w, y: 20)
        self.addSubview(backView)

        let rectAngle = CAShapeLayer()
        let triangle =  CAShapeLayer()
        let pentagram = CAShapeLayer()
        let round = CAShapeLayer()
        
        // Path
        rectAngle.path = rectAnglePath().cgPath
        triangle.path = trianglePath().cgPath
        pentagram.path = pentagramPath().cgPath
        round.path = roundPath().cgPath
        
        // Color
        rectAngle.fillColor = Colors.flatRed.cgColor
        triangle.fillColor = Colors.flatBlue.cgColor
        pentagram.fillColor = Colors.flatGreen.cgColor
        round.fillColor = Colors.flatPink.cgColor
        
        shapeLayers.append(contentsOf: [rectAngle,triangle,pentagram,round])
        
        shapeLayers.enums { (any, index) in
            guard let layer = any as? CAShapeLayer else{return}
            layer.frame = CGRect.init(x: 0, y: 0, width: 40, height: 40)
            backView.layer.addSublayer(layer)
        }
        switchShapLayer()

//        rectAngle.backgroundColor = UIColor.red.cgColor
//        triangle.backgroundColor = UIColor.blue.cgColor
//        pentagram.backgroundColor = UIColor.yellow.cgColor

    }
  
    // #MARK: - PATH
    func roundPath() ->UIBezierPath {
        let ovalPath = UIBezierPath(ovalIn: CGRect.init(x: 4, y: 4, width: 32, height: 32))
        ovalPath.apply(pathTransform)
        return ovalPath
    }
    func rectAnglePath () ->UIBezierPath {
        let rectanglePath = UIBezierPath(rect: CGRect.init(x: 4, y: 4, width: 32, height: 32))
        rectanglePath.apply(pathTransform)
        return rectanglePath
    }
    func trianglePath () -> UIBezierPath {
        let polygonPath = UIBezierPath()
        polygonPath.move(to: CGPoint(x:20,y: 0))
        polygonPath.addLine(to: CGPoint(x:37.32, y:30))
        polygonPath.addLine(to: CGPoint(x:2.68, y:30))
        polygonPath.close()
        polygonPath.apply(pathTransform)
        return polygonPath
    }
    func pentagramPath() -> UIBezierPath {
        let starPath = UIBezierPath()
        starPath.move(to: CGPoint(x:20,y: 0))
        starPath.addLine(to: CGPoint(x:27.05,y: 10.29))
    
            starPath.addLine(to: CGPoint(x:39.02, y:13.82))
        starPath.addLine(to: CGPoint(x:31.41, y:23.71))
        starPath.addLine(to: CGPoint(x:31.76, y:36.18))
        starPath.addLine(to: CGPoint(x:20, y:32))
        starPath.addLine(to: CGPoint(x:8.24,y: 36.18))
        starPath.addLine(to: CGPoint(x:8.59,y: 23.71))
        starPath.addLine(to: CGPoint(x:0.98, y:13.82))
        starPath.addLine(to: CGPoint(x:12.95, y:10.29))
        starPath.close()
        starPath.apply(pathTransform)
        return starPath
    }
    var pathTransform:CGAffineTransform{
        let scaleX =  BallSize.width / 40.0
        let scaleY =  BallSize.height / 40.0
        return CGAffineTransform.identity.scaledBy(x: scaleX, y: scaleY)
    }
    func setUpTextView()  {
        if isDebug { textView.backgroundColor = UIColor.gray }else{textView.backgroundColor = UIColor.clear}
        // textView.backgroundColor = UIColor.gray
        self.addSubview(textView)
        
      //  textView.attributeString = attriString
    }
    func setupView()  {
        setUpTextView()
        setupBallLayers()
        animate()
    }
    
    var timer :Timer?
    
    func animate()  {
        bounceBall()
        self.textView.animate()
        DispatchQueue.global().asyncAfter(deadline: .now() + BallDownTime) {
            if #available(iOS 10.0, *) {
                self.timer =   Timer.scheduledTimer(withTimeInterval: (2 * BallDownTime + TextBounceDuration), repeats: true) { [weak self] (timer)  in
                    self?.switchShapLayer()
                }
            } else {
                self.timer = Timer.scheduledTimer(timeInterval:(2 * BallDownTime + TextBounceDuration) , target: self, selector:#selector(self.switchShapLayer), userInfo: nil, repeats: true)
            }
           
           self.timer!.fire()
           RunLoop.current.add(self.timer!, forMode: .commonModes)
           RunLoop.current.run()
        }

    }
    
    func stopAnimtate() {
        backView.layer.removeAllAnimations()
        self.timer?.invalidate()
        textView.stopAnimate()
    }

    var currentIndex = 0
    
    func switchShapLayer(){
        currentIndex = currentIndex % (shapeLayers.count == 0 ? 1 :shapeLayers.count)
        backView.layer.sublayers?.enums({ (layer, index) in
            guard let layer = layer as? CAShapeLayer else{
                return
            }
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            if index == currentIndex{
                layer.opacity = 1
            }else{
                layer.opacity = 0
            }
            CATransaction.commit()
        })
        currentIndex += 1
    }
    
    
     func bounceBall()  {
     
         let period = 2*BallDownTime + TextBounceDuration
         let keyAnimation = CAKeyframeAnimation(keyPath: "position.y")
         keyAnimation.values = [0,h-20 - backView.bounds.size.height / 2.0,0]
         keyAnimation.duration = BallDownTime * 2
         keyAnimation.isAdditive = true
         keyAnimation.timingFunctions = [CAMediaTimingFunction.init(controlPoints: 0.6, 0.08, 0.91, 0.4),CAMediaTimingFunction.init(controlPoints: 0.08, 0.6, 0.4,0.91)]
         keyAnimation.delegate = self
         let group1 = CAAnimationGroup()
         group1.duration = period
         group1.repeatCount = Float.infinity
         group1.animations = [keyAnimation]
         backView.layer.add(group1, forKey: "drop")
         
            
         let rotateAniamtion = CAKeyframeAnimation(keyPath: "transform.rotation.z")
         //时间决定一个合适的角度
         rotateAniamtion.values = [0, M_PI * (period / (0.9))]
         rotateAniamtion.duration = period
         rotateAniamtion.beginTime = CACurrentMediaTime() + BallDownTime
         rotateAniamtion.repeatCount = Float.infinity
         rotateAniamtion.autoreverses = true
         // rotateAniamtion.beginTime =
         backView.layer.add(rotateAniamtion, forKey: "rotate")


/*
     let group = CAAnimationGroup()
     group.duration = 2 * BallDownTime + TextBounceDuration
     group.animations = [keyAnimation,rotateAniamtion]
     group.repeatCount = Float.infinity
    
     backView.layer.add(group, forKey: "group")
     
     return
*/
    /*
     UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 2.0, options:.curveEaseInOut, animations: { 
      
        var point =  self.backView.center
        point.y = self.h - 20 - self.backView.bounds.size.height / 2.0
        self.backView.center = point
        
        let transform =   self.backView.transform
        transform.rotated(by: CGFloat(Double(2.0 * M_PI)))
        self.backView.transform = transform
        
     }) { (finished) in
        self.textView.animate()
        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 2.0, options:.curveEaseInOut, animations: {
            
            var point =  self.backView.center
            point.y = self.backView.bounds.size.height / 2.0
            self.backView.center = point
            
            let transform =   self.backView.transform
            transform.rotated(by: CGFloat(Double(2.0 * M_PI)))
            self.backView.transform = transform
            
        }) {(finished) in
           
             self.bounceBall()
        
        }
        
     }
    */
    /*
        let moveAnimation = CABasicAnimation(keyPath: "position")
        moveAnimation.toValue = CGPoint.init(x: w * 1/2.0, y: h-20 - backView.bounds.size.height / 2.0)
        moveAnimation.duration = BallDownTime + TextBounceDuration
      //  moveAnimation.autoreverses = true
        
        let rotateAniamtion = CABasicAnimation(keyPath: "transform.rotation.z")
        rotateAniamtion.fromValue = 0
        rotateAniamtion.toValue = -M_PI * 2
        rotateAniamtion.duration = 5.0
        rotateAniamtion.repeatCount = Float.infinity
        
       // rotateAniamtion.autoreverses = true
        let group = CAAnimationGroup()
        group.duration = BallDownTime + TextBounceDuration
//        group.autoreverses = true
        group.animations = [moveAnimation,rotateAniamtion]
        group.repeatCount = Float.infinity
        
        backView.layer.add(group, forKey: "group")
        */
    }
    deinit {
        self.timer?.invalidate()
    }
}

fileprivate extension Array {
    func enums(_ block:(_ item:Any,_ index:Int)->()){
        for (i,obj) in self.enumerated() {
            block(obj,i)
        }
    }
}

fileprivate  extension UIColor {
     convenience init(rgb: (r: CGFloat, g: CGFloat, b: CGFloat)) {
        self.init(red: rgb.r/255, green: rgb.g/255, blue: rgb.b/255, alpha: 1.0)
     }
     convenience init(hsd:( H:CGFloat ,S:CGFloat,D:CGFloat)) {
        self.init(hue: hsd.H, saturation: hsd.S, brightness: hsd.D, alpha: 1.0)
     }
}

fileprivate struct Colors {
   
   static let flatRed = UIColor(hsd: (0.02,0.74,0.91))
   static let flatBlue = UIColor(hsd: (0.62,0.50,0.63))
   static let flatPink =  UIColor(hsd: (0.90,0.49,0.96))
   static let flatGreen = UIColor(hsd: (0.40,0.77,0.80))
}

