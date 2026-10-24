import Foundation
import Testing
@testable import ExarotonWebSocket

/// 状态码解码：文档里的每个取值都必须能解出来。
///
/// 回归背景：枚举曾漏掉 `9 = TRANSFERRING`，导致服务器启动/停止迁移期间的
/// `status` 消息**整条解码失败**，上层看到的就是"状态卡住不动"。
@Suite(.tags(.unit, .websocket, .codec))
final class ServerStatusDecodingTests {

    private func serverJSON(status: Int) -> Data {
        Data("""
        {"id":"X","name":"demo","address":"demo.exaroton.me","motd":"hi","status":\(status),
         "players":{"max":20,"count":0,"list":[]},
         "software":{"id":"1","name":"Paper","version":"1.0"},"shared":false}
        """.utf8)
    }

    @Test(arguments: [
        (0, ServerStatus.OFFLINE),
        (1, ServerStatus.ONLINE),
        (2, ServerStatus.STARTING),
        (3, ServerStatus.STOPPING),
        (4, ServerStatus.RESTARTING),
        (5, ServerStatus.SAVING),
        (6, ServerStatus.LOADING),
        (7, ServerStatus.CRASHED),
        (8, ServerStatus.PENDING),
        (9, ServerStatus.TRANSFERRING),
        (10, ServerStatus.PREPARING),
    ])
    func decodesEveryDocumentedCode(raw: Int, expected: ServerStatus) throws {
        let server = try JSONDecoder().decode(Server.self, from: serverJSON(status: raw))
        #expect(server.status == expected)
        #expect(server.status.rawValue == raw)
    }

    /// 将来 exaroton 新增状态码时不能把整条消息炸掉，退化成 `.UNKNOWN`。
    @Test
    func unknownCodeDegradesInsteadOfThrowing() throws {
        let server = try JSONDecoder().decode(Server.self, from: serverJSON(status: 99))
        #expect(server.status == .UNKNOWN)
    }
}
