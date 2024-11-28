//
//  RowStyleViewModifier.swift
//  DearDay
//
//  Created by Jaehui Yu on 11/28/24.
//

import SwiftUI

private struct RowTitle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(.secondary)
            .font(.callout)
            .lineLimit(1)
    }
}

private struct RowDDayText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(.secondary)
            .font(.title3)
            .fontWeight(.bold)
    }
}

private struct RowDate: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(.secondary.opacity(0.8))
            .font(.caption)
    }
}

extension View {
    func asRowTitle() -> some View {
        modifier(RowTitle())
    }
    
    func asRowDDayText() -> some View {
        modifier(RowDDayText())
    }
    
    func asRowDate() -> some View {
        modifier(RowDate())
    }
}
