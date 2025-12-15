//
//  CustomModifiers.swift
//  Step Tracker
//
//  Created by Chris Shireman on 12/15/25.
//

import SwiftUI

struct ProminentButton: ViewModifier {
    var color: Color

    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
                .buttonStyle(.glassProminent)
                .tint(color)
        } else {
            content
                .buttonStyle(.borderedProminent)
                .tint(color)
        }
    }
}

extension View {
    func prominentButton(color: Color = .blue) -> some View {
        modifier(ProminentButton(color: color))
    }
}
