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

public struct RaceData {
    public let id: Int32
    public let name: String
    public let desc: String
    public let hpMod: Int32
    public let physAtkMod: Float32
    public let magAtkMod: Float32
    public let physDefMod: Float32
    public let magDefMod: Float32
    public let spGainMod: Float32

    public init(id: Int32, name: String, desc: String,
                hpMod: Int32, physAtkMod: Float32, magAtkMod: Float32,
                physDefMod: Float32, magDefMod: Float32, spGainMod: Float32) {
        this.id = id
        this.name = name
        this.desc = desc
        this.hpMod = hpMod
        this.physAtkMod = physAtkMod
        this.magAtkMod = magAtkMod
        this.physDefMod = physDefMod
        this.magDefMod = magDefMod
        this.spGainMod = spGainMod
    }
}

public func getAllRaces(): ArrayList<RaceData> {
    let list = ArrayList<RaceData>()
    list.add(RaceData(1, "龙裔", "每回合+4%攻(叠10层). ≥5层暴击触发龙威双倍伤害",
        5, 0.03, 0.03, 0.0, 0.0, 1.0))
    list.add(RaceData(2, "精灵", "每回合+1骰子(最高+3). +6%闪避/层, 闪避成功反击",
        0, 0.0, 0.02, 0.02, 0.03, 1.0))
    list.add(RaceData(3, "不死族", "每回合+4%HP回复/层(最高40%). 死亡复活80%HP(1次)",
        -5, 0.05, 0.05, 0.0, 0.0, 0.95))
    list.add(RaceData(4, "恶魔", "每回合扣3%HP换+6%攻. 暴击倍率+0.07/层. 击杀+3层",
        -10, 0.08, 0.08, -0.02, -0.02, 1.05))
    list.add(RaceData(5, "天人", "每回合全属性+2%(最高20%). SP满时技能消耗-50%",
        8, 0.0, 0.0, 0.03, 0.03, 1.25))
    list.add(RaceData(6, "虚空族", "每回合穿透+2%(最高20%). 攻击时偷取敌方最高骰子",
        0, 0.02, 0.04, 0.0, 0.0, 1.0))
    list
}

public func getAllClasses(): ArrayList<CharData> {
    let list = ArrayList<CharData>()
    list.add(CharData(1, "剑士", "均衡物理型 — 物法兼备",
        80, 100, 4, 0.60, 0.20, 0.25, 0.22, 5, 4, 3))
    list.add(CharData(2, "盾卫", "坦克型 — 高血量高双防",
        130, 130, 3, 0.35, 0.10, 0.50, 0.45, 4, 3, 3))
    list.add(CharData(3, "暗影", "刺客型 — 极限物攻低防",
        55, 75, 6, 0.85, 0.15, 0.12, 0.12, 5, 4, 2))
    list.add(CharData(4, "术士", "技能型 — 法术为主",
        65, 60, 3, 0.15, 0.80, 0.18, 0.35, 6, 5, 2))
    list.add(CharData(5, "狂战", "狂战型 — 极限物攻输出",
        70, 85, 7, 0.75, 0.30, 0.12, 0.12, 5, 5, 2))
    list.add(CharData(6, "圣骑", "均衡双修型 — 双攻双防",
        100, 110, 5, 0.45, 0.40, 0.38, 0.38, 4, 3, 3))
    list.add(CharData(7, "元素使", "纯法型 — 极限法攻",
        55, 55, 4, 0.10, 0.90, 0.12, 0.35, 6, 5, 2))
    list.add(CharData(8, "死灵", "法坦型 — 法攻为主偏防御",
        60, 65, 5, 0.20, 0.70, 0.22, 0.35, 5, 4, 3))
    list.add(CharData(9, "魔剑士", "法战型 — 物法双修均衡",
        75, 100, 5, 0.45, 0.50, 0.28, 0.28, 5, 4, 3))
    list.add(CharData(10, "武僧", "高速暴击型 — 高暴连击回复",
        60, 65, 7, 0.70, 0.10, 0.20, 0.20, 6, 5, 2))
    list.add(CharData(11, "咒术师", "诅咒控制型 — 削弱敌方",
        50, 60, 5, 0.10, 0.65, 0.12, 0.32, 5, 4, 3))
    list.add(CharData(12, "龙骑士", "高血穿透型 — 物理破甲",
        110, 120, 5, 0.65, 0.10, 0.32, 0.22, 4, 4, 2))
    list
}

public class Character {
    public let data: CharData
    public var race: RaceData
    public var hp: Int32
    public var skillPoints: Int32
    public var shields: Int32
    public var diceResults: ArrayList<Int32>
    public var physDice: ArrayList<Bool>
    public var magDice: ArrayList<Bool>
    public var raceStacks: Int32
    public var bonusDice: Int32
    public var revived: Bool
    public var demonBuff: Float32
    public var damageVuln: Float32
    public var damageCounter: Float32

