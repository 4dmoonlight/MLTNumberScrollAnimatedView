//
//  MLTAnimatedNumberText.swift
//  TestSwift
//
//  Created by Hou Rui on 2024/9/25.
//

import UIKit
import SnapKit

class MLTNumberScrollView: UIView {
    
    let font: UIFont
    let textColor: UIColor
    private var currentNumber: Int = 0
    private var pendingNumber: Int?

    init(font: UIFont, textColor: UIColor) {
        self.font = font
        self.textColor = textColor
        super.init(frame: .zero)
        self.setupLabels()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let pendingNumber = pendingNumber {
            setNumber(pendingNumber, animated: false)
            self.pendingNumber = nil
        }
    }

    private func setupLabels() {
        addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        stackView.setContentCompressionResistancePriority(.required, for: .horizontal)
        stackView.setContentCompressionResistancePriority(.required, for: .vertical)
        stackView.setContentHuggingPriority(.required, for: .horizontal)
        stackView.setContentHuggingPriority(.required, for: .vertical)

        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(self)
            make.width.equalTo(stackView)
            make.height.equalTo(stackView).multipliedBy(0.1)
        }
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
        }
    }
    
    func setNumber(_ number: Int, animated: Bool) {
        if superview == nil {
            pendingNumber = number
            return
        }

        scrollView.setContentOffset(CGPoint(x: 0.0, y: (Double(number) * frame.height)), animated: animated)
        currentNumber = number
    }
        
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: labels)
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        return stackView
    }()
    
    lazy var labels: [UILabel] = {
        var labels = [UILabel]()
        for number in 0...9 {
            let label = UILabel()
            label.font = font
            label.textColor = textColor
            label.textAlignment = .center
            label.text = "\(number)"
            labels.append(label)
        }
        return labels
    }()
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = false
        scrollView.isScrollEnabled = false
        return scrollView
    }()
}

enum MLTCharEditOperation {
    case insert(char: Character, index: Int)
    case delete(char: Character, index: Int)
    case replace(oldChar: Character, newChar: Character, index: Int)
}

public class MLTNumberScrollAnimatedView: UIView {
    let font: UIFont
    let textColor: UIColor

    private var currentValue: String?
    private var viewArray = [UIView]()
    private var operationArray = [MLTCharEditOperation]()
    private var animator: UIViewPropertyAnimator?
    
