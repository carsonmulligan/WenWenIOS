import Foundation

class PinyinDictionary {
    static let shared = PinyinDictionary()
    
    private var dict: [String: [String: String]] = [:]
    
    private init() {
        if let url = Bundle.main.url(forResource: "chinese_to_pinyin_dictionary_with_tones", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: [String: String]] {
            dict = json
        }
    }
    
    func getPinyinTone(for character: String) -> String? {
        return dict[character]?["pinyin_tone_lines"]
    }
} 