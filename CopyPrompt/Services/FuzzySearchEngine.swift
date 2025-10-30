import Foundation

enum FuzzySearchEngine {
    private struct ScoredPrompt {
        let prompt: Prompt
        let score: Double
    }

    private static let titleWeight: Double = 2.0
    private static let bodyWeight: Double = 1.0

    static func search(query: String, in prompts: [Prompt]) -> [Prompt] {
        guard !query.isEmpty else {
            return prompts
        }

        let normalizedQuery = normalize(query)
        var scoredResults: [ScoredPrompt] = []

        for prompt in prompts {
            let normalizedTitle = normalize(prompt.title)
            let normalizedBody = normalize(prompt.body)

            let titleScore = fuzzyMatch(query: normalizedQuery, text: normalizedTitle) * titleWeight
            let bodyScore = fuzzyMatch(query: normalizedQuery, text: normalizedBody) * bodyWeight

            let totalScore = titleScore + bodyScore

            if totalScore > 0 {
                scoredResults.append(ScoredPrompt(prompt: prompt, score: totalScore))
            }
        }

        return scoredResults
            .sorted { $0.score > $1.score }
            .map(\.prompt)
    }

    private static func normalize(_ text: String) -> String {
        text
            .folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()
    }

    private static func fuzzyMatch(query: String, text: String) -> Double {
        guard !query.isEmpty else { return 0 }

        var score: Double = 0
        var previousIndex = text.startIndex
        var consecutiveMatches = 0

        for queryChar in query {
            guard let matchIndex = text[previousIndex...].firstIndex(of: queryChar) else {
                return 0
            }

            let distance = text.distance(from: previousIndex, to: matchIndex)

            if distance == 0 {
                consecutiveMatches += 1
                score += 10 + Double(consecutiveMatches) * 5
            } else {
                consecutiveMatches = 0
                score += max(0, 10 - Double(distance))
            }

            previousIndex = text.index(after: matchIndex)
        }

        let queryLength = Double(query.count)
        let textLength = Double(text.count)
        let lengthRatio = queryLength / textLength
        score *= (1 + lengthRatio * 0.5)

        return score
    }
}