    public init(data: CharData) {
        this.data = data
        this.race = getAllRaces()[0]
        this.hp = data.maxHP
        this.skillPoints = 0
        this.shields = 3
        this.diceResults = ArrayList<Int32>()
        this.physDice = ArrayList<Bool>()
        this.magDice = ArrayList<Bool>()
        this.raceStacks = 0
        this.bonusDice = 0
        this.revived = false
        this.demonBuff = Float32(0)
        this.damageVuln = Float32(1)
        this.damageCounter = Float32(0)
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
        let totalDice = data.dicenum + bonusDice
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
        let totalDice = data.dicenum + bonusDice
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
        let totalDice = data.dicenum + bonusDice
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
        let totalDice = data.dicenum + bonusDice
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

    public func checkShield(incomingDmg: Int32): Bool {
        if (shields <= 0) { return false }
        // 伤害致命则必定触发护盾
        if (incomingDmg >= hp) {
            shields = shields - 1
            return true
        }
        false
    }

    public func effPhysAtkMul(): Float32 {
        data.physicalAttackMul + race.physAtkMod
    }
    public func effMagAtkMul(): Float32 {
        data.magicalAttackMul + race.magAtkMod
    }
    public func effPhysDef(): Float32 {
        data.physicalDefense + race.physDefMod
    }
    public func effMagDef(): Float32 {
        data.magicalDefense + race.magDefMod
    }
    public func effMaxHP(): Int32 {
        data.maxHP + race.hpMod
    }

    public func canUseSkill(): Bool {
        let cost = effectiveSkillCost()
        skillPoints >= cost
    }

    public func effectiveSkillCost(): Int32 {
        if (race.id == 5 && skillPoints >= data.activeSkillCost) {
            data.activeSkillCost / 2
        } else {
            data.activeSkillCost
        }
    }

    public func useSkill(): Unit {
        skillPoints = skillPoints - effectiveSkillCost()
    }

    public func checkPassiveSkill(rng: Rng): Bool {
        rng.nextInt(10) > data.passiveSkillThreshold
    }

    public func addSkillPoints(amount: Int32): Unit {
        skillPoints = skillPoints + amount
    }
}

public enum GameMode {
    | VS_AI
    | VS_PLAYER

    public operator func ==(right: GameMode): Bool {
        match (this) {
            case VS_AI => match (right) { case VS_AI => true; case _ => false }
            case VS_PLAYER => match (right) { case VS_PLAYER => true; case _ => false }
        }
    }
}

public enum GamePhase {
    | SELECT_MODE
    | SELECT_CHARACTER
    | SELECT_RACE
    | SELECT_CHARACTER_P2
    | SELECT_RACE_P2
    | PLAYER_ROLL
    | PLAYER_ATTACK
    | AI_TURN
    | PLAYER_DEFEND
    | ROUND_RESULT
    | GAME_OVER

    public operator func ==(right: GamePhase): Bool {
        match (this) {
            case SELECT_MODE => match (right) { case SELECT_MODE => true; case _ => false }
            case SELECT_CHARACTER => match (right) { case SELECT_CHARACTER => true; case _ => false }
            case SELECT_RACE => match (right) { case SELECT_RACE => true; case _ => false }
            case SELECT_CHARACTER_P2 => match (right) { case SELECT_CHARACTER_P2 => true; case _ => false }
            case SELECT_RACE_P2 => match (right) { case SELECT_RACE_P2 => true; case _ => false }
            case PLAYER_ROLL => match (right) { case PLAYER_ROLL => true; case _ => false }
            case PLAYER_ATTACK => match (right) { case PLAYER_ATTACK => true; case _ => false }
            case AI_TURN => match (right) { case AI_TURN => true; case _ => false }
            case PLAYER_DEFEND => match (right) { case PLAYER_DEFEND => true; case _ => false }
            case ROUND_RESULT => match (right) { case ROUND_RESULT => true; case _ => false }
            case GAME_OVER => match (right) { case GAME_OVER => true; case _ => false }
        }
    }
}

public class CardGameEngine {
    public var player: Character
    public var ai: Character
    public var phase: GamePhase
    public var rng: Rng
    public var messages: ArrayList<String>
    public var lastAIPhysAtk: Int32
    public var lastAIMagAtk: Int32
    public var gameMode: GameMode
    public var halfTurnCount: Int32
    public var playerSkillStacks: Int32
    public var aiDebuff: Float32
    public var aiSkillPhysPen: Float32
    public var aiSkillMagPen: Float32
    public var aiSkillIgnoreDice: Bool

    public init() {
        player = Character(getAllClasses()[0])
        ai = Character(getAllClasses()[0])
        gameMode = GameMode.VS_AI
        phase = GamePhase.SELECT_MODE
        halfTurnCount = 0
        rng = Rng()
        messages = ArrayList<String>()
        lastAIPhysAtk = 0
        lastAIMagAtk = 0
        playerSkillStacks = 0
        aiDebuff = Float32(1)
        aiSkillPhysPen = Float32(0)
        aiSkillMagPen = Float32(0)
        aiSkillIgnoreDice = false
    }

    public func selectMode(mode: GameMode): Unit {
        gameMode = mode
        if (mode == GameMode.VS_AI) {
            phase = GamePhase.SELECT_CHARACTER
        } else {
            phase = GamePhase.SELECT_CHARACTER
        }
    }

    public func selectPlayerClass(charData: CharData): Unit {
        player = Character(charData)
        if (gameMode == GameMode.VS_AI) {
            log("你选择了: ${charData.name} — ${charData.desc}")
            let allClasses = getAllClasses()
            let aiIdx = rng.nextInt(Int32(allClasses.size))
            let idx = aiIdx - 1
            ai = Character(allClasses[Int64(idx)])
            log("AI选择了: ${ai.data.name} — ${ai.data.desc}")
            // AI随机选择种族
            let allRaces = getAllRaces()
            let aiRaceIdx = rng.nextInt(Int32(allRaces.size))
            let aiRaceIdx2 = aiRaceIdx - 1
            ai.race = allRaces[Int64(aiRaceIdx2)]
            ai.hp = ai.effMaxHP()
            log("AI种族: ${ai.race.name} — ${ai.race.desc}")
            phase = GamePhase.SELECT_RACE
        } else {
            log("玩家1选择了: ${charData.name} — ${charData.desc}")
            phase = GamePhase.SELECT_RACE
        }
    }

    public func selectP2Class(charData: CharData): Unit {
        ai = Character(charData)
        log("玩家2选择了: ${charData.name} — ${charData.desc}")
        phase = GamePhase.SELECT_RACE_P2
    }

