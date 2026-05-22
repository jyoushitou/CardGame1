package myapp

import cjform.*
import std.collection.*

public class CardGameUI {
    private var window: Window
    private var engine: CardGameEngine

    //Mode Select
    private var modeTitle: Label
    private var modeBtnAI: Button
    private var modeBtn2P: Button
    private var modeBtnLAN: Button

    //LAN Lobby
    private var lobbyTitle: Label
    private var lobbyBtnHost: Button
    private var lobbyBtnJoin: Button
    private var lobbyInfoLabel: Label
    private var lobbyBackBtn: Button

    //LAN Host / Client
    private var lanServer: NetServer
    private var lanClient: NetClient
    private var lanPort: Int32
    private var isHost: Bool
    private var lanGameStarted: Bool
    private var netLogText: String

    //Character Select
    private var selectTitle: Label
    private var classBtns: ArrayList<Button>
    private var selectInfoLabel: Label

    //Race Select
    private var raceTitle: Label
    private var raceBtns: ArrayList<Button>
    private var raceInfoLabel: Label

    //Class Detail Popup
    private var detailVisible: Bool
    private var detailLabel: Label

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
    private let MAX_DICE: Int32 = 9

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
        raceBtns = ArrayList<Button>()
        diceButtons = ArrayList<Button>()
        detailVisible = false

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

        //MODE SCREEN
        modeTitle = Label("选择游戏模式",
            Position.abs(WIN_W / Float32(2), Float32(80)), c.accent,
            "Microsoft YaHei", Float32(24), SizeScale.fixed(), Anchor.Center)
        window.addWidget(modeTitle)

        modeBtnAI = Button("单人 vs AI",
            Position.abs(WIN_W / Float32(2) - Float32(170), Float32(180)), Float32(240), Float32(60),
            "Microsoft YaHei", Float32(16), SizeScale.fixed(), Anchor.Center,
            ButtonStyle.outlined(), { => () })
        window.addWidget(modeBtnAI)

        modeBtn2P = Button("双人对战",
            Position.abs(WIN_W / Float32(2) + Float32(170), Float32(180)), Float32(240), Float32(60),
            "Microsoft YaHei", Float32(16), SizeScale.fixed(), Anchor.Center,
            ButtonStyle.outlined(), { => () })
        window.addWidget(modeBtn2P)

        modeBtnLAN = Button("局域网联机",
            Position.abs(WIN_W / Float32(2), Float32(260)), Float32(240), Float32(60),
            "Microsoft YaHei", Float32(16), SizeScale.fixed(), Anchor.Center,
            ButtonStyle.outlined(), { => () })
        window.addWidget(modeBtnLAN)

        //LAN LOBBY
        lobbyTitle = Label("局域网联机",
            Position.abs(OFF, OFF), c.accent,
            "Microsoft YaHei", Float32(22), SizeScale.fixed(), Anchor.Center)
        window.addWidget(lobbyTitle)

        lobbyBtnHost = Button("创建房间",
            Position.abs(OFF, OFF), Float32(240), Float32(60),
            "Microsoft YaHei", Float32(16), SizeScale.fixed(), Anchor.Center,
            ButtonStyle.outlined(), { => () })
        window.addWidget(lobbyBtnHost)

        lobbyBtnJoin = Button("加入房间",
            Position.abs(OFF, OFF), Float32(240), Float32(60),
            "Microsoft YaHei", Float32(16), SizeScale.fixed(), Anchor.Center,
            ButtonStyle.outlined(), { => () })
        window.addWidget(lobbyBtnJoin)

        lobbyInfoLabel = Label("",
            Position.abs(OFF, OFF), c.textSecondary,
            "Microsoft YaHei", Float32(14), SizeScale.fixed(), Anchor.Center)
        window.addWidget(lobbyInfoLabel)

        lobbyBackBtn = Button("返回",
            Position.abs(OFF, OFF), Float32(120), Float32(40),
            "Microsoft YaHei", Float32(14), SizeScale.fixed(), Anchor.Center,
            ButtonStyle.outlined(), { => () })
        window.addWidget(lobbyBackBtn)

        lanServer = NetServer()
        lanClient = NetClient()
        lanPort = 9527
        isHost = false
        lanGameStarted = false
        netLogText = ""

        //SELECT SCREEN
        selectTitle = Label("选择你的角色",
            Position.abs(WIN_W / Float32(2), Float32(50)), c.accent,
            "Microsoft YaHei", Float32(22), SizeScale.fixed(), Anchor.Center)
        window.addWidget(selectTitle)

        selectInfoLabel = Label("不同职业物攻/法攻/物防/法防不同。物防仅减免物伤，法防仅减免法伤。",
            Position.abs(WIN_W / Float32(2), Float32(85)), c.textSecondary,
            "Microsoft YaHei", Float32(12), SizeScale.fixed(), Anchor.Center)
        window.addWidget(selectInfoLabel)

        //Class detail popup (right-click shows as overlay)
        detailLabel = Label("",
            Position.abs(OFF, OFF), c.textPrimary,
            "Microsoft YaHei", Float32(12), SizeScale.fixed(), Anchor.TopLeft)

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

        //RACE SELECT SCREEN
        raceTitle = Label("选择你的种族",
            Position.abs(WIN_W / Float32(2), Float32(50)), c.accent,
            "Microsoft YaHei", Float32(22), SizeScale.fixed(), Anchor.Center)
        window.addWidget(raceTitle)

        raceInfoLabel = Label("种族提供独特机制和每回合成长。数值加成较小，特性极强。",
            Position.abs(WIN_W / Float32(2), Float32(85)), c.textSecondary,
            "Microsoft YaHei", Float32(12), SizeScale.fixed(), Anchor.Center)
        window.addWidget(raceInfoLabel)

