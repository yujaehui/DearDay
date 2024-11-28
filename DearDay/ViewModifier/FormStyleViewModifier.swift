//
//  FormStyleViewModifier.swift
//  DearDay
//
//  Created by Jaehui Yu on 11/28/24.
//

import SwiftUI

private struct FormDate: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title)
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
    }
}

private struct FormConvertedDate: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
    }
}

extension View {
    func asFormDate() -> some View {
        modifier(FormDate())
    }
    
    func asFormConvertedDate() -> some View {
        modifier(FormConvertedDate())
    }
}
