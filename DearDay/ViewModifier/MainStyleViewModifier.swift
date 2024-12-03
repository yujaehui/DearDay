//
//  MainStyleViewModifier.swift
//  DearDay
//
//  Created by Jaehui Yu on 11/28/24.
//

import SwiftUI

private struct MainTitle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundStyle(.secondary)
            .font(.title3)
            .lineLimit(1)
    }
}

private struct MainDDayText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundStyle(.secondary)
            .font(.largeTitle)
    }
}

private struct MainDate: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundStyle(.secondary.opacity(0.8))
            .font(.callout)
    }
}

private struct MainRepeatType: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundStyle(.secondary.opacity(0.8))
            .font(.caption)
    }
}

extension View {
    func asMainTitle() -> some View {
        modifier(MainTitle())
    }
    
    func asMainDDayText() -> some View {
        modifier(MainDDayText())
    }
    
    func asMainDate() -> some View {
        modifier(MainDate())
    }
    
    func asMainRepeatType() -> some View {
        modifier(MainRepeatType())
    }
}
