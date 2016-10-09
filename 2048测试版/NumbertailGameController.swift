
import UIKit


protocol GameModelProtocol : class {
    func changeScore(_ score : Int)
    func insertTile(_ position : (Int , Int), value : Int)
    func moveOneTile(_ from: (Int, Int), to: (Int, Int), value: Int)
    func moveTwoTiles(_ from: ((Int, Int), (Int, Int)), to: (Int, Int), value: Int)
}

class NumbertailGameController : UIViewController , GameModelProtocol {
    
    var dimension : Int
    var threshold : Int
    
    var bord : GamebordView?
    
    var scoreV : ScoreView?
    
    var gameModle : GameModle?
    
    
    let boardWidth: CGFloat = 280.0
    
    let thinPadding: CGFloat = 3.0
    
    
    let viewPadding: CGFloat = 10.0
    
    let verticalViewOffset: CGFloat = 0.0
    
    init(dimension d : Int , threshold t : Int) {
        dimension = d < 2 ? 2 : d
        threshold = t < 8 ? 8 : t
        super.init(nibName: nil, bundle: nil)
        gameModle = GameModle(dimension: dimension , threshold: threshold , delegate: self )
        view.backgroundColor = UIColor(red : 0xE6/255, green : 0xE2/255, blue : 0xD4/255, alpha : 1)
        setupSwipeConttoller()
    }
    
