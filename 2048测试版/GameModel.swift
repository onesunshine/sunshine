//
//  GameModel.swift
//  2048测试版
//
//  Created by qianfeng on 16/8/29.
//  Copyright © 2016年 joke. All rights reserved.
//


import UIKit


class GameModle : NSObject {
    
    let dimension : Int
    let threshold : Int
    
    var gamebord : SequenceGamebord<TileEnum>
    
    unowned let delegate : GameModelProtocol
    
    var score : Int = 0{
        didSet{
            delegate.changeScore(score)
        }
    }
    
    init(dimension : Int , threshold : Int , delegate : GameModelProtocol) {
        self.dimension = dimension
        self.threshold = threshold
        self.delegate = delegate
        gamebord = SequenceGamebord(demision: dimension , initValue: TileEnum.empty)
        super.init()
    }
    
    //---------------move相关
    
    func queenMove(_ direction : MoveDirection , completion : (Bool) -> ()){
        let changed = performMove(direction)
        completion(changed)
        
    }
    
    func performMove(_ direction : MoveDirection) -> Bool {
        
        let getMoveQueen : (Int) -> [(Int , Int)] = { (idx : Int) -> [(Int , Int)] in
            var buffer = Array<(Int , Int)>(repeating: (0, 0) , count: self.dimension)
            for i in 0..<self.dimension {
                switch direction {
                case .up : buffer[i] = (idx, i)
                case .down : buffer[i] = (idx, self.dimension - i - 1)
                case .left : buffer[i] = (i, idx)
                case .right : buffer[i] = (self.dimension - i - 1, idx)
                }
            }
            return buffer
        }
        
        var movedFlag = false
        for i in 0..<self.dimension {
            let moveQueen = getMoveQueen(i)
            let tiles = moveQueen.map({ (c : (Int, Int)) -> TileEnum in
                let (source , value) = c
                return self.gamebord[source , value]
            })
            
            let moveOrders = merge(tiles)
            movedFlag = moveOrders.count > 0 ? true : movedFlag
            
            for order in moveOrders {
                switch order {
                case let .singlemoveorder(s, d, v, m):
                    let (sx, sy) = moveQueen[s]
                    let (dx, dy) = moveQueen[d]
                    if m {
                        self.score += v
                    }
                    gamebord[sx , sy] = TileEnum.empty
                    gamebord[dx , dy] = TileEnum.tile(v)
                    
                    delegate.moveOneTile((sx, sy), to: (dx, dy), value: v)
                case let .doublemoveorder(fs , ts , d , v):
                    let (fsx , fsy) = moveQueen[fs]
                    let (tsx , tsy) = moveQueen[ts]
                    let (dx , dy) = moveQueen[d]
                    self.score += v
                    gamebord[fsx , fsy] = TileEnum.empty
                    gamebord[tsx , tsy] = TileEnum.empty
                    gamebord[dx , dy] = TileEnum.tile(v)
                    
                    delegate.moveTwoTiles((moveQueen[fs], moveQueen[ts]), to: moveQueen[d], value: v)
                    
                }
            }
        }
        return movedFlag
    }
    
    func tileBelowHasSameValue(_ location: (Int, Int), _ value: Int) -> Bool {
        let (x, y) = location
        guard y != dimension - 1 else {
            return false
        }
        if case let .tile(v) = gamebord[x, y+1] {
            return v == value
        }
        return false
    }
    
    func tileToRightHasSameValue(_ location: (Int, Int), _ value: Int) -> Bool {
        let (x, y) = location
        guard x != dimension - 1 else {
            return false
        }
        if case let .tile(v) = gamebord[x+1, y] {
            return v == value
        }
        return false
    }
    
    func reset() {
        score = 0
        gamebord.setAll(.empty)
    }
    
    
    func userHasLost() -> Bool {
        guard getEmptyPosition().isEmpty else {
            
            return false
        }
        
        
        for i in 0..<dimension {
            for j in 0..<dimension {
                switch gamebord[i, j] {
                case .empty:
                    assert(false, "Gameboard reported itself as full, but we still found an empty tile. This is a logic error.")
                case let .tile(v):
                    if tileBelowHasSameValue((i, j), v) || tileToRightHasSameValue((i, j), v) {
                        return false
                    }
                }
            }
        }
        return true
    }
    
