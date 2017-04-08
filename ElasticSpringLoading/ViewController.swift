//
//  ViewController.swift
//  ElasticSpringLoading
//
//  Created by 涛涛 on 2017/4/7.
//  Copyright © 2017年 I_MT. All rights reserved.
// GitHub : https://github.com/Stitch-Taotao
// 简书 :  http://www.jianshu.com/u/59df4965d888
import UIKit

class ViewController: UIViewController {
    let strings = ["我简直信了","Oh,My God!","You can display any text.","Please wait..."]
    var animateView :ElasticSpringLoading!
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.white
        animateView = ElasticSpringLoading(frame: CGRect.init(x: 0, y: 150, width: view.bounds.size.width, height: 100))//You can display text
        let attriString = NSMutableAttributedString(string: "我简直信了邪了!!!")
        attriString.addAttributes([NSFontAttributeName:UIFont.systemFont(ofSize: 16.0)], range:NSRange.init(location: 0, length: 3))
        attriString.addAttributes([NSForegroundColorAttributeName:UIColor.blue], range: NSRange.init(location: 1, length: 3))
        animateView.attriString = attriString
        view.addSubview(animateView)
        
        Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        
        DispatchQueue.main.asyncAfter(deadline:.now() + 10) {
           // self.animateView.stopAnimtate()
        }
    }
    
    func timerAction() {
        
        let index = Int(arc4random()%(UInt32((self.strings.count))))
        let string = strings[index]
        let attriString = NSMutableAttributedString(string:string)
        self.animateView.attriString = attriString
    }
}