    public init(font: UIFont, textColor: UIColor) {
        self.font = font
        self.textColor = textColor
        super.init(frame: .zero)
        setupUserInterface()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setValue(_ newValue: String?, animated: Bool = true, completion: (() -> Void)? = nil) {
        if currentValue == newValue {
            return
        }
        defer {
            currentValue = newValue
        }
        guard let value = newValue, value.isEmpty == false else {
            clearAllView()
            return
        }
        print("change value from \(String(describing: currentValue)) to \(String(describing: value))")
        if let oldValue = currentValue, oldValue.isEmpty == false, animated == true, UIApplication.shared.applicationState == .active {
            if animator?.isRunning == true {
                animator?.stopAnimation(true)
                setValueWithNoAni(oldValue)
            }
            operationArray = levenshteinDistanceWithCustomRules(oldValue, value).operations
            let sortedOperations = operationArray.sorted { op1, op2 in
                switch (op1, op2) {
                case (.replace(_, _, let index1), .replace(_, _, let index2)):
                    return index1 < index2  // 替换操作按正序执行
                case (.replace, _):
                    return true  // 替换操作优先于删除和插入操作
                case (_, .replace):
                    return false
                case (.delete(_, let index1), .delete(_, let index2)):
                    return index1 > index2  // 删除操作按逆序执行
                case (.insert(_, let index1), .insert(_, let index2)):
                    return index1 < index2  // 插入操作按正序执行
                case (.delete, .insert):
                    return true  // 删除操作优先于插入操作
                case (.insert, .delete):
                    return false
                default:
                    return true
                }
            }
            animator = UIViewPropertyAnimator(duration: 1.0, curve: .easeInOut)
            for operation in sortedOperations {
                print("\(descForOperation(operation: operation))")
                switch operation {
                case .insert(char: let char, index: let index):
                    if let digit = charToDigit(char) {
                        // 如果是数字，添加 NumberScrollView
                        let numberScrollView = MLTNumberScrollView(font: font, textColor: textColor)
                        numberScrollView.setNumber(digit, animated: false)
                        numberScrollView.isHidden = true
                        numberScrollView.alpha = 0
                        viewArray.insertSafely(numberScrollView, at: index)
                        if index == 0 {
                            stackView.insertArrangedSubview(numberScrollView, at: index)
                        } else if let viewInStack = viewArray[safely: index - 1], let indexInStack = stackView.arrangedSubviews.firstIndex(of: viewInStack) {
                            stackView.insertArrangedSubview(numberScrollView, at: indexInStack + 1)
                        }
                        
                        animator?.addAnimations { [weak numberScrollView] in
                            numberScrollView?.alpha = 1
                            numberScrollView?.isHidden = false
                        }

                    } else {
                        // 如果不是数字，添加 UILabel
                        let label = UILabel()
                        label.text = String(char)
                        label.textAlignment = .center
                        label.textColor = textColor
                        label.font = font
                        label.isHidden = true
                        label.alpha = 0
                        viewArray.insertSafely(label, at: index)
                        stackView.insertArrangedSubview(label, at: index)
                        
                        animator?.addAnimations { [weak label] in
                            label?.alpha = 1
                            label?.isHidden = false
                        }

                    }
                case .delete(char: _, index: let index):
                    let view = viewArray[safely: index]
                    viewArray.removeSafely(at: index)
                    animator?.addAnimations { [weak view] in
                        view?.alpha = 0
                        view?.isHidden = true
                    }
                case .replace(oldChar: _, newChar: let newChar, index: let index):
                    if let numberView = viewArray[safely: index] as? MLTNumberScrollView, let newNum = charToDigit(newChar) {
                        animator?.addAnimations { [weak numberView] in
                            numberView?.setNumber(newNum, animated: false)
                        }
                    } else if let label = viewArray[safely: index] as? UILabel {
                        label.text = String(newChar)
                    }
                }
            }
            animator?.addCompletion { [weak self] position in
                guard let self = self else { return }
                self.animator = nil

                self.removeHiddenViews()
                
                self.setValueWithNoAni(value)
                
                completion?()
            }
            animator?.startAnimation()
        } else {
            setValueWithNoAni(value)
            completion?()
        }
    }

    private func removeHiddenViews() {
        var index = 0
        
        while index < stackView.arrangedSubviews.count {
            let view = stackView.arrangedSubviews[index]
            
            if view.isHidden {
                stackView.removeArrangedSubview(view)
                view.removeFromSuperview()
            } else {
                index += 1 
            }
        }
    }
    
    private func setValueWithNoAni(_ value: String) {
        clearAllView()
        for char in value {
            if let digit = charToDigit(char) {
                // 如果是数字，添加 NumberScrollView
                let numberScrollView = MLTNumberScrollView(font: font, textColor: textColor)
                numberScrollView.setNumber(digit, animated: false)
                stackView.addArrangedSubview(numberScrollView)
                viewArray.append(numberScrollView)
            } else {
                // 如果不是数字，添加 UILabel
                let label = UILabel()
                label.text = String(char)
                label.textAlignment = .center
                label.textColor = textColor
                label.font = font
                stackView.addArrangedSubview(label)
                viewArray.append(label)
            }
        }
    }
    
    private func descForOperation(operation: MLTCharEditOperation) {
        switch operation {
        case .insert(let char, let index):
            print("Insert '\(char)' at position \(index)")
        case .delete(let char, let index):
            print("Delete '\(char)' from position \(index)")
        case .replace(let oldChar, let newChar, let index):
            print("Replace '\(oldChar)' with '\(newChar)' at position \(index)")
        }
    }
    
    private func clearAllView() {
        for view in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()  // 移除父视图中的视图
        }
        
        viewArray.removeAll()
    }
    
