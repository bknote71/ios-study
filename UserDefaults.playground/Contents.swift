import Foundation

// setValue 메소드로 저장한 경우, 해당 값은 기본 데이터 타입(Int, String, Bool 등)일 때 사용
UserDefaults.standard.setValue("a", forKey: "a")
let value = UserDefaults.standard.value(forKey: "a")
if let value = value as? String {
    print(value)
}

// [커스텀_클래스]를 UserDefaults에 저장
class PC: NSObject, NSSecureCoding {
    static var supportsSecureCoding: Bool = true

    let id: String
    let name: String
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }

    required init?(coder: NSCoder) {
        guard 
            let id = coder.decodeObject(forKey: "id") as? String,
                let name = coder.decodeObject(forKey: "name") as? String
        else {
            return nil
        }
        self.id = id
        self.name = name
    }

    func encode(with coder: NSCoder) {
        coder.encode(id, forKey: "id")
        coder.encode(name, forKey: "name")
    }
}

var pcArray: [PC] = []
pcArray.append(PC(id: "1", name: "1"))
pcArray.append(PC(id: "2", name: "2"))
pcArray.append(PC(id: "3", name: "3"))

let encodedData = try? NSKeyedArchiver.archivedData(withRootObject: pcArray, requiringSecureCoding: false)
UserDefaults.standard.setValue(encodedData, forKey: "pcArray")

if
    let data = UserDefaults.standard.value(forKey: "pcArray") as? Data,
    let array = try? NSKeyedUnarchiver.unarchivedArrayOfObjects(ofClass: PC.self, from: data)
{
    dump(array)
} else {
    print("실패..")
}


// [Int]
var intArr: [Int] = [1, 2]
UserDefaults.standard.setValue(intArr, forKey: "intArr")
if let arr = UserDefaults.standard.value(forKey: "intArr") as? [Int] {
    dump(arr)
}
