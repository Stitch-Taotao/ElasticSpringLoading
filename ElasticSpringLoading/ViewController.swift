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
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.white
        let animateView = ElasticSpringLoading(frame: CGRect.init(x: 0, y: 150, width: view.bounds.size.width, height: 100))//You can display text
        let attriString = NSMutableAttributedString(string: "我简直信了邪了!!!")
        attriString.addAttributes([NSFontAttributeName:UIFont.systemFont(ofSize: 16.0)], range:NSRange.init(location: 0, length: 3))
        attriString.addAttributes([NSForegroundColorAttributeName:UIColor.blue], range: NSRange.init(location: 1, length: 3))
        animateView.attriString = attriString
        view.addSubview(animateView)
        
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) {[weak self] (timer) in
            guard let weakSelf = self else{return}
            let index = Int(arc4random()%(UInt32((weakSelf.strings.count))))
            if let string = self?.strings[index]{
                let attriString = NSMutableAttributedString(string:string)
                animateView.attriString = attriString
                
            }
        }
        DispatchQueue.main.asyncAfter(deadline:.now() + 10) {
            animateView.stopAnimtate()
        }
    }

}

