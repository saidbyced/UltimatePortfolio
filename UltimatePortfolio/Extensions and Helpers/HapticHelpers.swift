//
//  HapticHelpers.swift
//  UltimatePortfolio
//
//  Created by Christopher Eadie on 24/03/2022.
//

import CoreHaptics
import Foundation

enum UPHaptic {
    case tada
    
    var sharpness: CHHapticEventParameter {
        return .init(
            parameterID: .hapticSharpness,
            value: 0
        )
    }
    var intensity: CHHapticEventParameter {
        return .init(
            parameterID: .hapticIntensity,
            value: 1
        )
    }
    var start: CHHapticParameterCurve.ControlPoint {
        return .init(
            relativeTime: 0,
            value: 1
        )
    }
    var end: CHHapticParameterCurve.ControlPoint {
        return .init(
            relativeTime: 1,
            value: 0
        )
    }
    var parameterCurve: CHHapticParameterCurve {
        return .init(
            parameterID: .hapticIntensityControl,
            controlPoints: [start, end],
            relativeTime: 0
        )
    }
    var quickTap: CHHapticEvent {
        return .init(
            eventType: .hapticTransient,
            parameters: [intensity, sharpness],
            relativeTime: 0
        )
    }
    var fadingBuzz: CHHapticEvent {
        return .init(
            eventType: .hapticContinuous,
            parameters: [intensity, sharpness],
            relativeTime: 0.125,
            duration: 0.75
        )
    }
    func pattern() throws -> CHHapticPattern {
        return try .init(
            events: [quickTap, fadingBuzz],
            parameterCurves: [parameterCurve]
        )
    }
}
