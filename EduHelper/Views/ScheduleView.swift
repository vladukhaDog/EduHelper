//
//  ScheduleView.swift
//  EduHelper
//
//  Created by vladukha on 08.01.2021.
//

import SwiftUI

func ifTherePairs(selectedDay: Int) -> Bool
{
	if (Storage.fileExists("Schedule.json", in: .caches)) {
		let schedules = Storage.retrieve("Schedule.json", from: .caches, as: Schedules.self)
		for schedule in schedules.schedule! {
			if (schedule.Group == UserDefaults.standard.string(forKey:"SelectedGroup") ?? "No Group Selected")
			{
				if (schedule.day?[selectedDay].pair?.count ?? 0 > 4)
				{
					return true
				}
			}
		}
		}
		return false
}

struct ScheduleView: View {
	let par = parser()
	@State private var selectedDay = 0
	let days = ["Mon", "Tu", "Wed","Thu","Fri","Sat"]
	@State var selectedGroup: String = UserDefaults.standard.string(forKey:"SelectedGroup") ?? "Группа не выбрана"
	@Environment(\.colorScheme) var colorScheme
	@State var thereIsMore = true
	var body: some View {
			ZStack
			{
				if(colorScheme == .dark)
				{BackgroundView(Schemes: .dark)}
				else
				{BackgroundView(Schemes: .light)}
				
		VStack {
			Text(selectedGroup)
				.fontWeight(.heavy)
				.font(.title)
			
			Picker(selection: $selectedDay, label: Text("Day of the week")) {
				ForEach(0..<days.count) { index in
					Text(self.days[index]).tag(index)
						}
				}.pickerStyle(SegmentedPickerStyle())
			ZStack
			{
				VStack{
					Spacer()
				HStack
				{
					if (ifTherePairs(selectedDay: selectedDay))
					{
						Spacer()
						Image(systemName: "arrow.down")
							.foregroundColor(.green)
							.shadow(color: .gray, radius: 2)
					}
				}}
				
			ScrollView(.vertical, showsIndicators: true) {
				Pairs(selectedDay: $selectedDay)
			}
			}

					
		}.onAppear(perform: {
			selectedGroup = UserDefaults.standard.string(forKey:"SelectedGroup") ?? "Группа не выбрана"
			selectedDay = par.getDay()
		})
		.gesture(DragGesture(minimumDistance: 20, coordinateSpace: .global)
					.onEnded { value in
						let horizontalAmount = value.translation.width as CGFloat
						let verticalAmount = value.translation.height as CGFloat
						if abs(horizontalAmount) > abs(verticalAmount) {
							if ((horizontalAmount < 0) && (selectedDay < 5))
							{
								selectedDay += 1
							}else if ((horizontalAmount > 0) && (selectedDay > 0))
							{
								selectedDay -= 1
							}
						}
					})
	}
	}
}

struct Pairs: View
{
	@Binding var selectedDay: Int
	var body: some View
	{
		VStack(spacing: 20) {
			if (Storage.fileExists("Schedule.json", in: .caches)) {
				let schedules = Storage.retrieve("Schedule.json", from: .caches, as: Schedules.self)
				let gay = schedules.schedule?.firstIndex(where: {$0.Group == UserDefaults.standard.string(forKey:"SelectedGroup") ?? "No Group Selected" } )
				let schedulele = schedules.schedule?[gay ?? 0].Group
				ForEach(schedules.schedule!, id: \.self) { schedule in
					if (schedule.Group == UserDefaults.standard.string(forKey:"SelectedGroup") ?? "No Group Selected")
					{
						
						let temp = schedule.day?[selectedDay].pair
						ForEach(temp!, id: \.self) { pair in
							PairSingle(pair: pair)
							
							}
					}
					
				}
			}
		}
		.padding()
	}
}


struct PairSingle: View
{
	@State var pair: Pair
	var body: some View
	{
		VStack()
		{
			Text(pair.Name ?? "--------------")
				.fontWeight(.heavy)
			Divider()
			Text(pair.Teacher ?? "")
				.fontWeight(.light)
		}
		.frame(minWidth: 0,
					maxWidth: .infinity,
					minHeight: 0,
					alignment: .topLeading
				)
		.padding()
		.overlay(
				RoundedRectangle(cornerRadius: 14)
					.stroke(Color.gray, lineWidth: 4)
			)
	}
}
