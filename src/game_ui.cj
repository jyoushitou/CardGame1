package myapp

import cjform.*
import std.collection.*

public class CardGameUI {
    private var window: Window
    private var engine: CardGameEngine

    //Character Select
    private var selectTitle: Label
    private var classBtns: ArrayList<Button>
    private var selectInfoLabel: Label

    //Battle: AI
    private var aiNameLabel: Label
    private var aiHpBar: ProgressBar
    private var aiHpLabel: Label
    private var aiShieldLabel: Label
    private var aiSpBar: ProgressBar
    private var aiSpLabel: Label
    private var aiSkillNameLabel: Label

    //Battle: Player
    private var playerNameLabel: Label
    private var playerHpBar: ProgressBar
    private var playerHpLabel: Label
    private var playerShieldLabel: Label
    private var playerSpBar: ProgressBar
    private var playerSpLabel: Label
    private var playerSkillBtn: Button

    //Battle: Center
    private var diceButtons: ArrayList<Button>
    private var selectionInfoLabel: Label
    private var actionBtn: Button
    private var messageLabel: Label
    private var messageScroll: ScrollArea
    private var phaseLabel: Label
    private var resultLabel: Label

    //Separators
    private var sep1: Separator
    private var sep2: Separator
    private var sep3: Separator

    //Styles
    private var physDiceStyle: ButtonStyle
    private var magDiceStyle: ButtonStyle
    private var spFullStyle: ProgressBarStyle
    private var spNormStyle: ProgressBarStyle

    //Layout
    private let MG: Float32 = Float32(95)
    private let WIN_W: Float32 = Float32(800)
    private let WIN_H: Float32 = Float32(640)
    private let OFF: Float32 = Float32(-5000)
    private let MAX_DICE: Int32 = 6

    //Y positions
    private let Y_AI_NAME: Float32 = Float32(20)
    private let Y_AI_HPROW: Float32 = Float32(46)
    private let Y_AI_SPROW: Float32 = Float32(66)
    private let Y_SEP1: Float32 = Float32(86)
    private let Y_PHASE: Float32 = Float32(102)
    private let Y_DICE_TITLE: Float32 = Float32(130)
    private let Y_DICE: Float32 = Float32(164)
    private let Y_SEL_INFO: Float32 = Float32(216)
    private let Y_RESULT: Float32 = Float32(242)
    private let Y_ACTION: Float32 = Float32(280)
    private let Y_SEP2: Float32 = Float32(320)
    private let Y_MSG: Float32 = Float32(332)
    private let Y_SEP3: Float32 = Float32(492)
    private let Y_PL_NAME: Float32 = Float32(510)
    private let Y_PL_HPROW: Float32 = Float32(536)
    private let Y_PL_SPROW: Float32 = Float32(556)

    //HP row X
    private let X_HPBAR: Float32 = Float32(0)
    private let W_HPBAR: Float32 = Float32(320)
    private let X_HPLABEL: Float32 = Float32(332)
    private let X_SHIELD: Float32 = Float32(395)

    //SP row X
    private let X_SPBAR: Float32 = Float32(0)
    private let W_SPBAR: Float32 = Float32(180)
    private let X_SPLABEL: Float32 = Float32(190)
    private let X_SKILLNAME: Float32 = Float32(270)

