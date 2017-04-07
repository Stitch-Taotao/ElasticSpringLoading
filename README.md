ElasticSpringLoading
---


ElasticSpringLoading is a sample simulated text spring effect . Inspired by [不烂漫的罪名](http://m.zcool.com.cn/work/ZMTI1Nzk3MjA=.html)

#### ![cn](https://raw.githubusercontent.com/gosquared/flags/master/flags/flags/shiny/24/China.png) **Chinese (Simplified)**: 

##### [中文说明](README.zh.md) 


![Screenshots](bounceBall.gif)


## Requirements

swift3.0,iOS 8.0+ 

## Usage

```
let animateView = ElasticSpringLoading(frame: CGRect.init(x: 0, y: 100, width: view.bounds.size.width, height: 100))//You can display text
let attriString = NSMutableAttributedString(string: "Your Text")//Your text should not wrap,just support one line
animateView.attriString = attriString

self.view.addSubview(animateView)


```

You can change text at any time in main thread ,just do this :

```
animateView.attriString = newAttriString

```

## Install

**Manually**

1. Download the latest code version 
2. Open your project in Xcode,drag the `ElasticSpringLoading` folder into your project.  Make sure to select Copy items when asked if you extracted the code archive outside of your project.
3. Build your project


##Contributing

Contributors are more than welcome.Pull your request 

If you have some suggestion or find my mistake, hope you point out
 

## Contacts

#### If you wish to contact me, email at: xyfqldy@163.com

#### Blog : [jianshu](http://www.jianshu.com/users/59df4965d888)


## License

ElasticSpringLoading is released under the [MIT license](LICENSE). See LICENSE for details.



