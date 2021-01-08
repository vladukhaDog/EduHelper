//
//  BackGroundView.swift
//  EduHelper
//
//  Created by vladukha on 08.01.2021.
//

import SwiftUI

struct BackgroundView: View {
	@State var Schemes: ColorScheme
	var body: some View {
		let colorSchemeWhite = [//Color.black,
			Color(red: 147/255, green: 165/255, blue: 207/255),
			Color(red: 228/255, green: 239/255, blue: 233/255),
			Color.white,
			Color.white]
		let colorSchemeBlack = [Color.black,
						   Color(red: 20/255, green: 31/255, blue: 78/255),
						   Color(red: 141/255, green: 87/255, blue: 151/255)]
		let colorScheme = Schemes == .dark ? colorSchemeBlack : colorSchemeWhite
		let gradient = Gradient(colors: colorScheme)
		let linearGradient = LinearGradient(gradient: gradient, startPoint: .top, endPoint: .bottom)
		
		let background = Rectangle()
			.fill(linearGradient)
			.blur(radius: 200, opaque: true)
			.edgesIgnoringSafeArea(.all)
		
		return background
	}
}

