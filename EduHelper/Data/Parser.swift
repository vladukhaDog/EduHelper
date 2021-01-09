//
//  Parser.swift
//  EduHelper
//
//  Created by vladukha on 08.01.2021.
//

import Foundation
import SwiftSoup
import UIKit

class parser
{
	func getDay() -> Int{
		var date = Calendar.current.component(.weekday, from: Date() - 1) // пятница - 6, воскресенье - 1
		switch date {
		case 1: // воскресенье
			date = 5
		case 2: //понедельник
			date = 0
		case 3:
			date = 1
		case 4:
			date = 2
		case 5:
			date = 3
		case 6:
			date = 4
		case 7: //суббота
			date = 5
		default:
			date = 0
		}
		let hour = Calendar.current.component(.hour, from: Date())
		if (hour >= 18 && hour < 23) //заходишь вечером - смотришь след день сразу
		{
			date = date == 5 ? 0 : (date + 1)
 		}
		
		return date
	}
	func CheckConnection() -> Bool
	{
		let myURLstring = "https://pkgh.edu.ru/obuchenie/shedule-of-classes.html"
		guard let myURL = URL(string: myURLstring) else {return false}
		do{
			let myHTMLString = try String(contentsOf: myURL, encoding: .utf8)
			let _ = try! SwiftSoup.parse(myHTMLString).select("div#main")
			return true
		} catch {
			return false
			}
	}
	
	func parse()
	{
		let myURLstring = "https://pkgh.edu.ru/obuchenie/shedule-of-classes.html"
		guard let myURL = URL(string: myURLstring) else {return}
		do{
			let myHTMLString = try String(contentsOf: myURL, encoding: .utf8)
			let doc = try! SwiftSoup.parse(myHTMLString).select("div#main")
			groups(doc: try doc.select("div#maininner"))
			changes(doc: try doc.select("section#innertop"))
			schedule(doc: try doc.select("section#content"))
			getRings(doc: try doc.select("div.custom"))
		} catch {
			print("Was error getting overall schedule")
			}
	}
	
	func schedule(doc: Elements)
	{
		
		do{
			var array : [Schedule] = []
			let perGroupDocument = try doc.select("div.column").array()
			for group in perGroupDocument
			{
				var days : [Day] = []
				let dayArray = try group.select("table.shedule").array()
				for day in dayArray
				{
					var pairs : [Pair] = []
					var dayInfo = Day()
					let pairArray = try day.select("tr.pair").array()
					for pair in pairArray
					{
						var pairInfo = Pair()
						if (try pair.select("b").text().contains("Занятий"))
						{
							pairInfo.Name = "Занятий по расписанию нет!"
						}else{
							pairInfo.Name = try pair.select("p.pname").text()
							pairInfo.Room = try pair.select("p.pcab").text()
							pairInfo.Teacher = try pair.select("p.pteacher").text()
						}
						
						pairs.append(pairInfo)
					}
					dayInfo.pair = pairs
					dayInfo.weekday = try day.select("p.groupname").text()
					days.append(dayInfo)
				}
				var scheduler = Schedule()
				scheduler.Group = try group.select("h4").text()
				scheduler.day = days
				array.append(scheduler)
			}
			var schedule = Schedules()
			schedule.schedule = array
			Storage.store(schedule, to: .caches, as: "Schedule.json")
		} catch {
			print("Was error getting changes")
		}
	}
	
	func changesFromScratch()
	{
		let myURLstring = "https://pkgh.edu.ru/obuchenie/shedule-of-classes.html"
		guard let myURL = URL(string: myURLstring) else {return}
		do{
			let myHTMLString = try String(contentsOf: myURL, encoding: .utf8)
			let doc = try! SwiftSoup.parse(myHTMLString).select("div#maininner")
			changes(doc: try doc.select("section#innertop"))
		} catch {
			print("Was error getting overall schedule")
			}
	}
	