    public func selectPlayerRace(raceData: RaceData): Unit {
        player.race = raceData
        player.hp = player.effMaxHP()
        log("你选择了种族: ${raceData.name} — ${raceData.desc}")
        if (gameMode == GameMode.VS_AI) {
            phase = GamePhase.PLAYER_ROLL
        } else {
            phase = GamePhase.SELECT_CHARACTER_P2
        }
    }

    public func selectP2Race(raceData: RaceData): Unit {
        ai.race = raceData
        ai.hp = ai.data.maxHP + raceData.hpMod
        log("玩家2选择了种族: ${raceData.name} — ${raceData.desc}")
        halfTurnCount = 0
        phase = GamePhase.PLAYER_ROLL
    }

    public func swapPlayers(): Unit {
        let temp = player
        player = ai
        ai = temp
        log("--- 交换回合 ---")
    }

    public func currentPlayerName(): String {
        if (gameMode == GameMode.VS_AI) {
            "你"
        } else {
            if (halfTurnCount % 2 == 0) { "玩家1" } else { "玩家2" }
        }
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
        for (m in messages) {
            result = result + m + "\n"
        }
        result
    }

    public func playerRoll(): Unit {
        player.rollDice(rng)
        log("玩家掷出骰子: " + diceToString(player))
        phase = GamePhase.PLAYER_ATTACK
    }

    public func addSkillStack(): Unit {
        if (player.canUseSkill()) {
            player.skillPoints = player.skillPoints - player.effectiveSkillCost()
            playerSkillStacks = playerSkillStacks + 1
        }
    }

    public func canActivateSkill(): Bool {
        player.canUseSkill()
    }

