extension Array {
    mutating func popFirst() -> Element? {
        guard let result = first else { return nil }

        removeFirst()
        return result
    }

    mutating func popFirst(_ k: Int) -> [Element]? {
        guard count >= k else { return nil }

        let result = Array(prefix(k))
        removeFirst(k)
        return result
    }
}
