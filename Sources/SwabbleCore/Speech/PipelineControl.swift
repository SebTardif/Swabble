import Foundation

/// Newest-one mailbox for the microphone tap. Extra buffers drop instead of spawning Tasks.
package struct NewestOneMailbox<Element: Sendable>: Sendable {
    package let stream: AsyncStream<Element>
    private let continuation: AsyncStream<Element>.Continuation

    package init() {
        let pair = AsyncStream.makeStream(of: Element.self, bufferingPolicy: .bufferingNewest(1))
        stream = pair.0
        continuation = pair.1
    }

    package func yield(_ element: Element) {
        continuation.yield(element)
    }

    package func finish() {
        continuation.finish()
    }
}

/// Always stop the speech pipeline when the serve body returns or throws.
package func withPipelineStop<T>(
    stop: @Sendable () async -> Void,
    isolation: isolated (any Actor)? = #isolation,
    perform body: () async throws -> T,
) async throws -> T {
    do {
        let value = try await body()
        await stop()
        return value
    } catch {
        await stop()
        throw error
    }
}