    public func playerAttack(): Int32 {
        let physSum = player.getPhysSum()
        let magSum = player.getMagSum()
        var physAtk = Int32(Float32(physSum) * player.effPhysAtkMul())
        var magAtk = Int32(Float32(magSum) * player.effMagAtkMul())
        log("玩家物攻: ${physAtk} (骰${physSum}x${player.effPhysAtkMul()}), 法攻: ${magAtk} (骰${magSum}x${player.effMagAtkMul()})")

        var skillPhysPen: Float32 = Float32(0)
        var skillMagPen: Float32 = Float32(0)
        var skillIgnoreDice: Bool = false
        var skillLifesteal: Float32 = Float32(0)
        var skillHealPct: Float32 = Float32(0)

        if (playerSkillStacks > 0) {
            let stacks = playerSkillStacks
            let id = player.data.id
            match (id) {
                case 1 => // 剑士 - 剑气斩: +50%/stack
                    let mult = Float32(1) + Float32(0.5) * Float32(stacks)
                    physAtk = Int32(Float32(physAtk) * mult)
                    magAtk = Int32(Float32(magAtk) * mult)
                    log("⚔ 剑气斩 x${stacks}! 物攻法攻 +${50 * stacks}%")
                case 2 => // 盾卫 - 坚盾: 下次受击减伤+反弹
                    player.damageVuln = Float32(0.6)
                    player.damageCounter = Float32(0.2)
                    log("🛡 坚盾! 下次受击伤害-40%, 反弹20%")
                case 3 => // 暗影 - 暗杀: +30%/stack
                    let mult = Float32(1) + Float32(0.3) * Float32(stacks)
                    physAtk = Int32(Float32(physAtk) * mult)
                    magAtk = Int32(Float32(magAtk) * mult)
                    log("🗡 暗杀 x${stacks}! 攻击+${30 * stacks}%")
                case 4 => // 术士 - 奥术爆发: +60%/stack, +30%pen/stack
                    let mult = Float32(1) + Float32(0.6) * Float32(stacks)
                    magAtk = Int32(Float32(magAtk) * mult)
                    skillMagPen = Float32(0.3) * Float32(stacks)
                    if (skillMagPen > Float32(1)) { skillMagPen = Float32(1) }
                    log("🔮 奥术爆发 x${stacks}! 法攻+${60 * stacks}%")
                case 5 => // 狂战 - 狂暴: +70%/stack, 自身受伤+30%
                    let mult = Float32(1) + Float32(0.7) * Float32(stacks)
                    physAtk = Int32(Float32(physAtk) * mult)
                    magAtk = Int32(Float32(magAtk) * mult)
                    player.damageVuln = Float32(1.3)
                    log("💢 狂暴 x${stacks}! 攻击+${70 * stacks}%")
                case 6 => // 圣骑 - 圣光审判: +25%/stack, +20%heal/stack
                    let mult = Float32(1) + Float32(0.25) * Float32(stacks)
                    physAtk = Int32(Float32(physAtk) * mult)
                    magAtk = Int32(Float32(magAtk) * mult)
                    skillHealPct = Float32(0.2) * Float32(stacks)
                    log("✨ 圣光审判 x${stacks}! 攻击+${25 * stacks}%")
                case 7 => // 元素使 - 元素过载: +100%/stack
                    let mult = Float32(1) + Float32(1.0) * Float32(stacks)
                    magAtk = Int32(Float32(magAtk) * mult)
                    skillIgnoreDice = true
                    log("⚡ 元素过载 x${stacks}! 法攻+${100 * stacks}%")
                case 8 => // 死灵 - 灵魂收割: +20%/stack
                    let mult = Float32(1) + Float32(0.2) * Float32(stacks)
                    physAtk = Int32(Float32(physAtk) * mult)
                    magAtk = Int32(Float32(magAtk) * mult)
                    skillLifesteal = Float32(0.4)
                    aiDebuff = Float32(0.75)
                    log("💀 灵魂收割 x${stacks}! 攻击+${20 * stacks}%")
                case 9 => // 魔剑士 - 魔剑共鸣: +45%/stack
                    let mult = Float32(1) + Float32(0.45) * Float32(stacks)
                    physAtk = Int32(Float32(physAtk) * mult)
                    magAtk = Int32(Float32(magAtk) * mult)
                    log("⚔ 魔剑共鸣 x${stacks}! 物攻法攻 +${45 * stacks}%")
                case 10 => // 武僧 - 连击: +50%/stack, +15%heal/stack
                    let mult = Float32(1) + Float32(0.5) * Float32(stacks)
                    physAtk = Int32(Float32(physAtk) * mult)
                    skillHealPct = Float32(0.15) * Float32(stacks)
                    log("👊 连击 x${stacks}! 攻击+${50 * stacks}%")
                case 11 => // 咒术师 - 恶咒: +40%/stack, +15%pen/stack
                    let mult = Float32(1) + Float32(0.4) * Float32(stacks)
                    magAtk = Int32(Float32(magAtk) * mult)
                    skillMagPen = Float32(0.15) * Float32(stacks)
                    if (skillMagPen > Float32(1)) { skillMagPen = Float32(1) }
                    aiDebuff = Float32(0.75)
                    log("👁 恶咒 x${stacks}! 法攻+${40 * stacks}%")
                case 12 => // 龙骑士 - 龙击: +80%/stack, +40%pen/stack
                    let mult = Float32(1) + Float32(0.8) * Float32(stacks)
                    physAtk = Int32(Float32(physAtk) * mult)
                    skillPhysPen = Float32(0.4) * Float32(stacks)
                    if (skillPhysPen > Float32(1)) { skillPhysPen = Float32(1) }
                    log("🐉 龙击 x${stacks}! 物攻+${80 * stacks}%")
                case _ => ()
            }
            playerSkillStacks = 0
        }

        // Race offensive effects
        let pRaceId = player.race.id
        // 天人: 全属性buff
        if (pRaceId == 5 && player.raceStacks > 0) {
            let celestialMult = Float32(1) + Float32(0.02) * Float32(player.raceStacks)
            physAtk = Int32(Float32(physAtk) * celestialMult)
            magAtk = Int32(Float32(magAtk) * celestialMult)
        }
        // 恶魔: demonBuff
        if (pRaceId == 4 && player.demonBuff > Float32(0)) {
            physAtk = Int32(Float32(physAtk) * (Float32(1) + player.demonBuff))
            magAtk = Int32(Float32(magAtk) * (Float32(1) + player.demonBuff))
            player.demonBuff = Float32(0)
        }
        // 虚空族: 偷取敌方最高骰子
        if (pRaceId == 6 && ai.diceResults.size > 0) {
            var bestDie: Int32 = 0
            for (d in ai.diceResults) {
                if (d > bestDie) { bestDie = d }
            }
            physAtk = physAtk + Int32(Float32(bestDie) * player.effPhysAtkMul())
            log("虚空侵蚀: 偷取敌方最高骰子 ${bestDie}!")
        }
        // 龙裔: 龙怒攻击加成
        if (pRaceId == 1 && player.raceStacks > 0) {
            let dragonMult = Float32(1) + Float32(0.04) * Float32(player.raceStacks)
            physAtk = Int32(Float32(physAtk) * dragonMult)
            magAtk = Int32(Float32(magAtk) * dragonMult)
        }

        // Passive crit with race bonuses
        if (player.checkPassiveSkill(rng)) {
            var critMult: Float32 = Float32(4)
            // 恶魔: 暴击倍率+0.07/层
            if (pRaceId == 4) {
                critMult = critMult + Float32(0.07) * Float32(player.raceStacks)
            }
            // 龙裔: ≥5层龙怒触发龙威双倍
            var dragonFury: Bool = false
            if (pRaceId == 1 && player.raceStacks >= 5) {
                critMult = critMult * Float32(2)
                player.raceStacks = player.raceStacks - 5
                dragonFury = true
            }
            physAtk = Int32(Float32(physAtk) * critMult)
            magAtk = Int32(Float32(magAtk) * critMult)
            if (dragonFury) {
                log("🐉 龙威咆哮! 暴击x${critMult} -> 物攻:${physAtk} 法攻:${magAtk}")
            } else if (pRaceId == 4) {
                log("被动技能暴击! x${critMult} (恶魔之力) -> 物攻:${physAtk} 法攻:${magAtk}")
            } else {
                log("被动技能暴击! x${critMult} -> 物攻:${physAtk} 法攻:${magAtk}")
            }
        }

        let totalRaw = physAtk + magAtk

        // 2P: apply effects, store info, defender will respond
        if (gameMode == GameMode.VS_PLAYER) {
            if (skillLifesteal > Float32(0) && player.hp > 0) {
                let heal = Int32(Float32(totalRaw) * skillLifesteal)
                player.hp = min2(player.data.maxHP, player.hp + heal)
                log("灵魂收割: 吸血回复 ${heal} HP")
            }
            if (skillHealPct > Float32(0) && player.hp > 0) {
                let heal = Int32(Float32(player.data.maxHP) * skillHealPct)
                player.hp = min2(player.data.maxHP, player.hp + heal)
                log("回复 ${heal} HP")
            }
            lastAIPhysAtk = physAtk
            lastAIMagAtk = magAtk
            aiSkillPhysPen = skillPhysPen
            aiSkillMagPen = skillMagPen
            aiSkillIgnoreDice = skillIgnoreDice
            ai.rollDice(rng)
            log("${ai.data.name} 请选择 ${ai.data.DMGnum} 个防御骰子")
            phase = GamePhase.PLAYER_DEFEND
            return 0
        }

        // AI defends
        ai.rollDice(rng)
        let aiDefPhysRatio = (Float32(1) - ai.effPhysDef()) / ((Float32(1) - ai.effPhysDef()) + (Float32(1) - ai.effMagDef()))
        ai.aiSelect(ai.data.DMGnum, aiDefPhysRatio)
        var physDef = ai.getPhysSum()
        var magDef = ai.getMagSum()

        // Apply penetration / ignore dice
        if (skillIgnoreDice) {
            physDef = 0
            magDef = 0
            log("元素过载: 无视AI防御骰!")
        } else {
            physDef = Int32(Float32(physDef) * (Float32(1) - skillPhysPen))
            magDef = Int32(Float32(magDef) * (Float32(1) - skillMagPen))
        }
        // 虚空族穿透
        var voidPen: Float32 = Float32(0)
        if (pRaceId == 6 && player.raceStacks > 0) {
            voidPen = Float32(0.02) * Float32(player.raceStacks)
            physDef = Int32(Float32(physDef) * (Float32(1) - voidPen))
            magDef = Int32(Float32(magDef) * (Float32(1) - voidPen))
            log("虚空侵蚀: 穿透${Int32(voidPen * Float32(100))}%防御")
        }
        log("AI物防骰: ${physDef}(${ai.getPhysCount()}个), 法防骰: ${magDef}(${ai.getMagCount()}个)")

        var physDmg = Int32(Float32(max2(0, physAtk - physDef)) * (Float32(1) - ai.effPhysDef()))
        var magDmg = Int32(Float32(max2(0, magAtk - magDef)) * (Float32(1) - ai.effMagDef()))
        var totalDmg = physDmg + magDmg

        // AI 防守方技能效果（坚盾/狂暴）
        if (ai.damageVuln != Float32(1)) {
            physDmg = Int32(Float32(physDmg) * ai.damageVuln)
            magDmg = Int32(Float32(magDmg) * ai.damageVuln)
            totalDmg = physDmg + magDmg
            if (ai.damageVuln < Float32(1)) {
                log("🛡 AI坚盾减伤! 伤害 -${Int32((Float32(1) - ai.damageVuln) * Float32(100))}%")
            } else {
                log("💢 AI狂暴负面! 受到伤害 +${Int32((ai.damageVuln - Float32(1)) * Float32(100))}%")
            }
            ai.damageVuln = Float32(1)
        }

        // AI 坚盾反击
        if (ai.damageCounter > Float32(0)) {
            let counterDmg = Int32(Float32(totalDmg) * ai.damageCounter)
            player.hp = max2(0, player.hp - counterDmg)
            log("🛡 AI坚盾反击! 你受到 ${counterDmg} 反弹伤害")
            ai.damageCounter = Float32(0)
        }

        // Lifesteal
        if (skillLifesteal > Float32(0) && player.hp > 0) {
            let heal = Int32(Float32(totalDmg) * skillLifesteal)
            player.hp = min2(player.data.maxHP, player.hp + heal)
            log("灵魂收割: 吸血回复 ${heal} HP")
        }

        // Heal
        if (skillHealPct > Float32(0) && player.hp > 0) {
            let heal = Int32(Float32(player.data.maxHP) * skillHealPct)
            player.hp = min2(player.data.maxHP, player.hp + heal)
            log("圣光审判: 回复 ${heal} HP")
        }

        // AI 精灵闪避
        if (ai.race.id == 2 && ai.raceStacks > 0 && totalDmg > 0) {
            let dodgeChance = Float32(ai.raceStacks) * Float32(0.06)
            if (rng.nextFloat() < dodgeChance) {
                log("🍃 AI精灵闪避! 伤害完全回避")
                let counterDmg = Int32(Float32(totalRaw) * Float32(0.3))
                player.hp = max2(0, player.hp - counterDmg)
                log("🍃 AI精灵反击! 你受到 ${counterDmg} 伤害")
                totalDmg = 0
            }
        }

        // AI 护盾 — 防御骰计算后再判断，仅致命伤害触发
        if (totalDmg >= ai.hp && ai.checkShield(totalDmg)) {
            log("🛡 AI护盾触发! 致命伤害 ${totalDmg} 被完全抵消 (剩余护盾: ${ai.shields})")
            totalDmg = 0
        }

        ai.hp = max2(0, ai.hp - totalDmg)
        log("AI受到 物伤:${physDmg} + 法伤:${magDmg} = ${totalDmg} 伤害, 剩余HP: ${ai.hp}/${ai.data.maxHP}")

        // AI 不死族复活
        if (ai.race.id == 3 && ai.hp <= 0 && !ai.revived) {
            ai.hp = Int32(Float32(ai.effMaxHP()) * Float32(0.8))
            ai.revived = true
            ai.raceStacks = max2(0, ai.raceStacks / 2)
            log("💀 AI亡者归来! ${ai.data.name}复活了! HP:${ai.hp}")
        }

        // 恶魔: 击杀奖励+3层
        if (pRaceId == 4 && ai.hp <= 0 && player.raceStacks < 10) {
            player.raceStacks = min2(10, player.raceStacks + 3)
            log("💀 恶魔之喜! 击杀奖励+3层 (${player.raceStacks}/10)")
        }

        player.addSkillPoints(calcAttackerSP(totalRaw, player.race.spGainMod))
        ai.addSkillPoints(calcDefenderSP(totalRaw, ai.race.spGainMod))

        if (gameMode == GameMode.VS_AI) {
            phase = if (ai.hp <= 0) { GamePhase.GAME_OVER } else { GamePhase.AI_TURN }
        } else {
            phase = GamePhase.PLAYER_DEFEND
        }
        totalDmg
    }

