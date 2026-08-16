import Foundation
import Testing
@testable import Swabble

@Test
func newestOneMailboxDropsStaleBuffers() async {
    let mailbox = NewestOneMailbox<Int>()
    for value in 1...50 {
        mailbox.yield(value)
    }
    mailbox.finish()

    var seen: [Int] = []
    for await value in mailbox.stream {
        seen.append(value)
    }

    #expect(seen == [50])
}

@Test
func newestOneMailboxAcceptsAfterDrain() async {
    let mailbox = NewestOneMailbox<Int>()
    mailbox.yield(1)
    mailbox.finish()

    var seen: [Int] = []
    for await value in mailbox.stream {
        seen.append(value)
    }
    #expect(seen == [1])
}

@Test
func pipelineStopRunsAfterHookTimeout() async {
    let stops = StopCounter()
    do {
        try await withPipelineStop(stop: { await stops.increment() }, perform: {
            throw HookRunnerError.timedOut
        })
        Issue.record("Expected hook timeout")
    } catch let error as HookRunnerError {
        #expect(error == .timedOut)
    } catch {
        Issue.record("Unexpected error: \(error)")
    }
    #expect(await stops.value == 1)
}

@Test
func pipelineStopRunsAfterSuccess() async throws {
    let stops = StopCounter()
    let result = try await withPipelineStop(stop: { await stops.increment() }, perform: {
        "ok"
    })
    #expect(result == "ok")
    #expect(await stops.value == 1)
}

@Test
func pipelineStopRunsAfterUnsuccessfulHookExit() async {
    let stops = StopCounter()
    do {
        try await withPipelineStop(stop: { await stops.increment() }, perform: {
            throw HookRunnerError.unsuccessfulExit(1)
        })
        Issue.record("Expected unsuccessful hook exit")
    } catch let error as HookRunnerError {
        #expect(error == .unsuccessfulExit(1))
    } catch {
        Issue.record("Unexpected error: \(error)")
    }
    #expect(await stops.value == 1)
}

@Test
func speechPipelineStopWithoutStartIsIdempotent() async {
    let pipeline = SpeechPipeline()
    await pipeline.stop()
    await pipeline.stop()
}

private actor StopCounter {
    private(set) var value = 0

    func increment() {
        value += 1
    }
}
