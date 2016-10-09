
import Foundation

enum TileEnum {
    case empty
    case tile(Int)
}

enum MoveDirection {
    case up,down,left,right
}

enum TileAction{
    case noaction(source : Int , value : Int)
    case move(source : Int , value : Int)
    case singlecombine(source : Int , value : Int)
    case doublecombine(firstSource : Int , secondSource : Int , value : Int)
    
    func getValue() -> Int {
        switch self {
        case let .noaction(_, value) : return value
        case let .move(_, value) : return value
        case let .singlecombine(_, value) : return value
        case let .doublecombine(_, _, value) : return value
        }
    }
    
    func getSource() -> Int {
        switch self {
        case let .noaction(source , _) : return source
        case let .move(source , _) : return source
        case let .singlecombine(source , _) : return source
        case let .doublecombine(source , _ , _) : return source
        }
    }
}

enum MoveOrder{
    case singlemoveorder(source : Int , destination : Int , value : Int , merged : Bool)
    case doublemoveorder(firstSource : Int , secondSource : Int , destination : Int , value : Int)
}

struct SequenceGamebord<T> {
    var demision : Int
    var tileArray : [T]
    
    init(demision d : Int , initValue : T ){
        self.demision = d
        tileArray = [T](repeating: initValue , count: d*d)
    }
    
    subscript(row : Int , col : Int) -> T {
        get{
            assert(row >= 0 && row < demision && col >= 0 && col < demision)
            return tileArray[demision*row + col]
        }
        set{
            assert(row >= 0 && row < demision && col >= 0 && col < demision)
            tileArray[demision*row + col] = newValue
        }
    }
    
    mutating func setAll(_ value : T){
        for i in 0..<demision {
            for j in 0..<demision {
                self[i , j] = value
            }
        }
    }
}