    public func aiAttack(): Int32 {
        if (ai.hp <= 0) {
            phase = GamePhase.ROUND_RESULT
            return 0
        }
        ai.rollDice(rng)
        let aiAtkPhysRatio = ai.effPhysAtkMul() / (ai.effPhysAtkMul() + ai.effMagAtkMul())
        ai.aiSelect(ai.data.ATKnum, aiAtkPhysRatio)
        let physSum = ai.getPhysSum()
        let magSum = ai.getMagSum()
        var physAtk = Int32(Float32(physSum) * ai.effPhysAtkMul())
        var magAtk = Int32(Float32(magSum) * ai.effMagAtkMul())
        log("AI物攻: ${physAtk} (骰${physSum}x${ai.effPhysAtkMul()}), 法攻: ${magAtk} (骰${magSum}x${ai.effMagAtkMul()})")

        // AI auto-uses skill
        aiSkillPhysPen = Float32(0)
        aiSkillMagPen = Float32(0)
        aiSkillIgnoreDice = false

        if (ai.canUseSkill()) {
            ai.useSkill()
            let aiId = ai.data.id
            match (aiId) {
                case 1 =>
                    physAtk = Int32(Float32(physAtk) * Float32(1.5))
                    magAtk = Int32(Float32(magAtk) * Float32(1.5))
                    log("AI ⚔ 剑气斩! 物攻法攻 +50%")
                case 2 =>
                    ai.damageVuln = Float32(0.6)
                    ai.damageCounter = Float32(0.2)
                    log("AI 🛡 坚盾! 下次受击伤害-40%, 反弹20%")
                case 3 =>
                    physAtk = Int32(Float32(physAtk) * Float32(1.3))
                    magAtk = Int32(Float32(magAtk) * Float32(1.3))
                    log("AI 🗡 暗杀! 攻击+30%")
                case 4 =>
                    magAtk = Int32(Float32(magAtk) * Float32(1.6))
                    aiSkillMagPen = Float32(0.3)
                    log("AI 🔮 奥术爆发! 法攻+60%, 穿透30%法防")
                case 5 =>
                    physAtk = Int32(Float32(physAtk) * Float32(1.7))
                    magAtk = Int32(Float32(magAtk) * Float32(1.7))
                    ai.damageVuln = Float32(1.3)
                    log("AI 💢 狂暴! 攻击+70%, 受到伤害+30%")
                case 6 =>
                    physAtk = Int32(Float32(physAtk) * Float32(1.25))
                    magAtk = Int32(Float32(magAtk) * Float32(1.25))
                    if (ai.hp > 0) {
                        let heal = Int32(Float32(ai.data.maxHP) * Float32(0.2))
                        ai.hp = min2(ai.data.maxHP, ai.hp + heal)
                        log("AI ✨ 圣光审判! 攻击+25%, 回复 ${heal} HP")
                    } else {
                        log("AI ✨ 圣光审判! 攻击+25%")
                    }
                case 7 =>
                    magAtk = Int32(Float32(magAtk) * Float32(2.0))
                    aiSkillIgnoreDice = true
                    log("AI ⚡ 元素过载! 法攻翻倍, 无视防御骰")
                case 8 =>
                    physAtk = Int32(Float32(physAtk) * Float32(1.2))
                    magAtk = Int32(Float32(magAtk) * Float32(1.2))
                    log("AI 💀 灵魂收割! 攻击+20%, 吸血40%")
                case 9 =>
                    physAtk = Int32(Float32(physAtk) * Float32(1.45))
                    magAtk = Int32(Float32(magAtk) * Float32(1.45))
                    log("AI ⚔ 魔剑共鸣! 物攻法攻 +45%")
                case 10 =>
                    physAtk = Int32(Float32(physAtk) * Float32(1.5))
                    if (ai.hp > 0) {
                        let heal10 = Int32(Float32(ai.data.maxHP) * Float32(0.15))
                        ai.hp = min2(ai.data.maxHP, ai.hp + heal10)
                        log("AI 👊 连击! 攻击+50%, 回复 ${heal10} HP")
                    } else {
                        log("AI 👊 连击! 攻击+50%")
                    }
                case 11 =>
                    magAtk = Int32(Float32(magAtk) * Float32(1.4))
                    aiSkillMagPen = Float32(0.15)
                    log("AI 👁 恶咒! 法攻+40%, 穿透15%法防")
                case 12 =>
                    physAtk = Int32(Float32(physAtk) * Float32(1.8))
                    aiSkillPhysPen = Float32(0.4)
                    log("AI 🐉 龙击! 物攻+80%, 穿透40%物防")
                case _ => ()
            }
        }

        // AI race offensive effects
        let aRaceId = ai.race.id
        // 天人
        if (aRaceId == 5 && ai.raceStacks > 0) {
            let celestialMult = Float32(1) + Float32(0.02) * Float32(ai.raceStacks)
            physAtk = Int32(Float32(physAtk) * celestialMult)
            magAtk = Int32(Float32(magAtk) * celestialMult)
        }
        // 恶魔
        if (aRaceId == 4 && ai.demonBuff > Float32(0)) {
            physAtk = Int32(Float32(physAtk) * (Float32(1) + ai.demonBuff))
            magAtk = Int32(Float32(magAtk) * (Float32(1) + ai.demonBuff))
            ai.demonBuff = Float32(0)
        }
        // 虚空族
        if (aRaceId == 6 && player.diceResults.size > 0) {
            var bestDie: Int32 = 0
            for (d in player.diceResults) {
                if (d > bestDie) { bestDie = d }
            }
            physAtk = physAtk + Int32(Float32(bestDie) * ai.effPhysAtkMul())
            log("AI虚空侵蚀: 偷取敌方最高骰子 ${bestDie}!")
        }
        // 龙裔
        if (aRaceId == 1 && ai.raceStacks > 0) {
            let dragonMult = Float32(1) + Float32(0.04) * Float32(ai.raceStacks)
            physAtk = Int32(Float32(physAtk) * dragonMult)
            magAtk = Int32(Float32(magAtk) * dragonMult)
        }

        if (ai.checkPassiveSkill(rng)) {
            var critMult: Float32 = Float32(4)
            if (aRaceId == 4) {
                critMult = critMult + Float32(0.07) * Float32(ai.raceStacks)
            }
            var dragonFury: Bool = false
            if (aRaceId == 1 && ai.raceStacks >= 5) {
                critMult = critMult * Float32(2)
                ai.raceStacks = ai.raceStacks - 5
                dragonFury = true
            }
            physAtk = Int32(Float32(physAtk) * critMult)
            magAtk = Int32(Float32(magAtk) * critMult)
            if (dragonFury) {
                log("AI 🐉 龙威咆哮! 暴击!")
            } else {
                log("AI被动技能暴击!")
            }
        }

        // Apply debuff from player's skill
        physAtk = Int32(Float32(physAtk) * aiDebuff)
        magAtk = Int32(Float32(magAtk) * aiDebuff)
        if (aiDebuff < Float32(1)) {
            log("灵魂收割削弱: AI攻击降低 ${Int32((Float32(1) - aiDebuff) * Float32(100))}%")
            aiDebuff = Float32(1)
        }

        let totalRaw = physAtk + magAtk

        player.rollDice(rng)
        lastAIPhysAtk = physAtk
        lastAIMagAtk = magAtk
        // Store AI penetration for defense calculation
        log("AI发动攻击! 物攻:${physAtk} 法攻:${magAtk} | 请选 ${player.data.DMGnum} 个防御骰子")

        phase = GamePhase.PLAYER_DEFEND
        physAtk + magAtk
    }