    public init() {
        engine = CardGameEngine()
        classBtns = ArrayList<Button>()
        diceButtons = ArrayList<Button>()

        physDiceStyle = ButtonStyle.fromTheme()
        magDiceStyle = ButtonStyle(6.0, false, 1.0,
            Color.rgb(160, 100, 220), Color.rgb(180, 120, 240), Color.rgb(140, 80, 200),
            Color.WHITE, Color.WHITE, Color.WHITE,
            Color.WHITE, Color.WHITE, Color.WHITE,
            TextAlignment.Center, Shadow.none())

        spFullStyle = ProgressBarStyle(Color.rgb(60, 60, 60), Color.rgb(255, 180, 60), Float32(6), Float32(12))
        spNormStyle = ProgressBarStyle(Color.rgb(60, 60, 60), Color.rgb(100, 149, 237), Float32(6), Float32(12))

        let c = Theme.colors()
        window = Window("Card Game — 卡牌对战", Int32(WIN_W), Int32(WIN_H))
        window.setBackgroundColor(c.bgSecondary)
        window.setMinSize(Int32(WIN_W), Int32(WIN_H))

        //SELECT SCREEN
        selectTitle = Label("选择你的角色",
            Position.abs(WIN_W / Float32(2), Float32(50)), c.accent,
            "Microsoft YaHei", Float32(22), SizeScale.fixed(), Anchor.Center)
        window.addWidget(selectTitle)

        selectInfoLabel = Label("不同职业物攻/法攻/物防/法防不同。物防仅减免物伤，法防仅减免法伤。",
            Position.abs(WIN_W / Float32(2), Float32(85)), c.textSecondary,
            "Microsoft YaHei", Float32(12), SizeScale.fixed(), Anchor.Center)
        window.addWidget(selectInfoLabel)

        //2 columns x 4 rows
        let classes = getAllClasses()
        let btnW: Float32 = Float32(330)
        let btnH: Float32 = Float32(64)
        let gapX: Float32 = Float32(18)
        let gapY: Float32 = Float32(10)
        let totalW = Float32(2) * btnW + gapX
        let row1X = (WIN_W - totalW) / Float32(2) + btnW / Float32(2)

        var idx: Int32 = 0
        for (cd in classes) {
            let col = idx % 2
            let row = idx / 2
            let x = row1X + Float32(col) * (btnW + gapX)
            let y = Float32(140) + Float32(row) * (btnH + gapY)
            let label = "${cd.name}  HP${cd.maxHP}  物x${cd.physicalAttackMul}  法x${cd.magicalAttackMul}"
            let btn = Button(label,
                Position.abs(x, y), btnW, btnH,
                "Microsoft YaHei", Float32(13), SizeScale.fixed(), Anchor.Center,
                ButtonStyle.outlined(), { => () })
            window.addWidget(btn)
            classBtns.add(btn)
            idx = idx + 1
        }

        //BATTLE: AI SECTION
        aiNameLabel = Label("AI: ---",
            Position.abs(MG, Y_AI_NAME), c.textPrimary,
            "Microsoft YaHei", Float32(14), SizeScale.fixed(), Anchor.TopLeft)
        window.addWidget(aiNameLabel)

        aiHpBar = ProgressBar(Float32(0), Float32(100), Float32(100), ProgressBarStyle.fromTheme())
        aiHpBar.setLayoutFrame(LayoutFrame(MG + X_HPBAR, Y_AI_HPROW, W_HPBAR, Float32(20)))
        window.addWidget(aiHpBar)

        aiHpLabel = Label("---",
            Position.abs(MG + X_HPLABEL, Y_AI_HPROW + Float32(2)), c.textSecondary,
            "Consolas", Float32(12), SizeScale.fixed(), Anchor.TopLeft)
        window.addWidget(aiHpLabel)

        aiShieldLabel = Label("盾:3",
            Position.abs(MG + X_SHIELD, Y_AI_HPROW + Float32(2)), c.textTertiary,
            "Consolas", Float32(11), SizeScale.fixed(), Anchor.TopLeft)
        window.addWidget(aiShieldLabel)

        //AI SP row
        aiSpBar = ProgressBar(Float32(0), Float32(100), Float32(0), spNormStyle)
        aiSpBar.setLayoutFrame(LayoutFrame(MG + X_SPBAR, Y_AI_SPROW, W_SPBAR, Float32(12)))
        window.addWidget(aiSpBar)

        aiSpLabel = Label("SP:0/100",
            Position.abs(MG + X_SPLABEL, Y_AI_SPROW + Float32(0)), c.textTertiary,
            "Consolas", Float32(11), SizeScale.fixed(), Anchor.TopLeft)
        window.addWidget(aiSpLabel)

        aiSkillNameLabel = Label("",
            Position.abs(MG + X_SKILLNAME, Y_AI_SPROW + Float32(0)), c.warning,
            "Microsoft YaHei", Float32(12), SizeScale.fixed(), Anchor.TopLeft)
        window.addWidget(aiSkillNameLabel)

        //BATTLE: CENTER
        sep1 = Separator(true, SeparatorStyle.fromTheme())
        sep1.setLayoutFrame(LayoutFrame(MG, Y_SEP1, WIN_W - MG * Float32(2), Float32(2)))
        window.addWidget(sep1)

        phaseLabel = Label("你的回合 — 请掷骰子",
            Position.abs(WIN_W / Float32(2), Y_PHASE), c.accent,
            "Microsoft YaHei", Float32(15), SizeScale.fixed(), Anchor.Center)
        window.addWidget(phaseLabel)

        let diceSize: Float32 = Float32(42)
        for (i in 0..MAX_DICE) {
            let btn = Button("",
                Position.abs(OFF, OFF), diceSize, diceSize,
                "Consolas", Float32(17), SizeScale.fixed(), Anchor.Center,
                ButtonStyle.outlined(), { => () })
            window.addWidget(btn)
            diceButtons.add(btn)
        }

        selectionInfoLabel = Label("",
            Position.abs(MG, Y_SEL_INFO), c.textSecondary,
            "Microsoft YaHei", Float32(12), SizeScale.fixed(), Anchor.TopLeft)
        window.addWidget(selectionInfoLabel)

        resultLabel = Label("",
            Position.abs(WIN_W / Float32(2), Y_RESULT), c.accent,
            "Microsoft YaHei", Float32(14), SizeScale.fixed(), Anchor.Center)
        window.addWidget(resultLabel)

        actionBtn = Button("掷骰子",
            Position.abs(WIN_W / Float32(2), Y_ACTION), Float32(160), Float32(42),
            "Microsoft YaHei", Float32(15), SizeScale.fixed(), Anchor.Center,
            ButtonStyle.fromTheme(), { => () })
        window.addWidget(actionBtn)

        sep2 = Separator(true, SeparatorStyle.fromTheme())
        sep2.setLayoutFrame(LayoutFrame(MG, Y_SEP2, WIN_W - MG * Float32(2), Float32(2)))
        window.addWidget(sep2)

        messageLabel = Label("",
            Position.abs(MG, Y_MSG), c.textSecondary,
            "Consolas", Float32(11), SizeScale.fixed(), Anchor.TopLeft)

        let scrollStyle = ScrollAreaStyle(
            Color.rgb(40, 40, 40), Color.rgb(100, 100, 100), Color.rgb(150, 150, 150),
            Float32(8), Float32(20))
        messageScroll = ScrollArea(scrollStyle)
        messageScroll.setContent(messageLabel)
        messageScroll.setWheelScrollSpeed(Float32(24))
        messageScroll.setLayoutFrame(LayoutFrame(MG, Y_MSG, WIN_W - MG * Float32(2), Float32(152)))
        window.addWidget(messageScroll)

        //BATTLE: PLAYER SECTION
        sep3 = Separator(true, SeparatorStyle.fromTheme())
        sep3.setLayoutFrame(LayoutFrame(MG, Y_SEP3, WIN_W - MG * Float32(2), Float32(2)))
        window.addWidget(sep3)

        playerNameLabel = Label("你: ---",
            Position.abs(MG, Y_PL_NAME), c.textPrimary,
            "Microsoft YaHei", Float32(14), SizeScale.fixed(), Anchor.TopLeft)
        window.addWidget(playerNameLabel)

        playerHpBar = ProgressBar(Float32(0), Float32(100), Float32(100), ProgressBarStyle.fromTheme())
        playerHpBar.setLayoutFrame(LayoutFrame(MG + X_HPBAR, Y_PL_HPROW, W_HPBAR, Float32(20)))
        window.addWidget(playerHpBar)

        playerHpLabel = Label("---",
            Position.abs(MG + X_HPLABEL, Y_PL_HPROW + Float32(2)), c.textSecondary,
            "Consolas", Float32(12), SizeScale.fixed(), Anchor.TopLeft)
        window.addWidget(playerHpLabel)

        playerShieldLabel = Label("盾:3",
            Position.abs(MG + X_SHIELD, Y_PL_HPROW + Float32(2)), c.textTertiary,
            "Consolas", Float32(11), SizeScale.fixed(), Anchor.TopLeft)
        window.addWidget(playerShieldLabel)

        //Player SP row
        playerSpBar = ProgressBar(Float32(0), Float32(100), Float32(0), spNormStyle)
        playerSpBar.setLayoutFrame(LayoutFrame(MG + X_SPBAR, Y_PL_SPROW, W_SPBAR, Float32(12)))
        window.addWidget(playerSpBar)

        playerSpLabel = Label("SP:0/100",
            Position.abs(MG + X_SPLABEL, Y_PL_SPROW + Float32(0)), c.textTertiary,
            "Consolas", Float32(11), SizeScale.fixed(), Anchor.TopLeft)
        window.addWidget(playerSpLabel)

        playerSkillBtn = Button("",
            Position.abs(WIN_W / Float32(2) + Float32(135), Y_ACTION), Float32(100), Float32(32),
            "Microsoft YaHei", Float32(12), SizeScale.fixed(), Anchor.Center,
            ButtonStyle.outlined(), { => () })
        window.addWidget(playerSkillBtn)

        //WIRE
        wireCallbacks()
        showSelectScreen()
    }

