package myapp

import cjform.*
import std.collection.*

public class CardGameUI {
    private var window: Window
    private var engine: CardGameEngine

    // ===== Character Select =====
    private var selectTitle: Label
    private var classBtns: ArrayList<Button>
    private var selectInfoLabel: Label

    // ===== Battle: AI =====
    private var aiNameLabel: Label
    private var aiHpBar: ProgressBar
    private var aiHpLabel: Label
    private var aiShieldLabel: Label
    private var aiSkillLabel: Label

    // ===== Battle: Player =====
    private var playerNameLabel: Label
    private var playerHpBar: ProgressBar
    private var playerHpLabel: Label
    private var playerShieldLabel: Label
    private var playerSkillLabel: Label

    // ===== Battle: Center =====
    private var diceButtons: ArrayList<Button>
    private var selectionInfoLabel: Label
    private var actionBtn: Button
    private var messageLabel: Label
    private var phaseLabel: Label
    private var resultLabel: Label

    // ===== Separators =====
    private var sep1: Separator
    private var sep2: Separator
    private var sep3: Separator
    private var diceTitleLabel: Label

    // Layout constants
    private let MG: Float32 = Float32(30)
    private let WIN_W: Float32 = Float32(720)
    private let WIN_H: Float32 = Float32(620)
    private let OFF: Float32 = Float32(-5000)

