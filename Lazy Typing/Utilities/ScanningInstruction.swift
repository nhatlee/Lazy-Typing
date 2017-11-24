//
//  ScanningInstruction.swift
//  Lazy Typing
//
//  Created by nhatlee on 11/22/17.
//  Copyright © 2017 nhatlee. All rights reserved.
//

import Foundation
import UIKit
import Instructions

class ScanningInstruction: CoachMarksControllerDataSource, CoachMarksControllerDelegate {
    weak var findingView: UIView!
    weak var btnCapture: UIButton!
    weak var slider: UISlider!
    unowned let viewController: UIViewController
    
    let findTextInstruction = "Move This area to your text numbers"
     let nextButtonText = "OKie!"
    let sliderTextInstr = "Move this slider to zoom in/out the camera"
    let captureButtonText = "Then Press this button to capture the text numbers"
    
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
        return 3
    }
    
    public func coachMarksController(_ coachMarksController: CoachMarksController,
                                     coachMarkAt index: Int) -> CoachMark {
        switch index {
        case 0:
            return coachMarksController.helper.makeCoachMark(for: findingView)
        case 1:
            return coachMarksController.helper.makeCoachMark(for: slider)
        case 2:
            return coachMarksController.helper.makeCoachMark(for: btnCapture)
//        case 3:
//            return coachMarksController.helper.makeCoachMark(for: showPianoBtn)
        default:
            return coachMarksController.helper.makeCoachMark()
        }
    }
    
    public func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark
        ) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation, hintText: findTextInstruction, nextText: nextButtonText)
        coachViews.bodyView.hintLabel.textColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        coachViews.bodyView.nextLabel.textColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        switch(index) {
        case 0:
            coachViews.bodyView.hintLabel.text = findTextInstruction
            coachViews.bodyView.nextLabel.text = nextButtonText
        case 1:
            coachViews.bodyView.hintLabel.text = sliderTextInstr
            coachViews.bodyView.nextLabel.text = nextButtonText
        case 2:
            coachViews.bodyView.hintLabel.text = captureButtonText
            coachViews.bodyView.nextLabel.text = nextButtonText
        default: break
        }
        
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
    
    //MARK: -CoachMarksControllerDelegate
    public func coachMarksController(_ coachMarksController: CoachMarksController, didHide coachMark: CoachMark, at index: Int) {
        UserDefaults.standard.set(true, forKey: Keys.userPressInstructionScaning)
    }
}