    private func wireCallbacks(): Unit {
        let classes = getAllClasses()
        var cIdx: Int32 = 0
        for (cd in classes) {
            if (cIdx < Int32(classBtns.size)) {
                classBtns[Int64(cIdx)].onClick() { onClassPicked(cd) }
            }
            cIdx = cIdx + 1
        }
        for (i in 0..diceButtons.size) {
            let di = Int32(i)
            diceButtons[Int64(di)].onClick() { onDiceClick(di) }
        }
        actionBtn.onClick() { onAction() }
        playerSkillBtn.onClick() { onSkillToggle() }
    }

    //Screen Toggle
    private func showSelectScreen(): Unit {
        selectTitle.setPosition(Position.abs(WIN_W / Float32(2), Float32(50)))
        selectInfoLabel.setPosition(Position.abs(WIN_W / Float32(2), Float32(85)))

        let classes = getAllClasses()
        let btnW: Float32 = Float32(330)
        let btnH: Float32 = Float32(64)
        let gapX: Float32 = Float32(18)
        let gapY: Float32 = Float32(10)
        let totalW = Float32(2) * btnW + gapX
        let row1X = (WIN_W - totalW) / Float32(2) + btnW / Float32(2)

        var idx: Int32 = 0
        for (cd in classes) {
            if (idx < Int32(classBtns.size)) {
                let col = idx % 2
                let row = idx / 2
                let x = row1X + Float32(col) * (btnW + gapX)
                let y = Float32(140) + Float32(row) * (btnH + gapY)
                let btn = classBtns[Int64(idx)]
                btn.setText("${cd.name}  HP${cd.maxHP}  物x${cd.physicalAttackMul}  法x${cd.magicalAttackMul}")
                btn.setPosition(Position.abs(x, y))
                btn.setStyle(ButtonStyle.outlined())
            }
            idx = idx + 1
        }

        hideAllBattleWidgets()
    }

