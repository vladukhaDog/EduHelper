//
//  Pair.swift
//  EduHelper
//
//  Created by vladukha on 25.01.2021.
//
import SwiftUI
import Foundation

struct PairSingle: View
{
	@State var PairOrAlt: PairOrAlt
	@State var alt: Bool
	var body: some View
	{
		let temp = (!isEvenWeek() && (PairOrAlt.altPair?.Name != ""))
		let pair = alt ? (temp ? PairOrAlt.Pair : PairOrAlt.altPair) : (temp ? PairOrAlt.altPair : PairOrAlt.Pair)
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
								if !alt {
									Text("Пара по числителю")
										.font(.footnote)
										.opacity(0.6)
								}else
								{
									Text("Пара по знаменателю")
										.font(.footnote)
										.opacity(0.6)
								}
							}
							else{
								if !alt {
									Text("Пара по знаменателю")
										.font(.footnote)
										.opacity(0.6)
								}else
								{
									Text("Пара по числителю")
										.font(.footnote)
										.opacity(0.6)
								}
							}
						}
					}
					
					Text(pair?.Name ?? "--------------")
						.fontWeight(.heavy)
						.fixedSize(horizontal: false, vertical: true)
						//.fontWeight(.heavy)
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
