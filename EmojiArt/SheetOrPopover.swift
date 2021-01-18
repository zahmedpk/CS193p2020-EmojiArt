//
//  SheetOrPopover.swift
//  EmojiArt
//
//  Created by Zubair Ahmed on 18/01/2021.
//  Show content using popover on iPad and
//  sheet otherwise.

import SwiftUI

extension View {
    @ViewBuilder func sheetOrPopover<Content>(isPresented: Binding<Bool>, onDismiss:(() -> Void)? = nil, content: @escaping () -> Content) -> some View where Content: View {
        if onIpad {
            self.popover(isPresented: isPresented, content: content)
        } else {
            self.sheet(isPresented: isPresented, content: content)
        }
    }
    var onIpad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
}
