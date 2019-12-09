//
//  NetworkErrorView.swift
//  isNamyang
//
//  Created by Jeong YunWon on 2019/11/23.
//  Copyright © 2019 Jeong YunWon. All rights reserved.
//

import SwiftUI

struct ApplicationView: View {
    @State var loaded = service != nil

    var body: some View {
        Group {
            if self.loaded {
                ContentView()
            } else {
                NetworkErrorView(loaded: self.$loaded)
            }
        }
    }
}

struct ActivityIndicator: UIViewRepresentable {
    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context _: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context _: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

struct NetworkErrorView: View {
    @Binding var loaded: Bool
    @State var connecting: Bool = false

    var body: some View {
        VStack {
            Spacer()
            Text("제품 목록을 받아오는 데 실패했습니다.")
            Button(action: reconnect) {
                Text("새로 불러오기")
                    .font(.system(size: 40))
            }
            .padding()
            .overlay(ActivityIndicator(isAnimating: $connecting, style: .large))
            .disabled(self.connecting)
            Text("네트워크 연결에 이상이 없는데도 문제가 지속된다면")
                .multilineTextAlignment(.center)
            Button(action: {
                UIApplication.shared.open(URL(string: "https://github.com/youknowone/isNamyang/issues")!)
            }) {
                Text("앱 버그 제보")
            }
            Spacer()
            if Service.logoImage != nil {
                LogoImage()
            } else {
                Text("남 양 유 없").font(.system(size: 80))
                    .fontWeight(.bold).padding()
            }
        }
        .padding()
        .edgesIgnoringSafeArea(.all)
    }

    func reconnect() {
        connecting = true
        DispatchQueue.global(qos: .userInitiated).async {
            if let newService = Service() {
                DispatchQueue.main.sync {
                    service = newService
                    self.loaded = true
                }
            } else {
                sleep(1)
                DispatchQueue.main.sync {
                    self.connecting = false
                }
            }
        }
    }
}

struct NetworkErrorView_Previews: PreviewProvider {
    static var previews: some View {
        NetworkErrorView(loaded: .constant(false), connecting: true)
    }
}
