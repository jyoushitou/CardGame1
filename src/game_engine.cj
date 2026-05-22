package myapp

import std.collection.*
import cjform.*

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

    public func nextFloat(): Float32 {
        Float32(nextInt(1000)) / Float32(1000)
    }
}

public struct CharData {
    public let id: Int32
    public let name: String
    public let desc: String
    public let maxHP: Int32
    public let activeSkillCost: Int32
    public let passiveSkillThreshold: Int32
    public let physicalAttackMul: Float32
    public let magicalAttackMul: Float32
    public let physicalDefense: Float32
    public let magicalDefense: Float32
    public let dicenum: Int32
    public let ATKnum: Int32
    public let DMGnum: Int32

    public init(id: Int32, name: String, desc: String, maxHP: Int32,
                activeSkillCost: Int32, passiveSkillThreshold: Int32,
                physicalAttackMul: Float32, magicalAttackMul: Float32,
                physicalDefense: Float32, magicalDefense: Float32,
                dicenum: Int32, ATKnum: Int32, DMGnum: Int32) {
        this.id = id
        this.name = name
        this.desc = desc
        this.maxHP = maxHP
        this.activeSkillCost = activeSkillCost
        this.passiveSkillThreshold = passiveSkillThreshold
        this.physicalAttackMul = physicalAttackMul
        this.magicalAttackMul = magicalAttackMul
        this.physicalDefense = physicalDefense
        this.magicalDefense = magicalDefense
        this.dicenum = dicenum
        this.ATKnum = ATKnum
        this.DMGnum = DMGnum
    }
}

public func getAllClasses(): ArrayList<CharData> {
    let list = ArrayList<CharData>()
    list.add(CharData(1, "剑士", "均衡物理型 — 物法兼备",
        80, 100, 4, 0.60, 0.20, 0.15, 0.10, 5, 4, 3))
    list.add(CharData(2, "盾卫", "坦克型 — 高血量高双防",
        130, 130, 3, 0.35, 0.10, 0.30, 0.25, 4, 3, 3))
    list.add(CharData(3, "暗影", "刺客型 — 极限物攻低防",
        55, 75, 6, 0.85, 0.15, 0.05, 0.05, 5, 4, 2))
    list.add(CharData(4, "术士", "技能型 — 法术为主",
        65, 60, 3, 0.15, 0.80, 0.10, 0.15, 6, 5, 2))
    list.add(CharData(5, "狂战", "狂战型 — 极限物攻输出",
        70, 85, 7, 0.75, 0.30, 0.05, 0.05, 5, 5, 2))
    list.add(CharData(6, "圣骑", "均衡双修型 — 双攻双防",
        100, 110, 5, 0.45, 0.40, 0.20, 0.20, 4, 3, 3))
    list.add(CharData(7, "元素使", "纯法型 — 极限法攻",
        55, 55, 4, 0.10, 0.90, 0.05, 0.20, 6, 5, 2))
    list.add(CharData(8, "死灵", "法坦型 — 法攻为主偏防御",
        60, 65, 5, 0.20, 0.70, 0.10, 0.15, 5, 4, 3))
    list
}

public class Character {
    public let data: CharData
    public var hp: Int32
    public var skillPoints: Int32
    public var shields: Int32
    public var diceResults: ArrayList<Int32>
    public var physDice: ArrayList<Bool>
    public var magDice: ArrayList<Bool>

