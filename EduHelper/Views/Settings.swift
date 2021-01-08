//
//  Settings.swift
//  EduHelper
//
//  Created by vladukha on 08.01.2021.
//

import SwiftUI

struct Settings: View {
	
	func printChanges()
	{
		if Storage.fileExists("Rings.json", in: .caches) {
			print(Storage.retrieve("Rings.json", from: .caches, as: RingTimes.self))
		}
		else
		{
			print("no changes in cache")
		}
	}
	
	var body: some View {
		ZStack
		{
			//BackgroundView()
			VStack
			{
				Button(action: {
					Storage.clear(.caches)
					print("Caches cleared")
				}) {
					Text("Clear Cache")
						.font(.system(size: 20, weight: .medium, design: .default))
				}
				Button(action: {
					printChanges()
				}) {
					Text("Show Cache")
						.font(.system(size: 20, weight: .medium, design: .default))
				}
			}
		}
		
		
	}
}
