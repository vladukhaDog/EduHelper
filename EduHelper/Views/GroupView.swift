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
			UpdateOnlineStatus()
			if (Parser.CheckConnection())
			{
				Parser.parse()
				self.groups = Storage.retrieve("Groups.json", from: .caches, as: Groups.self)
				self.ShouldUpdateBell = true
			}
			self.isLoading = false
		}
	}
	
	func UpdateOnlineStatus()
	{
		let dispatchQueue = DispatchQueue(label: "QueueIdentification", qos: .background)
		dispatchQueue.async{
			self.checkUpdateLocked = true
			let Parser = parser()
			if (Parser.CheckConnection())
			{
				withAnimation {
					self.online = true
				}
			}else
			{
				withAnimation {
					self.online = false
				}
			}
			self.checkUpdateLocked = false
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
	@State private var online = true
	@State private var selectedGroup = 0
	@State private var isLoading = false
	@State var ShouldUpdateBell = Storage.fileExists("Rings.json", in: .caches)
	@Environment(\.colorScheme) var colorScheme
	
	let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
	@State var checkUpdateLocked = false
	
	
	init() {
	}
	
	
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
			
			VStack
			{
				if !online
				{
					offlineMessage()
					Spacer()
				}
			}
		}
		.onReceive(timer) { time in
			if (!checkUpdateLocked)
			{
			UpdateOnlineStatus()
			}
				}
	}
}

struct offlineMessage: View {
	var body: some View {
		Text("Нет подключения к сайту расписания, проверьте подключение к интернету")
			.padding(.top, 14)
			.frame(maxWidth: .infinity)
			.foregroundColor(.black)
			.background(Color.orange)
			.opacity(0.9)
			.ignoresSafeArea()
			.transition(.move(edge: .top))
	}
}

struct bells: View {
	@State var SubOrPT = true // отобрать субботу или пятницу(true)
	@Binding var update: Bool
	var body: some View {
		VStack
		{
			HStack{
				Button(action: {
					withAnimation{
					SubOrPT = true
					}
				}) {
					if (SubOrPT)
					{
					Text("ПН-ПТ")
						.padding()
						.overlay(
								RoundedRectangle(cornerRadius: 16)
									.stroke(Color.pink, lineWidth: 1)
							)
						.transition(.opacity)
					}
					else
					{
						Text("ПН-ПТ")
							.padding()
					}
				}
				.buttonStyle(PlainButtonStyle())
				Button(action: {
					withAnimation{
					SubOrPT = false
					}
				}) {
					if (!SubOrPT)
					{
					Text("СБ")
						.padding()
						.overlay(
								RoundedRectangle(cornerRadius: 16)
									.stroke(Color.pink, lineWidth: 1)
							)
						.transition(.opacity)
					}
					else
					{
						Text("СБ")
							.padding()
					}
				}
				.buttonStyle(PlainButtonStyle())
			}
			if (update) {
				let rings = Storage.retrieve("Rings.json", from: .caches, as: RingTimes.self)
				ForEach(rings.ring!, id: \.self) { ring in
					HStack
					{
						if (SubOrPT)
						{
							Text(String(ring.id ?? 1))
								.fontWeight(.heavy)
								Divider()
							Text(ring.StartTime ?? "")
								.transition(.opacity)
							Text(" -- ")
							Text(ring.EndTime ?? "")
								.transition(.opacity)
						}else
						{
							Text(String(ring.id ?? 1))
								.fontWeight(.heavy)
								Divider()
							Text(ring.WEStartTime ?? "")
								.transition(.opacity)
							Text(" -- ")
							Text(ring.WEEndTime ?? "")
								.transition(.opacity)
						}
					
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


struct CheckboxStyle: ToggleStyle {
 
	func makeBody(configuration: Self.Configuration) -> some View {
 
		return HStack {
			Image(systemName: configuration.isOn ? "eye" : "eye.slash")
				.resizable()
				.frame(width: 38, height: 24)
				.foregroundColor(configuration.isOn ? .purple : .gray)
				.font(.system(size: 20, weight: .bold, design: .default))
				.onTapGesture {
					configuration.isOn.toggle()
				}
		}
 
	}
}
