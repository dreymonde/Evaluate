// Swift Playground

public protocol ExpressionOperation {
    
    var priority: Int { get }
    
    func evaluate(left: Int, right: Int) -> Int
    
}

public enum BasicArithmetic : ExpressionOperation, CustomStringConvertible {
    
    case addition
    case subtraction
    case multiplication
    
    public var priority: Int {
        switch self {
        case .addition:
            return 5
        case .subtraction:
            return 5
        case .multiplication:
            return 10
        }
    }
    
    public var description: String {
        switch self {
        case .addition:
            return "+"
        case .subtraction:
            return "-"
        case .multiplication:
            return "×"
        }
    }
    
    public func evaluate(left: Int, right: Int) -> Int {
        switch self {
        case .addition:
            return left + right
        case .subtraction:
            return left - right
        case .multiplication:
            return left * right
        }
    }
    
}

public class Expression {
    
    public class Node {
        
        public enum Neighbor {
            case number(Int)
            case unsolved(Node)
        }
        
        var left: Neighbor
        var right: Int
        let operation: ExpressionOperation
        
        public init(left: Int, operation: ExpressionOperation, right: Int) {
            self.left = .number(left)
            self.operation = operation
            self.right = right
        }
        
        public init(left: Node, operation: ExpressionOperation, right: Int) {
            self.left = .unsolved(left)
            self.operation = operation
            self.right = right
        }
        
        public func string() -> String {
            var str = ""
            switch left {
            case .number(let number):
                str.append(String(number))
            case .unsolved(let node):
                str.append(node.string())
            }
            str.append("\(operation)\(right)")
            return str
        }
        
        func evaluate() -> Int {
            print("Evaluating (\(string()))")
            switch left {
            case .number(let number):
                return operation.evaluate(left: number, right: right)
            case .unsolved(let node):
                if node.operation.priority >= self.operation.priority {
                    let evaluated = node.evaluate()
                    self.left = .number(evaluated)
                    return self.evaluate()
                } else {
                    self.left = .number(node.right)
                    let evaluated = self.evaluate()
                    node.right = evaluated
                    return node.evaluate()
                }
            }
        }
        
    }
    
    public let rightmostNode: Node
    
    public init(rightmostNode: Node) {
        self.rightmostNode = rightmostNode
    }
    
    public func evaluate() -> Int {
        return rightmostNode.evaluate()
    }
    
}

public protocol Operatable {
    
    func node(withOperation operation: ExpressionOperation, number: Int) -> Expression.Node
    
}

extension Operatable {
    
    public func op(_ operation: BasicArithmetic, _ number: Int) -> Expression.Node {
        return node(withOperation: operation, number: number)
    }
    
}

extension Int : Operatable {
    
    public func node(withOperation operation: ExpressionOperation, number: Int) -> Expression.Node {
        return Expression.Node(left: self, operation: operation, right: number)
    }
    
}

extension Expression.Node : Operatable {
    
    public func node(withOperation operation: ExpressionOperation, number: Int) -> Expression.Node {
        return Expression.Node(left: self, operation: operation, right: number)
    }
    
    public func expression() -> Expression {
        return Expression(rightmostNode: self)
    }
    
}
