//
//  ContentView.swift
//  EduHelper
//
//  Created by vladukha on 08.01.2021.
//

import SwiftUI

struct ContentView: View {
	@State private var selectedDay = 0
	var body: some View {
		
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
	}
}
