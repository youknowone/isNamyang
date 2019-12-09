//
//  EffectView.swift
//  isNamyang
//
//  Created by Jeong YunWon on 2019/12/10.
//  Copyright © 2019 NullFull. All rights reserved.
//

import SwiftUI

struct PartyPopperView: View {
    @State var size: CGFloat = 110

    var body: some View {
        Text("🎉")
            .font(.system(size: self.size))
            .animation(.spring())
    }
}

struct TadaView: View {
    @Binding var isShowing: Bool
    var body: some View {
        HStack {
            PartyPopperView().offset(x: self.isShowing ? 0 : -220, y: 20)
            PartyPopperView().offset(x: self.isShowing ? 0 : -40, y: self.isShowing ? -20 : -150)
            PartyPopperView().offset(x: self.isShowing ? 0 : 40, y: self.isShowing ? -20 : -150)
            PartyPopperView().offset(x: self.isShowing ? 0 : 220, y: 20)
        }
    }
}

struct TadaView_Previews: PreviewProvider {
    static var previews: some View {
        return TadaView(isShowing: .constant(false))
    }
}

struct PartyPopperView_Previews: PreviewProvider {
    static var previews: some View {
        PartyPopperView()
    }
}
