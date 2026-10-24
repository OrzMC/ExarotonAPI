//
//  File.swift
//
//
//  Created by joker on 2024/5/15.
//

import Foundation

/// exaroton 服务器状态码（https://developers.exaroton.com/ → "Server status"）。
///
/// ```
/// 0 = OFFLINE   1 = ONLINE   2 = STARTING   3 = STOPPING   4 = RESTARTING
/// 5 = SAVING    6 = LOADING  7 = CRASHED    8 = PENDING    9 = TRANSFERRING
/// 10 = PREPARING
/// ```
///
/// ⚠️ **必须覆盖全部官方取值**：这个枚举参与 WebSocket `status` 消息的解码，
/// 少一个值就意味着"整个状态消息解码失败 → 状态更新被丢掉"（实测漏了 9 = TRANSFERRING，
/// 服务器启动/停止期间的迁移阶段状态会卡住不动）。
/// 另外解码是**宽容**的：将来 exaroton 新增状态码时退化成 `.UNKNOWN`，而不是让整条消息失败。
public enum ServerStatus: Int, CaseIterable, Codable {
    case OFFLINE = 0
    case ONLINE = 1
    case STARTING = 2
    case STOPPING = 3
    case RESTARTING = 4
    case SAVING = 5
    case LOADING = 6
    case CRASHED = 7
    case PENDING = 8
    case TRANSFERRING = 9
    case PREPARING = 10

    /// 未知/未来新增的状态码。调用方应把它当成"过渡态"处理（不允许动作，等状态稳定）。
    case UNKNOWN = -1

    public init(from decoder: any Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(Int.self)
        self = ServerStatus(rawValue: raw) ?? .UNKNOWN
    }
}

public struct Server: Codable, Identifiable {
    public let id: String
    public let name: String
    public let address: String
    public let motd: String
    public let status: ServerStatus
    public let host: String?
    public let port: Int?
    public let players: Players
    public let software: Software?
    public let shared: Bool
}

public struct Players: Codable {
    public let max: Int
    public let count: Int
    public let list: [String]
}

public struct Software: Codable, Identifiable {
    public let id: String
    public let name: String
    public let version: String
}

public struct Tick: Codable {
    public let averageTickTime: Double
}

public struct Stats: Codable {
    public struct Memory: Codable {
        public let percent: Double
        public let usage: Double
    }
    public let memory: Memory

    public struct CPU: Codable {
        public let percent: Double
        public let usage: Double
        public let limit: Int
    }
    public let cpu: CPU
}

public struct Heap: Codable {
    public let usage: Int64
}
