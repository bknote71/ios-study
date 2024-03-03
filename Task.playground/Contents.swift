// 비동기 에러 핸들링

// 1. Task 블록 내부의 에러
// - Task 블록 내부에서 던져진 에러는 해당 블록 외부로 전파되지 않는다.
// - Result<Success, Failure> 인스턴스에 성공 혹은 에러 결과가 담긴다.

struct TestError: Error {}

func performAsync() async {}
func asyncFn() async -> Bool {
    let task = Task {
        await performAsync()
        throw TestError()
    }
    print("inner task", "result", await task.result)
    return true
}

Task {
    let result = await Task { return await asyncFn() }.result
    switch result {
        case .success(let value):
            print("asyncFn success: \(value)")
        case .failure(let error):
            print("asyncFn failure: \(error)")
    }
}

// 참고: Task.checkCancellation
// - task가 cancel 되면 CancellationError 에러 throw


// 2. continuation 에서의 에러 처리
// - withCheckedThrowingContinuation으로 동기 블럭을 감싼다. (continuation의 목적)
// - continuation.resume(with: Result<Success, Failure>) 을 호출한다.
// - Result가 .failure이면 withCheckedThrowingContinuation 블록 밖으로 에러가 throw 된다.
func errorHandlingInContinuation() async {
    do {
        try await withCheckedThrowingContinuation { continuation in
            syncFn(arg: true, completion: continuation.resume(with:))
        }
    } catch {
        print("error check: \(error)")
    }
}

func syncFn<T>(arg: T, completion: (Result<T, Error>) -> Void) {
    completion(.failure(TestError()))
}

Task {
    print("error handling")
    await errorHandlingInContinuation()
}

// async 콜백의 예외를 밖으로 전달하는 방법
// - task: @escaping () async throws -> Void

// 1. async 함수에서 사용
//    try await task()

// 2. 동기 함수에서 사용
//    let task = Task { 전처리.. try await task() 후처리.. }
//    task.result -> failure -> throw

// 3. 동기 함수를 async로 래핑
//    try await withCheckedThrowingContinuation {
//        continuation.resume(with: .failure)
//    }

// 비동기
import Foundation


// Call to main actor-isolated initializer 'init()' in a synchronous nonisolated context
// actor에 대한 접근은 isolated context에서만 가능 (생성자 역시!)
// 액터는 여러 비동기 컨텍스트(Task)에서 실행될 때 동시 접근 및 변경으로 인한 문제를 방지하기 위한 보호 수단

// Task: (기본적으로) 독립된 실행 컨텍스트를 생성 (자체적으로 "isolated context" 내에서 실행)
//       액터 내에서 사용되는 Task는 isolated context를 상속한다. (같은 액터에 접근할 때 await 사용 X)
//       액터가 아닌 곳에서 사용되는 Task(독립적 isolated-context) 내에서 다른 액터에 접근할 때 await을 사용.

// (중요) 액터의 isolated context 내에서 실행되는 모든 비동기 컨텍스트(Task, async)은 해당 액터의 isolated context를 상속
// 다른 (액터 isolated context의 메서드) 혹은 (비동기 함수)는 상속받지 않는다.
// 매인 엑터에서 실행되는 Task는 isolated-context를 상속하기 때문에 메인 스레드에서 실행된다.
@MainActor
class Main {

    init() {
        print("init Main")
    }

    func task() {
        Task { // (메인) 액터 내에서 실행되는 Task: isolated-context를 상속
            // main actor(isolated) context
            print("thread", Thread.current)
            await asyncfn()                // 같은 액터 컨텍스트
            await anotherIsolatedContext() // 다른 액터 컨텍스트
        }
    }

    func asyncfn() async { // 특정 액터 isolated-context에서 실행되는 async 역시 isolated-context를 상속
        print("asyncfn", Thread.current)
    }
}

func anotherIsolatedContext() async { // 다른 비동기 컨텍스트는 isolated-context를 상속받지 않음
    print("another isolated context", Thread.current)
}

Task { // 액터가 아닌 곳에서 사용되는 Task: 독립적인 isolated-context 생성
    let main = await Main() // 다른 액터에 접근: awiat
    await main.task()       // 다른 액터에 접근: await
}