    public init() {
        engine = CardGameEngine()
        classBtns = ArrayList<Button>()
        diceButtons = ArrayList<Button>()

        let mg = MG
        let c = Theme.colors()
        window = Window("Card Game — 卡牌对战", Int32(WIN_W), Int32(WIN_H))
        window.setBackgroundColor(c.bgSecondary)
        window.setMinSize(Int32(WIN_W), Int32(WIN_H))

        // ========== CHARACTER SELECT WIDGETS ==========
        selectTitle = Label("选择你的角色",
            Position.abs(WIN_W / Float32(2), Float32(50)), c.accent,
            "Microsoft YaHei", Float32(22), SizeScale.fixed(), Anchor.Center)
        window.addWidget(selectTitle)

        selectInfoLabel = Label("不同职业攻防倍率、骰子数不同。高伤害时护盾可能触发抵消。",
            Position.abs(WIN_W / Float32(2), Float32(82)), c.textSecondary,
            "Microsoft YaHei", Float32(12), SizeScale.fixed(), Anchor.Center)
        window.addWidget(selectInfoLabel)

        // Class buttons with dummy callbacks (wired later)
        let classes = getAllClasses()
        let btnW: Float32 = Float32(210)
        let btnH: Float32 = Float32(68)
        let gapX: Float32 = Float32(14)
        let gapY: Float32 = Float32(10)
        let cols: Int32 = 3
        let row1X: Float32 = WIN_W / Float32(2) - (Float32(cols) * btnW + Float32(cols - 1) * gapX) / Float32(2) + btnW / Float32(2)

        var idx: Int32 = 0
        for (cd in classes) {
            let col = idx % Int32(cols)
            let row = idx / Int32(cols)
            let x = row1X + Float32(col) * (btnW + gapX)
            let y = Float32(150) + Float32(row) * (btnH + gapY)
            let label = "${cd.name}  HP:${cd.maxHP}  攻:x${cd.attackMul}  防:x${cd.damageMul}"
            let btn = Button(label,
                Position.abs(x, y), btnW, btnH,
                "Microsoft YaHei", Float32(13), SizeScale.fixed(), Anchor.Center,
                ButtonStyle.outlined(), { => () })
            window.addWidget(btn)
            classBtns.add(btn)
            idx = idx + 1
        }

        // ========== BATTLE: AI SECTION ==========
        aiNameLabel = Label("AI: ---",
            Position.abs(mg, Float32(20)), c.textPrimary,
            "Microsoft YaHei", Float32(14), SizeScale.fixed(), Anchor.TopLeft)
        window.addWidget(aiNameLabel)

        aiHpBar = ProgressBar(Float32(0), Float32(100), Float32(100), ProgressBarStyle.fromTheme())
        aiHpBar.setLayoutFrame(LayoutFrame(mg + Float32(110), Float32(20), Float32(380), Float32(20)))
        window.addWidget(aiHpBar)

        aiHpLabel = Label("---",
            Position.abs(mg + Float32(498), Float32(22)), c.textSecondary,
            "Consolas", Float32(12), SizeScale.fixed(), Anchor.TopLeft)
        window.addWidget(aiHpLabel)

        aiShieldLabel = Label("盾:3",
            Position.abs(mg + Float32(555), Float32(22)), c.textTertiary,
            "Consolas", Float32(11), SizeScale.fixed(), Anchor.TopLeft)
        window.addWidget(aiShieldLabel)

        aiSkillLabel = Label("SP:0/100",
            Position.abs(mg + Float32(600), Float32(22)), c.textTertiary,
            "Consolas", Float32(11), SizeScale.fixed(), Anchor.TopLeft)
        window.addWidget(aiSkillLabel)

        sep1 = Separator(true, SeparatorStyle.fromTheme())
        sep1.setLayoutFrame(LayoutFrame(mg, Float32(50), WIN_W - mg * Float32(2), Float32(2)))
        window.addWidget(sep1)

        // ========== BATTLE: CENTER ==========
        phaseLabel = Label("你的回合 — 请掷骰子",
            Position.abs(WIN_W / Float32(2), Float32(65)), c.accent,
            "Microsoft YaHei", Float32(15), SizeScale.fixed(), Anchor.Center)
        window.addWidget(phaseLabel)

        diceTitleLabel = Label("骰子:",
            Position.abs(mg, Float32(95)), c.textPrimary,
            "Microsoft YaHei", Float32(13), SizeScale.fixed(), Anchor.TopLeft)
        window.addWidget(diceTitleLabel)

        // Dice buttons (max 6), dummy callbacks
        let diceSize: Float32 = Float32(46)
        let diceSpacing: Float32 = Float32(8)
        let diceTotalW = Float32(6) * diceSize + Float32(5) * diceSpacing
        let diceStartX = (WIN_W - mg * Float32(2) - diceTotalW) / Float32(2) + mg + diceSize / Float32(2)
        for (i in 0..6) {
            let di = Int32(i)
            let dx = diceStartX + Float32(di) * (diceSize + diceSpacing)
            let btn = Button("",
                Position.abs(dx, Float32(130)), diceSize, diceSize,
                "Consolas", Float32(17), SizeScale.fixed(), Anchor.Center,
                ButtonStyle.outlined(), { => () })
            window.addWidget(btn)
            diceButtons.add(btn)
        }

        selectionInfoLabel = Label("",
            Position.abs(mg, Float32(168)), c.textSecondary,
            "Microsoft YaHei", Float32(12), SizeScale.fixed(), Anchor.TopLeft)
        window.addWidget(selectionInfoLabel)

        resultLabel = Label("",
            Position.abs(WIN_W / Float32(2), Float32(198)), c.accent,
            "Microsoft YaHei", Float32(15), SizeScale.fixed(), Anchor.Center)
        window.addWidget(resultLabel)

        actionBtn = Button("掷骰子",
            Position.abs(WIN_W / Float32(2), Float32(240)), Float32(150), Float32(42),
            "Microsoft YaHei", Float32(15), SizeScale.fixed(), Anchor.Center,
            ButtonStyle.fromTheme(), { => () })
        window.addWidget(actionBtn)

        sep2 = Separator(true, SeparatorStyle.fromTheme())
        sep2.setLayoutFrame(LayoutFrame(mg, Float32(278), WIN_W - mg * Float32(2), Float32(2)))
        window.addWidget(sep2)

        // ========== BATTLE: MESSAGE LOG ==========
        messageLabel = Label("",
            Position.abs(mg, Float32(288)), c.textSecondary,
            "Consolas", Float32(11), SizeScale.fixed(), Anchor.TopLeft)
        window.addWidget(messageLabel)

        sep3 = Separator(true, SeparatorStyle.fromTheme())
        sep3.setLayoutFrame(LayoutFrame(mg, Float32(432), WIN_W - mg * Float32(2), Float32(2)))
        window.addWidget(sep3)

        // ========== BATTLE: PLAYER SECTION ==========
        playerNameLabel = Label("你: ---",
            Position.abs(mg, Float32(445)), c.textPrimary,
            "Microsoft YaHei", Float32(14), SizeScale.fixed(), Anchor.TopLeft)
        window.addWidget(playerNameLabel)

        playerHpBar = ProgressBar(Float32(0), Float32(100), Float32(100), ProgressBarStyle.fromTheme())
        playerHpBar.setLayoutFrame(LayoutFrame(mg + Float32(110), Float32(445), Float32(380), Float32(20)))
        window.addWidget(playerHpBar)

        playerHpLabel = Label("---",
            Position.abs(mg + Float32(498), Float32(447)), c.textSecondary,
            "Consolas", Float32(12), SizeScale.fixed(), Anchor.TopLeft)
        window.addWidget(playerHpLabel)

        playerShieldLabel = Label("盾:3",
            Position.abs(mg + Float32(555), Float32(447)), c.textTertiary,
            "Consolas", Float32(11), SizeScale.fixed(), Anchor.TopLeft)
        window.addWidget(playerShieldLabel)

        playerSkillLabel = Label("SP:0/100",
            Position.abs(mg + Float32(600), Float32(447)), c.textTertiary,
            "Consolas", Float32(11), SizeScale.fixed(), Anchor.TopLeft)
        window.addWidget(playerSkillLabel)

        // ===== ALL FIELDS INITIALIZED, NOW WIRE CALLBACKS =====
        wireCallbacks()

        // ===== INITIAL STATE: SHOW SELECT, HIDE BATTLE =====
        showSelectScreen()
    }

