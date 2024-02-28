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
