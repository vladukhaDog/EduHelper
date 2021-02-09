//
//  ChangesView.swift
//  EduHelper
//
//  Created by vladukha on 08.01.2021.
//

import SwiftUI

struct ChangesView: View {
	
	
	func GettingSchedule()
	{
		let dispatchQueue = DispatchQueue(label: "QueueIdentification", qos: .background)
		dispatchQueue.async{
			let Parser = parser()
			self.isLoading = true
			if (Parser.CheckConnection())
			{
				withAnimation {
					self.group = "No Group Selected"
					Parser.changesFromScratch()
					self.group = UserDefaults.standard.string(forKey:"SelectedGroup") ?? "No Group Selected"
				}
			}
			self.isLoading = false
		}
	}
	
	@State var isLoading = false
	@Environment(\.colorScheme) var colorScheme
	@State var group = "No group selected"
	init() {
		//обьявляется в ините потому что при создании view не видит и не отображает замены (cringe)
		self.group = UserDefaults.standard.string(forKey:"SelectedGroup") ?? "No Group Selected"
	}
	var body: some View {
		
		ZStack
		{
			if(colorScheme == .dark)
			{BackgroundView(Schemes: .dark)}
			else
			{BackgroundView(Schemes: .light)}
		VStack
		{
			HStack
			{
				if (Storage.fileExists("Changes.json", in: .caches)) {
					let changes = Storage.retrieve("Changes.json", from: .caches, as: Changes.self)
					let check = changes.date ?? ""
					if (check.contains("Замен"))
					{
						Text(changes.date ?? "No date")
							.fontWeight(.heavy)
							.font(.title)
					}
					else
					{
						Text("Замен нет!")
							.fontWeight(.heavy)
							.font(.title)
					}
				}
				Spacer()
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
						Image(systemName: "arrow.clockwise.circle")
							.font(Font.system(.largeTitle))
					} .disabled(isLoading)
				}
			}
			
			ScrollView(.vertical) {
				VStack(spacing: 20) {
					Divider()
					if (Storage.fileExists("Changes.json", in: .caches)) {
						let changes = Storage.retrieve("Changes.json", from: .caches, as: Changes.self)
						ForEach(changes.change!, id: \.self) { change in
							if (change.Group == group)
							{
								VStack()
								{
									HStack()
									{
										Text(change.PairNumber ?? "")
											.fontWeight(.heavy)
											.font(.title)
										Spacer()
										Text(change.SchPair?.Name ?? "")
											.fontWeight(.light)
											.foregroundColor(.red)
									}
									Divider()
									Text(change.ChPair?.Name ?? "")
										.fontWeight(.heavy)
									Text((change.ChPair?.Teacher ?? ""))
										.fontWeight(.light)
										.font(.subheadline)
								}
								.padding()
								.overlay(
										RoundedRectangle(cornerRadius: 14)
											.stroke(Color.gray, lineWidth: 4)
									)
								.transition(.move(edge: .top))
							}
							
						}
					}
				}
			}
			
			
		}
		.padding()
		}
		.onAppear{
			group = UserDefaults.standard.string(forKey:"SelectedGroup") ?? "No Group Selected"
		}
	}
}
