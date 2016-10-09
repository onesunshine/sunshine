
import UIKit

class TileView : UIView{
    
    
    var dict:Dictionary<Int , String> = [2:"fun",4:"joke",8:"独",16:"家",32:"版",64:"本",128:"禁",256:"止",512:"牟",1024:"利",2048:"！"]
    
    var value : Int = 0 {
        didSet{
           
            backgroundColor = delegate.tileColor(value)
            lable.textColor = delegate.numberColor(value)
            lable.text = "\(dict[value]!)"
        }
    }
    
    unowned let delegate : AppearanceProviderProtocol
    
    var lable : UILabel

    init(position : CGPoint, width : CGFloat, value : Int, delegate d: AppearanceProviderProtocol){
        delegate = d
        lable = UILabel(frame : CGRect(x: 0 , y: 0 , width: width , height: width))
        lable.textAlignment = NSTextAlignment.center
        lable.minimumScaleFactor = 0.5
        lable.font = UIFont(name: "HelveticaNeue-Bold", size: 15) ?? UIFont.systemFont(ofSize: 15)
        super.init(frame: CGRect(x: position.x, y: position.y, width: width, height: width))
        addSubview(lable)
        lable.layer.cornerRadius = 6
        
        self.value = value
        backgroundColor = delegate.tileColor(value)
        lable.textColor = delegate.numberColor(value)
        lable.text = "\(dict[value]!)"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