        let races = getAllRaces()
        let raceBtnW: Float32 = Float32(360)
        let raceBtnH: Float32 = Float32(72)
        let raceGapX: Float32 = Float32(18)
        let raceGapY: Float32 = Float32(10)
        let raceTotalW = Float32(2) * raceBtnW + raceGapX
        let raceRow1X = (WIN_W - raceTotalW) / Float32(2) + raceBtnW / Float32(2)

        var rIdx: Int32 = 0
        for (rd in races) {
            let col = rIdx % 2
            let row = rIdx / 2
            let x = raceRow1X + Float32(col) * (raceBtnW + raceGapX)
            let y = Float32(140) + Float32(row) * (raceBtnH + raceGapY)
            let rlabel = "${rd.name}\n${rd.desc}"
            let btn = Button(rlabel,
                Position.abs(x, y), raceBtnW, raceBtnH,
                "Microsoft YaHei", Float32(12), SizeScale.fixed(), Anchor.Center,
                ButtonStyle.outlined(), { => () })
            window.addWidget(btn)
            raceBtns.add(btn)
            rIdx = rIdx + 1
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
        window.setIdleCallback({ => pollNetwork() })
        showModeScreen()
    }

    private func wireCallbacks(): Unit {
        modeBtnAI.onClick() { onModePick(false) }
        modeBtn2P.onClick() { onModePick(true) }
        modeBtnLAN.onClick() { showLobbyScreen() }
        lobbyBtnHost.onClick() { onHostRoom() }
        lobbyBtnJoin.onClick() { onJoinRoom() }
        lobbyBackBtn.onClick() { hideLobbyScreen(); showModeScreen() }
        let classes = getAllClasses()
        var cIdx: Int32 = 0
        for (cd in classes) {
            if (cIdx < Int32(classBtns.size)) {
                classBtns[Int64(cIdx)].onClick() { onClassPicked(cd) }
                classBtns[Int64(cIdx)].onRightClick() { onClassRightClick(cd) }
            }
            cIdx = cIdx + 1
        }
        let races = getAllRaces()
        var rIdx2: Int32 = 0
        for (rd in races) {
            if (rIdx2 < Int32(raceBtns.size)) {
                raceBtns[Int64(rIdx2)].onClick() { onRacePicked(rd) }
            }
            rIdx2 = rIdx2 + 1
        }
        for (i in 0..diceButtons.size) {
            let di = Int32(i)
            diceButtons[Int64(di)].onClick() { onDiceClick(di) }
        }
        actionBtn.onClick() { onAction() }
        playerSkillBtn.onClick() { onSkillToggle() }
    }

    //Mode Screen
    private func showModeScreen(): Unit {
        modeTitle.setPosition(Position.abs(WIN_W / Float32(2), Float32(80)))
        modeBtnAI.setText("单人 vs AI")
        modeBtnAI.setPosition(Position.abs(WIN_W / Float32(2) - Float32(170), Float32(180)))
        modeBtnAI.setStyle(ButtonStyle.outlined())
        modeBtn2P.setText("双人对战")
        modeBtn2P.setPosition(Position.abs(WIN_W / Float32(2) + Float32(170), Float32(180)))
        modeBtn2P.setStyle(ButtonStyle.outlined())

        modeBtnLAN.setText("局域网联机")
        modeBtnLAN.setPosition(Position.abs(WIN_W / Float32(2), Float32(260)))
        modeBtnLAN.setStyle(ButtonStyle.outlined())

        hideLobbyScreen()

        selectTitle.setPosition(Position.abs(OFF, OFF))
        selectInfoLabel.setPosition(Position.abs(OFF, OFF))
        for (btn in classBtns) {
            btn.setText("")
            btn.setPosition(Position.abs(OFF, OFF))
        }
        hideAllBattleWidgets()
    }

    private func hideModeScreen(): Unit {
        modeTitle.setPosition(Position.abs(OFF, OFF))
        modeBtnAI.setText("")
        modeBtnAI.setPosition(Position.abs(OFF, OFF))
        modeBtn2P.setText("")
        modeBtn2P.setPosition(Position.abs(OFF, OFF))
        modeBtnLAN.setText("")
        modeBtnLAN.setPosition(Position.abs(OFF, OFF))
    }

    private func onModePick(isTwoPlayer: Bool): Unit {
        hideModeScreen()
        if (isTwoPlayer) {
            engine.selectMode(GameMode.VS_PLAYER)
            selectTitle.setText("玩家1 — 选择角色")
        } else {
            engine.selectMode(GameMode.VS_AI)
            selectTitle.setText("选择你的角色")
        }
        selectInfoLabel.setPosition(Position.abs(WIN_W / Float32(2), Float32(85)))
        showSelectScreen()
    }

    private func showLobbyScreen(): Unit {
        hideModeScreen()
        lobbyTitle.setPosition(Position.abs(WIN_W / Float32(2), Float32(80)))
        lobbyBtnHost.setPosition(Position.abs(WIN_W / Float32(2), Float32(170)))
        lobbyBtnJoin.setPosition(Position.abs(WIN_W / Float32(2), Float32(250)))
        lobbyInfoLabel.setText("")
        lobbyInfoLabel.setPosition(Position.abs(WIN_W / Float32(2), Float32(320)))
        lobbyBackBtn.setPosition(Position.abs(WIN_W / Float32(2), Float32(400)))
    }

    private func hideLobbyScreen(): Unit {
        lobbyTitle.setPosition(Position.abs(OFF, OFF))
        lobbyBtnHost.setPosition(Position.abs(OFF, OFF))
        lobbyBtnJoin.setPosition(Position.abs(OFF, OFF))
        lobbyInfoLabel.setPosition(Position.abs(OFF, OFF))
        lobbyBackBtn.setPosition(Position.abs(OFF, OFF))
    }

    private func onHostRoom(): Unit {
        netInit()
        if (lanServer.start(lanPort)) {
            isHost = true
            lobbyInfoLabel.setText("等待对手连接...\n端口: ${lanPort}\n\n请将你的IP地址告诉对手")
        } else {
            lobbyInfoLabel.setText("创建房间失败!")
        }
    }

