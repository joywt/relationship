//: Playground - noun: a place where people can play

import UIKit

/*
 关系】f:父,m:母,h:夫,w:妻,s:子,d:女,xb:兄弟,ob:兄,lb:弟,xs:姐妹,os:姐,ls:妹
 
 【修饰符】 &o:年长,&l:年幼,#:隔断,[a|b]:并列
 */


// 算法分析
/*
 
 1. 我的爸爸的妻子(f,w) = 妈妈(m)
 2. 我的姐姐的弟弟(os,lb) = 自己/弟弟/哥哥 ["","lb","ob"]
 */




// 返回称谓集合

var dataSource:[String:[Any]]? {
    if let filePath = Bundle.main.path(forResource: "data", ofType: "json"){
        let fileUrl = URL(fileURLWithPath: filePath, isDirectory: true)
        if let fileData = try? Data(contentsOf: fileUrl, options: []) {
            if let data = try? JSONSerialization.jsonObject(with: fileData, options: JSONSerialization.ReadingOptions.mutableContainers) as? Dictionary<String,Array<Any>> {
                return data
            }
        }
        return nil
    }else {
        return nil
    }
}
let data = dataSource

// 关系链检索集合

var relationShipSource:[[String:String]]? {
    if let filePath = Bundle.main.path(forResource: "filter", ofType: "json") {
        let fileUrl = URL.init(fileURLWithPath: filePath, isDirectory: true)
        if let fileData = try? Data(contentsOf: fileUrl, options: []){
            if let data = try? JSONSerialization.jsonObject(with: fileData, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String:Any]{
                if let filter = data?["filter"] as? Array<Dictionary<String,String>> {
                    return filter
                }
            }
            
        }
        return nil
    }else {
        return nil
    }
}

let filter = relationShipSource

// 称谓转换成关联字符

// 是否反转
var reverse = false

func transformTitleToKey(str:String) -> String? {
    var result = String()
    if !str.isEmpty{
        var lists = str.components(separatedBy: "的")
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

class FilteHelper {
    var result: Array<String>
    let filterData = relationShipSource
    var hash = Set<String>()
    init() {
        result = Array()
    }
    
    func filt(input:String) {
        var theInputStr = input
        if !hash.contains(theInputStr) {
            hash.insert(theInputStr)
            if theInputStr.isEmpty { // "" 指 我，直接添加不进行检索
                result.append(theInputStr)
            }else{
                var temp = String()
                var status = true
                repeat {
                    temp = str
                    if let fd = filterData {
                        for item in fd {
                            let exp:String = item["exp"] ?? ""
                            let str:String = item["str"] ?? ""
                            let replacer: RegexHelper = try! RegexHelper(exp)
                            theInputStr = replacer.replace(input: theInputStr, template: str)
                            print(theInputStr)
                            
                            if theInputStr.contains("#"){
                                let sepSource = str.components(separatedBy: "#")
                                for key in sepSource {
                                    print(key)
                                    filt(input: key)
                                }
                                status = false
                                break
                            }
                        }
                    }
                }while temp != str
                
                if (status){
                    result.append(theInputStr)
                }
            }
        }
    }

}



// 从数据源中查找对应 key 的结果

func dataValueByKeys(result:Array<String>) -> String? {
    var dataValue = String()
    var array = Array<String>()
    for key in result {
        var temp = key
        if !temp.isEmpty {
            temp.remove(at: temp.startIndex)
        }
        let errorMes = errorMessage(key: temp)
        if  errorMes.isEmpty {
            let value  = valueByKey(key: temp)
            if  let value = value {
                array.append(value)
            }else {
                
                array = getData(d: temp)
                if array.isEmpty {
                    temp
                    let replacer: RegexHelper = try! RegexHelper("[ol]") // 过滤兄弟、姐妹这种大小关系
                    let newkey = replacer.replace(input: temp, template: "")
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

        }else {
            dataValue = errorMes
            break
        }
        
    }
    if dataValue.isEmpty {
        if (array.isEmpty){
            dataValue = "关系有点远，再玩就坏了"
        }else {
            for v in array {
                dataValue = dataValue + "/\(v)"
            }
            dataValue.remove(at: dataValue.startIndex)
        }
    }
    
    return dataValue
}

func errorMessage(key:String) -> String{
    var message = String()
    switch key {
    case "ob,h","xb,h","lb,h","os,w","ls,w","xs,w":
        message = "根据我国法律暂不支持同性婚姻，怎么称呼你自己决定吧"
        break
    default: break
    }
    return message
}
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

func calculate(str:String) -> String {
    if let keys = transformTitleToKey(str: str){
        let filterHelper = FilteHelper()
        filterHelper.filt(input: keys)
        if let  result = dataValueByKeys(result: filterHelper.result){
            return result
        }
        
    }
    return "计算错误"
}
var str  = "我的哥哥的妈妈的爸爸"
calculate(str: str)
