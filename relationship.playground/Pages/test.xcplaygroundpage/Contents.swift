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



//: [Next](@next)
