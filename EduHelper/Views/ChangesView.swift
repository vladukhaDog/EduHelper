//
//  ChangesView.swift
//  EduHelper
//
//  Created by vladukha on 08.01.2021.
//

import SwiftUI

struct ChangesView: View {
	
	func updateView()
	{
		self.update = false
		self.update = true
	}
	
	func GettingSchedule()
	{
		let dispatchQueue = DispatchQueue(label: "QueueIdentification", qos: .background)
		dispatchQueue.async{
			let Parser = parser()
			if (Parser.CheckConnection())
			{
				Parser.changesFromScratch()
			}
		}
	}
	
	@State private var update = Storage.fileExists("Changes.json", in: .caches)
	@Environment(\.colorScheme) var colorScheme
	
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
				Button(action: {
					update = false
					GettingSchedule()
					update = true
				}) {
					Image(systemName: "arrow.clockwise.circle")
						.font(Font.system(.largeTitle))
				}.onAppear{
					updateView()
				}
			}
			
			if (update)
			{
				ScrollView(.vertical) {
					VStack(spacing: 20) {
						Divider()
						if (Storage.fileExists("Changes.json", in: .caches)) {
							let changes = Storage.retrieve("Changes.json", from: .caches, as: Changes.self)
							ForEach(changes.change!, id: \.self) { change in
								if (change.Group == UserDefaults.standard.string(forKey:"SelectedGroup") ?? "No Group Selected")
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
								}
								
							}
						}
					}
				}
			}
			
		}
		.padding()
		}
	}
}
