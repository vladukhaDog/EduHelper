//
//  ScheduleStruct.swift
//  EduHelper
//
//  Created by vladukha on 08.01.2021.
//

import SwiftUI
import Foundation

struct RingTimes: Codable {
	var ring: [Ring]?
}

struct Ring: Codable, Hashable
{
	var id: Int?
	var StartTime: String?
	var EndTime: String?
	var WEStartTime: String?
	var WEEndTime: String?
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}

struct Changes: Codable{
	var date: String?
	var change: [Change]?
}

struct Groups: Codable{
	var name: [String]?
}

struct Change: Hashable, Codable, Identifiable {
	var id = UUID()
	var PairNumber: String?
	var Group: String?
	var SchPair: Pair?
	var ChPair: Pair?
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}
extension Change {
	static func ==(lhs: Change, rhs: Change) -> Bool {
		return lhs.id == rhs.id
	}
}

struct Pair: Codable, Hashable, Identifiable{
	var id = UUID()
	var Name: String?
	var Teacher: String?
	var Room: String?
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}
extension Pair {
	static func ==(lhs: Pair, rhs: Pair) -> Bool {
		return lhs.id == rhs.id
	}
}

struct Day: Codable, Hashable {
	
	var id = UUID()
	var weekday: String?
	var pair: [Pair]?
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}

struct Schedule: Codable, Hashable, Identifiable
{
	var id = UUID()
	var Group: String?
	var day: [Day]?
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
	
}
extension Schedule {
	static func ==(lhs: Schedule, rhs: Schedule) -> Bool {
		return lhs.id == rhs.id
	}
}

struct Schedules: Codable {
	var schedule: [Schedule]?
}
