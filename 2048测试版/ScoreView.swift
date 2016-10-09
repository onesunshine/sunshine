
import UIKit

protocol ScoreProtocol{
    func scoreChanged(newScore s : Int)
}

class ScoreView : UIView , ScoreProtocol{

    var lable : UILabel
    
    var score : Int = 0{
        didSet{
            lable.text = "SCORE:\(score)"
        }
    }
    
    let defaultFrame = CGRect(x: 0, y: 0, width: 140, height: 40)
    
    init(backgroundColor bgColor : UIColor, textColor tColor : UIColor , font : UIFont){
        lable = UILabel(frame : defaultFrame)
        lable.textAlignment = NSTextAlignment.center
        super.init(frame : defaultFrame)
        backgroundColor = bgColor
        lable.textColor = tColor
        lable.font = font
        lable.layer.cornerRadius = 6
        self.addSubview(lable)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func scoreChanged(newScore s : Int){
        score = s
    }

}
