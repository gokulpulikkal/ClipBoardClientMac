//
//  AlertMessage.swift
//  AlertMessage
//
//  Created by Daniel Marks on 31/03/2022.
//

#if os(iOS)
import SwiftUI
import Combine

public struct AlertMessage<AlertMessageContent: View>: ViewModifier {
    
    init(isPresented: Binding<Bool>,
         type: AlertMessageType,
         animation: Animation,
         autoHideIn: Double?,
         dragToDismiss: Bool,
         closeOnTap: Bool,
         backgroundColor: Color,
         dismissCallback: @escaping () -> (),
         view: @escaping () -> AlertMessageContent) {
        self._isPresented = isPresented
        self.type = type
        self.animation = animation
        self.autoHideIn = autoHideIn
        self.dragToDismiss = dragToDismiss
        self.closeOnTap = closeOnTap
        self.backgroundColor = backgroundColor
        self.dismissCallback = dismissCallback
        self.view = view
    }
    
    public enum AlertMessageType {
        case banner
        case centered
        case snackbar
    }

    private enum DragState {
        case inactive
        case dragging(translation: CGSize)

        var translation: CGSize {
            switch self {
            case .inactive:
                return .zero
            case .dragging(let translation):
                return translation
            }
        }

        var isDragging: Bool {
            switch self {
            case .inactive:
                return false
            case .dragging:
                return true
            }
        }
    }

    // MARK: - Public Properties

    /// Tells if the sheet should be presented or not
    @Binding var isPresented: Bool

    var type: AlertMessageType
    var animation: Animation
    var autoHideIn: Double? // If nil - never hides on its own
    var closeOnTap: Bool
    var dragToDismiss: Bool
    var backgroundColor: Color // Background color for outside area - default is `Color.clear`
    var dismissCallback: () -> ()
    var view: () -> AlertMessageContent

    // MARK: - Private Properties

    /// The rect and safe area of the hosting controller
    @State private var presenterContentRect: CGRect = .zero
    @State private var presenterSafeArea: EdgeInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

    /// The rect and safe area of AlertMessage content
    @State private var sheetContentRect: CGRect = .zero
    @State private var sheetSafeArea: EdgeInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

    /// Drag to dismiss gesture state
    @GestureState private var dragState = DragState.inactive

    /// Last position for drag gesture
    @State private var lastDragPosition: CGFloat = 0
    
    /// Show content for lazy loading
    @State private var showContent: Bool = false
    
    /// Should present the animated part of AlertMessage (sliding background)
    @State private var animatedContentIsPresented: Bool = false
    
    /// The offset when the AlertMessage is displayed
    private var displayedOffset: CGFloat {
        switch type {
        case .banner:
            return presenterContentRect.minY - presenterSafeArea.top - presenterContentRect.midY + sheetContentRect.height/2
        case .centered:
            return -presenterContentRect.midY + screenHeight/2
        case .snackbar:
            return presenterContentRect.minY + presenterSafeArea.bottom + presenterContentRect.height - presenterContentRect.midY - sheetContentRect.height/2
        }
    }

    /// The offset when the AlertMessage is hidden
    private var hiddenOffset: CGFloat {
        if type == .banner {
            if presenterContentRect.isEmpty {
                return -1000
            }
            return -presenterContentRect.midY - sheetContentRect.height/2 - 5
        } else {
            if presenterContentRect.isEmpty {
                return 1000
            }
            return screenHeight - presenterContentRect.midY + sheetContentRect.height/2 + 5
        }
    }

    /// The current offset, based on the **presented** property
    private var currentOffset: CGFloat {
        return animatedContentIsPresented ? displayedOffset : hiddenOffset
    }
    
    /// The current background opacity, based on the **presented** property
    private var currentBackgroundOpacity: Double {
        return animatedContentIsPresented ? 1.0 : 0.0
    }

    private var screenSize: CGSize {
        return UIScreen.main.bounds.size
    }

    private var screenHeight: CGFloat {
        screenSize.height
    }

    // MARK: - Content Builders

    public func body(content: Content) -> some View {
        main(content: content)
            .onAppear {
                appearAction(sheetPresented: isPresented)
            }
            .onChange(of: isPresented, perform: { newValue in
                appearAction(sheetPresented: newValue)
            })
    }

