//
//  PopUpInstruction.swift
//  Lazy Typing
//
//  Created by nhatlee on 11/22/17.
//  Copyright © 2017 nhatlee. All rights reserved.
//

import Foundation
import UIKit
import Instructions

class PopUpInstruction: CoachMarksControllerDataSource, CoachMarksControllerDelegate {
    weak var btnCopy: UIButton!
    unowned let viewController: UIViewController
    let copyTextInstruction = "Press this button if the numbers you were captured is phone card. Just use for Phone number at Viet Nam!"
    let nextButtonText = "OKie!"
    
    
    //MARK: - Private properties
    private var coachMarksController: CoachMarksController!
    
    init(parentViewController viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func startTour() {
        self.coachMarksController = CoachMarksController()
        self.coachMarksController.overlay.allowTap = true
        self.coachMarksController.dataSource = self
        self.coachMarksController.delegate = self
        self.coachMarksController.start(on: viewController)
    }
    
    //MARK: - CoachMarksControllerDataSource
    public func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 1
    }
    
    public func coachMarksController(_ coachMarksController: CoachMarksController,
                                     coachMarkAt index: Int) -> CoachMark {
        switch index {
        case 0:
            return coachMarksController.helper.makeCoachMark(for: btnCopy)
        
        default:
            return coachMarksController.helper.makeCoachMark()
        }
    }
    
    public func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark
        ) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation, hintText: copyTextInstruction, nextText: nextButtonText)
        coachViews.bodyView.hintLabel.textColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        coachViews.bodyView.nextLabel.textColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        switch(index) {
        case 0:
            coachViews.bodyView.hintLabel.text = copyTextInstruction
            coachViews.bodyView.nextLabel.text = nextButtonText
        
        default: break
        }
        
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
    
    //MARK: -CoachMarksControllerDelegate
    public func coachMarksController(_ coachMarksController: CoachMarksController, didHide coachMark: CoachMark, at index: Int) {
        UserDefaults.standard.set(true, forKey: Keys.userPressInstructionPopup)
    }
}