    private func wireCallbacks(): Unit {
        // Wire class button callbacks
        let classes = getAllClasses()
        var cIdx: Int32 = 0
        for (cd in classes) {
            if (cIdx < Int32(classBtns.size)) {
                classBtns[Int64(cIdx)].onClick() { onClassPicked(cd) }
            }
            cIdx = cIdx + 1
        }
        // Wire dice button callbacks
        for (i in 0..diceButtons.size) {
            let di = Int32(i)
            diceButtons[Int64(di)].onClick() { onDiceClick(di) }
        }
        // Wire action button
        actionBtn.onClick() { onAction() }
    }

    // ================================================================
    //  Screen Toggle
    // ================================================================
    private func showSelectScreen(): Unit {
        // Restore select widgets
        selectTitle.setText("选择你的角色")
        selectTitle.setPosition(Position.abs(WIN_W / Float32(2), Float32(50)))
        selectInfoLabel.setText("不同职业攻防倍率、骰子数不同。高伤害时护盾可能触发抵消。")
        selectInfoLabel.setPosition(Position.abs(WIN_W / Float32(2), Float32(82)))

        let classes = getAllClasses()
        let btnW: Float32 = Float32(210)
        let btnH: Float32 = Float32(68)
        let gapX: Float32 = Float32(14)
        let gapY: Float32 = Float32(10)
        let cols: Int32 = 3
        let row1X: Float32 = WIN_W / Float32(2) - (Float32(cols) * btnW + Float32(cols - 1) * gapX) / Float32(2) + btnW / Float32(2)

        var idx: Int32 = 0
        for (cd in classes) {
            if (idx < Int32(classBtns.size)) {
                let col = idx % Int32(cols)
                let row = idx / Int32(cols)
                let x = row1X + Float32(col) * (btnW + gapX)
                let y = Float32(150) + Float32(row) * (btnH + gapY)
                let btn = classBtns[Int64(idx)]
                btn.setText("${cd.name}  HP:${cd.maxHP}  攻:x${cd.attackMul}  防:x${cd.damageMul}")
                btn.setPosition(Position.abs(x, y))
                btn.setStyle(ButtonStyle.outlined())
            }
            idx = idx + 1
        }

        // Hide all battle widgets off-screen
        hideBattleOffscreen()
    }

