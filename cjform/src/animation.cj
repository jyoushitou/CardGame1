package cjform

public enum Easing {
    | Linear
    | EaseIn
    | EaseOut
    | EaseInOut
}

public func applyEasing(easing: Easing, t: Float32): Float32 {
    match (easing) {
        case Easing.Linear => t
        case Easing.EaseIn =>
            if (t < 0.0) { 0.0 } else if (t > 1.0) { 1.0 } else { t * t * t }
        case Easing.EaseOut =>
            if (t < 0.0) { 0.0 } else if (t > 1.0) { 1.0 } else { 1.0 - (1.0 - t) * (1.0 - t) * (1.0 - t) }
        case Easing.EaseInOut =>
            if (t < 0.0) { 0.0 } else if (t > 1.0) { 1.0 } else {
                if (t < 0.5) { 4.0 * t * t * t } else { 1.0 - (-2.0 * t + 2.0) * (-2.0 * t + 2.0) * (-2.0 * t + 2.0) / 2.0 }
            }
    }
}

public func lerp(a: Float32, b: Float32, t: Float32): Float32 {
    a + (b - a) * t
}

public func lerpColor(a: Color, b: Color, t: Float32): Color {
    let ct = if (t < 0.0) { Float32(0.0) } else if (t > 1.0) { Float32(1.0) } else { t }
    Color(
        UInt8(Float32(a.r) + (Float32(b.r) - Float32(a.r)) * ct),
        UInt8(Float32(a.g) + (Float32(b.g) - Float32(a.g)) * ct),
        UInt8(Float32(a.b) + (Float32(b.b) - Float32(a.b)) * ct),
        UInt8(Float32(a.a) + (Float32(b.a) - Float32(a.a)) * ct)
    )
}

public class AnimationState {
    private var from: Float32 = 0.0
    private var to: Float32 = 0.0
    private var duration: Int64 = 0
    private var easing: Easing = Easing.Linear
    private var startTime: Int64 = 0
    private var finished: Bool = true
    private var currentValue: Float32 = 0.0

    public init() {}

    public func start(from: Float32, to: Float32, duration: Int64, easing: Easing): Unit {
        this.from = from
        this.to = to
        this.duration = duration
        this.easing = easing
        this.startTime = unsafe { bridge_get_tick_count() }
        this.finished = false
        this.currentValue = from
    }

    public func update(now: Int64): Unit {
        if (finished) { return }
        let elapsed = now - startTime
        if (elapsed >= duration) {
            currentValue = to
            finished = true
            return
        }
        let rawT = Float32(elapsed) / Float32(duration)
        currentValue = lerp(from, to, applyEasing(easing, rawT))
    }

    public func jumpToEnd(): Unit {
        currentValue = to
        finished = true
    }

    public func isFinished(): Bool { finished }
    public func getValue(): Float32 { currentValue }
}