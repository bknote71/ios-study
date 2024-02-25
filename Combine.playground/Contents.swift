import Combine

// Subject
// Publisher protocol을 직접 구현하는 대신 손쉽게 사용할 수 있음

// PassthroughSubject
// - on demand publish (by calling send(_:))
// - sink 호출 이후 값(이벤트)을 받을 수 있다.

// CurrentValueSubject
// - 현재 값(underlying value)을 가지고 있고, send(_:) 호출 시마다 publish
// - 최초의 sink 호출 시에 현재 가지고 있는 값을 publish 해준다.

// 예) 커스텀_버튼 클래스의 tap
// - 최초 sink 시에 publish X
// - sink 이후의 send 부터 publish 해준다.
let tap = PassthroughSubject<Void, Never>()
tap.send()
tap.sink { print("tap!") }
tap.send() // print("tap!")
tap.send() // print("tap!")


let age = CurrentValueSubject<Int, Never>(18)
age.send(19)
age.send(19) // sink시 현재 가지고 있는 값을 publish
age.sink { print("age", $0) } // print("age", 19) (현재값)
age.send(20) // print("age", 20)
age.send(20) // print("age", 20)
age.send(21) // print("age", 21)

// dropFirst: 첫 번째 요소 제거
// removeDuplicates: 중복 요소 제거

// 예) CurrentValueSubject + dropFirst
// CurrentValueSubject에서 첫 번째 요소를 제거한다는 것은, 최초 sink 호출 시의 현재 값을 publish 하는 것을 처리하지 않는다는 것!
let count = CurrentValueSubject<Int, Never>(1)
count
    .dropFirst()
    .sink { print("count", $0) }

count.send(2)
count.send(3)

// 예) CurrentValueSubject + removeDuplicates
// - 이벤트가 2번 통과해야 호출된다.
count
    .dropFirst() // 최초 X
    .removeDuplicates { // 상세한 조건 정의
        print("old:", $0, "new:", $1)
        return $0 == $1
    }
    .sink { print("removed duplicates count", $0) }

count.send(4) // 1
count.send(4) // 2
count.send(5) // 3

// Q. 여기서의 old value는 removeDuplicates를 통과한 값이겠죠? O
struct Member: Identifiable {
    var id: String
    var name: String?
    var age: Int?

    static func == (lhs: Member, rhs: Member) -> Bool {
        return lhs.id == rhs.id
    }
}

let members = CurrentValueSubject<Member, Never>(Member(id: "1", name: "bk"))
members
    .removeDuplicates {
        print("old:", $0, "new:", $1)
        return $0 == $1
    }
    .sink { print("member", $0) }

members.send(Member(id: "1", name: "bk2"))

// cf) static func == 를 오버라이드하는 것은 Equatable 프로토콜을 채택하는 것? X
// 즉 == 를 오버라이드하면 == 연산자 자체는 사용 가능하나, Equatable 프로토콜은 아닌 것!!!
let x = Member(id: "x")
print(x is (any Equatable)) // false