    private func showBattleScreen(): Unit {
        // Hide select widgets off-screen
        selectTitle.setText("")
        selectTitle.setPosition(Position.abs(OFF, OFF))
        selectInfoLabel.setText("")
        selectInfoLabel.setPosition(Position.abs(OFF, OFF))
        for (btn in classBtns) {
            btn.setText("")
            btn.setPosition(Position.abs(OFF, OFF))
        }

        // Restore battle widget positions
        let mg = MG
        aiNameLabel.setPosition(Position.abs(mg, Float32(20)))
        aiHpBar.setLayoutFrame(LayoutFrame(mg + Float32(110), Float32(20), Float32(380), Float32(20)))
        aiHpLabel.setPosition(Position.abs(mg + Float32(498), Float32(22)))
        aiShieldLabel.setPosition(Position.abs(mg + Float32(555), Float32(22)))
        aiSkillLabel.setPosition(Position.abs(mg + Float32(600), Float32(22)))
        sep1.setLayoutFrame(LayoutFrame(mg, Float32(50), WIN_W - mg * Float32(2), Float32(2)))

        phaseLabel.setPosition(Position.abs(WIN_W / Float32(2), Float32(65)))
        diceTitleLabel.setPosition(Position.abs(mg, Float32(95)))

        let diceSize: Float32 = Float32(46)
        let diceSpacing: Float32 = Float32(8)
        let diceTotalW = Float32(6) * diceSize + Float32(5) * diceSpacing
        let diceStartX = (WIN_W - mg * Float32(2) - diceTotalW) / Float32(2) + mg + diceSize / Float32(2)
        for (i in 0..diceButtons.size) {
            let di = Int32(i)
            let dx = diceStartX + Float32(di) * (diceSize + diceSpacing)
            let btn = diceButtons[Int64(di)]
            btn.setPosition(Position.abs(dx, Float32(130)))
        }

        selectionInfoLabel.setPosition(Position.abs(mg, Float32(168)))
        resultLabel.setPosition(Position.abs(WIN_W / Float32(2), Float32(198)))

        actionBtn.setPosition(Position.abs(WIN_W / Float32(2), Float32(240)))
        actionBtn.setText("掷骰子")

        sep2.setLayoutFrame(LayoutFrame(mg, Float32(278), WIN_W - mg * Float32(2), Float32(2)))
        messageLabel.setPosition(Position.abs(mg, Float32(288)))
        sep3.setLayoutFrame(LayoutFrame(mg, Float32(432), WIN_W - mg * Float32(2), Float32(2)))

        playerNameLabel.setPosition(Position.abs(mg, Float32(445)))
        playerHpBar.setLayoutFrame(LayoutFrame(mg + Float32(110), Float32(445), Float32(380), Float32(20)))
        playerHpLabel.setPosition(Position.abs(mg + Float32(498), Float32(447)))
        playerShieldLabel.setPosition(Position.abs(mg + Float32(555), Float32(447)))
        playerSkillLabel.setPosition(Position.abs(mg + Float32(600), Float32(447)))
    }