    private func showBattleScreen(): Unit {
        selectTitle.setPosition(Position.abs(OFF, OFF))
        selectInfoLabel.setPosition(Position.abs(OFF, OFF))
        for (btn in classBtns) {
            btn.setText("")
            btn.setPosition(Position.abs(OFF, OFF))
        }

        aiNameLabel.setPosition(Position.abs(MG, Y_AI_NAME))
        aiHpBar.setLayoutFrame(LayoutFrame(MG + X_HPBAR, Y_AI_HPROW, W_HPBAR, Float32(20)))
        aiHpLabel.setPosition(Position.abs(MG + X_HPLABEL, Y_AI_HPROW + Float32(2)))
        aiShieldLabel.setPosition(Position.abs(MG + X_SHIELD, Y_AI_HPROW + Float32(2)))
        aiSpBar.setLayoutFrame(LayoutFrame(MG + X_SPBAR, Y_AI_SPROW, W_SPBAR, Float32(12)))
        aiSpLabel.setPosition(Position.abs(MG + X_SPLABEL, Y_AI_SPROW))
        aiSkillNameLabel.setPosition(Position.abs(MG + X_SKILLNAME, Y_AI_SPROW))

        sep1.setLayoutFrame(LayoutFrame(MG, Y_SEP1, WIN_W - MG * Float32(2), Float32(2)))

        phaseLabel.setPosition(Position.abs(WIN_W / Float32(2), Y_PHASE))

        selectionInfoLabel.setPosition(Position.abs(MG, Y_SEL_INFO))
        resultLabel.setPosition(Position.abs(WIN_W / Float32(2), Y_RESULT))

        actionBtn.setPosition(Position.abs(WIN_W / Float32(2), Y_ACTION))
        actionBtn.setText("掷骰子")

        sep2.setLayoutFrame(LayoutFrame(MG, Y_SEP2, WIN_W - MG * Float32(2), Float32(2)))
        messageScroll.setLayoutFrame(LayoutFrame(MG, Y_MSG, WIN_W - MG * Float32(2), Float32(152)))

        sep3.setLayoutFrame(LayoutFrame(MG, Y_SEP3, WIN_W - MG * Float32(2), Float32(2)))

        playerNameLabel.setPosition(Position.abs(MG, Y_PL_NAME))
        playerHpBar.setLayoutFrame(LayoutFrame(MG + X_HPBAR, Y_PL_HPROW, W_HPBAR, Float32(20)))
        playerHpLabel.setPosition(Position.abs(MG + X_HPLABEL, Y_PL_HPROW + Float32(2)))
        playerShieldLabel.setPosition(Position.abs(MG + X_SHIELD, Y_PL_HPROW + Float32(2)))
        playerSpBar.setLayoutFrame(LayoutFrame(MG + X_SPBAR, Y_PL_SPROW, W_SPBAR, Float32(12)))
        playerSpLabel.setPosition(Position.abs(MG + X_SPLABEL, Y_PL_SPROW))
        playerSkillBtn.setPosition(Position.abs(WIN_W / Float32(2) + Float32(135), Y_ACTION))
    }

