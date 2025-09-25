////
////  PlaceData.swift
////  zentra_v0
////
////  Created by Evelyn Tran on 25/9/2025.
////
//
//
//
//import UIKit
//
//class PlaceData: NSObject, Decodable {
//
//    var isbn13: String?
//    var title: String
//    var authors: String
//    var publisher: String?
//    var publicationDate: String?
//    var bookDescription: String?
//    var imageURL: String?
//
//    private enum RootKeys: String, CodingKey {
//        case volumeInfo
//    }
//
//    private enum BookKeys: String, CodingKey {
//        case title
//        case authors
//        case publisher
//        case publicationDate = "publishedDate"
//        case bookDescription = "description"
//        case industryIdentifiers
//        case imageLinks
//    }
//
//    private enum ImageKeys: String, CodingKey {
//        case smallThumbnail
//    }
//
//    private struct ISBNCode: Decodable {
//        var type: String
//        var identifier: String
//    }
//
//    required init(from decoder: Decoder) throws {
//        let rootContainer = try decoder.container(keyedBy: RootKeys.self)
//        let bookContainer = try rootContainer.nestedContainer(keyedBy: BookKeys.self, forKey: .volumeInfo)
//
//        // Title
//        title = try bookContainer.decode(String.self, forKey: .title)
//
//        // Authors as joined string
//        if let authorArray = try? bookContainer.decode([String].self, forKey: .authors),
//           !authorArray.isEmpty {
//            authors = authorArray.joined(separator: ", ")
//        } else {
//            authors = "Unknown Author"
//        }
//
//        // Optional fields
//        publisher = try? bookContainer.decode(String.self, forKey: .publisher)
//        publicationDate = try? bookContainer.decode(String.self, forKey: .publicationDate)
//        bookDescription = try? bookContainer.decode(String.self, forKey: .bookDescription)
//
//        // ISBN
//        if let isbnCodes = try? bookContainer.decode([ISBNCode].self, forKey: .industryIdentifiers) {
//            for code in isbnCodes {
//                if code.type == "ISBN_13" { isbn13 = code.identifier }
//            }
//        }
//
//        // Image
//        if let imageContainer = try? bookContainer.nestedContainer(keyedBy: ImageKeys.self, forKey: .imageLinks) {
//            imageURL = try? imageContainer.decode(String.self, forKey: .smallThumbnail)
//        }
//    }
//}
