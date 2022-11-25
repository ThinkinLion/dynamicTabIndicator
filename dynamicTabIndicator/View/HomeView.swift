//
//  HomeView.swift
//  dynamicTabIndicator
//
//  Created by 1100690 on 2022/11/24.
//

import SwiftUI

struct HomeView: View {
    @State var offset: CGFloat = 0
    @State var currentTab: TabModel = tabs.first ?? TabModel(name: "Iceland", image: "image1")
    @State var isTapped: Bool = false
    
    //gesture manager
    @StateObject var gestureManager: InteractionManager = .init()
    
    var body: some View {
        GeometryReader { proxy in
            let screenSize = proxy.size
            
            ZStack(alignment: .top) {
                //MARK: Tab View
                TabView(selection: $currentTab) {
                    ForEach(tabs) { tab in
                        GeometryReader { proxy in
                            let size = proxy.size
                            
                            Image(tab.image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: size.width, height: size.height)
                                .clipped()
                        }
                        .ignoresSafeArea()
                        .offsetX { value in
                            //calulating  offset with the help of currently active tab
                            if currentTab == tab && !isTapped {
                                //to keep track of  total offset
                                //here is a trick, simply multiply offset with (width of the tab view * current index)
                                print(value)
                                offset = value - (screenSize.width * CGFloat(indexOf(tab: tab)))
                            }
                            
                            if value == 0 && isTapped {
                                isTapped = false
                            }
                            
                            if isTapped && gestureManager.isInteracting {
                                isTapped = false
                            }
                        }
                        .tag(tab)
                    }
                }
                .ignoresSafeArea()
                .tabViewStyle(.page(indexDisplayMode: .never))
                .onAppear(perform: gestureManager.addGesture)
                .onDisappear(perform: gestureManager.removeGesture)
                
                //test
                Text("\(offset)")
                    .offset(y: 100)
                
                //MARK: Custom Header View
                dynamicTabHeaderView(size: screenSize)
            }
            .frame(width: screenSize.width, height: screenSize.height)
        }
        .onChange(of: gestureManager.isInteracting) { newValue in
            print(newValue ? "Interacting" : "stopped")
        }
    }
    
    @ViewBuilder
    func dynamicTabHeaderView(size: CGSize) -> some View {
        VStack(alignment: .leading, spacing: 22) {
            Text("Dynamic Tabs")
                .font(.title.bold())
                .foregroundColor(.white)
            
            HStack(spacing: 0) {
                ForEach(tabs) { tab in
                    Text(tab.name)
                        .fontWeight(.semibold)
                        .padding(.vertical, 6)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                }
            }
            .overlay(alignment: .leading) {
                Capsule()
                    .fill(.white)
                    .overlay(alignment: .leading, content: {
                        GeometryReader { _ in
                            HStack(spacing: 0) {
                                ForEach(tabs) { tab in
                                    Text(tab.name)
                                        .fontWeight(.semibold)
                                        .padding(.vertical, 6)
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity)
                                        .contentShape(Capsule())
                                        .onTapGesture {
                                            //disabling the tabscrollOffset detection
                                            isTapped = true
                                            withAnimation(.easeOut) {
                                                currentTab = tab
                                                offset = -(size.width) * CGFloat(indexOf(tab: tab))
                                            }
                                        }
                                }
                            }
                            //MARK: simply reverse the offset
                            .offset(x: -tabOffset(size: size, padding: 30))
                            
                        }
                        .frame(width: size.width - 30)
                    })
                    .frame(width: (size.width - 30) / CGFloat(tabs.count))
                    .mask({
                        Capsule()
                    })
                    .offset(x: tabOffset(size: size, padding: 30))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(15)
        .background {
            Rectangle()
                .fill(.ultraThinMaterial)
                //dark mode only
                .environment(\.colorScheme, .dark)
                .ignoresSafeArea()
        }
    }
    
    //MARK: tab offset
    func tabOffset(size: CGSize, padding: CGFloat) -> CGFloat {
        return (-offset / size.width) * ((size.width - padding) / CGFloat(tabs.count))
    }
    
    //MARK: tab index
    func indexOf(tab: TabModel) -> Int {
        let index = tabs.firstIndex { model in
            tab == model
        } ?? 0
        
        return index
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//MARK: universal interaction manager
class InteractionManager: NSObject, ObservableObject, UIGestureRecognizerDelegate {
    @Published var isInteracting: Bool = false
    @Published var isGestureAdded: Bool = false
    
    func addGesture() {
        if !isGestureAdded {
            let gesture = UIPanGestureRecognizer(target: self, action: #selector(onChange(gesture: )))
            gesture.name = "UNIVERSAL"
            gesture.delegate = self
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            guard let window = windowScene.windows.last?.rootViewController else { return }
            window.view.addGestureRecognizer(gesture)
            
            isGestureAdded = true
        }
    }
    
    func removeGesture() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        guard let window = windowScene.windows.last?.rootViewController else { return }
        
        window.view.gestureRecognizers?.removeAll(where: { gesture in
            return gesture.name == "UNIVERSAL"
        })
        
        isGestureAdded = false
    }
    
    @objc
    func onChange(gesture: UIPanGestureRecognizer) {
        isInteracting = (gesture.state == .changed)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

//type 1
//HStack(spacing: 0) {
//    ForEach(tabs) { tab in
//        Text(tab.name)
//            .fontWeight(.semibold)
//            .foregroundColor(.white)
//            .frame(maxWidth: .infinity)
//    }
//}
//.background(alignment: .bottomLeading) {
//    Capsule()
//        .fill(.white)
//    //dont forgot to remove padding in screen width
//        .frame(width: (size.width - 30) / CGFloat(tabs.count), height: 4)
//        .offset(y: 12)
//    //we need to eliminate the padding
////                    .offset(x: -offset / CGFloat(tabs.count))
//        .offset(x: tabOffset(size: size, padding: 30))
//}
