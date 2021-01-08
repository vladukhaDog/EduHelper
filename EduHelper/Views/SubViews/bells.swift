//
//  bells.swift
//  EduHelper
//
//  Created by vladukha on 08.01.2021.
//

import SwiftUI

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
