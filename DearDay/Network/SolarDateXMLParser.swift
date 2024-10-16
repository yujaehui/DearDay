//
//  SolarDateXMLParser.swift
//  DearDay
//
//  Created by Jaehui Yu on 10/16/24.
//

import Foundation

class SolarDateXMLParser: NSObject, XMLParserDelegate {
    private var currentElement: String = ""
    private var items: [SolarDateItem] = []
    private var solYear = ""
    private var solMonth = ""
    private var solDay = ""

    func parse(data: Data) -> [SolarDateItem] {
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        return items
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        if currentElement == "item" {
            solYear = ""
            solMonth = ""
            solDay = ""
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedString.isEmpty {
            switch currentElement {
            case "solYear": solYear += trimmedString
            case "solMonth": solMonth += trimmedString
            case "solDay": solDay += trimmedString
            default: break
            }
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            let item = SolarDateItem(solYear: solYear, solMonth: solMonth, solDay: solDay)
            items.append(item)
        }
    }
}
