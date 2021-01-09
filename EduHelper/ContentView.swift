//
//  ContentView.swift
//  EduHelper
//
//  Created by vladukha on 08.01.2021.
//

import SwiftUI

struct ContentView: View {
	@State var duck = false
	var body: some View {
		ZStack{
			TabView {
				GroupView()
					.tabItem {
						Image(systemName: "person.fill")
						Text("Group")
					}
				ScheduleView()
					.tabItem {
						Image(systemName: "book.fill")
						Text("Schedule")
					}
				ChangesView()
					.tabItem {
						Image(systemName: "exclamationmark.bubble.fill")
						Text("Changes")
					}
				#if DEBUG
				Settings()
					.tabItem {
						Text("DebugSettings")
					}
				#endif
				
			}
			.onReceive(NotificationCenter.default.publisher(for: .deviceDidShakeNotification)) { _ in
					  withAnimation{
							duck = true
					}
			   }
			VStack{
				if duck{
				Text("Не тряси, утке плохо!")
					.font(.title)
					.fontWeight(.heavy)
					.transition(.slide)
					.background(Color.black)
					.cornerRadius(14)
					.shadow(radius: 20)
				}
				if duck{
					Image("duck")
						.resizable()
						.cornerRadius(10)
						.shadow(radius: 10)
						.scaledToFit()
						.transition(.scale)
					Button(action: {
						withAnimation{
							duck = false
						}
					}) {
						Text("Простите!")
							.fontWeight(.heavy)
							.frame(width: 120, height: 40, alignment: .center)
							.background(Color.black)
							.cornerRadius(14)
							.shadow(radius: 20)
							
						
					}.transition(.scale)
				
				}
			}
			
		}
	}
}

extension NSNotification.Name {
	public static let deviceDidShakeNotification = NSNotification.Name("MyDeviceDidShakeNotification")
}

extension UIWindow {
	open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
		super.motionEnded(motion, with: event)
		NotificationCenter.default.post(name: .deviceDidShakeNotification, object: event)
	}
}
