package myapp

import std.collection.*

// --- Message types ---

public enum MsgType {
    | DISCOVER
    | ANNOUNCE
    | JOIN
    | JOIN_ACK
    | READY
    | GAME_START
    | PICK_CLASS
    | PICK_RACE
    | DICE_ROLL
    | DICE_ASSIGN
    | SKILL_TOGGLE
    | STATE_SYNC
    | PHASE_CHANGE
    | ATTACK_RESULT
    | DEFEND_RESULT
    | GAME_OVER
    | CHAT
    | LEAVE
    | UNKNOWN

    public operator func ==(right: MsgType): Bool {
        match (this) {
            case DISCOVER => match (right) { case DISCOVER => true; case _ => false }
            case ANNOUNCE => match (right) { case ANNOUNCE => true; case _ => false }
            case JOIN => match (right) { case JOIN => true; case _ => false }
            case JOIN_ACK => match (right) { case JOIN_ACK => true; case _ => false }
            case READY => match (right) { case READY => true; case _ => false }
            case GAME_START => match (right) { case GAME_START => true; case _ => false }
            case PICK_CLASS => match (right) { case PICK_CLASS => true; case _ => false }
            case PICK_RACE => match (right) { case PICK_RACE => true; case _ => false }
            case DICE_ROLL => match (right) { case DICE_ROLL => true; case _ => false }
            case DICE_ASSIGN => match (right) { case DICE_ASSIGN => true; case _ => false }
            case SKILL_TOGGLE => match (right) { case SKILL_TOGGLE => true; case _ => false }
            case STATE_SYNC => match (right) { case STATE_SYNC => true; case _ => false }
            case PHASE_CHANGE => match (right) { case PHASE_CHANGE => true; case _ => false }
            case ATTACK_RESULT => match (right) { case ATTACK_RESULT => true; case _ => false }
            case DEFEND_RESULT => match (right) { case DEFEND_RESULT => true; case _ => false }
            case GAME_OVER => match (right) { case GAME_OVER => true; case _ => false }
            case CHAT => match (right) { case CHAT => true; case _ => false }
            case LEAVE => match (right) { case LEAVE => true; case _ => false }
            case UNKNOWN => match (right) { case UNKNOWN => true; case _ => false }
        }
    }
}

func msgTypeToString(t: MsgType): String {
    match (t) {
        case DISCOVER => "DISCOVER"
        case ANNOUNCE => "ANNOUNCE"
        case JOIN => "JOIN"
        case JOIN_ACK => "JOIN_ACK"
        case READY => "READY"
        case GAME_START => "GAME_START"
        case PICK_CLASS => "PICK_CLASS"
        case PICK_RACE => "PICK_RACE"
        case DICE_ROLL => "DICE_ROLL"
        case DICE_ASSIGN => "DICE_ASSIGN"
        case SKILL_TOGGLE => "SKILL_TOGGLE"
        case STATE_SYNC => "STATE_SYNC"
        case PHASE_CHANGE => "PHASE_CHANGE"
        case ATTACK_RESULT => "ATTACK_RESULT"
        case DEFEND_RESULT => "DEFEND_RESULT"
        case GAME_OVER => "GAME_OVER"
        case CHAT => "CHAT"
        case LEAVE => "LEAVE"
        case _ => "UNKNOWN"
    }
}

func stringToMsgType(s: String): MsgType {
    if (s == "DISCOVER") { return DISCOVER }
    if (s == "ANNOUNCE") { return ANNOUNCE }
    if (s == "JOIN") { return JOIN }
    if (s == "JOIN_ACK") { return JOIN_ACK }
    if (s == "READY") { return READY }
    if (s == "GAME_START") { return GAME_START }
    if (s == "PICK_CLASS") { return PICK_CLASS }
    if (s == "PICK_RACE") { return PICK_RACE }
    if (s == "DICE_ROLL") { return DICE_ROLL }
    if (s == "DICE_ASSIGN") { return DICE_ASSIGN }
    if (s == "SKILL_TOGGLE") { return SKILL_TOGGLE }
    if (s == "STATE_SYNC") { return STATE_SYNC }
    if (s == "PHASE_CHANGE") { return PHASE_CHANGE }
    if (s == "ATTACK_RESULT") { return ATTACK_RESULT }
    if (s == "DEFEND_RESULT") { return DEFEND_RESULT }
    if (s == "GAME_OVER") { return GAME_OVER }
    if (s == "CHAT") { return CHAT }
    if (s == "LEAVE") { return LEAVE }
    UNKNOWN
}

