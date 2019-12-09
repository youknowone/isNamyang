//
//  ContentView.swift
//  isNamyang
//
//  Created by Jeong YunWon on 2019/12/09.
//  Copyright © 2019 NullFull. All rights reserved.
//

import AVFoundation
import SwiftUI

struct LogoImage: View {
    var body: some View {
        Image(uiImage: Service.logoImage!)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding()
            .background(Color.white)
    }
}

struct ContentView: View {
    var body: some View {
        //                .onRead
        //                .overlay(
        //                    Text("여기에 바코드")
        //                )

        return
            NavigationView {
                MainView()
            }
    }
}

struct FrameView<Content: View>: View {
    let viewBuilder: () -> Content

    var body: some View {
        GeometryReader {
            geometry in
            ZStack {
                Rectangle().fill(Color(UIColor.systemBackground))
                    .shadow(radius: 20)
                    .frame(minHeight: geometry.size.width * 0.5, maxHeight: geometry.size.width)

                self.viewBuilder()
            }.frame(minHeight: geometry.size.width * 0.5, maxHeight: geometry.size.width)
                .padding()
        }
    }
}

struct MainView: View {
    @State var captureEnabled: Bool = false
    @State var capturing: Bool = false
    @State var keyword: String = ""
    @State var productName: String = ""
    @State var showsResult: Bool = false

    @State var searchedItem: Item?

    var body: some View {
        let captureView = CaptureView(capturing: $capturing)
            .metadata(objectTypes: [.ean13, .ean8])
            .onRead { AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                self.capturing = false
                self.keyword = $0
                self.checkKeyword()
            }
        captureEnabled = captureView.error == nil

        return VStack {
            FrameView {
                VStack {
                    Text("남양 제품인지 확인해보세요")
                        .font(.system(.title))
                        .padding(.vertical)
                    Spacer()
                    ZStack {
                        VStack {
                            if !self.captureEnabled {
                                Text("카메라 권한에 동의하여야 바코드 스캔 기능을 이용할 수 있습니다. 카메라를 이용하지 않으려면 아래에서 수동으로 입력해 주세요.")
                            }
                            TextField("제품 이름이나 바코드 입력", text: self.$keyword, onCommit: self.checkKeyword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()
                        }
                        if self.capturing {
                            GeometryReader {
                                geometry in
                                captureView
                                    .frame(width: geometry.size.width - 30, height: (geometry.size.width - 30) * 0.5)
                                    .overlay(
                                        VStack {
                                            Text("가운데에 바코드를 비추어 주세요")
                                                .foregroundColor(Color(UIColor.systemBackground))
                                                .font(.system(.footnote))
                                            Rectangle()
                                                .fill(Color.black)
                                                .frame(width: geometry.size.width - 30, height: 1)
                                            Spacer()
                                            Rectangle()
                                                .fill(Color.black)
                                                .frame(width: geometry.size.width - 30, height: 1)

                                            Text("가운데에 바코드를 비추어 주세요")

                                                .font(.system(.footnote))
                                        }
                                    )
                            }
                        }
                    }
                    Spacer()
                    if self.capturing {
                        Button(action: {
                            self.capturing = false
                        }) {
                            Text("제품 이름으로 찾으시겠어요?")
                        }.padding(.vertical)
                    } else if self.captureEnabled {
                        Button(action: {
                            self.capturing = true
                        }) {
                            Text("바코드로 찾으시겠어요?")
                        }.padding(.vertical)
                    }
                }.padding()
            }
            Spacer()
            if Service.logoImage != nil {
                LogoImage()
            } else {
                Text("남 양 유 없").font(.system(size: 80))
                    .fontWeight(.bold).padding()
            }
        }
        .background(Color.white)
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .onAppear {
            self.capturing = self.captureEnabled
        }
        .sheet(isPresented: $showsResult) {
            ResultView(item: self.$searchedItem, keyword: self.$keyword)
        }
    }

    func checkKeyword() {
        if let item = service.database.search(barcode: self.keyword) {
            searchedItem = item
            showsResult = true
        } else {
            showsResult = true
        }
        capturing = captureEnabled
    }
}

struct ResultView: View {
    @Binding var item: Item?
    @Binding var keyword: String

    @State var tada: Bool = false

    var body: some View {
        ZStack {
            VStack {
                FrameView {
                    VStack {
                        Group {
                            Text("남양제품이")
                            if self.item == nil {
                                Text("아닙니다!").fontWeight(.bold)
                            } else {
                                Text("맞습니다!").fontWeight(.bold)
                            }
                        }
                        .font(.system(.largeTitle))
                        Rectangle().fill(Color.gray).frame(width: 300, height: 1)
                            .padding()
                        if self.item != nil {
                            Text("제품명: \(self.item!.name)")
                        }
                        Text("검색어: \(self.keyword)")
                    }
                }
                Group {
                    Text("잠깐! 남양\(self.item == nil ? "인데" : "이 아닌데") 잘못 나왔나요?")
                    Button(action: {
                        let url: URL
                        if let item = self.item {
                            url = URL(string: "https://docs.google.com/forms/d/e/1FAIpQLSebCozKAt9f0hNqOaQ1BsieW39BdVfuOuz-9Tcpi-nXFzyNIQ/viewform?usp=pp_url&entry.651419076=%EB%82%A8%EC%96%91%EC%9D%B4+%EC%95%84%EB%8B%8C%EB%8D%B0+%EB%82%A8%EC%96%91%EC%9D%B4%EB%9D%BC%EA%B3%A0+%EB%96%A0%EC%9A%94&entry.877829228=\(item.barcode)")!
                        } else {
                            url = URL(string: "https://docs.google.com/forms/d/e/1FAIpQLSebCozKAt9f0hNqOaQ1BsieW39BdVfuOuz-9Tcpi-nXFzyNIQ/viewform?usp=pp_url&entry.651419076=%EB%82%A8%EC%96%91%EC%9D%B8%EB%8D%B0+%EB%82%A8%EC%96%91%EC%9D%B4+%EC%95%84%EB%8B%88%EB%9D%BC%EA%B3%A0+%EB%96%A0%EC%9A%94&entry.877829228=\(self.keyword)")!
                        }
                        UIApplication.shared.open(url)
                    }) {
                        Text("데이터베이스 오류 신고")
                    }
                }.padding(.vertical)
            }
            VStack {
                TadaView(isShowing: self.$tada)
                Spacer()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.36) {
                self.tada = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.tada = false
                }
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

struct ResultView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ResultView(item: .constant(nil), keyword: .constant("880004keyword"))
            ResultView(item: .constant(Item(data: ["바코드": "880800000", "제품명": "테스트제품"])), keyword: .constant("880004keyword"))
        }
    }
}
