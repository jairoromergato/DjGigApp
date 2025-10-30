import Foundation

struct ImportedTrack: Hashable {
    let title: String
    let artist: String
}

enum RekordboxImportError: Error {
    case invalidData
    case empty
}

enum RekordboxImporter {
    /// Parsea CSV de Rekordbox y devuelve lista de tracks (título, artista).
    static func parseCSV(_ data: Data) throws -> [ImportedTrack] {
        guard let text = String(data: data, encoding: .utf8)
            ?? String(data: data, encoding: .isoLatin1) else {
            throw RekordboxImportError.invalidData
        }

        // Partimos líneas; Rekordbox suele usar coma y comillas dobles.
        let lines = text
            .components(separatedBy: .newlines)
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }

        guard let header = lines.first else { throw RekordboxImportError.empty }

        // Indices de columnas típicas
        let columns = header.lowercased().components(separatedBy: ",")
        let titleIdx = index(ofAny: ["title", "track title", "nombre de pista", "título"], in: columns)
        let artistIdx = index(ofAny: ["artist", "artista"], in: columns)

        guard let tIdx = titleIdx else { throw RekordboxImportError.invalidData }

        var result: [ImportedTrack] = []
        for line in lines.dropFirst() {
            let fields = splitCSV(line)

            func field(_ i: Int?) -> String {
                guard let i = i, i < fields.count else { return "" }
                return fields[i].trimmingCharacters(in: .whitespacesAndNewlines)
                    .trimmingCharacters(in: CharacterSet(charactersIn: "\""))
            }

            let title = field(tIdx)
            let artist = field(artistIdx) // puede ir vacío
            if !title.isEmpty {
                result.append(ImportedTrack(title: title, artist: artist))
            }
        }

        // Deduplicamos por (title, artist)
        let unique = Array(Set(result))
        return unique
    }

    // MARK: - Helpers CSV

    /// Divide una línea CSV básica respetando comillas.
    private static func splitCSV(_ line: String) -> [String] {
        var result: [String] = []
        var current = ""
        var insideQuotes = false

        for char in line {
            if char == "\"" {
                insideQuotes.toggle()
                current.append(char)
            } else if char == "," && !insideQuotes {
                result.append(current)
                current = ""
            } else {
                current.append(char)
            }
        }
        result.append(current)
        return result
    }

    private static func index(ofAny keys: [String], in columns: [String]) -> Int? {
        for (i, col) in columns.enumerated() {
            let trimmed = col.trimmingCharacters(in: .whitespacesAndNewlines)
                .trimmingCharacters(in: CharacterSet(charactersIn: "\""))
            if keys.contains(trimmed) { return i }
        }
        return nil
    }
}