// --- Key-value pair ---

public struct KvPair {
    var key: String
    var value: String

    public init(k: String, v: String) {
        this.key = k
        this.value = v
    }
}

// --- NetMsg: parsed network message ---

public class NetMsg {
    public var msgType: MsgType
    private var pairs: ArrayList<KvPair>

    public init(msgType: MsgType) {
        this.msgType = msgType
        this.pairs = ArrayList<KvPair>()
    }

    public func add(key: String, value: String): Unit {
        pairs.add(KvPair(key, value))
    }

    public func addInt(key: String, value: Int32): Unit {
        pairs.add(KvPair(key, "${value}"))
    }

    public func get(key: String): String {
        for (p in pairs) {
            if (p.key == key) { return p.value }
        }
        ""
    }

    public func getInt(key: String): Int32 {
        parseInt(get(key))
    }

    public func getBool(key: String): Bool {
        getInt(key) != 0
    }

    public func getPairs(): ArrayList<KvPair> {
        pairs
    }

    public func toWire(): String {
        let builder = MsgBuilder(msgType)
        for (p in pairs) {
            builder.add(p.key, p.value)
        }
        builder.build()
    }
}

// --- MsgBuilder: fluent wire-format builder ---

public class MsgBuilder {
    private var msgType: MsgType
    private var parts: ArrayList<String>

    public init(msgType: MsgType) {
        this.msgType = msgType
        this.parts = ArrayList<String>()
        parts.add(msgTypeToString(msgType))
    }

    public func add(key: String, value: String): MsgBuilder {
        parts.add("${key}=${value}")
        this
    }

    public func addInt(key: String, value: Int32): MsgBuilder {
        parts.add("${key}=${value}")
        this
    }

    public func build(): String {
        var s = ""
        var first = true
        for (p in parts) {
            if (!first) { s = s + "|" }
            s = s + p
            first = false
        }
        s
    }
}

// --- Deserialization ---

public func deserialize(raw: String): NetMsg {
    let parts = splitBy(raw, "|")
    if (parts.size == 0) {
        return NetMsg(UNKNOWN)
    }
    let msg = NetMsg(stringToMsgType(parts[0]))
    for (i in 1..Int32(parts.size)) {
        let kv = parts[Int64(i)]
        let eqIdx = indexOf(kv, "=")
        if (eqIdx >= 0) {
            let key = slice(kv, 0, eqIdx)
            let val = slice(kv, eqIdx + 1, Int32(kv.size))
            msg.add(key, val)
        }
    }
    msg
}

// --- TCP stream reader (newline-delimited frames) ---

public class StreamReader {
    private var buffer: String

    public init() {
        buffer = ""
    }

    public func feed(data: String): ArrayList<String> {
        buffer = buffer + data
        let msgs = ArrayList<String>()
        while (true) {
            let nlIdx = indexOf(buffer, "\n")
            if (nlIdx < 0) { break }
            let line = slice(buffer, 0, nlIdx)
            buffer = slice(buffer, nlIdx + 1, Int32(buffer.size))
            if (line.size > 0) {
                msgs.add(line)
            }
        }
        msgs
    }
}

// --- String helpers (work with String, not Rune) ---