    private func onJoinRoom(): Unit {
        netInit()
        lobbyInfoLabel.setText("正在搜索房间...")
        let hosts = NetClient.discover(lanPort)
        var host = ""
        if (hosts.size > 0) {
            host = hosts[0]
        } else {
            //Fallback: try localhost for testing
            host = "127.0.0.1"
        }
        if (lanClient.connect(host, lanPort)) {
            lobbyInfoLabel.setText("已连接到 ${host}\n等待房主开始游戏...")
            //Send READY to host
            lanClient.sendString(MsgBuilder(READY).build())
        } else {
            lobbyInfoLabel.setText("连接失败! (${host}:${lanPort})")
        }
    }

    //Check if it's this player's turn in network mode
    private func isMyTurn(): Bool {
        if (!lanGameStarted) { return true }
        let hostAttacks = engine.halfTurnCount % 2 == 0
        match (engine.phase) {
            case PLAYER_ROLL | PLAYER_ATTACK =>
                isHost == hostAttacks
            case PLAYER_DEFEND =>
                isHost != hostAttacks
            case _ => true
        }
    }

    //Network poll - call each frame
    public func pollNetwork(): Unit {
        if (isHost) {
            lanServer.acceptClient()
            let msgs = lanServer.poll()
            for (msg in msgs) {
                handleNetMsg(msg)
            }
        } else if (lanClient.isConnected()) {
            let msgs = lanClient.poll()
            for (msg in msgs) {
                handleNetMsg(msg)
            }
        }
    }

    private func sendToNet(msg: NetMsg): Unit {
        if (isHost) {
            lanServer.send(msg)
        } else {
            lanClient.send(msg)
        }
    }

    private func sendToNetStr(wire: String): Unit {
        if (isHost) {
            lanServer.sendString(wire)
        } else {
            lanClient.sendString(wire)
        }
    }

    private func handleNetMsg(msg: NetMsg): Unit {
        match (msg.msgType) {
            case READY =>
                if (isHost) {
                    lobbyInfoLabel.setText("对手已连接! 开始游戏中...")
                    lanServer.sendString(MsgBuilder(GAME_START).build())
                }
                startNetGame()
            case GAME_START =>
                startNetGame()
            case PHASE_CHANGE =>
                if (!isHost && lanGameStarted) {
                    //Host finished setup; now it's client's turn to pick
                    selectInfoLabel.setPosition(Position.abs(OFF, OFF))
                    selectTitle.setText("选择你的角色")
                    showSelectScreen()
                }
            case PICK_CLASS =>
                if (isHost && lanGameStarted) {
                    let classId = msg.getInt("id")
                    let classes = getAllClasses()
                    for (cd in classes) {
                        if (cd.id == classId) {
                            engine.selectP2Class(cd)
                            //Don't show screens — still waiting for PICK_RACE
                        }
                    }
                }
            case PICK_RACE =>
                if (isHost && lanGameStarted) {
                    let raceId = msg.getInt("id")
                    let races = getAllRaces()
                    for (rd in races) {
                        if (rd.id == raceId) {
                            engine.selectP2Race(rd)
                            selectInfoLabel.setPosition(Position.abs(OFF, OFF))
                            showBattleScreen()
                            refreshUI()
                            sendStateSync()
                        }
                    }
                }
            case STATE_SYNC =>
                if (!isHost) {
                    applyStateSync(msg)
                }
            case DICE_ROLL =>
                if (isHost && lanGameStarted) {
                    engine.playerRoll()
                    refreshUI()
                    sendStateSync()
                }
            case DICE_ASSIGN =>
                if (isHost && lanGameStarted) {
                    let diceOwner = engine.activeDiceOwner()
                    let physIdx = decodeIntArray(msg.get("phys"))
                    let magIdx = decodeIntArray(msg.get("mag"))
                    //Clear and re-apply assignment
                    diceOwner.clearSelection()
                    for (idx in physIdx) {
                        if (idx >= 0 && idx < Int32(diceOwner.physDice.size)) {
                            let newPhys = ArrayList<Bool>()
                            var pi: Int32 = 0
                            for (_ in 0..Int32(diceOwner.physDice.size)) {
                                newPhys.add(pi == idx)
                                pi = pi + 1
                            }
                            diceOwner.physDice = newPhys
                        }
                    }
                    for (idx in magIdx) {
                        if (idx >= 0 && idx < Int32(diceOwner.magDice.size)) {
                            let newMag = ArrayList<Bool>()
                            var pi: Int32 = 0
                            for (_ in 0..Int32(diceOwner.magDice.size)) {
                                newMag.add(pi == idx)
                                pi = pi + 1
                            }
                            diceOwner.magDice = newMag
                        }
                    }
                    //Auto-execute the next step
                    match (engine.phase) {
                        case PLAYER_ATTACK =>
                            engine.playerAttack()
                            refreshUI()
                            sendStateSync()
                        case PLAYER_DEFEND =>
                            engine.playerDefend()
                            refreshUI()
                            sendStateSync()
                        case _ => ()
                    }
                }
            case _ => ()
        }
    }

    private func startNetGame(): Unit {
        hideLobbyScreen()
        if (isHost) {
            engine.selectMode(GameMode.VS_PLAYER)
            selectTitle.setText("选择你的角色")
            showSelectScreen()
        } else {
            //Client: set mode, wait for host to pick first
            engine.gameMode = GameMode.VS_PLAYER
            selectTitle.setPosition(Position.abs(OFF, OFF))
            selectInfoLabel.setText("等待房主选择职业和种族...")
            selectInfoLabel.setPosition(Position.abs(WIN_W / Float32(2), Float32(200)))
        }
        lanGameStarted = true
    }

