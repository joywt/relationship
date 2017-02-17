//: [Previous](@previous)

import Foundation

class Test {
    lazy var str:String = {
        let str = "Hello playground"
        print("xx")
        return str
    }()
}

let test = Test()
test.str
test.str

func randomInRange(range: Range<Int>) -> Int {
    let count = UInt32(range.count)
    return Int(arc4random_uniform(count)) + range.lowerBound
}

for i in 0..<100 {
    print(randomInRange(range: 1..<6))
}



//: [Next](@next)
