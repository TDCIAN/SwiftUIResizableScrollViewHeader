//
//  ResizableHeaderScrollView.swift
//  SwiftUIResizableScrollViewHeader
//
//  Created by 김정민 on 7/7/25.
//

import SwiftUI

struct ResizableHeaderScrollView<Header: View, StickyHeader: View, Background: View, Content: View>: View {
    
    var spacing: CGFloat = 10
    
    @ViewBuilder var header: Header
    @ViewBuilder var stickyHeader: StickyHeader
    
    // Only for header background, not for the entire view
    @ViewBuilder var background: Background
    @ViewBuilder var content: Content
    
    // View Properties
    @State private var currentDragOffset: CGFloat = 0
    @State private var previousDragOffset: CGFloat = 0
    @State private var headerOffset: CGFloat = 0
    @State private var headerSize: CGFloat = 0
    @State private var scrollOffset: CGFloat = 0
    
    var body: some View {
        ScrollView(.vertical) {
            content
        }
        .frame(maxWidth: .infinity)
        .onScrollGeometryChange(for: CGFloat.self, of: { geometry in
            geometry.contentOffset.y + geometry.contentInsets.top
        }, action: { oldValue, newValue in
            scrollOffset = newValue
        })
        .simultaneousGesture(
            DragGesture(minimumDistance: 10)
                .onChanged({ value in
                    /*
                     Adjusting the minimum distance value,
                     Thus it starts from 0
                     */
                    let dragOffset = -max(
                        0,
                        abs(value.translation.height) - 50
                    ) * (value.translation.height < 0 ? -1 : 1)
                    
                    previousDragOffset = currentDragOffset
                    currentDragOffset = dragOffset
                    
                    let deltaOffset = (currentDragOffset - previousDragOffset).rounded()
                    
                    headerOffset = max(
                        min(
                            headerOffset + deltaOffset,
                            headerSize
                        ),
                        0
                    )
                    
                }).onEnded({ value in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        if headerOffset > (headerSize * 0.5) && scrollOffset > headerSize {
                            headerOffset = headerSize
                        } else {
                            headerOffset = 0
                        }
                    }
                    // Resetting offset data
                    currentDragOffset = 0
                    previousDragOffset = 0
                })
        )
        .safeAreaInset(edge: .top, spacing: spacing) {
            CombinedHeaderView()
        }
    }
    
    @ViewBuilder
    private func CombinedHeaderView() -> some View {
        VStack(spacing: spacing) {
            header
                .onGeometryChange(for: CGFloat.self) { proxy in
                    proxy.size.height
                } action: { newValue in
                    /// Optional (Spacing)
                    headerSize = newValue + spacing
                }

            stickyHeader
        }
        .offset(y: -headerOffset)
        .clipped()
        .background {
            background
                .ignoresSafeArea()
                .offset(y: -headerOffset)
        }
    }
}

#Preview {
    ContentView()
}
