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
        var operation: ExpressionOperation
        
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
        
        func evaluate(caller: Node?) {
            switch left {
            case .number(let number):
                print("flat-eval-numb \(number)\(operation)\(right)")
                let result = operation.evaluate(left: number, right: right)
                caller?.left = .number(result)
            case .unsolved(let node):
                print("flat-eval-node \(node.right)\(operation)\(right)")
                let result = operation.evaluate(left: node.right, right: right)
                node.right = result
                if let caller = caller {
                    caller.left = .unsolved(node)
                } else {
                    self.right = result
                    self.operation = node.operation
                    self.left = node.left
                }
            }
        }
        
        func fold() {
            var highestCaller: Node? = nil
            var highest = self
            var current = self
            while true {
                switch current.left {
                case .number:
                    highest.evaluate(caller: highestCaller)
                    return
                case .unsolved(let node):
                    if node.operation.priority >= highest.operation.priority {
                        highest = node
                        highestCaller = current
                    }
                    current = node
                }
            }
        }
        
        func evaluateAll() -> Int {
            while true {
                switch left {
                case .number(let number):
                    return operation.evaluate(left: number, right: right)
                case .unsolved:
                    fold()
                }
            }
        }
        
    }
    
    public let rightmostNode: Node
    
    public init(rightmostNode: Node) {
        self.rightmostNode = rightmostNode
    }
    
    public func evaluate() -> Int {
        return rightmostNode.evaluateAll()
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
