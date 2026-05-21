package myapp

import std.collection.*
import cjform.*

// ===== Simple RNG =====
public class Rng {
    private var counter: Int64

    public init() {
        counter = Int64(0)
    }

    public func nextInt(max: Int32): Int32 {
        counter = counter + Int64(1)
        let tick = ffi_getTickCount()
        let combined = tick + counter
        let r = combined % Int64(max)
        if (r < Int64(0)) {
            Int32(r + Int64(max) + Int64(1))
        } else {
            Int32(r + Int64(1))
        }
    }

    // Returns 0.0 .. 1.0 as Float32
    public func nextFloat(): Float32 {
        Float32(nextInt(1000)) / Float32(1000)
    }
}

// ===== Character Data =====
public struct CharData {
    public let id: Int32
    public let name: String
    public let desc: String
    public let maxHP: Int32
    public let activeSkillCost: Int32
    public let passiveSkillThreshold: Int32
    public let attackMul: Float32
    public let damageMul: Float32
    public let dicenum: Int32
    public let ATKnum: Int32
    public let DMGnum: Int32

    public init(id: Int32, name: String, desc: String, maxHP: Int32,
                activeSkillCost: Int32, passiveSkillThreshold: Int32,
                attackMul: Float32, damageMul: Float32,
                dicenum: Int32, ATKnum: Int32, DMGnum: Int32) {
        this.id = id
        this.name = name
        this.desc = desc
        this.maxHP = maxHP
        this.activeSkillCost = activeSkillCost
        this.passiveSkillThreshold = passiveSkillThreshold
        this.attackMul = attackMul
        this.damageMul = damageMul
        this.dicenum = dicenum
        this.ATKnum = ATKnum
        this.DMGnum = DMGnum
    }
}

// All available classes
public func getAllClasses(): ArrayList<CharData> {
    let list = ArrayList<CharData>()
    list.add(CharData(1, "剑士", "均衡型 — 攻守兼备",
        50, 100, 4, 0.60, 1.00, 5, 4, 3))
    list.add(CharData(2, "盾卫", "防御型 — 高血量高护甲",
        80, 130, 3, 0.40, 1.30, 4, 3, 3))
    list.add(CharData(3, "暗影", "刺客型 — 低血高攻高暴击",
        35, 75, 6, 0.85, 0.70, 5, 4, 2))
    list.add(CharData(4, "术士", "技能型 — 技能频繁触发",
        40, 60, 3, 0.55, 0.80, 6, 5, 2))
    list.add(CharData(5, "狂战", "狂战型 — 极限输出",
        45, 85, 7, 0.75, 0.85, 5, 5, 2))
    list
}

// ===== Character State =====
public class Character {
    public let data: CharData
    public var hp: Int32
    public var skillPoints: Int32
    public var shields: Int32
    public var diceResults: ArrayList<Int32>
    public var selectedDice: ArrayList<Bool>

    public init(data: CharData) {
        this.data = data
        this.hp = data.maxHP
        this.skillPoints = 0
        this.shields = 3
        this.diceResults = ArrayList<Int32>()
        this.selectedDice = ArrayList<Bool>()
        for (_ in 0..data.dicenum) {
            diceResults.add(0)
            selectedDice.add(false)
        }
    }

    public func getDice(index: Int32): Int32 {
        var result: Int32 = 0
        var pos: Int32 = 0
        for (v in diceResults) {
            if (pos == index) { result = v }
            pos = pos + 1
        }
        result
    }

    public func isDiceSelected(index: Int32): Bool {
        var result: Bool = false
        var pos: Int32 = 0
        for (s in selectedDice) {
            if (pos == index) { result = s }
            pos = pos + 1
        }
        result
    }

    public func rollDice(rng: Rng): Unit {
        let newDice = ArrayList<Int32>()
        let newSel = ArrayList<Bool>()
        for (_ in 0..data.dicenum) {
            newDice.add(rng.nextInt(9))
            newSel.add(false)
        }
        diceResults = newDice
        selectedDice = newSel
    }

    public func clearSelection(): Unit {
        let newSel = ArrayList<Bool>()
        for (_ in 0..data.dicenum) { newSel.add(false) }
        selectedDice = newSel
    }

    public func toggleDice(index: Int32): Unit {
        let current = isDiceSelected(index)
        let newSel = ArrayList<Bool>()
        var pos: Int32 = 0
        for (_ in 0..data.dicenum) {
            if (pos == index) {
                newSel.add(!current)
            } else {
                newSel.add(isDiceSelected(pos))
            }
            pos = pos + 1
        }
        selectedDice = newSel
    }

    public func getSelectedSum(): Int32 {
        var sum: Int32 = 0
        var pos: Int32 = 0
        for (_ in selectedDice) {
            if (isDiceSelected(pos)) { sum = sum + getDice(pos) }
            pos = pos + 1
        }
        sum
    }

