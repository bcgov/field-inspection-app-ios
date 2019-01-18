//
//  AsyncOperation.swift
//  EAO
//
//  Created by Evgeny Yagrushkin on 2019-01-07.
//  Copyright © 2019 Province of British Columbia. All rights reserved.
//

import Foundation

open class AsyncOperation: Operation {
    
    public enum State {
        case ready
        case executing
        case finished
        
        fileprivate var key: String {
            switch self {
            case .ready:
                return "isReady"
            case .executing:
                return "isExecuting"
            case .finished:
                return "isFinished"
            }
        }
    }
    
    private(set) public var state = State.ready {
        willSet {
            willChangeValue(forKey: state.key)
            willChangeValue(forKey: newValue.key)
        }
        didSet {
            didChangeValue(forKey: oldValue.key)
            didChangeValue(forKey: state.key)
        }
    }
    
    final override public var isAsynchronous: Bool {
        return true
    }
    
    final override public var isExecuting: Bool {
        return state == .executing
    }
    
    final override public var isFinished: Bool {
        return state == .finished
    }
    
    final override public var isReady: Bool {
        return state == .ready
    }
    
    final public func finished() {
        state = .finished
    }
    
    override open func start() {
        state = .executing
        execute()
    }
    
    open func execute() {
        state = .finished
    }
}