    public func playerDefend(): Int32 {
        // In 2P mode, ai is the defender (player is the attacker). In AI mode, player is the defender.
        let defender = if (gameMode == GameMode.VS_PLAYER) { ai } else { player }
        let attacker = if (gameMode == GameMode.VS_PLAYER) { player } else { ai }

        var physDef = defender.getPhysSum()
        var magDef = defender.getMagSum()

        if (aiSkillIgnoreDice) {
            physDef = 0
            magDef = 0
            log("元素过载: 无视防御骰!")
            aiSkillIgnoreDice = false
        } else {
            physDef = Int32(Float32(physDef) * (Float32(1) - aiSkillPhysPen))
            magDef = Int32(Float32(magDef) * (Float32(1) - aiSkillMagPen))
            aiSkillPhysPen = Float32(0)
            aiSkillMagPen = Float32(0)
        }
        // 虚空族穿透 (攻击方)
        if (attacker.race.id == 6 && attacker.raceStacks > 0) {
            let atkVoidPen = Float32(0.02) * Float32(attacker.raceStacks)
            physDef = Int32(Float32(physDef) * (Float32(1) - atkVoidPen))
            magDef = Int32(Float32(magDef) * (Float32(1) - atkVoidPen))
        }
        log("${defender.data.name}物防骰: ${physDef}(${defender.getPhysCount()}个), 法防骰: ${magDef}(${defender.getMagCount()}个)")

        var physDmg = Int32(Float32(max2(0, lastAIPhysAtk - physDef)) * (Float32(1) - defender.effPhysDef()))
        var magDmg = Int32(Float32(max2(0, lastAIMagAtk - magDef)) * (Float32(1) - defender.effMagDef()))

        // 防守方技能效果（坚盾减伤/狂暴增伤）
        if (defender.damageVuln != Float32(1)) {
            physDmg = Int32(Float32(physDmg) * defender.damageVuln)
            magDmg = Int32(Float32(magDmg) * defender.damageVuln)
            if (defender.damageVuln < Float32(1)) {
                log("🛡 坚盾减伤! 伤害 -${Int32((Float32(1) - defender.damageVuln) * Float32(100))}%")
            } else {
                log("💢 狂暴负面! 受到伤害 +${Int32((defender.damageVuln - Float32(1)) * Float32(100))}%")
            }
            defender.damageVuln = Float32(1)
        }

        var totalDmg = physDmg + magDmg

        // 防守方坚盾反击
        if (defender.damageCounter > Float32(0)) {
            let counterDmg = Int32(Float32(totalDmg) * defender.damageCounter)
            attacker.hp = max2(0, attacker.hp - counterDmg)
            log("🛡 坚盾反击! ${attacker.data.name}受到 ${counterDmg} 反弹伤害")
            defender.damageCounter = Float32(0)
        }

        // 精灵闪避
        if (defender.race.id == 2 && defender.raceStacks > 0 && totalDmg > 0) {
            let dodgeChance = Float32(defender.raceStacks) * Float32(0.06)
            if (rng.nextFloat() < dodgeChance) {
                log("🍃 精灵闪避! 伤害完全回避 (闪避率${Int32(dodgeChance * Float32(100))}%)")
                // 反击: 造成攻击方物攻的30%伤害
                let counterDmg = Int32(Float32(lastAIPhysAtk) * Float32(0.3))
                attacker.hp = max2(0, attacker.hp - counterDmg)
                log("🍃 精灵反击! ${attacker.data.name}受到 ${counterDmg} 伤害")
                totalDmg = 0
            }
        }

        // 护盾 — 防御骰计算后再判断，仅致命伤害触发
        if (totalDmg >= defender.hp && defender.checkShield(totalDmg)) {
            log("🛡 ${defender.data.name}护盾触发! 致命伤害 ${totalDmg} 被完全抵消 (剩余护盾: ${defender.shields})")
            totalDmg = 0
        }

        defender.hp = max2(0, defender.hp - totalDmg)
        log("${defender.data.name}受到 物伤:${physDmg} + 法伤:${magDmg} = ${totalDmg} 伤害, 剩余HP: ${defender.hp}/${defender.data.maxHP}")

        // 不死族复活
        if (defender.race.id == 3 && defender.hp <= 0 && !defender.revived) {
            defender.hp = Int32(Float32(defender.effMaxHP()) * Float32(0.8))
            defender.revived = true
            defender.raceStacks = max2(0, defender.raceStacks / 2)
            log("💀 亡者归来! ${defender.data.name}复活了! HP:${defender.hp}")
        }

        // 恶魔: 击杀奖励 (defender被击杀 → 攻击方恶魔+3层)
        if (attacker.race.id == 4 && defender.hp <= 0 && attacker.raceStacks < 10) {
            attacker.raceStacks = min2(10, attacker.raceStacks + 3)
            log("💀 恶魔之喜! ${attacker.data.name}+3层 (${attacker.raceStacks}/10)")
        }

        let defRaw = lastAIPhysAtk + lastAIMagAtk
        defender.addSkillPoints(calcDefenderSP(defRaw, defender.race.spGainMod))
        attacker.addSkillPoints(calcAttackerSP(defRaw, attacker.race.spGainMod))

        // 检查是否有角色阵亡 → 直接进入结束界面
        if (player.hp <= 0 || ai.hp <= 0) {
            phase = GamePhase.GAME_OVER
        } else if (gameMode == GameMode.VS_PLAYER) {
            halfTurnCount = halfTurnCount + 1
            swapPlayers()
            if (halfTurnCount >= 2) {
                halfTurnCount = 0
                phase = GamePhase.ROUND_RESULT
            } else {
                phase = GamePhase.PLAYER_ROLL
            }
        } else {
            phase = GamePhase.ROUND_RESULT
        }
        totalDmg
    }