    private func isDigit(_ char: Character) -> Bool {
        return charToDigit(char) != nil
    }

    private func charToDigit(_ char: Character) -> Int? {
        Int(String(char))
    }

    private func levenshteinDistanceWithCustomRules(_ str1: String, _ str2: String) -> (distance: Int, operations: [MLTCharEditOperation]) {
        let m = str1.count
        let n = str2.count
        let str1Array = Array(str1)
        let str2Array = Array(str2)
        
        var dp = Array(repeating: Array(repeating: 0, count: n + 1), count: m + 1)
        var operationMatrix = Array(repeating: Array(repeating: "", count: n + 1), count: m + 1)
        
        // 初始化 dp 表
        for i in 0...m {
            dp[i][0] = i
            operationMatrix[i][0] = "delete"
        }
        for j in 0...n {
            dp[0][j] = j
            operationMatrix[0][j] = "insert"
        }

        // 填充 dp 表
        for i in 1...m {
            for j in 1...n {
                if str1Array[i - 1] == str2Array[j - 1] {
                    dp[i][j] = dp[i - 1][j - 1]
                    operationMatrix[i][j] = "none"
                } else if (isDigit(str1Array[i - 1]) && isDigit(str2Array[j - 1])) || (!isDigit(str1Array[i - 1]) && !isDigit(str2Array[j - 1])) {
                    // 如果都是数字或者都不是数字，允许替换
                    let delete = dp[i - 1][j] + 1
                    let insert = dp[i][j - 1] + 1
                    let replace = dp[i - 1][j - 1] + 1
                    
                    dp[i][j] = min(delete, min(insert, replace))
                    
                    if dp[i][j] == replace {
                        operationMatrix[i][j] = "replace"
                    } else if dp[i][j] == delete {
                        operationMatrix[i][j] = "delete"
                    } else {
                        operationMatrix[i][j] = "insert"
                    }
                } else {
                    // 如果一个是数字，另一个不是，必须删除并插入
                    let deleteInsert = dp[i - 1][j - 1] + 2
                    let delete = dp[i - 1][j] + 1
                    let insert = dp[i][j - 1] + 1
                    
                    dp[i][j] = min(deleteInsert, min(delete, insert))
                    
                    if dp[i][j] == deleteInsert {
                        operationMatrix[i][j] = "deleteInsert"
                    } else if dp[i][j] == delete {
                        operationMatrix[i][j] = "delete"
                    } else {
                        operationMatrix[i][j] = "insert"
                    }
                }
            }
        }

        // 反向追踪操作步骤
        var operations: [MLTCharEditOperation] = []
        var i = m
        var j = n
        
        while i > 0 || j > 0 {
            let operation = operationMatrix[i][j]
            if operation == "replace" {
                operations.append(.replace(oldChar: str1Array[i - 1], newChar: str2Array[j - 1], index: i - 1))
                i -= 1
                j -= 1
            } else if operation == "deleteInsert" {
                operations.append(.delete(char: str1Array[i - 1], index: i - 1))
                operations.append(.insert(char: str2Array[j - 1], index: j - 1))
                i -= 1
                j -= 1
            } else if operation == "delete" {
                operations.append(.delete(char: str1Array[i - 1], index: i - 1))
                i -= 1
            } else if operation == "insert" {
                operations.append(.insert(char: str2Array[j - 1], index: j - 1))
                j -= 1
            } else {
                i -= 1
                j -= 1
            }
        }
        
        return (dp[m][n], operations.reversed())
    }

    private func setupUserInterface() {
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }
    
    private lazy var stackView = {
        let stack = UIStackView()
        stack.spacing = 0
        stack.axis = .horizontal
        return stack
    }()
}

extension Array {
    mutating func insertSafely(_ element: Element, at index: Int) {
        if index <= count {
            insert(element, at: index)
        } else {
            print("Error: Index \(index) is out of bounds for inserting element.")
        }
    }

    mutating func removeSafely(at index: Int) {
        if indices.contains(index) {
            remove(at: index)
        } else {
            print("Error: Index \(index) is out of bounds for removing element.")
        }
    }

    subscript(safely index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