    private func main(content: Content) -> some View {
        ZStack {
            content
                .frameGetter($presenterContentRect, $presenterSafeArea)

            if showContent {
                alertMessageBackground()
            }
        }
        .overlay(
            Group {
                if showContent {
                    sheet()
                }
            }
        )
    }

    private func alertMessageBackground() -> some View {
        backgroundColor
            .edgesIgnoringSafeArea(.all)
            .opacity(currentBackgroundOpacity)
            .animation(animation, value: isPresented)
    }

    /// This is the builder for the sheet content
    func sheet() -> some View {
        if let autoHideIn = autoHideIn {
            DispatchQueue.main.asyncAfter(deadline: .now() + autoHideIn) {
                isPresented = false
            }
        }

        let sheet = ZStack {
            self.view()
                .applyIf(type != .centered, apply: { view in
                    view.padding(type == .banner ? .top : .bottom, 30)
                })
                .simultaneousGesture(
                    TapGesture().onEnded {
                        dismiss()
                    }
                )
                .frameGetter($sheetContentRect, $sheetSafeArea)
                .offset(x: 0, y: currentOffset)
                .animation(animation, value: currentOffset)
        }

        let drag = DragGesture()
            .updating($dragState) { drag, state, _ in
                state = .dragging(translation: drag.translation)
            }
            .onEnded(onDragEnded)

        return sheet
            .applyIf(dragToDismiss) {
                $0.offset(y: dragOffset())
                    .simultaneousGesture(drag)
            }
    }

    func dragOffset() -> CGFloat {
        if (type == .snackbar && dragState.translation.height > 0) ||
            (type == .banner && dragState.translation.height < 0) {
            return dragState.translation.height
        }
        return lastDragPosition
    }

    private func onDragEnded(drag: DragGesture.Value) {
        let reference = sheetContentRect.height / 3
        if (type == .snackbar && drag.translation.height > reference) ||
            (type == .banner && drag.translation.height < -reference) {
            lastDragPosition = drag.translation.height
            withAnimation {
                lastDragPosition = 0
            }
            dismiss()
        }
    }
    
    private func appearAction(sheetPresented: Bool) {
        if sheetPresented {
            showContent = true
            DispatchQueue.main.async {
                animatedContentIsPresented = true
            }
        } else {
            animatedContentIsPresented = false
        }
    }
    
    private func dismiss() {
        isPresented = false
        dismissCallback()
    }
}

struct FrameGetter: ViewModifier {

    @Binding var frame: CGRect
    @Binding var safeArea: EdgeInsets

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy -> AnyView in
                    let rect = proxy.frame(in: .global)
                    // This avoids an infinite layout loop
                    if rect.integral != self.frame.integral {
                        DispatchQueue.main.async {
                            self.safeArea = proxy.safeAreaInsets
                            self.frame = rect
                        }
                    }
                    return AnyView(EmptyView())
                }
            )
    }
}

extension View {

    public func alertMessage<AlertMessageContent: View>(
        isPresented: Binding<Bool>,
        type: AlertMessage<AlertMessageContent>.AlertMessageType = .centered,
        animation: Animation = Animation.easeOut(duration: 0.3),
        autoHideIn: Double? = nil,
        dragToDismiss: Bool = true,
        closeOnTap: Bool = true,
        backgroundColor: Color = Color.clear,
        dismissCallback: @escaping () -> () = {},
        @ViewBuilder view: @escaping () -> AlertMessageContent) -> some View {
        self.modifier(
            AlertMessage<AlertMessageContent>(
                isPresented: isPresented,
                type: type,
                animation: animation,
                autoHideIn: autoHideIn,
                dragToDismiss: dragToDismiss,
                closeOnTap: closeOnTap,
                backgroundColor: backgroundColor,
                dismissCallback: dismissCallback,
                view: view)
        )
    }

    @ViewBuilder
    func applyIf<T: View>(_ condition: Bool, apply: (Self) -> T) -> some View {
        if condition {
            apply(self)
        } else {
            self
        }
    }
    
    public func frameGetter(_ frame: Binding<CGRect>, _ safeArea: Binding<EdgeInsets>) -> some View {
        modifier(FrameGetter(frame: frame, safeArea: safeArea))
    }
}
#endif
