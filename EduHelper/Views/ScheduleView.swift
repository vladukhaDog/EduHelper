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

func isEvenWeek() -> Bool
{
	//проверяем знаменатель недели четный или нет
	let weekInt = NSCalendar.current.component(.weekOfYear, from: Date())
	if (weekInt % 2 == 0) {
		return true
	}else
	{
	return false
	}
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
					Text(self.days[index]).fontWeight(.heavy).tag(index)
						
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
				VStack(spacing: 20) {
					if (Storage.fileExists("Schedule.json", in: .caches)) {
						let schedules = Storage.retrieve("Schedule.json", from: .caches, as: Schedules.self)
						let GroupIndex = schedules.schedule?.firstIndex(where: {$0.Group == UserDefaults.standard.string(forKey:"SelectedGroup") ?? "No Group Selected" } )
						let schedule = schedules.schedule?[GroupIndex ?? 0]
						let temp = schedule?.day?[selectedDay].pair
						ForEach(temp!, id: \.self) { pair in
							if (!isEvenWeek() && (pair.altPair?.Name != ""))
							{
								buttonPair(PairOrAlt: pair)
							}
							else
							{
								PairSingle(PairOrAlt: pair, alt: false)
							}
							
						}
					}
				}
				.padding()
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

struct buttonPair: View
{
	@State var PairOrAlt: PairOrAlt
	@State var showAltPair = false
	var body: some View
	{
		ZStack{
			Button(action: {
				withAnimation{
					showAltPair.toggle()
				}
			}){
				PairSingle(PairOrAlt: PairOrAlt, alt: false)
				
			}
			.buttonStyle(PlainButtonStyle())
			if (showAltPair)
			{
				PairSingle(PairOrAlt: PairOrAlt, alt: true)
			}
		}
	}
}


struct PairSingle: View
{
	@State var PairOrAlt: PairOrAlt
	@State var alt: Bool
	var body: some View
	{
		if(alt){
			let pair = (!isEvenWeek() && (PairOrAlt.altPair?.Name != "")) ? PairOrAlt.Pair : PairOrAlt.altPair
		}
		else
		{
			let pair = (!isEvenWeek() && (PairOrAlt.altPair?.Name != "")) ? PairOrAlt.altPair : PairOrAlt.Pair
		}
			VStack()
			{
				HStack
				{
					Text(pair?.PairNumber ?? "")
						.fontWeight(.heavy)
						.font(.title)
					Spacer()
					VStack
					{
						if (PairOrAlt.altPair?.Name != ""){
							HStack{
								Spacer()
								if(isEvenWeek())
								{
									Text("Пара по числителю")
										.font(.footnote)
										.opacity(0.6)
								}
								else{
									Text("Пара по знаменателю")
										.font(.footnote)
										.opacity(0.6)
								}
								
							}
						}
						
						Text(pair?.Name ?? "--------------")
							.fontWeight(.heavy)
					}
					
				}
				Divider()
				Text(pair?.Teacher ?? "--")
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