func splitBy(s: String, delim: String): ArrayList<String> {
    let result = ArrayList<String>()
    let dlen = Int32(delim.size)
    if (dlen == 0) {
        result.add(s)
        return result
    }
    var start: Int32 = 0
    let len = Int32(s.size)
    var i: Int32 = 0
    while (i <= len - dlen) {
        if (matchAt(s, i, delim)) {
            result.add(slice(s, start, i))
            start = i + dlen
            i = start
        } else {
            i = i + 1
        }
    }
    result.add(slice(s, start, len))
    result
}

func matchAt(s: String, pos: Int32, sub: String): Bool {
    let slen = Int32(sub.size)
    if (pos + slen > Int32(s.size)) { return false }
    var i: Int32 = 0
    while (i < slen) {
        if (charAt(s, pos + i) != charAt(sub, i)) { return false }
        i = i + 1
    }
    true
}

func indexOf(s: String, sub: String): Int32 {
    let slen = Int32(s.size)
    let sublen = Int32(sub.size)
    if (sublen == 0) { return 0 }
    var i: Int32 = 0
    while (i <= slen - sublen) {
        if (matchAt(s, i, sub)) { return i }
        i = i + 1
    }
    -1
}

func charAt(s: String, idx: Int32): String {
    let len = Int32(s.size)
    if (idx < 0 || idx >= len) { return "" }
    // Use substring to extract one char (Cangjie strings are UTF-16 on Windows)
    slice(s, idx, idx + 1)
}

func slice(s: String, start: Int32, end: Int32): String {
    let len = Int32(s.size)
    var a = start
    var b = end
    if (a < 0) { a = 0 }
    if (b > len) { b = len }
    if (a >= b) { return "" }
    // Build result character by character
    var result = ""
    var i: Int32 = 0
    // Cangjie strings support indexed access via runes
    for (r in s.runes()) {
        if (i >= a && i < b) {
            result = result + "${r}"
        }
        i = i + 1
        if (i >= b) { break }
    }
    result
}

func parseInt(s: String): Int32 {
    if (s.size == 0) { return 0 }
    var result: Int32 = 0
    var neg: Bool = false
    var i: Int32 = 0
    let len = Int32(s.size)
    while (i < len) {
        let ch = charAt(s, i)
        if (ch == "-" && i == 0) {
            neg = true
        } else if (ch == "0") { result = result * 10 + 0
        } else if (ch == "1") { result = result * 10 + 1
        } else if (ch == "2") { result = result * 10 + 2
        } else if (ch == "3") { result = result * 10 + 3
        } else if (ch == "4") { result = result * 10 + 4
        } else if (ch == "5") { result = result * 10 + 5
        } else if (ch == "6") { result = result * 10 + 6
        } else if (ch == "7") { result = result * 10 + 7
        } else if (ch == "8") { result = result * 10 + 8
        } else if (ch == "9") { result = result * 10 + 9
        } else { break }
        i = i + 1
    }
    if (neg) { -result } else { result }
}

// --- Int array serialization ---

public func encodeIntArray(arr: ArrayList<Int32>): String {
    if (arr.size == 0) { return "" }
    var s = ""
    var first = true
    for (v in arr) {
        if (!first) { s = s + "," }
        s = s + "${v}"
        first = false
    }
    s
}

public func decodeIntArray(s: String): ArrayList<Int32> {
    let result = ArrayList<Int32>()
    if (s.size == 0) { return result }
    let parts = splitBy(s, ",")
    for (p in parts) {
        result.add(parseInt(p))
    }
    result
}

// --- Bool array serialization ---

public func encodeBoolArray(arr: ArrayList<Bool>): String {
    if (arr.size == 0) { return "" }
    var s = ""
    var first = true
    for (v in arr) {
        if (!first) { s = s + "," }
        s = s + (if (v) { "1" } else { "0" })
        first = false
    }
    s
}

public func decodeBoolArray(s: String): ArrayList<Bool> {
    let result = ArrayList<Bool>()
    if (s.size == 0) { return result }
    let parts = splitBy(s, ",")
    for (p in parts) {
        result.add(p == "1")
    }
    result
}