    private func sendStateSync(): Unit {
        let b = MsgBuilder(STATE_SYNC)
        b.addInt("phase", phaseToInt(engine.phase))
        //Send player/ai directly — host and client mirror the same swap state
        b.addInt("pl_hp", engine.player.hp)
        b.addInt("pl_sp", engine.player.skillPoints)
        b.addInt("pl_sh", engine.player.shields)
        b.addInt("pl_rs", engine.player.raceStacks)
        b.addInt("pl_bd", engine.player.bonusDice)
        b.addInt("pl_cls", engine.player.data.id)
        b.addInt("pl_rac", engine.player.race.id)
        b.addInt("ai_hp", engine.ai.hp)
        b.addInt("ai_sp", engine.ai.skillPoints)
        b.addInt("ai_sh", engine.ai.shields)
        b.addInt("ai_rs", engine.ai.raceStacks)
        b.addInt("ai_bd", engine.ai.bonusDice)
        b.addInt("ai_cls", engine.ai.data.id)
        b.addInt("ai_rac", engine.ai.race.id)
        b.addInt("gm", 1)
        b.addInt("turn", engine.halfTurnCount)
        let diceOwner = engine.activeDiceOwner()
        b.add("dice", encodeIntArray(diceOwner.diceResults))
        b.add("physd", encodeBoolArray(diceOwner.physDice))
        b.add("magd", encodeBoolArray(diceOwner.magDice))
        var logText = ""
        var firstLog = true
        for (m in engine.messages) {
            if (!firstLog) { logText = logText + "@@" }
            for (r in m.runes()) {
                if (r == r'|') { logText = logText + "!" }
                else if (r == r'=') { logText = logText + ":" }
                else { logText = logText + "${r}" }
            }
            firstLog = false
        }
        b.add("log", logText)
        sendToNetStr(b.build())
    }

    private func applyStateSync(msg: NetMsg): Unit {
        if (msg.getInt("gm") == 1) { engine.gameMode = GameMode.VS_PLAYER }
        engine.phase = intToPhase(msg.getInt("phase"))
        let plCls = msg.getInt("pl_cls")
        let plRac = msg.getInt("pl_rac")
        let aiCls = msg.getInt("ai_cls")
        let aiRac = msg.getInt("ai_rac")
        if (plCls > 0 && engine.player.data.id != plCls) {
            for (cd in getAllClasses()) {
                if (cd.id == plCls) { engine.player = Character(cd) }
            }
        }
        if (aiCls > 0 && engine.ai.data.id != aiCls) {
            for (cd in getAllClasses()) {
                if (cd.id == aiCls) { engine.ai = Character(cd) }
            }
        }
        if (plRac > 0) {
            for (rd in getAllRaces()) {
                if (rd.id == plRac) { engine.player.race = rd }
            }
        }
        if (aiRac > 0) {
            for (rd in getAllRaces()) {
                if (rd.id == aiRac) { engine.ai.race = rd }
            }
        }
        engine.player.hp = msg.getInt("pl_hp")
        engine.player.skillPoints = msg.getInt("pl_sp")
        engine.player.shields = msg.getInt("pl_sh")
        engine.player.raceStacks = msg.getInt("pl_rs")
        engine.player.bonusDice = msg.getInt("pl_bd")
        engine.ai.hp = msg.getInt("ai_hp")
        engine.ai.skillPoints = msg.getInt("ai_sp")
        engine.ai.shields = msg.getInt("ai_sh")
        engine.ai.raceStacks = msg.getInt("ai_rs")
        engine.ai.bonusDice = msg.getInt("ai_bd")
        engine.halfTurnCount = msg.getInt("turn")
        //Update dice for active player
        let diceVals = decodeIntArray(msg.get("dice"))
        let physAssign = decodeBoolArray(msg.get("physd"))
        let magAssign = decodeBoolArray(msg.get("magd"))
        if (diceVals.size > 0) {
            engine.activeDiceOwner().diceResults = diceVals
            engine.activeDiceOwner().physDice = physAssign
            engine.activeDiceOwner().magDice = magAssign
        }
        //Update log for client
        let logText = msg.get("log")
        if (logText.size > 0) {
            netLogText = logText
        }
        hideRaceScreen()
        showBattleScreen()
        refreshUI()
    }

    private func phaseToInt(phase: GamePhase): Int32 {
        match (phase) {
            case SELECT_MODE => 0
            case SELECT_CHARACTER => 1
            case SELECT_RACE => 2
            case SELECT_CHARACTER_P2 => 3
            case SELECT_RACE_P2 => 4
            case PLAYER_ROLL => 5
            case PLAYER_ATTACK => 6
            case AI_TURN => 7
            case PLAYER_DEFEND => 8
            case ROUND_RESULT => 9
            case GAME_OVER => 10
        }
    }

    private func intToPhase(i: Int32): GamePhase {
        if (i == 0) { SELECT_MODE }
        else if (i == 1) { SELECT_CHARACTER }
        else if (i == 2) { SELECT_RACE }
        else if (i == 3) { SELECT_CHARACTER_P2 }
        else if (i == 4) { SELECT_RACE_P2 }
        else if (i == 5) { PLAYER_ROLL }
        else if (i == 6) { PLAYER_ATTACK }
        else if (i == 7) { AI_TURN }
        else if (i == 8) { PLAYER_DEFEND }
        else if (i == 9) { ROUND_RESULT }
        else { GAME_OVER }
    }

    private func hideSelectScreenLocal(): Unit {
        selectTitle.setPosition(Position.abs(OFF, OFF))
        selectInfoLabel.setPosition(Position.abs(OFF, OFF))
        for (b in classBtns) {
            b.setText("")
            b.setPosition(Position.abs(OFF, OFF))
        }
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
        hideRaceScreen()
    }

