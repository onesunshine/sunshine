
import UIKit

class GamebordView : UIView {
    var dimension : Int
    var tileWidth : CGFloat
    var tilePadding : CGFloat
    
    let provider = AppearanceProvider()
    
    let tilePopStartScale: CGFloat = 0.1
    let tilePopMaxScale: CGFloat = 1.1
    let tilePopDelay: TimeInterval = 0.05
    let tileExpandTime: TimeInterval = 0.18
    let tileContractTime: TimeInterval = 0.08
    
    let tileMergeStartScale: CGFloat = 1.0
    let tileMergeExpandTime: TimeInterval = 0.08
    let tileMergeContractTime: TimeInterval = 0.08
    
    let perSquareSlideDuration: TimeInterval = 0.08
    
    var tiles : Dictionary<IndexPath , TileView>
    
    init(dimension d : Int, titleWidth width : CGFloat, titlePadding padding : CGFloat, backgroundColor : UIColor, foregroundColor : UIColor ) {
        dimension = d
        tileWidth = width
        tilePadding = padding
        tiles = Dictionary()
        let totalWidth = tilePadding + CGFloat(dimension)*(tilePadding + tileWidth)
        super.init(frame : CGRect(x: 0, y: 0, width: totalWidth, height: totalWidth))
        setColor(backgroundColor: backgroundColor , foregroundColor: foregroundColor)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setColor(backgroundColor bgcolor : UIColor, foregroundColor forecolor : UIColor){
        self.backgroundColor = bgcolor
        var xCursor = tilePadding
        var yCursor : CGFloat
        
        for _ in 0..<dimension{
            yCursor = tilePadding
            for _ in 0..<dimension {
                let tileFrame = UIView(frame : CGRect(x: xCursor, y: yCursor, width: tileWidth, height: tileWidth))
                tileFrame.backgroundColor = forecolor
                tileFrame.layer.cornerRadius = 8
                addSubview(tileFrame)
                yCursor += tilePadding + tileWidth
            }
            xCursor += tilePadding + tileWidth
        }
        
    }
    
    func reset() {
        for (_, tile) in tiles {
            tile.removeFromSuperview()
        }
        tiles.removeAll(keepingCapacity: true)
    }

    
    func insertTile(_ pos : (Int , Int) , value : Int) {
        assert(positionIsValied(pos))
        let (row , col) = pos
        let x = tilePadding + CGFloat(row)*(tilePadding + tileWidth)
        let y = tilePadding + CGFloat(col)*(tilePadding + tileWidth)
        let tileView = TileView(position : CGPoint(x: x, y: y), width: tileWidth, value: value, delegate: provider)
        addSubview(tileView)
        bringSubview(toFront: tileView)
        
        tiles[IndexPath(row : row , section:  col)] = tileView
        
        UIView.animate(withDuration: tileExpandTime, delay: tilePopDelay, options: UIViewAnimationOptions(),
            animations: {
                tileView.layer.setAffineTransform(CGAffineTransform(scaleX: self.tilePopMaxScale, y: self.tilePopMaxScale))
            },
            completion: { finished in
                UIView.animate(withDuration: self.tileContractTime, animations: { () -> Void in
                tileView.layer.setAffineTransform(CGAffineTransform.identity)
            })
        })
    }
    
    func positionIsValied(_ position : (Int , Int)) -> Bool{
        let (x , y) = position
        return x >= 0 && x < dimension && y >= 0 && y < dimension
    }
    
    func moveOneTiles(_ from : (Int , Int)  , to : (Int , Int) , value : Int) {
        let (fx , fy) = from
        let (tx , ty) = to
        let fromKey = IndexPath(row: fx , section: fy)
        let toKey = IndexPath(row: tx, section: ty)
        
        guard let tile = tiles[fromKey] else{
            assert(false, "not exists tile")
        }
        let endTile = tiles[toKey]
        
        var changeFrame = tile.frame
        changeFrame.origin.x = tilePadding + CGFloat(tx)*(tilePadding + tileWidth)
        changeFrame.origin.y = tilePadding + CGFloat(ty)*(tilePadding + tileWidth)
        
        tiles.removeValue(forKey: fromKey)
        tiles[toKey] = tile
        
       
        let shouldPop = endTile != nil
        UIView.animate(withDuration: perSquareSlideDuration,
                                   delay: 0.0,
                                   options: UIViewAnimationOptions.beginFromCurrentState,
                                   animations: {
                                    // Slide tile
                                    tile.frame = changeFrame
            },
                                   completion: { (finished: Bool) -> Void in
                                    tile.value = value
                                    endTile?.removeFromSuperview()
                                    if !shouldPop || !finished {
                                        return
                                    }
                                    tile.layer.setAffineTransform(CGAffineTransform(scaleX: self.tileMergeStartScale, y: self.tileMergeStartScale))
                                    
                                    UIView.animate(withDuration: self.tileMergeExpandTime,
                                        animations: {
                                            tile.layer.setAffineTransform(CGAffineTransform(scaleX: self.tilePopMaxScale, y: self.tilePopMaxScale))
                                        },
                                        completion: { finished in
                                            // Contract tile to original size
                                            UIView.animate(withDuration: self.tileMergeContractTime, animations: {
                                                tile.layer.setAffineTransform(CGAffineTransform.identity)
                                            }) 
                                    })
        })
    }
    
    func moveTwoTiles(_ from: ((Int, Int), (Int, Int)), to: (Int, Int), value: Int) {
        assert(positionIsValid(from.0) && positionIsValid(from.1) && positionIsValid(to))
        let (fromRowA, fromColA) = from.0
        let (fromRowB, fromColB) = from.1
        let (toRow, toCol) = to
        let fromKeyA = IndexPath(row: fromRowA, section: fromColA)
        let fromKeyB = IndexPath(row: fromRowB, section: fromColB)
        let toKey = IndexPath(row: toRow, section: toCol)
        
        guard let tileA = tiles[fromKeyA] else {
            assert(false, "placeholder error")
        }
        guard let tileB = tiles[fromKeyB] else {
            assert(false, "placeholder error")
        }
        
        var finalFrame = tileA.frame
        finalFrame.origin.x = tilePadding + CGFloat(toRow)*(tileWidth + tilePadding)
        finalFrame.origin.y = tilePadding + CGFloat(toCol)*(tileWidth + tilePadding)
        
        let oldTile = tiles[toKey]  
        oldTile?.removeFromSuperview()
        tiles.removeValue(forKey: fromKeyA)
        tiles.removeValue(forKey: fromKeyB)
        tiles[toKey] = tileA
        
        UIView.animate(withDuration: perSquareSlideDuration,
                                   delay: 0.0,
                                   options: UIViewAnimationOptions.beginFromCurrentState,
                                   animations: {
                                    
                                    tileA.frame = finalFrame
                                    tileB.frame = finalFrame
            },
                                   completion: { finished in
                                    tileA.value = value
                                    tileB.removeFromSuperview()
                                    if !finished {
                                        return
                                    }
                                    tileA.layer.setAffineTransform(CGAffineTransform(scaleX: self.tileMergeStartScale, y: self.tileMergeStartScale))
                                    
                                    UIView.animate(withDuration: self.tileMergeExpandTime,
                                        animations: {
                                            tileA.layer.setAffineTransform(CGAffineTransform(scaleX: self.tilePopMaxScale, y: self.tilePopMaxScale))
                                        },
                                        completion: { finished in
                                            // Contract tile to original size
                                            UIView.animate(withDuration: self.tileMergeContractTime, animations: {
                                                tileA.layer.setAffineTransform(CGAffineTransform.identity)
                                            }) 
                                    })
        })
    }
    
    func positionIsValid(_ pos: (Int, Int)) -> Bool {
        let (x, y) = pos
        return (x >= 0 && x < dimension && y >= 0 && y < dimension)
    }
}