    public func getSelectedCount(): Int32 {
        var count: Int32 = 0
        var pos: Int32 = 0
        for (_ in selectedDice) {
            if (isDiceSelected(pos)) { count = count + 1 }
            pos = pos + 1
        }
        count
    }

    public func aiSelectBest(count: Int32): Unit {
        let topIndices = ArrayList<Int32>()
        var used = ArrayList<Bool>()
        for (_ in 0..data.dicenum) { used.add(false) }

        for (_ in 0..count) {
            var bestIdx: Int32 = -1
            var bestVal: Int32 = -1
            var pi: Int32 = 0
            for (u in used) {
                if (!u) {
                    let val = getDice(pi)
                    if (val > bestVal) {
                        bestVal = val
                        bestIdx = pi
                    }
                }
                pi = pi + 1
            }
            if (bestIdx >= 0) {
                let newUsed = ArrayList<Bool>()
                var pj: Int32 = 0
                for (uv in used) {
                    if (pj == bestIdx) { newUsed.add(true) }
                    else { newUsed.add(uv) }
                    pj = pj + 1
                }
                used = newUsed
                topIndices.add(bestIdx)
            }
        }

        let newSel = ArrayList<Bool>()
        var pi2: Int32 = 0
        for (_ in 0..data.dicenum) {
            var found: Bool = false
            for (ti in topIndices) {
                if (ti == pi2) { found = true }
            }
            newSel.add(found)
            pi2 = pi2 + 1
        }
        selectedDice = newSel
    }

    // Shield check: returns true if shield absorbed the attack
    // Trigger when rawAttack >= 30% maxHP, probability increases as HP decreases
    public func checkShield(rawAttack: Int32, rng: Rng): Bool {
        if (shields <= 0) { return false }
        let threshold: Int32 = data.maxHP * 3 / 10  // 30% of max HP
        if (rawAttack < threshold) { return false }

        let hpRatio = Float32(hp) / Float32(data.maxHP)
        // Probability: 0% at full HP, up to 85% at 0 HP
        let prob = (Float32(1) - hpRatio) * Float32(0.85)
        let roll = rng.nextFloat()

        if (roll < prob) {
            shields = shields - 1
            return true
        }
        false
    }

    public func canUseSkill(): Bool {
        skillPoints >= data.activeSkillCost
    }

    public func useSkill(): Unit {
        skillPoints = 0
    }

    public func checkPassiveSkill(rng: Rng): Bool {
        rng.nextInt(10) > data.passiveSkillThreshold
    }

    public func addSkillPoints(amount: Int32): Unit {
        skillPoints = skillPoints + amount
    }
}

// ===== Game State =====
public enum GamePhase {
    | SELECT_CHARACTER
    | PLAYER_ROLL
    | PLAYER_ATTACK
    | AI_TURN
    | PLAYER_DEFEND
    | ROUND_RESULT
    | GAME_OVER
}

public class CardGameEngine {
    public var player: Character
    public var ai: Character
    public var phase: GamePhase
    public var rng: Rng
    public var messages: ArrayList<String>
    public var lastPlayerDamage: Int32
    public var lastAIDamage: Int32

    public init() {
        player = Character(getAllClasses()[0])
        ai = Character(getAllClasses()[0])
        phase = GamePhase.SELECT_CHARACTER
        rng = Rng()
        messages = ArrayList<String>()
        lastPlayerDamage = 0
        lastAIDamage = 0
    }

    public func selectPlayerClass(charData: CharData): Unit {
        player = Character(charData)
        log("你选择了: ${charData.name} — ${charData.desc}")
        // AI randomly picks
        let allClasses = getAllClasses()
        let aiIdx = rng.nextInt(Int32(allClasses.size))
        let idx = aiIdx - 1
        ai = Character(allClasses[Int64(idx)])
        log("AI选择了: ${ai.data.name} — ${ai.data.desc}")
        phase = GamePhase.PLAYER_ROLL
    }

    public func log(msg: String): Unit {
        messages.add(msg)
        if (messages.size > 20) {
            let newMsgs = ArrayList<String>()
            var pos: Int32 = 0
            let total: Int32 = Int32(messages.size)
            for (m in messages) {
                if (pos >= total - 20) { newMsgs.add(m) }
                pos = pos + 1
            }
            messages = newMsgs
        }
    }

    public func getRecentMessages(): String {
        var result: String = ""
        let total: Int32 = Int32(messages.size)
        let start: Int32 = if (total > 8) { total - 8 } else { 0 }
        var pos: Int32 = 0
        for (m in messages) {
            if (pos >= start) { result = result + m + "\n" }
            pos = pos + 1
        }
        result
    }

    public func playerRoll(): Unit {
        player.rollDice(rng)
        log("玩家掷出骰子: " + diceToString(player))
        phase = GamePhase.PLAYER_ATTACK
    }