    private func showRaceScreen(): Unit {
        hideClassDetail()
        raceTitle.setPosition(Position.abs(WIN_W / Float32(2), Float32(50)))
        raceInfoLabel.setPosition(Position.abs(WIN_W / Float32(2), Float32(85)))

        let races = getAllRaces()
        let raceBtnW: Float32 = Float32(360)
        let raceBtnH: Float32 = Float32(72)
        let raceGapX: Float32 = Float32(18)
        let raceGapY: Float32 = Float32(10)
        let raceTotalW = Float32(2) * raceBtnW + raceGapX
        let raceRow1X = (WIN_W - raceTotalW) / Float32(2) + raceBtnW / Float32(2)

        var rIdx: Int32 = 0
        for (rd in races) {
            if (rIdx < Int32(raceBtns.size)) {
                let col = rIdx % 2
                let row = rIdx / 2
                let x = raceRow1X + Float32(col) * (raceBtnW + raceGapX)
                let y = Float32(140) + Float32(row) * (raceBtnH + raceGapY)
                let btn = raceBtns[Int64(rIdx)]
                btn.setText("${rd.name}\n${rd.desc}")
                btn.setPosition(Position.abs(x, y))
                btn.setStyle(ButtonStyle.outlined())
            }
            rIdx = rIdx + 1
        }
    }

    private func hideRaceScreen(): Unit {
        raceTitle.setPosition(Position.abs(OFF, OFF))
        raceInfoLabel.setPosition(Position.abs(OFF, OFF))
        for (btn in raceBtns) {
            btn.setText("")
            btn.setPosition(Position.abs(OFF, OFF))
        }
    }

    private func showBattleScreen(): Unit {
        hideClassDetail()
        selectTitle.setPosition(Position.abs(OFF, OFF))
        selectInfoLabel.setPosition(Position.abs(OFF, OFF))
        for (btn in classBtns) {
            btn.setText("")
            btn.setPosition(Position.abs(OFF, OFF))
        }
        hideRaceScreen()

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

        hideRaceScreen()
    }

    //Handlers
    private func onClassRightClick(cd: CharData): Unit {
        if (detailVisible) {
            hideClassDetail()
        } else {
            showClassDetail(cd)
        }
    }

    private func showClassDetail(cd: CharData): Unit {
        let detailText = getClassDetail(cd)
        detailLabel.setText(detailText)
        //Create a popover to float on top with background
        let popover = Popover(detailLabel, WIN_W / Float32(2), Float32(400), Float32(520), Float32(200),
            PopoverStyle.fromTheme())
        window.showOverlay(popover)
        detailVisible = true
    }

    private func hideClassDetail(): Unit {
        window.dismissOverlay()
        detailVisible = false
    }

    private func onClassPicked(cd: CharData): Unit {
        //Network mode: client sends pick to host
        if (lanGameStarted && !isHost) {
            sendToNetStr(MsgBuilder(PICK_CLASS).addInt("id", cd.id).build())
            selectInfoLabel.setText("已选择 ${cd.name}，等待对手...")
            selectTitle.setPosition(Position.abs(OFF, OFF))
            selectInfoLabel.setPosition(Position.abs(WIN_W / Float32(2), Float32(200)))
            for (b in classBtns) {
                b.setText("")
                b.setPosition(Position.abs(OFF, OFF))
            }
            //Client also picks race immediately
            raceTitle.setText("选择你的种族")
            showRaceScreen()
            return
        }
        match (engine.phase) {
            case GamePhase.SELECT_CHARACTER =>
                engine.selectPlayerClass(cd)
                if (lanGameStarted && isHost) {
                    //Host P1: go to race selection
                    raceTitle.setText("选择你的种族")
                } else if (engine.gameMode == GameMode.VS_PLAYER) {
                    selectTitle.setText("玩家1 — 选择角色")
                    raceTitle.setText("玩家1 — 选择种族")
                }
                selectTitle.setPosition(Position.abs(OFF, OFF))
                selectInfoLabel.setPosition(Position.abs(OFF, OFF))
                for (b in classBtns) {
                    b.setText("")
                    b.setPosition(Position.abs(OFF, OFF))
                }
                showRaceScreen()
            case GamePhase.SELECT_CHARACTER_P2 =>
                engine.selectP2Class(cd)
                raceTitle.setText("玩家2 — 选择种族")
                selectTitle.setPosition(Position.abs(OFF, OFF))
                selectInfoLabel.setPosition(Position.abs(OFF, OFF))
                for (b in classBtns) {
                    b.setText("")
                    b.setPosition(Position.abs(OFF, OFF))
                }
                showRaceScreen()
            case _ => ()
        }
    }

    private func onRacePicked(rd: RaceData): Unit {
        //Network mode: client sends pick to host, then waits
        if (lanGameStarted && !isHost) {
            sendToNetStr(MsgBuilder(PICK_RACE).addInt("id", rd.id).build())
            hideRaceScreen()
            selectInfoLabel.setText("已选择 ${rd.name}，等待房主开始对战...")
            selectInfoLabel.setPosition(Position.abs(WIN_W / Float32(2), Float32(250)))
            return
        }
        match (engine.phase) {
            case GamePhase.SELECT_RACE =>
                engine.selectPlayerRace(rd)
                if (lanGameStarted && isHost) {
                    //Host P1 done; tell client to pick, then wait
                    hideRaceScreen()
                    selectInfoLabel.setText("等待对手选择职业和种族...")
                    selectInfoLabel.setPosition(Position.abs(WIN_W / Float32(2), Float32(250)))
                    //Signal client it's their turn
                    sendToNetStr(MsgBuilder(PHASE_CHANGE).addInt("phase", phaseToInt(engine.phase)).build())
                } else if (engine.gameMode == GameMode.VS_PLAYER) {
                    selectTitle.setText("玩家2 — 选择角色")
                    hideRaceScreen()
                    showSelectScreen()
                } else {
                    hideRaceScreen()
                    showBattleScreen()
                    refreshUI()
                }
            case GamePhase.SELECT_RACE_P2 =>
                engine.selectP2Race(rd)
                hideRaceScreen()
                showBattleScreen()
                refreshUI()
                if (lanGameStarted && isHost) {
                    sendStateSync()
                }
            case _ => ()
        }
    }

