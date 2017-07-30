//
//  Processing.swift
//  Evaluate
//
//  Created by Олег on 23.07.17.
//
//

import Foundation

extension Expression {
    
    public enum Token {
        case number(Int)
        case operation(ExpressionOperation)
    }
    
}

extension BasicArithmetic {
    
    public static var parser: ExpressionTokenParser {
        return ExpressionTokenParser(elementOfTag: { (element, tag) -> Expression.Token? in
            switch element {
            case "-", "minus", "subtracting":
                return .operation(BasicArithmetic.subtraction)
            case "+", "plus", "adding", "add":
                return .operation(BasicArithmetic.addition)
            case "*", "×", "times":
                return .operation(BasicArithmetic.multiplication)
            case "/", "divided", "÷":
                return .operation(BasicArithmetic.division)
            default:
                return nil
            }
        })
    }
    
}

extension NumberFormatter {
    
    public static let spellOut: NumberFormatter = {
        let nf = NumberFormatter()
        nf.locale = Locale(identifier: "en_US")
        nf.numberStyle = .spellOut
        return nf
    }()
    
    public static let decimal: NumberFormatter = {
        let nf = NumberFormatter()
        nf.locale = Locale(identifier: "en_US")
        nf.numberStyle = .decimal
        return nf
    }()

    public static let expressionTokenParser: ExpressionTokenParser = ExpressionTokenParser { (element, tag) -> Expression.Token? in
        if let decimal = NumberFormatter.decimal.number(from: element) as? Int {
            return .number(decimal)
        }
        if let spellOut  = NumberFormatter.spellOut.number(from: element) as? Int {
            return .number(spellOut)
        }
        return nil
    }
    
}

public struct ExpressionTokenParser {
    
    let _parse: (String, String) -> Expression.Token?
    
    init(elementOfTag: @escaping (String, String) -> Expression.Token?) {
        self._parse = elementOfTag
    }
    
    func parse(element: String, of tag: String) -> Expression.Token? {
        return _parse(element, tag)
    }
    
    public static let always0 = ExpressionTokenParser(elementOfTag: { _ in .number(0) })
    
    public func chained(with anotherParser: ExpressionTokenParser) -> ExpressionTokenParser {
        return ExpressionTokenParser(elementOfTag: { (element, tag) -> Expression.Token? in
            if let first = self.parse(element: element, of: tag) {
                return first
            } else {
                return anotherParser.parse(element: element, of: tag)
            }
        })
    }
    
}

public struct UnparsedExpression {
    
    public init(_ unparsedString: String) {
        self.unparsedString = unparsedString
    }
    
    public let unparsedString: String
    
    public func parse(with parser: ExpressionTokenParser) -> [Expression.Token] {
        var tokens: [Expression.Token] = []
        let fullRange = unparsedString.startIndex ..< unparsedString.endIndex
        unparsedString.enumerateLinguisticTags(in: fullRange, scheme: NSLinguisticTagSchemeLexicalClass) { (tag, range, _, _) in
            let pretoken = unparsedString.substring(with: range)
            if let token = parser.parse(element: pretoken, of: tag) {
                tokens.append(token)
            }
        }
        return tokens
    }
    
}

extension Expression {
    
    public enum Error : Swift.Error {
        case firstTokenIsNotANumber(Expression.Token)
        case noTokens
        case notOperation(Token)
        case notANumber(Token)
        case evenNumberOfTokens
        case noOperations
    }
    
    public convenience init(tokens: [Expression.Token]) throws {
        guard !tokens.isEmpty else {
            throw Error.noTokens
        }
        var tokens = tokens
        let firstToken = tokens.removeFirst()
        guard case .number(let num) = firstToken else {
            throw Error.firstTokenIsNotANumber(firstToken)
        }
        let others = try Expression.split(tokens: tokens)
        var current: Operatable = num
        for (operation, number) in others {
            let next = current.node(withOperation: operation, number: number)
            current = next
        }
        guard let node = current as? Expression.Node else {
            throw Error.noOperations
        }
        self.init(rightmostNode: node)
    }
    
    static func split(tokens: [Expression.Token]) throws -> [(ExpressionOperation, Int)] {
        var tokens = tokens
        var count = tokens.count
        guard count % 2 == 0 else {
            throw Error.evenNumberOfTokens
        }
        var result: [(ExpressionOperation, Int)] = []
        while count >= 2 {
            let first = tokens.removeFirst()
            let second = tokens.removeFirst()
            count -= 2
            
            var operation: ExpressionOperation
            var number: Int
            
            if case .operation(let op) = first {
                operation = op
            } else {
                throw Error.notOperation(first)
            }
            if case .number(let num) = second {
                number = num
            } else {
                throw Error.notANumber(second)
            }
            result.append((operation, number))
        }
        return result
    }
    
}

extension Expression {
    
    public convenience init(from string: String,
                            parser: ExpressionTokenParser = NumberFormatter.expressionTokenParser.chained(with: BasicArithmetic.parser)) throws {
        let tokens = UnparsedExpression(string).parse(with: parser)
        try self.init(tokens: tokens)
    }
    
}
