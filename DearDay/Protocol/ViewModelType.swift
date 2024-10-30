//
//  ViewModelType.swift
//  DearDay
//
//  Created by Jaehui Yu on 10/30/24.
//

import Foundation
import Combine

protocol ViewModelType: AnyObject, ObservableObject {
    // AnyObject: 해당 프로토콜이 클래스에서만 사용될 것임
    // ObservableObject: ObservableObject 대상이 되는 경우에만 사용될 것임
    var cancellables: Set<AnyCancellable> { get set }
    associatedtype Input
    associatedtype Output
    var input: Input { get set }
    var output: Output { get set }
    func transform()
}