    private func hideAllBattleWidgets(): Unit {
        aiNameLabel.setPosition(Position.abs(OFF, OFF))
        aiHpBar.setLayoutFrame(LayoutFrame(OFF, OFF, Float32(1), Float32(1)))
        aiHpLabel.setPosition(Position.abs(OFF, OFF))
        aiShieldLabel.setPosition(Position.abs(OFF, OFF))
        aiSpBar.setLayoutFrame(LayoutFrame(OFF, OFF, Float32(1), Float32(1)))
        aiSpLabel.setPosition(Position.abs(OFF, OFF))
        aiSkillNameLabel.setPosition(Position.abs(OFF, OFF))
        sep1.setLayoutFrame(LayoutFrame(OFF, OFF, Float32(1), Float32(1)))

        phaseLabel.setPosition(Position.abs(OFF, OFF))
        for (btn in diceButtons) {
            btn.setText("")
            btn.setPosition(Position.abs(OFF, OFF))
        }
        selectionInfoLabel.setPosition(Position.abs(OFF, OFF))
        resultLabel.setPosition(Position.abs(OFF, OFF))
        actionBtn.setPosition(Position.abs(OFF, OFF))
        actionBtn.setText("")
        sep2.setLayoutFrame(LayoutFrame(OFF, OFF, Float32(1), Float32(1)))
        messageScroll.setLayoutFrame(LayoutFrame(OFF, OFF, Float32(1), Float32(1)))
        sep3.setLayoutFrame(LayoutFrame(OFF, OFF, Float32(1), Float32(1)))

        playerNameLabel.setPosition(Position.abs(OFF, OFF))
        playerHpBar.setLayoutFrame(LayoutFrame(OFF, OFF, Float32(1), Float32(1)))
        playerHpLabel.setPosition(Position.abs(OFF, OFF))
        playerShieldLabel.setPosition(Position.abs(OFF, OFF))
        playerSpBar.setLayoutFrame(LayoutFrame(OFF, OFF, Float32(1), Float32(1)))
        playerSpLabel.setPosition(Position.abs(OFF, OFF))
        playerSkillBtn.setPosition(Position.abs(OFF, OFF))
        playerSkillBtn.setText("")
    }