    // Calculate raw attack value BEFORE defense (for shield check)
    private func calcRawAttack(ch: Character): Int32 {
        let sum = ch.getSelectedSum()
        var atk = Int32(Float32(sum) * ch.data.attackMul)
        if (ch.canUseSkill()) { atk = atk * 2 }
        if (ch.checkPassiveSkill(rng)) { atk = atk * 4 }
        atk
    }

    public func playerAttack(): Int32 {
        let sum = player.getSelectedSum()
        var atk = Int32(Float32(sum) * player.data.attackMul)
        log("玩家攻击基础值: ${atk}")

        if (player.canUseSkill()) {
            player.useSkill()
            atk = atk * 2
            log("主动技能发动! 攻击翻倍 -> ${atk}")
        }

        var passiveTriggered: Bool = false
        if (player.checkPassiveSkill(rng)) {
            atk = atk * 4
            passiveTriggered = true
            log("被动技能暴击! 最终伤害 -> ${atk}")
        }

        // Check AI shield (before defense)
        if (ai.checkShield(atk, rng)) {
            log("AI护盾触发! 伤害被完全抵消 (剩余护盾: ${ai.shields})")
            player.addSkillPoints(atk * 2)
            ai.addSkillPoints(atk)
            lastPlayerDamage = 0
            phase = GamePhase.AI_TURN
            return 0
        }

        // AI defends
        ai.rollDice(rng)
        ai.aiSelectBest(ai.data.DMGnum)
        let defense = ai.getSelectedSum()
        log("AI防御点数: ${defense} (选了${ai.data.DMGnum}个骰子)")

        let actualDamage = max2(0, Int32(Float32(atk) * ai.data.damageMul) - defense)
        ai.hp = max2(0, ai.hp - actualDamage)
        log("AI受到 ${actualDamage} 点伤害, 剩余HP: ${ai.hp}/${ai.data.maxHP}")

        player.addSkillPoints(atk * 2)
        ai.addSkillPoints(atk)

        lastPlayerDamage = actualDamage
        phase = GamePhase.AI_TURN
        actualDamage
    }

    public func aiAttack(): Int32 {
        ai.rollDice(rng)
        ai.aiSelectBest(ai.data.ATKnum)
        let sum = ai.getSelectedSum()
        var atk = Int32(Float32(sum) * ai.data.attackMul)
        log("AI攻击基础值: ${atk} (选了${ai.data.ATKnum}个骰子)")

        if (ai.canUseSkill()) {
            ai.useSkill()
            atk = atk * 2
            log("AI主动技能发动! 攻击翻倍 -> ${atk}")
        }

        if (ai.checkPassiveSkill(rng)) {
            atk = atk * 4
            log("AI被动技能暴击! 最终伤害 -> ${atk}")
        }

        // Check player shield (before defense)
        if (player.checkShield(atk, rng)) {
            log("你的护盾触发! 伤害被完全抵消 (剩余护盾: ${player.shields})")
            player.addSkillPoints(atk)
            ai.addSkillPoints(atk * 2)
            lastAIDamage = 0
            phase = GamePhase.ROUND_RESULT
            return 0
        }

        player.rollDice(rng)
        log("AI发动攻击! 请选择 ${player.data.DMGnum} 个防御骰子")

        phase = GamePhase.PLAYER_DEFEND
        lastAIDamage = atk
        atk
    }

    public func playerDefend(): Int32 {
        let defense = player.getSelectedSum()
        log("玩家防御点数: ${defense}")

        let actualDamage = max2(0, Int32(Float32(lastAIDamage) * player.data.damageMul) - defense)
        player.hp = max2(0, player.hp - actualDamage)
        log("玩家受到 ${actualDamage} 点伤害, 剩余HP: ${player.hp}/${player.data.maxHP}")

        player.addSkillPoints(lastAIDamage)
        ai.addSkillPoints(lastAIDamage * 2)

        phase = GamePhase.ROUND_RESULT
        actualDamage
    }

    public func startNewRound(): Unit {
        if (isGameOver()) {
            phase = GamePhase.GAME_OVER
        } else {
            phase = GamePhase.PLAYER_ROLL
        }
    }

    public func isGameOver(): Bool {
        player.hp <= 0 || ai.hp <= 0
    }

    public func getWinner(): String {
        if (ai.hp <= 0) { "玩家胜利!" }
        else if (player.hp <= 0) { "AI胜利!" }
        else { "" }
    }

    private func diceToString(ch: Character): String {
        var s: String = ""
        var pos: Int32 = 0
        for (_ in 0..ch.data.dicenum) {
            s = s + "${ch.getDice(pos)} "
            pos = pos + 1
        }
        s
    }
}

public func max2(a: Int32, b: Int32): Int32 {
    if (a > b) { a } else { b }
}
