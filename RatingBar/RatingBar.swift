//  基本原理：在这个RatingBar里面分别创建两个子View，一个覆盖另一个，每个子View创建numStars个UIImageView，然后通过修改rating的值来控制最顶层的子View可见范围来实现Rating数值变化效果
//  RatingBar.swift
//  RatingBar
//
//  Created by Sai on 15/4/22.
//  Copyright (c) 2015年 Sai. All rights reserved.
//

import UIKit
//@IBDesignable 在视图中拖入控件可以看到渲染情况，结果出现以下错误，http://stackoverflow.com/questions/27374330/ibdesignable-error-ib-designables-failed-to-update-auto-layout-status-interf 这里也是一样情况，暂时无解
//error: IB Designables: Failed to update auto layout status: Interface Builder Cocoa Touch Tool crashed
//error: IB Designables: Failed to render instance of PlaceholderTextView: Rendering the view took longer than 200 ms. Your drawing code may suffer from slow performance.
class RatingBar: UIView {
    
    @IBInspectable var rating: CGFloat = 0{//当前数值
        didSet{
            if 0 > rating {rating = 0}
            else if ratingMax < rating {rating = ratingMax}
            //回调给代理
            delegate?.ratingDidChange(self, rating: rating)

            self.setNeedsLayout()
        }
    }
    @IBInspectable var ratingMax: CGFloat = 5//总数值,必须为numStars的倍数
    @IBInspectable var numStars: Int = 5 //星星总数
    @IBInspectable var canAnimation: Bool = false//是否开启动画模式
    @IBInspectable var animationTimeInterval: NSTimeInterval = 0.2//动画时间
    @IBInspectable var incomplete:Bool = false//评分时是否允许不是整颗星星
    @IBInspectable var isIndicator:Bool = false//RatingBar是否是一个指示器（用户无法进行更改）
    
    @IBInspectable var imageLight: UIImage = UIImage(named: "ic_ratingbar_star_light")!
    @IBInspectable var imageDark: UIImage = UIImage(named: "ic_ratingbar_star_dark")!

    var foregroundRatingView: UIView!
    var backgroundRatingView: UIView!
    
    var delegate: RatingBarDelegate?
    var isDrew = false
    
    func buildView(){
        if isDrew {return}
        isDrew = true
        //创建前后两个View，作用是通过rating数值显示或者隐藏“foregroundRatingView”来改变RatingBar的星星效果
        self.backgroundRatingView = self.createRatingView(imageDark)
        self.foregroundRatingView = self.createRatingView(imageLight)
        animationRatingChange()
        self.addSubview(self.backgroundRatingView)
        self.addSubview(self.foregroundRatingView)
        //加入单击手势
        let tapGesture = UITapGestureRecognizer(target: self, action: "tapRateView:")
        tapGesture.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapGesture)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        buildView()
        let animationTimeInterval = self.canAnimation ? self.animationTimeInterval : 0
        //开启动画改变foregroundRatingView可见范围
        UIView.animateWithDuration(animationTimeInterval, animations: {self.animationRatingChange()})
    }
    //改变foregroundRatingView可见范围
    func animationRatingChange(){
        var realRatingScore = self.rating / self.ratingMax
        self.foregroundRatingView.frame = CGRectMake(0, 0,self.bounds.size.width * realRatingScore, self.bounds.size.height)

    }
    //根据图片名，创建一列RatingView
    func createRatingView(image: UIImage) ->UIView{
        var view = UIView(frame: self.bounds)
        view.clipsToBounds = true
        view.backgroundColor = UIColor.clearColor()
        //开始创建子Item,根据numStars总数
        for position in 0 ..< numStars{
            var imageView = UIImageView(image: image)
            imageView.frame = CGRectMake(CGFloat(position) * self.bounds.size.width / CGFloat(numStars), 0, self.bounds.size.width / CGFloat(numStars), self.bounds.size.height)
            imageView.contentMode = UIViewContentMode.ScaleAspectFit
            view.addSubview(imageView)
        }
        return view
    }
    //点击编辑分数后，通过手势的x坐标来设置数值
    func tapRateView(sender: UITapGestureRecognizer){
        if isIndicator {return}//如果是指示器，就不能交互
        let tapPoint = sender.locationInView(self)
        let offset = tapPoint.x
        //通过x坐标判断分数
        let realRatingScore = offset / (self.bounds.size.width / ratingMax);
        self.rating = self.incomplete ? realRatingScore : round(realRatingScore)

    }
}
protocol RatingBarDelegate{
    func ratingDidChange(ratingBar: RatingBar,rating: CGFloat)
}
