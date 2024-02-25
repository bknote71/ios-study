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


