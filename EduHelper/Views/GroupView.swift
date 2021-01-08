//
//  GroupView.swift
//  EduHelper
//
//  Created by vladukha on 08.01.2021.
//

import SwiftUI
import SwiftSoup

struct GroupView: View {
	
	func GettingSchedule()
	{
		self.isLoading = true
		let dispatchQueue = DispatchQueue(label: "QueueIdentification", qos: .background)
		dispatchQueue.async{
			let Parser = parser()
			Parser.parse()
			self.isLoading = false
			self.groups = Storage.retrieve("Groups.json", from: .caches, as: Groups.self)
			self.ShouldUpdateBell = true
		}
	}
	
	func ShouldUpdate() -> Bool
	{//stupid
		return !Storage.fileExists("Groups.json", in: .caches)
	}
	
	func PickerChanged(){
		UserDefaults.standard.set(groups?.name?[selectedGroup], forKey: "SelectedGroup")
	}
	
	@State private var groups = (Storage.fileExists("Groups.json", in: .caches)) ? Storage.retrieve("Groups.json", from: .caches, as: Groups.self) : nil
	
	@State private var selectedGroup = 0
	@State private var isLoading = false
	@State var ShouldUpdateBell = Storage.fileExists("Rings.json", in: .caches)
	@Environment(\.colorScheme) var colorScheme
	var body: some View {
		ZStack
		{
			if(colorScheme == .dark)
			{BackgroundView(Schemes: .dark)}
			else
			{BackgroundView(Schemes: .light)}
			
		VStack {
			Text("Выберите группу")
				.font(.system(size: 30, weight: .medium, design: .default))
				.padding(.top)
				.onAppear {
			
				}
			
				 Picker(selection: $selectedGroup, label: Text("Choose your Group")) {
					let groupCount = groups?.name!.count ?? 0
					if (groupCount > 0)
					{
						ForEach(0 ..< (groupCount)) {
							Text(self.groups?.name?[$0] ?? "no Group")
						}
					}
				 }
				.onAppear(perform: {
					if(ShouldUpdate())
					{
						GettingSchedule()
					}
					if let x = UserDefaults.standard.object(forKey: "SelectedGroup") {
						selectedGroup = groups?.name?.firstIndex(of: x as! String) ?? 0
					}
					PickerChanged()
				})
				.onChange(of: selectedGroup, perform: { value in
					PickerChanged()
				})
				.padding(-25)
			ZStack
			{
				if (isLoading)
				{
					ProgressView()
						.progressViewStyle(CircularProgressViewStyle())
				}
				Button(action: {
					GettingSchedule()
				}) {
					Text("Обновить расписание")
				} .disabled(isLoading)
				
			}
			HStack
			{
				bells(update: $ShouldUpdateBell)
					.padding(4)
			}
			}
	}
		
	}
}

struct bells: View {
	@Binding var update: Bool
	var body: some View {
		VStack
		{
			Text("ПН-ПТ")
				.fontWeight(.heavy)
			if (update) {
				let rings = Storage.retrieve("Rings.json", from: .caches, as: RingTimes.self)
				ForEach(rings.ring!, id: \.self) { ring in
					HStack
					{
					Text(String(ring.id ?? 1))
						.fontWeight(.heavy)
						Divider()
					Text(ring.StartTime ?? "")
						Text(" -- ")
					Text(ring.EndTime ?? "")
					}
					
				}
				}else
				{
					Text("")
				}
		}
		.padding()
		.overlay(
				RoundedRectangle(cornerRadius: 17)
					.stroke(Color.blue, lineWidth: 1)
			)
	}
}
