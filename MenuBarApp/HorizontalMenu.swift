//
//  HorizontalMenu.swift
//  MenuBarApp
//
//  Created by Evert De Spiegeleer on 10/11/2023.
//

import SwiftUI

struct HorizontalMenu: View {
    var currentMenuItem: Binding<MenuItems>
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(MenuItems.allCases, id: \.self) { item in
                if (MenuItems.allCases.first != item) {
                    Spacer()
                }
                Button(action: {
                    currentMenuItem.wrappedValue = item
                }, label: {
                    Image(systemName: item.getItemDetails().systemImage)
                })
                .buttonStyle(.link)
                .foregroundStyle((currentMenuItem.wrappedValue == item) ? Color.accentColor : Color.secondary)
            }
        }
    }
}

#if DEBUG
struct HorizontalMenuPreviewContainer_1 : View {
    @State var currentMenuItem: MenuItems = .preview
     var body: some View {
         HorizontalMenu(currentMenuItem: $currentMenuItem)
     }
}

struct HorizontalMenuPreview : PreviewProvider {
    static var previews: some View {
        HorizontalMenuPreviewContainer_1()
    }
}
#endif