    func userHasWon() -> (Bool, (Int, Int)?) {
        for i in 0..<dimension {
            for j in 0..<dimension {
                
                if case let .tile(v) = gamebord[i, j] , v >= threshold {
                    return (true, (i, j))
                }
            }
        }
        return (false, nil)
    }
    
    
    
  
    
    func insertRandomPositoinTile(_ value : Int)  {
        let emptyArrays = getEmptyPosition()
        if emptyArrays.isEmpty {
            return
        }
        let randomPos = Int(arc4random_uniform(UInt32(emptyArrays.count - 1)))
        let (x , y) = emptyArrays[randomPos]
        gamebord[(x , y)] = TileEnum.tile(value)
        delegate.insertTile((x , y), value: value)
    }
    
    func getEmptyPosition() -> [(Int , Int)]  {
        var emptyArrys : [(Int , Int)] = []
        for i in 0..<dimension {
            for j in 0..<dimension {
                if case .empty = gamebord[i , j] {
                    emptyArrys.append((i , j))
                }
            }
        }
        return emptyArrys
    }
    
    
   
    
    func merge(_ group : [TileEnum]) -> [MoveOrder] {
        return convert(collapse(condense(group)))
    }
    
        func condense(_ group : [TileEnum]) -> [TileAction] {
        var buffer = [TileAction]()
        for (index , tile) in group.enumerated(){
            switch tile {
            case let .tile(value) where buffer.count == index :
                buffer.append(TileAction.noaction(source: index, value: value))
            case let .tile(value) :
                buffer.append(TileAction.move(source: index, value: value))
            default:
                break
            }
        }
        return buffer
    }
    
    
    func collapse(_ group : [TileAction]) -> [TileAction] {
        
        var tokenBuffer = [TileAction]()
        var skipNext = false
        for (idx, token) in group.enumerated() {
            if skipNext {
                
                skipNext = false
                continue
            }
            switch token {
            case .singlecombine:
                assert(false, "Cannot have single combine token in input")
            case .doublecombine:
                assert(false, "Cannot have double combine token in input")
            case let .noaction(s, v)
                where (idx < group.count-1
                    && v == group[idx+1].getValue()
                    && GameModle.quiescentTileStillQuiescent(idx, outputLength: tokenBuffer.count, originalPosition: s)):
                
                let next = group[idx+1]
                let nv = v + group[idx+1].getValue()
                skipNext = true
                tokenBuffer.append(TileAction.singlecombine(source: next.getSource(), value: nv))
            case let t where (idx < group.count-1 && t.getValue() == group[idx+1].getValue()):
                
                let next = group[idx+1]
                let nv = t.getValue() + group[idx+1].getValue()
                skipNext = true
                tokenBuffer.append(TileAction.doublecombine(firstSource: t.getSource(), secondSource: next.getSource(), value: nv))
            case let .noaction(s, v) where !GameModle.quiescentTileStillQuiescent(idx, outputLength: tokenBuffer.count, originalPosition: s):
               
                tokenBuffer.append(TileAction.move(source: s, value: v))
            case let .noaction(s, v):
            tokenBuffer.append(TileAction.noaction(source: s, value: v))
            case let .move(s, v):
                
                tokenBuffer.append(TileAction.move(source: s, value: v))
            default:
                
                break
            }
        }
        return tokenBuffer
           }
    
    class func quiescentTileStillQuiescent(_ inputPosition: Int, outputLength: Int, originalPosition: Int) -> Bool {
        
        return (inputPosition == outputLength) && (originalPosition == inputPosition)
    }
    
    
    func convert(_ group : [TileAction]) -> [MoveOrder] {
        var buffer = [MoveOrder]()
        for (idx , tileAction) in group.enumerated() {
            switch tileAction {
            case let .move(s, v) :
                buffer.append(MoveOrder.singlemoveorder(source: s, destination: idx, value: v, merged: false))
            case let .singlecombine(s, v) :
                buffer.append(MoveOrder.singlemoveorder(source: s, destination: idx, value: v, merged: true))
            case let .doublecombine(s, d, v) :
                buffer.append(MoveOrder.doublemoveorder(firstSource: s, secondSource: d, destination: idx, value: v))
            default:
                break
            }
        }
        return buffer
    }
    
    
}