    //Handlers
    private func onClassPicked(cd: CharData): Unit {
        engine.selectPlayerClass(cd)
        showBattleScreen()
        refreshUI()
    }

    private func onSkillToggle(): Unit {
        engine.addSkillStack()
        refreshSkillButton()
        refreshSkillBars()
        refreshMessageLog()
    }

    private func onDiceClick(index: Int32): Unit {
        if (index >= engine.player.data.dicenum) { return }
        match (engine.phase) {
            case GamePhase.PLAYER_ATTACK =>
                engine.player.cycleDiceMode(index)
                refreshDiceDisplay()
                refreshSelectionInfo()
            case GamePhase.PLAYER_DEFEND =>
                engine.player.cycleDiceMode(index)
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
                if (engine.player.getTotalCount() != need) {
                    engine.log("请分配 ${need} 个骰子到物攻/法攻! (已分配: ${engine.player.getTotalCount()})")
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
                if (engine.player.getTotalCount() != need) {
                    engine.log("请分配 ${need} 个骰子到物防/法防! (已分配: ${engine.player.getTotalCount()})")
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

    //UI Refresh
    private func refreshUI(): Unit {
        refreshHPBars()
        refreshSkillBars()
        refreshShieldLabels()
        refreshNameLabels()
        refreshDiceDisplay()
        refreshSelectionInfo()
        refreshActionButton()
        refreshSkillButton()
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

    private func refreshSkillBars(): Unit {
        aiSpBar.setValue(Float32(engine.ai.skillPoints))
        aiSpLabel.setText("SP:${engine.ai.skillPoints}/${engine.ai.data.activeSkillCost}")
        let aiFull = engine.ai.skillPoints >= engine.ai.data.activeSkillCost
        aiSpBar.setStyle(if (aiFull) { spFullStyle } else { spNormStyle })
        aiSkillNameLabel.setText(if (aiFull) { getSkillName(engine.ai.data.id) } else { "" })

        playerSpBar.setValue(Float32(engine.player.skillPoints))
        playerSpLabel.setText("SP:${engine.player.skillPoints}/${engine.player.data.activeSkillCost}")
        let plFull = engine.player.skillPoints >= engine.player.data.activeSkillCost
        playerSpBar.setStyle(if (plFull) { spFullStyle } else { spNormStyle })
    }

    private func getSkillName(id: Int32): String {
        match (id) {
            case 1 => "剑气斩"
            case 2 => "坚盾"
            case 3 => "暗杀"
            case 4 => "奥术爆发"
            case 5 => "狂暴"
            case 6 => "圣光审判"
            case 7 => "元素过载"
            case 8 => "灵魂收割"
            case 9 => "魔剑共鸣"
            case 10 => "连击"
            case 11 => "恶咒"
            case 12 => "龙击"
            case _ => ""
        }
    }

    private func refreshSkillButton(): Unit {
        let plFull = engine.player.skillPoints >= engine.player.data.activeSkillCost
        if (plFull) {
            let name = getSkillName(engine.player.data.id)
            let stacks = engine.playerSkillStacks
            playerSkillBtn.setText(if (stacks > 0) { "${name} x${stacks}" } else { name })
            playerSkillBtn.setStyle(if (stacks > 0) { ButtonStyle.fromTheme() } else { ButtonStyle.outlined() })
        } else {
            if (engine.playerSkillStacks == 0) {
                playerSkillBtn.setText("")
                playerSkillBtn.setStyle(ButtonStyle.outlined())
            }
        }
    }

    private func refreshNameLabels(): Unit {
        aiNameLabel.setText("AI: ${engine.ai.data.name} (物防${engine.ai.data.physicalDefense} 法防${engine.ai.data.magicalDefense})")
        playerNameLabel.setText("你: ${engine.player.data.name} (物防${engine.player.data.physicalDefense} 法防${engine.player.data.magicalDefense})")
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
        let totalDice = engine.player.data.dicenum
        let diceSize: Float32 = Float32(42)
        let diceSpacing: Float32 = Float32(6)
        let totalW = Float32(totalDice) * diceSize + Float32(totalDice - 1) * diceSpacing
        let startX = (WIN_W - totalW) / Float32(2) + diceSize / Float32(2)

        for (i in 0..diceButtons.size) {
            let idx = Int32(i)
            let btn = diceButtons[Int64(idx)]
            if (idx < totalDice) {
                let dx = startX + Float32(idx) * (diceSize + diceSpacing)
                btn.setPosition(Position.abs(dx, Y_DICE))
                let val = engine.player.getDice(idx)
                let isPhys = engine.player.isPhysDice(idx)
                let isMag = engine.player.isMagDice(idx)
                if (clickable && isPhys) {
                    btn.setText("${val}")
                    btn.setStyle(physDiceStyle)
                } else if (clickable && isMag) {
                    btn.setText("${val}")
                    btn.setStyle(magDiceStyle)
                } else {
                    btn.setText("${val}")
                    btn.setStyle(ButtonStyle.outlined())
                }
            } else {
                btn.setText("")
                btn.setPosition(Position.abs(OFF, OFF))
            }
        }
    }

    private func refreshSelectionInfo(): Unit {
        match (engine.phase) {
            case GamePhase.PLAYER_ATTACK =>
                selectionInfoLabel.setText("物攻骰:${engine.player.getPhysCount()}/${engine.player.data.ATKnum} 合计:${engine.player.getPhysSum()} | 法攻骰:${engine.player.getMagCount()}/${engine.player.data.ATKnum} 合计:${engine.player.getMagSum()} | 需选${engine.player.data.ATKnum}个")
            case GamePhase.PLAYER_DEFEND =>
                selectionInfoLabel.setText("物防骰:${engine.player.getPhysCount()}/${engine.player.data.DMGnum} 合计:${engine.player.getPhysSum()} | 法防骰:${engine.player.getMagCount()}/${engine.player.data.DMGnum} 合计:${engine.player.getMagSum()} | 需选${engine.player.data.DMGnum}个")
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
            case GamePhase.PLAYER_ATTACK => phaseLabel.setText("分配 ${engine.player.data.ATKnum} 个骰子到物攻/法攻")
            case GamePhase.PLAYER_DEFEND => phaseLabel.setText("AI 攻击! 分配 ${engine.player.data.DMGnum} 个骰子到物防/法防")
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
        messageScroll.scrollBy(Float32(0), Float32(9999))
    }

    public func run(): Int32 {
        window.show()
        let result = window.run()
        Int32(result)
    }
}
