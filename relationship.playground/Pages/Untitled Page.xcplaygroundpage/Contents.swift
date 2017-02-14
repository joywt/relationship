//: Playground - noun: a place where people can play

import UIKit









/*
 关系】f:父,m:母,h:夫,w:妻,s:子,d:女,xb:兄弟,ob:兄,lb:弟,xs:姐妹,os:姐,ls:妹
 
 【修饰符】 1:男性,0:女性,&o:年长,&l:年幼,#:隔断,[a|b]:并列
 */

// 返回称谓集合
func chengweiData() -> Dictionary<String,Array<Any>>? {
    let filePath = Bundle.main.path(forResource: "data", ofType: "json")
    let fileUrl = URL.init(fileURLWithPath: filePath!, isDirectory: true)
    let fileData = try? Data(contentsOf: fileUrl, options: [])
    if let fileData = fileData {
        let data = try? JSONSerialization.jsonObject(with: fileData, options: JSONSerialization.ReadingOptions.mutableContainers)
        if let data = data as? Dictionary<String,Array<Any>> {
            return data
        }
        
    }
    return nil
}

// 关系链集合
func relationship() -> Array<Dictionary<String,String>>? {
    let filePath = Bundle.main.path(forResource: "filter", ofType: "json")
    let fileUrl = URL.init(fileURLWithPath: filePath!, isDirectory: true)
    let fileData = try? Data(contentsOf: fileUrl, options: [])
    if let fileData = fileData {
        let data:AnyObject! = try? JSONSerialization.jsonObject(with: fileData, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject!
        if let data = data {
            let filter:Array<Dictionary<String,String>> = data["filter"] as! Array<Dictionary<String, String>>
            return filter
        }
        
    }
    return nil
}

let data = chengweiData()
let filter = relationship()

// 是否反转
var reverse = false
// 称谓转换成关联字符
func selectors(str:String) -> String? {
    var result = String()
    if !str.isEmpty{
        var lists = str.components(separatedBy: "的")
        //var match = true
        while lists.count > 0 {
            let name = lists.first
            lists.removeFirst()
            var arr = String()
            var has = false
            if let theData = data {
                for (key,value) in theData {
                    let isContain = value.contains {
                        if let f = $0 as? String {
                            return f == name
                        }
                        return false
                    }
                    
                    if isContain && (key != "") { // 过滤 “我”
                        arr = key
                        has = true
                    }
                }
            }
            if has{
                result.append(",\(arr)")
            }
            
        }
    }
    //result.remove(at: result.startIndex)
    if reverse {
        result = reverseKey(key: result)
    }
    return result
}


struct RegexHelper {
    let regex: NSRegularExpression
    init(_ pattern: String) throws {
        try regex = NSRegularExpression(pattern: pattern, options: .caseInsensitive)
    }
    func replace(input:String,template:String) -> String {
        return regex.stringByReplacingMatches(in: input, options: [], range: NSMakeRange(0, input.utf16.count), withTemplate: template);
    }
}

struct FilteHelper {
    var result: Array<String>
    let filterData = relationship()
    let selector: String
    var hash = Set<String>()
    init(_ input: String) {
        result = Array()
        selector = input
    }
    mutating func filter(input:String){
        var sel = input
        var s = String()
        if (!hash.contains(sel)){
            hash.insert(sel)
            var status = true
            repeat{
                s = sel
                if let temp = filterData {
                    for item in temp {
                        let exp = item["exp"]
                        let str = item["str"]
                        let replacer: RegexHelper = try! RegexHelper(exp!)
                        sel = replacer.replace(input: sel, template: str!)
                        print(sel)
                        if sel.contains("#"){
                            let sep = sel.components(separatedBy: "#")
                            for key in sep {
                                //filterSelectors(selector: key)
                                print(key)
                                filter(input: key)
                            }
                            status = false
                            break
                        }
                    }
                }
            }while s != sel
            
            if (status){
                result.append(sel)
            }
        }
    }
    
    mutating func filterSelectors(){
        filter(input:selector)
    }
}
/*
func filterSelectors(selector:String) -> Array<String>? {
    var result = [String]()
    var sel = filter(input: selector)
    let sep = sel.components(separatedBy: "#")
    if !sep.isEmpty{
        for key in sep {
            //filterSelectors(selector: key)
            sel = filter(input: key)
            result.append(key)
        }
    }else {
        result.append(selector)
    }

    //var hash = Dictionary<String,Bool>()
        return result
}*/

func getData(d:String) -> Array<String>{
    var res = Array<String>()
    let filter =  "[olx]"
    let replacer: RegexHelper = try! RegexHelper(filter)
    if let theData = data {
        for (key,values) in theData {
            let newkey = replacer.replace(input: key, template: "")
            if (newkey == d){
                let value = values.first as! String
                res.append(value)
            }
        }
    }
    
    return res
}


    //return valueByKey(key: newkey)
func valueByKey(key:String) -> String? {
    
    if let theData = data {
        let values = theData[key]
        if let values = values {
            let value = values.first as! String
            return value
        }
        
    }
    return nil
}

func dataValueByKeys(result:Array<String>) -> String? {
    var dataValue = String()
    var array = Array<String>()
    for key in result {
        print(key)
        var temp = key
        if !temp.isEmpty {
            temp.remove(at: temp.startIndex)
        }
        
        let value  = valueByKey(key: temp)
        if  let value = value {
            array.append(value)
        }else {
            
            array = getData(d: temp)
            if array.isEmpty {
                temp
                let replacer: RegexHelper = try! RegexHelper("[ol]") // 过滤兄弟、姐妹这种大小关系
                let newkey = replacer.replace(input: temp, template: "")
                newkey
                array = getData(d: newkey)
            }
            if array.isEmpty {
                let replacer: RegexHelper = try! RegexHelper("[ol]") // 过滤兄弟、姐妹这种大小关系
                let newkey = replacer.replace(input: temp, template: "x")
                array = getData(d: newkey)
            }
            if array.isEmpty {
                let replacer: RegexHelper = try! RegexHelper("x") // 过滤兄弟、姐妹这种大小关系
                var newkey = replacer.replace(input: temp, template: "l")
                array = getData(d: newkey)
                newkey = replacer.replace(input: temp, template: "o")
                array = array + getData(d: newkey)
            }
        }
    }
    for v in array {
        dataValue = dataValue + "/\(v)"
    }
    dataValue.remove(at: dataValue.startIndex)
    return dataValue
}

// 互查 反转

func reverseKey(key:String) -> String {
    var newKey = String()
    let reverseData:[String:String] = [
        "f":"[s|d]",
        "m":"[s|d]",
        "h":"w",
        "w":"h",
        "s":"[f|m]",
        "d":"[f|m]",
        "lb":"[os|ob]",
        "ob":"[ls|lb]",
        "xb":"[xs|xb]",
        "ls":"[os|ob]",
        "os":"[ls|lb]",
        "xs":"[xs|xb]",
    ]
    if !key.isEmpty {
        var temp = key
        temp.remove(at: key.startIndex)
        let keys = temp.components(separatedBy: ",").reversed()
        
        for k in keys {
            let rk = reverseData[k]
            if let rk = rk {
                newKey.append(","+rk)
            }
        }
    }
    
    return newKey
}

var str  = "我的妈妈"
let result = selectors(str: str)

var filterHelper = FilteHelper(result!)
filterHelper.filterSelectors()
filterHelper.result
//filterHelper.filter(input: ",ob")
//dataValueByKeys(result: [",s,d",",d"])
dataValueByKeys(result: filterHelper.result)