    public init(data: CharData) {
        this.data = data
        this.hp = data.maxHP
        this.skillPoints = 0
        this.shields = 3
        this.diceResults = ArrayList<Int32>()
        this.physDice = ArrayList<Bool>()
        this.magDice = ArrayList<Bool>()
        let totalDice = data.dicenum
        for (_ in 0..totalDice) {
            diceResults.add(0)
            physDice.add(false)
            magDice.add(false)
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

    public func isPhysDice(index: Int32): Bool {
        var result: Bool = false
        var pos: Int32 = 0
        for (s in physDice) {
            if (pos == index) { result = s }
            pos = pos + 1
        }
        result
    }

    public func isMagDice(index: Int32): Bool {
        var result: Bool = false
        var pos: Int32 = 0
        for (s in magDice) {
            if (pos == index) { result = s }
            pos = pos + 1
        }
        result
    }

    public func cycleDiceMode(index: Int32): Unit {
        let isPhys = isPhysDice(index)
        let isMag = isMagDice(index)
        let newPhys = ArrayList<Bool>()
        let newMag = ArrayList<Bool>()
        var pos: Int32 = 0
        let totalDice = data.dicenum
        for (_ in 0..totalDice) {
            if (pos == index) {
                if (!isPhys && !isMag) {
                    newPhys.add(true)
                    newMag.add(false)
                } else if (isPhys) {
                    newPhys.add(false)
                    newMag.add(true)
                } else {
                    newPhys.add(false)
                    newMag.add(false)
                }
            } else {
                newPhys.add(isPhysDice(pos))
                newMag.add(isMagDice(pos))
            }
            pos = pos + 1
        }
        physDice = newPhys
        magDice = newMag
    }

    public func rollDice(rng: Rng): Unit {
        let totalDice = data.dicenum
        let newDice = ArrayList<Int32>()
        let newPhys = ArrayList<Bool>()
        let newMag = ArrayList<Bool>()
        for (_ in 0..totalDice) {
            newDice.add(rng.nextInt(9))
            newPhys.add(false)
            newMag.add(false)
        }
        diceResults = newDice
        physDice = newPhys
        magDice = newMag
    }

    public func clearSelection(): Unit {
        let totalDice = data.dicenum
        let newPhys = ArrayList<Bool>()
        let newMag = ArrayList<Bool>()
        for (_ in 0..totalDice) {
            newPhys.add(false)
            newMag.add(false)
        }
        physDice = newPhys
        magDice = newMag
    }

    public func getPhysSum(): Int32 {
        var sum: Int32 = 0
        var pos: Int32 = 0
        for (_ in physDice) {
            if (isPhysDice(pos)) { sum = sum + getDice(pos) }
            pos = pos + 1
        }
        sum
    }

    public func getMagSum(): Int32 {
        var sum: Int32 = 0
        var pos: Int32 = 0
        for (_ in magDice) {
            if (isMagDice(pos)) { sum = sum + getDice(pos) }
            pos = pos + 1
        }
        sum
    }

    public func getPhysCount(): Int32 {
        var count: Int32 = 0
        var pos: Int32 = 0
        for (_ in physDice) {
            if (isPhysDice(pos)) { count = count + 1 }
            pos = pos + 1
        }
        count
    }

    public func getMagCount(): Int32 {
        var count: Int32 = 0
        var pos: Int32 = 0
        for (_ in magDice) {
            if (isMagDice(pos)) { count = count + 1 }
            pos = pos + 1
        }
        count
    }

    public func getTotalCount(): Int32 {
        getPhysCount() + getMagCount()
    }

    public func aiSelect(totalCount: Int32, physRatio: Float32): Unit {
        let totalDice = data.dicenum
        let topIndices = ArrayList<Int32>()
        var used = ArrayList<Bool>()
        for (_ in 0..totalDice) { used.add(false) }

        for (_ in 0..totalCount) {
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

        var physCount = Int32(Float32(totalCount) * physRatio)
        if (physCount < 0) { physCount = 0 }
        if (physCount > totalCount) { physCount = totalCount }

        let newPhys = ArrayList<Bool>()
        let newMag = ArrayList<Bool>()
        var pi2: Int32 = 0
        for (_ in 0..totalDice) {
            var assignedPhys: Bool = false
            var assignedMag: Bool = false
            var rank: Int32 = 0
            for (ti in topIndices) {
                if (ti == pi2) {
                    if (rank < physCount) { assignedPhys = true }
                    else { assignedMag = true }
                }
                rank = rank + 1
            }
            newPhys.add(assignedPhys)
            newMag.add(assignedMag)
            pi2 = pi2 + 1
        }
        physDice = newPhys
        magDice = newMag
    }

    public func checkShield(rawAttack: Int32, rng: Rng): Bool {
        if (shields <= 0) { return false }
        let threshold: Int32 = data.maxHP * 3 / 10
        if (rawAttack < threshold) { return false }

        let hpRatio = Float32(hp) / Float32(data.maxHP)
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
    public var lastAIPhysAtk: Int32
    public var lastAIMagAtk: Int32

    public init() {
        player = Character(getAllClasses()[0])
        ai = Character(getAllClasses()[0])
        phase = GamePhase.SELECT_CHARACTER
        rng = Rng()
        messages = ArrayList<String>()
        lastAIPhysAtk = 0
        lastAIMagAtk = 0
    }

    public func selectPlayerClass(charData: CharData): Unit {
        player = Character(charData)
        log("你选择了: ${charData.name} — ${charData.desc}")
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

    public func playerAttack(): Int32 {
        let physSum = player.getPhysSum()
        let magSum = player.getMagSum()
        var physAtk = Int32(Float32(physSum) * player.data.physicalAttackMul)
        var magAtk = Int32(Float32(magSum) * player.data.magicalAttackMul)
        log("玩家物攻: ${physAtk} (骰${physSum}x${player.data.physicalAttackMul}), 法攻: ${magAtk} (骰${magSum}x${player.data.magicalAttackMul})")

        if (player.canUseSkill()) {
            player.useSkill()
            physAtk = physAtk * 2
            magAtk = magAtk * 2
            log("主动技能发动! 攻击翻倍 -> 物攻:${physAtk} 法攻:${magAtk}")
        }

        if (player.checkPassiveSkill(rng)) {
            physAtk = physAtk * 4
            magAtk = magAtk * 4
            log("被动技能暴击! 最终伤害 -> 物攻:${physAtk} 法攻:${magAtk}")
        }

        let totalRaw = physAtk + magAtk
        if (ai.checkShield(totalRaw, rng)) {
            log("AI护盾触发! 伤害被完全抵消 (剩余护盾: ${ai.shields})")
            player.addSkillPoints(totalRaw * 2)
            ai.addSkillPoints(totalRaw)
            phase = GamePhase.AI_TURN
            return 0
        }

        ai.rollDice(rng)
        let aiDefPhysRatio = (Float32(1) - ai.data.physicalDefense) / ((Float32(1) - ai.data.physicalDefense) + (Float32(1) - ai.data.magicalDefense))
        ai.aiSelect(ai.data.DMGnum, aiDefPhysRatio)
        let physDef = ai.getPhysSum()
        let magDef = ai.getMagSum()
        log("AI物防骰: ${physDef}(${ai.getPhysCount()}个), 法防骰: ${magDef}(${ai.getMagCount()}个)")

        let physDmg = Int32(Float32(max2(0, physAtk - physDef)) * (Float32(1) - ai.data.physicalDefense))
        let magDmg = Int32(Float32(max2(0, magAtk - magDef)) * (Float32(1) - ai.data.magicalDefense))
        let totalDmg = physDmg + magDmg
        ai.hp = max2(0, ai.hp - totalDmg)
        log("AI受到 物伤:${physDmg} + 法伤:${magDmg} = ${totalDmg} 伤害, 剩余HP: ${ai.hp}/${ai.data.maxHP}")

        player.addSkillPoints(totalRaw * 2)
        ai.addSkillPoints(totalRaw)

        phase = GamePhase.AI_TURN
        totalDmg
    }

    public func aiAttack(): Int32 {
        ai.rollDice(rng)
        let aiAtkPhysRatio = ai.data.physicalAttackMul / (ai.data.physicalAttackMul + ai.data.magicalAttackMul)
        ai.aiSelect(ai.data.ATKnum, aiAtkPhysRatio)
        let physSum = ai.getPhysSum()
        let magSum = ai.getMagSum()
        var physAtk = Int32(Float32(physSum) * ai.data.physicalAttackMul)
        var magAtk = Int32(Float32(magSum) * ai.data.magicalAttackMul)
        log("AI物攻: ${physAtk} (骰${physSum}x${ai.data.physicalAttackMul}), 法攻: ${magAtk} (骰${magSum}x${ai.data.magicalAttackMul})")

        if (ai.canUseSkill()) {
            ai.useSkill()
            physAtk = physAtk * 2
            magAtk = magAtk * 2
            log("AI主动技能发动! 攻击翻倍")
        }

        if (ai.checkPassiveSkill(rng)) {
            physAtk = physAtk * 4
            magAtk = magAtk * 4
            log("AI被动技能暴击!")
        }

        let totalRaw = physAtk + magAtk
        if (player.checkShield(totalRaw, rng)) {
            log("你的护盾触发! 伤害被完全抵消 (剩余护盾: ${player.shields})")
            player.addSkillPoints(totalRaw)
            ai.addSkillPoints(totalRaw * 2)
            lastAIPhysAtk = 0
            lastAIMagAtk = 0
            phase = GamePhase.ROUND_RESULT
            return 0
        }

        player.rollDice(rng)
        lastAIPhysAtk = physAtk
        lastAIMagAtk = magAtk
        log("AI发动攻击! 物攻:${physAtk} 法攻:${magAtk} | 请选 ${player.data.DMGnum} 个防御骰子")

        phase = GamePhase.PLAYER_DEFEND
        physAtk + magAtk
    }

    public func playerDefend(): Int32 {
        let physDef = player.getPhysSum()
        let magDef = player.getMagSum()
        log("玩家物防骰: ${physDef}(${player.getPhysCount()}个), 法防骰: ${magDef}(${player.getMagCount()}个)")

        let physDmg = Int32(Float32(max2(0, lastAIPhysAtk - physDef)) * (Float32(1) - player.data.physicalDefense))
        let magDmg = Int32(Float32(max2(0, lastAIMagAtk - magDef)) * (Float32(1) - player.data.magicalDefense))
        let totalDmg = physDmg + magDmg
        player.hp = max2(0, player.hp - totalDmg)
        log("你受到 物伤:${physDmg} + 法伤:${magDmg} = ${totalDmg} 伤害, 剩余HP: ${player.hp}/${player.data.maxHP}")

        player.addSkillPoints(lastAIPhysAtk + lastAIMagAtk)
        ai.addSkillPoints((lastAIPhysAtk + lastAIMagAtk) * 2)

        phase = GamePhase.ROUND_RESULT
        totalDmg
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
        let totalDice = ch.data.dicenum
        for (_ in 0..totalDice) {
            s = s + "${ch.getDice(pos)} "
            pos = pos + 1
        }
        s
    }
}

public func max2(a: Int32, b: Int32): Int32 {
    if (a > b) { a } else { b }
}