    // Get the character whose dice to show in the UI (bottom area)
    public func activeDiceOwner(): Character {
        if (gameMode == GameMode.VS_PLAYER && phase == GamePhase.PLAYER_DEFEND) {
            ai  // defender needs to select defense dice
        } else {
            player
        }
    }

    // Get the opponent character (top area)
    public func topChar(): Character {
        if (gameMode == GameMode.VS_PLAYER && phase == GamePhase.PLAYER_DEFEND) {
            player
        } else {
            ai
        }
    }

    public func startNewRound(): Unit {
        if (isGameOver()) {
            phase = GamePhase.GAME_OVER
        } else {
            // 重置未触发的技能效果
            player.damageVuln = Float32(1)
            player.damageCounter = Float32(0)
            ai.damageVuln = Float32(1)
            ai.damageCounter = Float32(0)
            applyRaceRoundBonus(player)
            applyRaceRoundBonus(ai)
            phase = GamePhase.PLAYER_ROLL
        }
    }

    private func applyRaceRoundBonus(ch: Character): Unit {
        let rid = ch.race.id
        match (rid) {
            case 1 => // 龙裔: +4%攻击, 最高10层
                if (ch.raceStacks < 10) {
                    ch.raceStacks = ch.raceStacks + 1
                }
                log("${ch.data.name} 龙裔龙怒: ${ch.raceStacks}/10层")
            case 2 => // 精灵: +1骰子, 最高3层; +6%闪避/层
                if (ch.raceStacks < 3) {
                    ch.raceStacks = ch.raceStacks + 1
                    ch.bonusDice = ch.raceStacks
                }
                log("${ch.data.name} 精灵自然祝福: ${ch.raceStacks}/3层 (+${ch.bonusDice}骰子)")
            case 3 => // 不死族: +4%最大HP回复/层, 最高10层
                if (ch.raceStacks < 10) {
                    ch.raceStacks = ch.raceStacks + 1
                }
                if (ch.hp > 0) {
                    let heal3 = Int32(Float32(ch.data.maxHP) * Float32(0.04) * Float32(ch.raceStacks))
                    ch.hp = min2(ch.effMaxHP(), ch.hp + heal3)
                    log("${ch.data.name} 不死族回复: +${heal3} HP (${ch.raceStacks}/10层)")
                } else {
                    log("${ch.data.name} 不死族: ${ch.raceStacks}/10层 (已阵亡, 跳过回复)")
                }
            case 4 => // 恶魔: +3%暴击倍率/层, 每回合扣3%HP换+6%攻
                if (ch.raceStacks < 10) {
                    ch.raceStacks = ch.raceStacks + 1
                }
                let burn = Int32(Float32(ch.hp) * Float32(0.03))
                if (burn > 0) {
                    ch.hp = max2(1, ch.hp - burn)
                }
                ch.demonBuff = Float32(0.06)
                log("${ch.data.name} 恶魔契约: 燃烧${burn}HP, +6%攻 (${ch.raceStacks}/10层)")
            case 5 => // 天人: +2%全属性, 最高10层
                if (ch.raceStacks < 10) {
                    ch.raceStacks = ch.raceStacks + 1
                }
                log("${ch.data.name} 天人合一: ${ch.raceStacks}/10层 (+${ch.raceStacks * 2}%全属性)")
            case 6 => // 虚空族: +2%穿透, 最高10层
                if (ch.raceStacks < 10) {
                    ch.raceStacks = ch.raceStacks + 1
                }
                log("${ch.data.name} 虚空侵蚀: ${ch.raceStacks}/10层 (+${ch.raceStacks * 2}%穿透)")
            case _ => ()
        }
    }

    public func isGameOver(): Bool {
        player.hp <= 0 || ai.hp <= 0
    }

    public func getWinner(): String {
        if (ai.hp <= 0) { "${player.data.name} 胜利!" }
        else if (player.hp <= 0) { "${ai.data.name} 胜利!" }
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

public func min2(a: Int32, b: Int32): Int32 {
    if (a < b) { a } else { b }
}

func approxSqrt(n: Int32): Int32 {
    if (n <= 0) { return 0 }
    var x: Int64 = Int64(n)
    var y: Int64 = (x + Int64(1)) / Int64(2)
    while (y < x) {
        x = y
        y = (x + Int64(n) / x) / Int64(2)
    }
    Int32(x)
}

func calcAttackerSP(damage: Int32, spMod: Float32): Int32 {
    let base = approxSqrt(damage)
    let raw = Int32(Float32(9) * Float32(base) * spMod)
    if (raw > 120) { 120 } else { raw }
}

func calcDefenderSP(damage: Int32, spMod: Float32): Int32 {
    let base = approxSqrt(damage)
    let raw = Int32(Float32(4) * Float32(base) * spMod)
    if (raw > 60) { 60 } else { raw }
}
