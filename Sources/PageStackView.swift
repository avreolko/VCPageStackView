//
//  PageStackView.swift
//  EasyFit
//
//  Created by Valentin Cherepyanko on 09.03.2020.
//  Copyright © 2020 Valentin Cherepyanko. All rights reserved.
//

#if canImport(UIKit)

import UIKit

final public class PageStackView: UIStackView {

    struct Settings {
        static let animationDuration: Double = 0.3
        static let scale: CGFloat = 0.8
        static let axisTransition: CGFloat = 100
    }

    enum Direction {
        case up, down, left, right

        var reverse: Direction {
            switch self {
            case .up: return .down
            case .down: return .up
            case .left: return .right
            case .right: return .left
            }
        }
    }

    private var selectedIndex: Int = 0

    private let transitionMap: [Direction: (x: CGFloat, y: CGFloat)] = [
        .up:    (0, Settings.axisTransition),
        .down:  (0, -Settings.axisTransition),
        .right: (Settings.axisTransition, 0),
        .left:  (-Settings.axisTransition, 0),
    ]

    public override func addArrangedSubview(_ view: UIView) {
        super.addArrangedSubview(view)
        self.select(index: self.arrangedSubviews.count - 1, animated: false)
    }

    public func select(index: Int, animated: Bool = true) {

        guard index < self.arrangedSubviews.count else { return }
        guard index != self.selectedIndex else { return }

        defer { self.selectedIndex = index }

        let viewToHide = self.arrangedSubviews[self.selectedIndex]
        let viewToShow = self.arrangedSubviews[index]

        guard animated else {
            viewToShow.isHidden = false
            viewToShow.alpha = 1
            viewToHide.isHidden = true
            viewToHide.alpha = 0
            return
        }

        let direction = self.direction(for: index)
        self.fadeIn(viewToHide, to: direction) { self.fadeOut(viewToShow, from: direction.reverse) }
        self.hide(viewToHide) { self.show(viewToShow) }
    }
}

private extension PageStackView {

    func direction(for index: Int) -> Direction {
        switch (self.axis, self.selectedIndex < index) {
        case (.vertical, true): return .down
        case (.vertical, false): return .up
        case (.horizontal, true): return .left
        case (.horizontal, false): return .right
        default: fatalError()
        }
    }

    func hide(_ view: UIView, completion: @escaping () -> Void) {
        view.alpha = 1
        self.animate({
            view.alpha = 0
        }) {
            view.isHidden = true
            completion()
        }
    }

    func show(_ view: UIView) {
        view.alpha = 0
        view.isHidden = false
        self.animate { view.alpha = 1 }
    }

    func fadeIn(_ view: UIView,
                to direction: Direction,
                completion: @escaping () -> Void) {

        self.animate({
            let transition = self.transitionMap[direction]!

            view.transform = CGAffineTransform
                .identity
                .translatedBy(x: transition.x, y: transition.y)
                .scaledBy(x: Settings.scale, y: Settings.scale)
        }, completion: completion)
    }

    func fadeOut(_ view: UIView, from direction: Direction) {

        let transition = self.transitionMap[direction]!
        view.transform = CGAffineTransform
            .identity
            .translatedBy(x: transition.x, y: transition.y)
            .scaledBy(x: Settings.scale, y: Settings.scale)

        self.animate {
            view.transform = CGAffineTransform.identity
        }
    }
}

// MARK: - utility
private extension PageStackView {
    func animate(_ animation: @escaping () -> Void) {
        self.animate(animation, completion: nil)
    }

    func animate(_ animation: @escaping () -> Void, completion: (() -> Void)?) {
        UIView.animate(withDuration: Settings.animationDuration,
                       delay: 0,
                       options: .curveEaseOut,
                       animations: animation,
                       completion: { _ in completion?() })
    }
}

#endif