    private func hideBattleOffscreen(): Unit {
        aiNameLabel.setPosition(Position.abs(OFF, OFF))
        aiHpBar.setLayoutFrame(LayoutFrame(OFF, OFF, Float32(1), Float32(1)))
        aiHpLabel.setPosition(Position.abs(OFF, OFF))
        aiShieldLabel.setPosition(Position.abs(OFF, OFF))
        aiSkillLabel.setPosition(Position.abs(OFF, OFF))
        sep1.setLayoutFrame(LayoutFrame(OFF, OFF, Float32(1), Float32(1)))

        phaseLabel.setPosition(Position.abs(OFF, OFF))
        diceTitleLabel.setPosition(Position.abs(OFF, OFF))
        for (btn in diceButtons) {
            btn.setText("")
            btn.setPosition(Position.abs(OFF, OFF))
        }
        selectionInfoLabel.setPosition(Position.abs(OFF, OFF))
        resultLabel.setPosition(Position.abs(OFF, OFF))
        actionBtn.setPosition(Position.abs(OFF, OFF))
        actionBtn.setText("")
        sep2.setLayoutFrame(LayoutFrame(OFF, OFF, Float32(1), Float32(1)))
        messageLabel.setPosition(Position.abs(OFF, OFF))
        sep3.setLayoutFrame(LayoutFrame(OFF, OFF, Float32(1), Float32(1)))

        playerNameLabel.setPosition(Position.abs(OFF, OFF))
        playerHpBar.setLayoutFrame(LayoutFrame(OFF, OFF, Float32(1), Float32(1)))
        playerHpLabel.setPosition(Position.abs(OFF, OFF))
        playerShieldLabel.setPosition(Position.abs(OFF, OFF))
        playerSkillLabel.setPosition(Position.abs(OFF, OFF))
    }

    // ================================================================
    //  Handlers
    // ================================================================
    private func onClassPicked(cd: CharData): Unit {
        engine.selectPlayerClass(cd)
        showBattleScreen()
        refreshUI()
    }

    private func onDiceClick(index: Int32): Unit {
        if (index >= engine.player.data.dicenum) { return }
        match (engine.phase) {
            case GamePhase.PLAYER_ATTACK =>
                engine.player.toggleDice(index)
                refreshDiceDisplay()
                refreshSelectionInfo()
            case GamePhase.PLAYER_DEFEND =>
                engine.player.toggleDice(index)
                refreshDiceDisplay()
                refreshSelectionInfo()
            case _ => ()
        }
    }

    private func onAction(): Unit {
        match (engine.phase) {
            case GamePhase.PLAYER_ROLL =>
                engine.playerRoll()
                refreshUI()

            case GamePhase.PLAYER_ATTACK =>
                let need = engine.player.data.ATKnum
                if (engine.player.getSelectedCount() != need) {
                    engine.log("请选择 ${need} 个攻击骰子! (已选: ${engine.player.getSelectedCount()})")
                    refreshMessageLog()
                    return
                }
                engine.playerAttack()
                match (engine.phase) {
                    case GamePhase.AI_TURN => engine.aiAttack()
                    case _ => ()
                }
                refreshUI()

            case GamePhase.PLAYER_DEFEND =>
                let need = engine.player.data.DMGnum
                if (engine.player.getSelectedCount() != need) {
                    engine.log("请选择 ${need} 个防御骰子! (已选: ${engine.player.getSelectedCount()})")
                    refreshMessageLog()
                    return
                }
                engine.playerDefend()
                refreshUI()

            case GamePhase.ROUND_RESULT =>
                engine.startNewRound()
                refreshUI()

            case GamePhase.GAME_OVER =>
                engine = CardGameEngine()
                showSelectScreen()

            case _ => ()
        }
    }

    // ================================================================
    //  UI Refresh
    // ================================================================
    private func refreshUI(): Unit {
        refreshHPBars()
        refreshSkillLabels()
        refreshShieldLabels()
        refreshNameLabels()
        refreshDiceDisplay()
        refreshSelectionInfo()
        refreshActionButton()
        refreshPhaseLabel()
        refreshResultLabel()
        refreshMessageLog()
    }

    private func refreshHPBars(): Unit {
        aiHpBar.setValue(Float32(engine.ai.hp))
        aiHpLabel.setText("${engine.ai.hp}/${engine.ai.data.maxHP}")
        playerHpBar.setValue(Float32(engine.player.hp))
        playerHpLabel.setText("${engine.player.hp}/${engine.player.data.maxHP}")
    }

