/*
   Copyright 2017 Ryuichi Saito, LLC and the Yanagiba project contributors

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

import Source
import AST

protocol TTYASTDumpRepresentable {
  var ttyDump: String { get }

  func dump(_ nodeType: String, _ sourceRange: SourceRange) -> String
  func dump(_ exprs: ExpressionList) -> String
  func dump(_ funcSign: FunctionSignature) -> String
  func dump(_ funcResult: FunctionResult) -> String
  func dump(_ condition: Condition) -> String
  func dump(_ conditionList: ConditionList) -> String
  func dump(_ inits: [PatternInitializer]) -> String
  func dump(_ patternInit: PatternInitializer) -> String
}

extension TTYASTDumpRepresentable {
  func dump(_ nodeType: String, _ sourceRange: SourceRange) -> String {
    return nodeType.colored(with: .magenta) + " " +
      "<range: \(sourceRange.ttyDescription)>".colored(with: .yellow)
  }

  func dump(_ exprs: ExpressionList) -> String {
    return exprs.enumerated()
      .map { "\($0): \($1.ttyDump)" }
      .joined(separator: "\n")
  }

  func dump(_ funcSign: FunctionSignature) -> String {
    var dumps: [String] = []
    if !funcSign.parameterList.isEmpty {
      let paramsDump = "parameters:\n" + funcSign.parameterList.enumerated()
        .map { "\($0): \($1.textDescription)" }
        .joined(separator: "\n")
      dumps.append(paramsDump)
    }
    if funcSign.throwsKind != .nothrowing {
      dumps.append("throws_kind: `\(funcSign.throwsKind.textDescription)`")
    }
    if let result = funcSign.result {
      dumps.append(dump(result))
    }
    return dumps.joined(separator: "\n")
  }

  func dump(_ funcResult: FunctionResult) -> String {
    let typeDump = "return_type: `\(funcResult.type.textDescription)`"
    if funcResult.attributes.isEmpty {
      return typeDump
    }
    return "\(typeDump) with attributes `\(funcResult.attributes.textDescription)`"
  }

  func dump(_ conditions: ConditionList) -> String {
    return "conditions:\n" + conditions.enumerated()
      .map { "\($0): \(dump($1))" }
      .joined(separator: "\n")
  }

  func dump(_ condition: Condition) -> String {
    switch condition {
    case .expression(let expr):
      return expr.ttyDump
    case .availability(let availabilityCondition):
      return availabilityCondition.textDescription
    case let .case(pattern, expr):
      return "case_binding: `\(pattern)`\n\(expr.ttyDump.indent)"
    case let .let(pattern, expr):
      return "constant_optional_binding: `\(pattern)`\n\(expr.ttyDump.indent)"
    case let .var(pattern, expr):
      return "variable_optional_binding: `\(pattern)`\n\(expr.ttyDump.indent)"
    }
  }

  func dump(_ inits: [PatternInitializer]) -> String {
    switch inits.count {
    case 0:
      return "<no_pattern_initializers>" // Note: this should never happen
    case 1:
      return dump(inits[0])
    default:
      return "pattern_initializers:\n" + inits.enumerated()
        .map { "\($0): \(dump($1))" }
        .joined(separator: "\n")
    }
  }

  func dump(_ patternInit: PatternInitializer) -> String {
    let patternDump = "pattern: \(patternInit.pattern.textDescription)"
    guard let initExpr = patternInit.initializerExpression else {
      return patternDump
    }
    return "\(patternDump)\n\(initExpr.ttyDump.indent)"
  }
}
