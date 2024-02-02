//
//  fetchWiki.swift
//  MenuBarApp
//
//  Created by Evert De Spiegeleer on 15/11/2023.
//

import Foundation

enum WikipediaError: Error {
    case invalidURL
    case requestFailed
    case invalidData
}

func fetchWikipediaExtract(for title: String, completion: @escaping (Result<String, Error>) -> Void) {
    // Create the Wikipedia API URL
    print("Fetching wiki extract for \(title)")
    guard let apiUrl = URL(string: "https://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro&explaintext&redirects=1&titles=\(title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") else {
        completion(.failure(WikipediaError.invalidURL))
        return
    }

    // Create the URLSession
    let session = URLSession.shared

    // Create the data task
    let task = session.dataTask(with: apiUrl) { (data, response, error) in
        // Check for errors
        if let error = error {
            completion(.failure(error))
            return
        }

        // Check if there is data
        guard let data = data else {
            completion(.failure(WikipediaError.invalidData))
            return
        }

        // Parse the JSON response
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

            // Extract the page ID and extract text
            if let query = json?["query"] as? [String: Any],
               let pages = query["pages"] as? [String: Any],
               let firstPage = pages.values.first as? [String: Any],
               let extract = firstPage["extract"] as? String {
                completion(.success(extract))
            } else if let query = json?["query"] as? [String: Any],
                      let normalized = query["normalized"] as? [[String: String]],
                      let firstNormalized = normalized.first,
                      let missingTitle = firstNormalized["to"] {
                completion(.failure(WikipediaError.invalidData))
                print("Page with title '\(missingTitle)' not found.")
            } else {
                completion(.failure(WikipediaError.invalidData))
                print("Invalid JSON structure.")
            }
        } catch {
            completion(.failure(error))
        }
    }

    // Start the data task
    task.resume()
}

//// Example usage:
//fetchWikipediaExtract(for: "Stack Overflow") { result in
//    switch result {
//    case .success(let extract):
//        print("Wikipedia Extract:\n\(extract)")
//    case .failure(let error):
//        print("Error fetching Wikipedia extract: \(error)")
//    }
//}