    private func onSkillToggle(): Unit {
        if (!isMyTurn()) { return }
        engine.addSkillStack()
        refreshSkillButton()
        refreshSkillBars()
        refreshMessageLog()
    }

    private func onDiceClick(index: Int32): Unit {
        if (!isMyTurn()) { return }
        let diceOwner = engine.activeDiceOwner()
        if (index >= Int32(diceOwner.diceResults.size)) { return }
        match (engine.phase) {
            case GamePhase.PLAYER_ATTACK =>
                diceOwner.cycleDiceMode(index)
                refreshDiceDisplay()
                refreshSelectionInfo()
            case GamePhase.PLAYER_DEFEND =>
                diceOwner.cycleDiceMode(index)
                refreshDiceDisplay()
                refreshSelectionInfo()
            case _ => ()
        }
    }

    private func onAction(): Unit {
        if (!isMyTurn()) { return }
        //Network client: send actions to host
        if (lanGameStarted && !isHost) {
            match (engine.phase) {
                case PLAYER_ROLL =>
                    sendToNetStr(MsgBuilder(DICE_ROLL).build())
                case PLAYER_ATTACK =>
                    let need = engine.player.data.ATKnum
                    if (engine.player.getTotalCount() != need) {
                        engine.log("请分配 ${need} 个骰子到物攻/法攻!")
                        refreshMessageLog()
                        return
                    }
                    //Send dice assignment to host
                    let diceOwner = engine.activeDiceOwner()
                    let physIdx = ArrayList<Int32>()
                    let magIdx = ArrayList<Int32>()
                    var pos: Int32 = 0
                    for (_ in 0..Int32(diceOwner.diceResults.size)) {
                        if (diceOwner.isPhysDice(pos)) { physIdx.add(pos) }
                        if (diceOwner.isMagDice(pos)) { magIdx.add(pos) }
                        pos = pos + 1
                    }
                    sendToNetStr(MsgBuilder(DICE_ASSIGN).add("phys", encodeIntArray(physIdx)).add("mag", encodeIntArray(magIdx)).build())
                case PLAYER_DEFEND =>
                    let diceOwner = engine.activeDiceOwner()
                    let need = diceOwner.data.DMGnum
                    if (diceOwner.getTotalCount() != need) {
                        engine.log("请分配 ${need} 个骰子到物防/法防!")
                        refreshMessageLog()
                        return
                    }
                    let physIdx = ArrayList<Int32>()
                    let magIdx = ArrayList<Int32>()
                    var pos: Int32 = 0
                    for (_ in 0..Int32(diceOwner.diceResults.size)) {
                        if (diceOwner.isPhysDice(pos)) { physIdx.add(pos) }
                        if (diceOwner.isMagDice(pos)) { magIdx.add(pos) }
                        pos = pos + 1
                    }
                    sendToNetStr(MsgBuilder(DICE_ASSIGN).add("phys", encodeIntArray(physIdx)).add("mag", encodeIntArray(magIdx)).build())
                case _ => ()
            }
            return
        }

        match (engine.phase) {
            case GamePhase.PLAYER_ROLL =>
                engine.playerRoll()
                refreshUI()
                if (isHost && lanGameStarted) { sendStateSync() }

            case GamePhase.PLAYER_ATTACK =>
                let need = engine.player.data.ATKnum
                if (engine.player.getTotalCount() != need) {
                    engine.log("请分配 ${need} 个骰子到物攻/法攻! (已分配: ${engine.player.getTotalCount()})")
                    refreshMessageLog()
                    return
                }
                engine.playerAttack()
                if (engine.gameMode == GameMode.VS_AI && engine.phase == GamePhase.AI_TURN && engine.ai.hp > 0) {
                    engine.aiAttack()
                }
                refreshUI()
                if (isHost && lanGameStarted) { sendStateSync() }

            case GamePhase.PLAYER_DEFEND =>
                let diceOwner = engine.activeDiceOwner()
                let need = diceOwner.data.DMGnum
                if (diceOwner.getTotalCount() != need) {
                    engine.log("请分配 ${need} 个骰子到物防/法防! (已分配: ${diceOwner.getTotalCount()})")
                    refreshMessageLog()
                    return
                }
                engine.playerDefend()
                refreshUI()
                if (isHost && lanGameStarted) { sendStateSync() }

            case GamePhase.ROUND_RESULT =>
                engine.startNewRound()
                refreshUI()
                if (isHost && lanGameStarted) { sendStateSync() }

            case GamePhase.GAME_OVER =>
                engine = CardGameEngine()
                showModeScreen()

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
        let bottom = engine.activeDiceOwner()
        let top = engine.topChar()
        aiHpBar.setValue(Float32(top.hp))
        aiHpLabel.setText("${top.hp}/${top.effMaxHP()}")
        playerHpBar.setValue(Float32(bottom.hp))
        playerHpLabel.setText("${bottom.hp}/${bottom.data.maxHP}")
    }

    private func refreshSkillBars(): Unit {
        let bottom = engine.activeDiceOwner()
        let top = engine.topChar()
        aiSpBar.setValue(Float32(top.skillPoints))
        let topCost = top.effectiveSkillCost()
        aiSpLabel.setText("SP:${top.skillPoints}/${topCost}")
        let topFull = top.skillPoints >= topCost
        aiSpBar.setStyle(if (topFull) { spFullStyle } else { spNormStyle })
        aiSkillNameLabel.setText(if (topFull) { getSkillName(top.data.id) } else { "" })

        playerSpBar.setValue(Float32(bottom.skillPoints))
        let plCost = bottom.effectiveSkillCost()
        playerSpLabel.setText("SP:${bottom.skillPoints}/${plCost}")
        let plFull = bottom.skillPoints >= plCost
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
        let plFull = engine.player.skillPoints >= engine.player.effectiveSkillCost()
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
        let bottom = engine.activeDiceOwner()
        let top = engine.topChar()
        if (engine.gameMode == GameMode.VS_PLAYER) {
            let isP1Att = engine.halfTurnCount % 2 == 0
            var bottomName: String = ""
            var topName: String = ""
            if (engine.phase == GamePhase.PLAYER_DEFEND) {
                //defend phase: bottom=defender, top=attacker
                bottomName = if (isP1Att) { "玩家2" } else { "玩家1" }
                topName = if (isP1Att) { "玩家1" } else { "玩家2" }
            } else {
                bottomName = if (isP1Att) { "玩家1" } else { "玩家2" }
                topName = if (isP1Att) { "玩家2" } else { "玩家1" }
            }
            playerNameLabel.setText("${bottomName}: ${bottom.data.name}[${bottom.race.name}] (物防${bottom.data.physicalDefense} 法防${bottom.data.magicalDefense})")
            aiNameLabel.setText("${topName}: ${top.data.name}[${top.race.name}] (物防${top.data.physicalDefense} 法防${top.data.magicalDefense})")
        } else {
            aiNameLabel.setText("AI: ${top.data.name}[${top.race.name}] (物防${top.data.physicalDefense} 法防${top.data.magicalDefense})")
            playerNameLabel.setText("你: ${bottom.data.name}[${bottom.race.name}] (物防${bottom.data.physicalDefense} 法防${bottom.data.magicalDefense})")
        }
    }

    private func refreshShieldLabels(): Unit {
        let bottom = engine.activeDiceOwner()
        let top = engine.topChar()
        aiShieldLabel.setText("盾:${top.shields}")
        playerShieldLabel.setText("盾:${bottom.shields}")
    }

    private func refreshDiceDisplay(): Unit {
        let clickable = match (engine.phase) {
            case GamePhase.PLAYER_ATTACK => true
            case GamePhase.PLAYER_DEFEND => true
            case _ => false
        }
        let diceOwner = engine.activeDiceOwner()
        let totalDice = Int32(diceOwner.diceResults.size)
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
                let val = diceOwner.getDice(idx)
                let isPhys = diceOwner.isPhysDice(idx)
                let isMag = diceOwner.isMagDice(idx)
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
        let diceOwner = engine.activeDiceOwner()
        match (engine.phase) {
            case GamePhase.PLAYER_ATTACK =>
                selectionInfoLabel.setText("物攻骰:${diceOwner.getPhysCount()}/${diceOwner.data.ATKnum} 合计:${diceOwner.getPhysSum()} | 法攻骰:${diceOwner.getMagCount()}/${diceOwner.data.ATKnum} 合计:${diceOwner.getMagSum()} | 需选${diceOwner.data.ATKnum}个")
            case GamePhase.PLAYER_DEFEND =>
                selectionInfoLabel.setText("物防骰:${diceOwner.getPhysCount()}/${diceOwner.data.DMGnum} 合计:${diceOwner.getPhysSum()} | 法防骰:${diceOwner.getMagCount()}/${diceOwner.data.DMGnum} 合计:${diceOwner.getMagSum()} | 需选${diceOwner.data.DMGnum}个")
            case _ => selectionInfoLabel.setText("")
        }
    }

    private func refreshActionButton(): Unit {
        if (lanGameStarted && !isMyTurn()) {
            actionBtn.setText("等待对手...")
            return
        }
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
        let who = if (engine.gameMode == GameMode.VS_PLAYER) {
            if (engine.phase == GamePhase.PLAYER_DEFEND) {
                if (engine.halfTurnCount % 2 == 0) { "玩家2" } else { "玩家1" }
            } else {
                if (engine.halfTurnCount % 2 == 0) { "玩家1" } else { "玩家2" }
            }
        } else {
            "你"
        }
        let diceOwner = engine.activeDiceOwner()
        match (engine.phase) {
            case GamePhase.PLAYER_ROLL => phaseLabel.setText("${who}的回合 — 请掷骰子")
            case GamePhase.PLAYER_ATTACK => phaseLabel.setText("${who} — 分配 ${diceOwner.data.ATKnum} 个骰子到物攻/法攻")
            case GamePhase.PLAYER_DEFEND => phaseLabel.setText("${who} — 分配 ${diceOwner.data.DMGnum} 个骰子到物防/法防")
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
        if (lanGameStarted && !isHost) {
            var displayText = ""
            let len = Int32(netLogText.size)
            var i: Int32 = 0
            while (i < len) {
                if (i + 1 < len && charAt(netLogText, i) == "@" && charAt(netLogText, i + 1) == "@") {
                    displayText = displayText + "\n"
                    i = i + 2
                } else {
                    displayText = displayText + charAt(netLogText, i)
                    i = i + 1
                }
            }
            messageLabel.setText(displayText)
        } else {
            messageLabel.setText(engine.getRecentMessages())
        }
        messageScroll.scrollBy(Float32(0), Float32(9999))
    }

    public func run(): Int32 {
        window.show()
        let result = window.run()
        Int32(result)
    }
}

func getClassDetail(cd: CharData): String {
    match (cd.id) {
        case 1 => "【剑士】HP${cd.maxHP}  物x${cd.physicalAttackMul} 法x${cd.magicalAttackMul}  物防${cd.physicalDefense} 法防${cd.magicalDefense}\n骰子${cd.dicenum}个  攻击选${cd.ATKnum}个  防御选${cd.DMGnum}个\n\n主动技【剑气斩】SP${cd.activeSkillCost}\n物攻法攻 +50%/层，可叠加\n\n被动技【剑气暴击】阈值${cd.passiveSkillThreshold}\n暴击 x4 伤害"
        case 2 => "【盾卫】HP${cd.maxHP}  物x${cd.physicalAttackMul} 法x${cd.magicalAttackMul}  物防${cd.physicalDefense} 法防${cd.magicalDefense}\n骰子${cd.dicenum}个  攻击选${cd.ATKnum}个  防御选${cd.DMGnum}个\n\n主动技【坚盾】SP${cd.activeSkillCost}\n受到伤害-40%，反弹20%伤害\n\n被动技【铁壁】阈值${cd.passiveSkillThreshold}\n暴击 x4 伤害"
        case 3 => "【暗影】HP${cd.maxHP}  物x${cd.physicalAttackMul} 法x${cd.magicalAttackMul}  物防${cd.physicalDefense} 法防${cd.magicalDefense}\n骰子${cd.dicenum}个  攻击选${cd.ATKnum}个  防御选${cd.DMGnum}个\n\n主动技【暗杀】SP${cd.activeSkillCost}\n攻击 +30%/层，可叠加\n\n被动技【致命一击】阈值${cd.passiveSkillThreshold}\n暴击 x4 伤害"
        case 4 => "【术士】HP${cd.maxHP}  物x${cd.physicalAttackMul} 法x${cd.magicalAttackMul}  物防${cd.physicalDefense} 法防${cd.magicalDefense}\n骰子${cd.dicenum}个  攻击选${cd.ATKnum}个  防御选${cd.DMGnum}个\n\n主动技【奥术爆发】SP${cd.activeSkillCost}\n法攻 +60%/层，穿透+30%/层\n\n被动技【奥术暴击】阈值${cd.passiveSkillThreshold}\n暴击 x4 伤害"
        case 5 => "【狂战】HP${cd.maxHP}  物x${cd.physicalAttackMul} 法x${cd.magicalAttackMul}  物防${cd.physicalDefense} 法防${cd.magicalDefense}\n骰子${cd.dicenum}个  攻击选${cd.ATKnum}个  防御选${cd.DMGnum}个\n\n主动技【狂暴】SP${cd.activeSkillCost}\n攻击 +70%/层，但受到伤害+30%\n\n被动技【狂怒暴击】阈值${cd.passiveSkillThreshold}\n暴击 x4 伤害"
        case 6 => "【圣骑】HP${cd.maxHP}  物x${cd.physicalAttackMul} 法x${cd.magicalAttackMul}  物防${cd.physicalDefense} 法防${cd.magicalDefense}\n骰子${cd.dicenum}个  攻击选${cd.ATKnum}个  防御选${cd.DMGnum}个\n\n主动技【圣光审判】SP${cd.activeSkillCost}\n攻击 +25%/层，回复20%HP/层\n\n被动技【圣光暴击】阈值${cd.passiveSkillThreshold}\n暴击 x4 伤害"
        case 7 => "【元素使】HP${cd.maxHP}  物x${cd.physicalAttackMul} 法x${cd.magicalAttackMul}  物防${cd.physicalDefense} 法防${cd.magicalDefense}\n骰子${cd.dicenum}个  攻击选${cd.ATKnum}个  防御选${cd.DMGnum}个\n\n主动技【元素过载】SP${cd.activeSkillCost}\n法攻 +100%/层，无视防御骰！\n\n被动技【元素暴击】阈值${cd.passiveSkillThreshold}\n暴击 x4 伤害"
        case 8 => "【死灵】HP${cd.maxHP}  物x${cd.physicalAttackMul} 法x${cd.magicalAttackMul}  物防${cd.physicalDefense} 法防${cd.magicalDefense}\n骰子${cd.dicenum}个  攻击选${cd.ATKnum}个  防御选${cd.DMGnum}个\n\n主动技【灵魂收割】SP${cd.activeSkillCost}\n攻击 +20%/层，吸血40%，削弱敌方25%\n\n被动技【死灵暴击】阈值${cd.passiveSkillThreshold}\n暴击 x4 伤害"
        case 9 => "【魔剑士】HP${cd.maxHP}  物x${cd.physicalAttackMul} 法x${cd.magicalAttackMul}  物防${cd.physicalDefense} 法防${cd.magicalDefense}\n骰子${cd.dicenum}个  攻击选${cd.ATKnum}个  防御选${cd.DMGnum}个\n\n主动技【魔剑共鸣】SP${cd.activeSkillCost}\n物攻法攻 +45%/层，可叠加\n\n被动技【魔剑暴击】阈值${cd.passiveSkillThreshold}\n暴击 x4 伤害"
        case 10 => "【武僧】HP${cd.maxHP}  物x${cd.physicalAttackMul} 法x${cd.magicalAttackMul}  物防${cd.physicalDefense} 法防${cd.magicalDefense}\n骰子${cd.dicenum}个  攻击选${cd.ATKnum}个  防御选${cd.DMGnum}个\n\n主动技【连击】SP${cd.activeSkillCost}\n攻击 +50%/层，回复15%HP/层\n\n被动技【连击暴击】阈值${cd.passiveSkillThreshold}\n暴击 x4 伤害"
        case 11 => "【咒术师】HP${cd.maxHP}  物x${cd.physicalAttackMul} 法x${cd.magicalAttackMul}  物防${cd.physicalDefense} 法防${cd.magicalDefense}\n骰子${cd.dicenum}个  攻击选${cd.ATKnum}个  防御选${cd.DMGnum}个\n\n主动技【恶咒】SP${cd.activeSkillCost}\n法攻 +40%/层，穿透+15%/层，削弱敌方25%\n\n被动技【咒术暴击】阈值${cd.passiveSkillThreshold}\n暴击 x4 伤害"
        case 12 => "【龙骑士】HP${cd.maxHP}  物x${cd.physicalAttackMul} 法x${cd.magicalAttackMul}  物防${cd.physicalDefense} 法防${cd.magicalDefense}\n骰子${cd.dicenum}个  攻击选${cd.ATKnum}个  防御选${cd.DMGnum}个\n\n主动技【龙击】SP${cd.activeSkillCost}\n物攻 +80%/层，穿透+40%/层\n\n被动技【龙骑暴击】阈值${cd.passiveSkillThreshold}\n暴击 x4 伤害"
        case _ => ""
    }
}