    func setupSwipeConttoller() {
        let upSwipe = UISwipeGestureRecognizer(target: self , action: "upCommand:")
        upSwipe.numberOfTouchesRequired = 1
        upSwipe.direction = UISwipeGestureRecognizerDirection.up
        view.addGestureRecognizer(upSwipe)
        
        let downSwipe = UISwipeGestureRecognizer(target: self , action: "downCommand:")
        downSwipe.numberOfTouchesRequired = 1
        downSwipe.direction = UISwipeGestureRecognizerDirection.down
        view.addGestureRecognizer(downSwipe)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self , action: "leftCommand:")
        leftSwipe.numberOfTouchesRequired = 1
        leftSwipe.direction = UISwipeGestureRecognizerDirection.left
        view.addGestureRecognizer(leftSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self , action: "rightCommand:")
        rightSwipe.numberOfTouchesRequired = 1
        rightSwipe.direction = UISwipeGestureRecognizerDirection.right
        view.addGestureRecognizer(rightSwipe)
    }
    
    func upCommand(_ r : UIGestureRecognizer) {
        let m = gameModle!
        m.queenMove(MoveDirection.up , completion: { (changed : Bool) -> () in
            if  changed {
                self.followUp()
            }
        })
    }
    
    func downCommand(_ r : UIGestureRecognizer) {
        let m = gameModle!
        m.queenMove(MoveDirection.down , completion: { (changed : Bool) -> () in
            if  changed {
                self.followUp()
            }
        })
    }
    
    func leftCommand(_ r : UIGestureRecognizer) {
        let m = gameModle!
        m.queenMove(MoveDirection.left , completion: { (changed : Bool) -> () in
            if  changed {
                self.followUp()
            }
        })
    }
    
    func rightCommand(_ r : UIGestureRecognizer) {
        let m = gameModle!
        m.queenMove(MoveDirection.right , completion: { (changed : Bool) -> () in
            if  changed {
                self.followUp()
            }
        })
    }
    
    func followUp() {
        assert(gameModle != nil)
        let m = gameModle!
        let (userWon, _) = m.userHasWon()
        if userWon {
            
            let winAlertView = UIAlertController(title: "結果", message: "你贏了", preferredStyle: UIAlertControllerStyle.alert)
            let resetAction = UIAlertAction(title: "重置", style: UIAlertActionStyle.default, handler: {(u : UIAlertAction) -> () in
                self.reset()
            })
            winAlertView.addAction(resetAction)
            let cancleAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.default, handler: nil)
            winAlertView.addAction(cancleAction)
            self.present(winAlertView, animated: true, completion: nil)
           
            return
        }
        
        
        let randomVal = Int(arc4random_uniform(10))
        m.insertRandomPositoinTile(randomVal == 1 ? 4 : 2)
        
       
        if m.userHasLost() {
            
            NSLog("You lost...")
            let lostAlertView = UIAlertController(title: "結果", message: "你輸了", preferredStyle: UIAlertControllerStyle.alert)
            let resetAction = UIAlertAction(title: "重置", style: UIAlertActionStyle.default, handler: {(u : UIAlertAction) -> () in
                self.reset()
            })
            lostAlertView.addAction(resetAction)
            let cancleAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.default, handler: nil)
            lostAlertView.addAction(cancleAction)
            self.present(lostAlertView, animated: true, completion: nil)
        }
    }
    
    func reset() {
        assert(bord != nil && gameModle != nil)
        let b = bord!
        let m = gameModle!
        b.reset()
        m.reset()
        m.insertRandomPositoinTile(2)
        m.insertRandomPositoinTile(2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGame()
    }
    
    func setupGame(){
        let viewWidth = view.bounds.size.width
        let viewHeight = view.bounds.size.height
        
        func xposition2Center(view v : UIView) -> CGFloat{
            let vWidth = v.bounds.size.width
            return 0.5*(viewWidth - vWidth)
            
        }
        
        func yposition2Center(_ order : Int , views : [UIView]) -> CGFloat {
            assert(views.count > 0)
            let totalViewHeigth = CGFloat(views.count - 1)*viewPadding +
                views.map({$0.bounds.size.height}).reduce(verticalViewOffset, {$0 + $1})
            let firstY = 0.5*(viewHeight - totalViewHeigth)
            
            var acc : CGFloat = 0
            for i in 0..<order{
                acc += viewPadding + views[i].bounds.size.height
            }
            return acc + firstY
        }
        
        let width = (boardWidth - thinPadding*CGFloat(dimension + 1))/CGFloat(dimension)
        
        let scoreView = ScoreView(
            backgroundColor:  UIColor(red : 0xA2/255, green : 0x94/255, blue : 0x5E/255, alpha : 1),
            textColor: UIColor(red : 0xF3/255, green : 0xF1/255, blue : 0x1A/255, alpha : 0.5),
            font: UIFont(name: "HelveticaNeue-Bold", size: 16.0) ?? UIFont.systemFont(ofSize: 16.0)
        )
        
        let gamebord = GamebordView(
            dimension : dimension,
            titleWidth: width,
            titlePadding: thinPadding,
            backgroundColor:  UIColor(red : 0x90/255, green : 0x8D/255, blue : 0x80/255, alpha : 1),
            foregroundColor:UIColor(red : 0xF9/255, green : 0xF9/255, blue : 0xE3/255, alpha : 0.5)
        )
        
        let views = [scoreView , gamebord]
        
        var f = scoreView.frame
        f.origin.x = xposition2Center(view: scoreView)
        f.origin.y = yposition2Center(0, views: views)
        scoreView.frame = f
        
        f = gamebord.frame
        f.origin.x = xposition2Center(view: gamebord)
        f.origin.y = yposition2Center(1, views: views)
        gamebord.frame = f
        
        view.addSubview(scoreView)
        view.addSubview(gamebord)
        
        scoreV = scoreView
        bord = gamebord
        
        scoreView.scoreChanged(newScore: 0)
        
        assert(gameModle != nil)
        let modle = gameModle!
        modle.insertRandomPositoinTile(2)
        modle.insertRandomPositoinTile(2)
        
    }
    
    
    
    
    func changeScore(_ score : Int){
        assert(scoreV != nil)
        let s =  scoreV!
        s.scoreChanged(newScore: score)
    }
    
    
    func insertTile(_ pos : (Int , Int) , value : Int){
        assert(bord != nil)
        let b = bord!
        b.insertTile(pos, value: value)
    }
    
    func moveOneTile(_ from: (Int, Int), to: (Int, Int), value: Int) {
        assert(bord != nil)
        let b = bord!
        b.moveOneTiles(from, to: to, value: value)
    }
    
    func moveTwoTiles(_ from: ((Int, Int), (Int, Int)), to: (Int, Int), value: Int) {
        assert(bord != nil)
        let b = bord!
        b.moveTwoTiles(from, to: to, value: value)
    }
    
}
