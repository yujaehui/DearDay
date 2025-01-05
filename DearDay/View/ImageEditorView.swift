//
//  ImageEditorView.swift
//  DearDay
//
//  Created by Jaehui Yu on 1/3/25.
//

import SwiftUI

struct ImageEditorView: View {
    @Binding var selectedImage: UIImage? // 선택된 이미지
    var onComplete: ((UIImage?) -> Void)? // 완료 시 호출되는 클로저
    var onCancel: (() -> Void)? // 취소 시 호출되는 클로저
    
    @State private var scale: CGFloat = 1.0 // 확대/축소 배율
    @State private var lastScale: CGFloat = 1.0 // 이전 확대/축소 값
    @State private var offset: CGSize = .zero // 이미지 위치
    @State private var lastOffset: CGSize = .zero // 드래그 종료 시 위치
    
    @State private var isInteracting: Bool = false // 제스처 활성화 여부
    @State private var isGridAppear: Bool = false // 그리드 활성화 여부
    
    @State private var isPortrait: Bool = true // 세로/가로 방향 선택
    @State private var aspectRatio: CGSize = CGSize(width: 1, height: 1) // 초기 비율 1:1
    @State private var selectedRatioIndex: Int = 0 // 선택된 비율 인덱스
    private let aspectRatios: [(name: String, size: CGSize)] = [
        ("1:1", CGSize(width: 1, height: 1)),
        ("2:3", CGSize(width: 2, height: 3)),
        ("3:4", CGSize(width: 3, height: 4)),
        ("4:5", CGSize(width: 4, height: 5)),
        ("5:7", CGSize(width: 5, height: 7))
    ]
    
    @State private var cropSize: CGSize = .zero
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                imageEditor()
                Spacer()
            }
            .padding()
            editorControls()
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("취소") {
                            onCancel?()
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("완료") {
                            let render = ImageRenderer(content: imageEditor())
                            render.proposedSize = .init(cropSize)
                            render.scale = UIScreen.main.scale // 디스플레이 스케일 설정
                            if let image = render.uiImage {
                                onComplete?(image)
                            } else {
                                onComplete?(nil)
                            }
                        }
                    }
                }
        }
    }
}

private extension ImageEditorView {
    // MARK: - ImageEditor
    @ViewBuilder
    private func imageEditor() -> some View {
        if let image = selectedImage {
            GeometryReader { geometry in
                let size = geometry.size
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .overlay { imageBoundsOverlay(size: size) }
                    .frame(width: size.width, height: size.height)
            }
            .scaleEffect(scale)
            .offset(offset)
            .coordinateSpace(name: "CROPVIEW")
            .gesture(dragGesture())
            .gesture(magnificationGesture())
            .background { Color.secondary }
            .overlay { isGridAppear ? GridOverlay() : nil }
            .aspectRatio(aspectRatio, contentMode: .fit)
            .clipped()
        } else {
            Text("이미지가 선택되지 않았습니다.")
                .foregroundColor(.secondary)
        }
    }
    
    private func imageBoundsOverlay(size: CGSize) -> some View {
        GeometryReader { proxy in
            let rect = proxy.frame(in: .named("CROPVIEW"))
            Color.clear
                .onAppear {
                    isInteracting = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isInteracting = false
                    }
                }
                .onChange(of: isInteracting) { newValue in
                    validateBounds(rect: rect, size: size)
                    if !newValue { lastOffset = offset }
                    cropSize = size
                }
        }
    }
    
    private func validateBounds(rect: CGRect, size: CGSize) {
        withAnimation(.easeInOut(duration: 0.2)) {
            if rect.minX > 0 {
                offset.width -= rect.minX
                haptic(.medium)
            }
            if rect.minY > 0 { 
                offset.height -= rect.minY
                haptic(.medium)
            }
            if rect.maxX < size.width {
                offset.width -= (rect.maxX - size.width)
                haptic(.medium)
            }
            if rect.maxY < size.height {
                offset.height -= (rect.maxY - size.height)
                haptic(.medium)
            }
        }
    }
    
    private func haptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
    
    private func dragGesture() -> some Gesture {
        DragGesture()
            .onChanged { value in
                isInteracting = true
                isGridAppear = true
                offset = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
            }
            .onEnded { _ in
                isInteracting = false
                isGridAppear = false
                lastOffset = offset
            }
    }
    
    private func magnificationGesture() -> some Gesture {
        MagnificationGesture()
            .onChanged { value in
                isInteracting = true
                isGridAppear = true
                scale = max(0.5, lastScale * value)
            }
            .onEnded { _ in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isInteracting = false
                    isGridAppear = false
                    if scale < 1 {
                        scale = 1
                        lastScale = scale
                    } else {
                        lastScale = scale
                    }
                }
            }
    }
    
    //MARK: - EditorControls
    @ViewBuilder
    private func editorControls() -> some View {
        VStack {
            if selectedRatioIndex != 0 {
                HStack(spacing: 10) {
                    Button {
                        isPortrait = true
                        toggleOrientation()
                    } label: {
                        Image(systemName: isPortrait ? "checkmark.rectangle.portrait" : "rectangle.portrait")
                            .font(.title2)
                            .foregroundColor(isPortrait ? .yellow : .gray)
                    }
                    
                    Button {
                        isPortrait = false
                        toggleOrientation()
                    } label: {
                        Image(systemName: !isPortrait ? "checkmark.rectangle" : "rectangle")
                            .font(.title2)
                            .foregroundColor(!isPortrait ? .yellow : .gray)
                    }
                }
                .padding()
            }
            
            HStack {
                ForEach(0..<aspectRatios.count, id: \.self) { index in
                    Button {
                        selectedRatioIndex = index
                        setAspectRatio(aspectRatios[index].size)
                    } label: {
                        Text(aspectRatios[index].name)
                            .padding()
                            .font(.callout)
                            .foregroundColor(selectedRatioIndex == index ? .yellow : .secondary)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func toggleOrientation() {
        aspectRatio = CGSize(width: aspectRatio.height, height: aspectRatio.width)
        // 제스처 상태 시뮬레이션
        isInteracting = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isInteracting = false
        }
    }
    
    private func setAspectRatio(_ size: CGSize) {
        aspectRatio = isPortrait ? size : CGSize(width: size.height, height: size.width)
        // 제스처 상태 시뮬레이션
        isInteracting = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isInteracting = false
        }
    }
}

struct GridOverlay: View {
    var lineColor: Color = .white.opacity(0.5)
    var lineWidth: CGFloat = 1
    
    var body: some View {
        GeometryReader { geometry in
            let spacingX = geometry.size.width / 3
            let spacingY = geometry.size.height / 3
            
            ZStack {
                ForEach(1...2, id: \.self) { index in
                    Path { path in
                        let x = CGFloat(index) * spacingX
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: geometry.size.height))
                    }
                    .stroke(lineColor, lineWidth: lineWidth)
                }
                
                ForEach(1...2, id: \.self) { index in
                    Path { path in
                        let y = CGFloat(index) * spacingY
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                    }
                    .stroke(lineColor, lineWidth: lineWidth)
                }
            }
        }
    }
}