	func groupsFromScratch()
	{
		let myURLstring = "https://pkgh.edu.ru/obuchenie/shedule-of-classes.html"
		guard let myURL = URL(string: myURLstring) else {return}
		do{
			let myHTMLString = try String(contentsOf: myURL, encoding: .utf8)
			let doc = try! SwiftSoup.parse(myHTMLString).select("ul.showhide")
			groups(doc: doc)
		} catch {
			print("Was error getting overall schedule")
			}
	}
	
	func groups(doc: Elements)
	{
		var arrayOf : [String] = []
		do{
			let groupDocument = try doc.select("h4.expanded").array()
			for group in groupDocument
			{
				if (try !group.text().contains("Замены"))
				{
					arrayOf.append(try group.text())
				}
				
			}
			var groups = Groups()
			groups.name = arrayOf
			Storage.store(groups, to: .caches, as: "Groups.json")
		} catch {
			print("Was error getting changes")
		}
	}
	
	func changes(doc: Elements)
	{
		var arrayOf : [Change] = []
		do{
			let changeDocument = try doc.select("table.changes tbody").select("tr").array()
			for change in changeDocument
			{
				var changeClass = Change()
				var pair = Pair()
				var topair = Pair()
				changeClass.Group = try change.select("td.group").text()
				changeClass.PairNumber = try change.select("td.pnum").text()
				let Pairs = try change.select("td.onepair").array()
				pair.Name = try Pairs[0].select("p.pname").text()
				pair.Teacher = try Pairs[0].select("p.pteacher").text()
				pair.Room = try Pairs[0].select("span.pcab").text()
				topair.Name = try Pairs[1].select("p.pname").text()
				topair.Teacher = try Pairs[1].select("p.pteacher").text()
				topair.Room = try Pairs[1].select("span.pcab").text()
				changeClass.SchPair = pair
				changeClass.ChPair = topair
				arrayOf.append(changeClass)
			}
			var changes = Changes()
			let changesDateHTML = try doc.select("h4.expanded").first()
			changes.date = try changesDateHTML?.text()
			changes.change = arrayOf
			Storage.store(changes, to: .caches, as: "Changes.json")
		} catch {
			print("Was error getting changes")
		}
	}
	
	func getRings(doc: Elements)
	{
		
		do{
			let ringBody = try doc.select("table.simple-little-table").select("tbody").select("tr").array()
			var Rings = RingTimes()
			var RingArray: [Ring] = []
			for pair in ringBody
			{
				var ring = Ring()
				let tds = try pair.select("td").array()
				ring.id = Int(try tds[0].text())
				let arrayEnd = getArrayRings(tds: tds, weekpart: 2)
				let arrayDay = getArrayRings(tds: tds, weekpart: 1)
				var str = arrayDay[0]
				str.insert(":", at: str.index(str.startIndex, offsetBy: 2))
				ring.StartTime = str
				str = arrayDay[1]
				str.insert(":", at: str.index(str.startIndex, offsetBy: 2))
				ring.EndTime = str
				str = arrayEnd[0]
				str.insert(":", at: str.index(str.endIndex, offsetBy: -2))
				ring.WEStartTime = str
				str = arrayEnd[1]
				str.insert(":", at: str.index(str.endIndex, offsetBy: -2))
				ring.WEEndTime = str
				RingArray.append(ring)
			}
			Rings.ring = RingArray
			Storage.store(Rings, to: .caches, as: "Rings.json")
		} catch {
			print("Was error getting Rings list!")
			}
	}
	
	func getArrayRings(tds: [Element], weekpart: Int) -> [String]
	{
		do
		{
			
			if ((try tds[weekpart].text()).components(separatedBy: " - ").count != 2)
			{
				return (try tds[weekpart].text()).components(separatedBy: "-")
			}else
			{
				return (try tds[weekpart].text()).components(separatedBy: " - ")
			}
		}catch{
			print("error")
		}
		return(["geg","nogeg"])
	}

}
