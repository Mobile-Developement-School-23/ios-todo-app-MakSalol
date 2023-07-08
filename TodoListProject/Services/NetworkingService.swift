import Foundation

enum NetworkingErrors: Error {
    case invalidURL
    case decodingError
    case parsingError
}

protocol NetworkingService {
    func getList() async throws -> [TodoItem]
    func getItem(id: String) async throws -> TodoItem?
    func postItem(item: TodoItem) async throws
    func updateItem(item: TodoItem) async throws
    func deleteItem(id: String) async throws
    func patch(items: [TodoItem]) async throws -> [TodoItem]
}


final class DefaultNetworkingService: NetworkingService {
    
    private let token = "noveletter"
    private let user = "Bogomolov_M"
    private let baseURL = "https://beta.mrdekk.ru/todobackend"
    private var revision: Int = 0
    
    private func createURL(ending : String = "") -> URL? {
        return URL(string: baseURL + "/list" + "\(ending)")
    }
    
    
    private func parseList(data: Data) throws -> [TodoItem] {
        
        let jsonData = try JSONSerialization.jsonObject(with: data)
        
        guard let json = jsonData as? [String: Any],
              let revision = json["revision"] as? Int,
              let list = json["list"] as? [[String: Any]]
        else {
            throw NetworkingErrors.decodingError
        }
        self.revision = revision
        var itemsList = [TodoItem]()
        for dictItem in list {
            if let item = TodoItem.parse(json: dictItem) {
                itemsList.append(item)
            }
            else {
                throw NetworkingErrors.parsingError
            }
        }
        return itemsList
    }
    
    private func parseItem(data: Data) throws -> TodoItem? {
        
        let jsonData = try JSONSerialization.jsonObject(with: data)
        
        guard let json = jsonData as? [String: Any],
              let revision = json["revision"] as? Int,
              let element = json["element"] as? [String: Any]
        else {
            throw NetworkingErrors.decodingError
        }
        
        self.revision = revision
        return TodoItem.parse(json: element)
    }
    
    func getList() async throws -> [TodoItem] {
        guard let url = createURL() else { throw NetworkingErrors.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (data, _) = try await URLSession.shared.dataTask(for: request)
        let itemsList = try parseList(data: data)
        return itemsList
    }
    
    func getItem(id: String) async throws -> TodoItem? {
        guard let url = createURL(ending: "/\(id)") else { throw NetworkingErrors.invalidURL}
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.dataTask(for: request)
        let item = try parseItem(data: data)
        return item
    }
    
    func postItem(item: TodoItem) async throws {
        guard let url = createURL() else { throw NetworkingErrors.invalidURL }

        let data = try JSONSerialization.data(withJSONObject: [
            "status": "ok",
            "element": item.json
        ] as [String: Any])
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("\(self.revision)", forHTTPHeaderField: "X-Last-Known-Revision")
        request.httpBody = data
     
        self.revision += 1
        let (_,_) = try await URLSession.shared.dataTask(for: request)
    }
    
    func updateItem(item: TodoItem) async throws {
        guard let url = createURL(ending: "/\(item.id)") else { throw NetworkingErrors.invalidURL }
        
        let data = try JSONSerialization.data(withJSONObject: [
            "status": "ok",
            "element": item.json
        ] as [String: Any])
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("\(self.revision)", forHTTPHeaderField: "X-Last-Known-Revision")
        request.httpBody = data
        
        self.revision += 1
        let (_,_) = try await URLSession.shared.dataTask(for: request)
    }
    
    func deleteItem(id: String) async throws {
        guard let url = createURL(ending: "/\(id)") else { throw NetworkingErrors.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("\(self.revision)", forHTTPHeaderField: "X-Last-Known-Revision")
        
        self.revision += 1
        let (_,_) = try await URLSession.shared.dataTask(for: request)
    }
    
    func patch(items: [TodoItem]) async throws -> [TodoItem] {
        guard let url = createURL() else { throw NetworkingErrors.invalidURL }
        
        let jsonList = items.map { $0.json }
        let body = try JSONSerialization.data(withJSONObject: [
            "status": "ok",
            "list": jsonList
        ] as [String: Any])
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("\(self.revision)", forHTTPHeaderField: "X-Last-Known-Revision")
        request.httpBody = body
        
        self.revision += 1
        let (data, _) = try await URLSession.shared.dataTask(for: request)
        let itemsList = try parseList(data: data)
        return itemsList
    }
    
}