    private func refreshNameLabels(): Unit {
        aiNameLabel.setText("AI: ${engine.ai.data.name}")
        playerNameLabel.setText("你: ${engine.player.data.name}")
    }

    private func refreshSkillLabels(): Unit {
        aiSkillLabel.setText("SP:${engine.ai.skillPoints}/${engine.ai.data.activeSkillCost}")
        playerSkillLabel.setText("SP:${engine.player.skillPoints}/${engine.player.data.activeSkillCost}")
    }

    private func refreshShieldLabels(): Unit {
        aiShieldLabel.setText("盾:${engine.ai.shields}")
        playerShieldLabel.setText("盾:${engine.player.shields}")
    }

    private func refreshDiceDisplay(): Unit {
        let clickable = match (engine.phase) {
            case GamePhase.PLAYER_ATTACK => true
            case GamePhase.PLAYER_DEFEND => true
            case _ => false
        }
        let n = engine.player.data.dicenum
        for (i in 0..diceButtons.size) {
            let idx = Int32(i)
            let btn = diceButtons[Int64(idx)]
            if (idx < n) {
                let val = engine.player.getDice(idx)
                let sel = engine.player.isDiceSelected(idx)
                btn.setText("${val}")
                btn.setStyle(if (clickable && sel) { ButtonStyle.fromTheme() } else { ButtonStyle.outlined() })
            } else {
                btn.setText("")
            }
        }
    }

    private func refreshSelectionInfo(): Unit {
        match (engine.phase) {
            case GamePhase.PLAYER_ATTACK =>
                selectionInfoLabel.setText("选 ${engine.player.data.ATKnum} 个攻击骰子 | 已选: ${engine.player.getSelectedCount()} | 合计: ${engine.player.getSelectedSum()}")
            case GamePhase.PLAYER_DEFEND =>
                selectionInfoLabel.setText("选 ${engine.player.data.DMGnum} 个防御骰子 | 已选: ${engine.player.getSelectedCount()} | 合计: ${engine.player.getSelectedSum()}")
            case _ => selectionInfoLabel.setText("")
        }
    }

    private func refreshActionButton(): Unit {
        match (engine.phase) {
            case GamePhase.PLAYER_ROLL => actionBtn.setText("掷骰子")
            case GamePhase.PLAYER_ATTACK => actionBtn.setText("确认攻击")
            case GamePhase.PLAYER_DEFEND => actionBtn.setText("确认防御")
            case GamePhase.ROUND_RESULT => actionBtn.setText("下一回合")
            case GamePhase.GAME_OVER => actionBtn.setText("再来一局")
            case _ => ()
        }
    }

    private func refreshPhaseLabel(): Unit {
        match (engine.phase) {
            case GamePhase.PLAYER_ROLL => phaseLabel.setText("你的回合 — 请掷骰子")
            case GamePhase.PLAYER_ATTACK => phaseLabel.setText("选择 ${engine.player.data.ATKnum} 个攻击骰子")
            case GamePhase.PLAYER_DEFEND => phaseLabel.setText("AI 攻击! 选 ${engine.player.data.DMGnum} 个防御骰子")
            case GamePhase.ROUND_RESULT => phaseLabel.setText(if (engine.isGameOver()) { engine.getWinner() } else { "回合结束 — 点击进入下一回合" })
            case GamePhase.GAME_OVER => phaseLabel.setText(engine.getWinner())
            case _ => ()
        }
    }

    private func refreshResultLabel(): Unit {
        resultLabel.setText(match (engine.phase) {
            case GamePhase.ROUND_RESULT => if (engine.isGameOver()) { engine.getWinner() } else { "" }
            case GamePhase.GAME_OVER => engine.getWinner()
            case _ => ""
        })
    }

    private func refreshMessageLog(): Unit {
        messageLabel.setText(engine.getRecentMessages())
    }

    public func run(): Int32 {
        window.show()
        let result = window.run()
        Int32(result)
    }
}
