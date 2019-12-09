//
//  LoadingView.swift
//  isNamyang
//
//  Created by Jeong YunWon on 2019/12/10.
//  Copyright © 2019 NullFull. All rights reserved.
//

import SwiftUI

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

struct LoadingView: View {
    @State var loaded: Bool = false
    @State var loading: Bool = true
    @State var logoLoaded: Bool = false
    var body: some View {
        VStack {
            Spacer()
            VStack {
                if loading {
                    Text("제품 목록 받아오는 중...")
                } else {
                    if loaded {
                        Text("\(service.database.items.count)개의 제품 목록을 받아왔습니다.")
                    } else {
                        Button(action: {
                            self.tryLoading()
                        }) {
                            Text("새로 불러오기")
                        }
                        Spacer()
                        Text("네트워크 연결 중에도 문제가 지속되면\n버그일 수 있습니다.")
                        Button(action: {
                            UIApplication.shared.open(URL(string: "https://github.com/youknowone/isNamyang/issues")!)
                        }) {
                            Text("앱 버그 제보")
                        }
                    }
                }
                ActivityIndicator(isAnimating: self.$loading, style: .large)
            }
            .padding()
            Spacer()
            if self.logoLoaded {
                LogoImage()
            } else {
                Text("남 양 유 없").font(.system(size: 80))
                    .fontWeight(.bold).padding()
            }
        }
        .onAppear {
            self.tryLoading()
        }
    }

    func tryLoading() {
        loading = true
        DispatchQueue.global(qos: .userInitiated).async {
            let newService = service ?? Service()
            DispatchQueue.main.sync {
                service = newService
                self.loaded = newService != nil
                if !self.loaded {
                    sleep(1)
                }
                self.logoLoaded = Service.logoImage != nil
                self.loading = false

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    let keyWindow = UIApplication.shared.windows.filter { $0.isKeyWindow }.first!
                    keyWindow.rootViewController = UIHostingController(rootView: ContentView())
                }
            }
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView(logoLoaded: true)
    }
}
