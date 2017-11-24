//
//  PopupVC.swift
//  Lazy Typing
//
//  Created by nhatlee on 11/22/17.
//  Copyright © 2017 nhatlee. All rights reserved.
//

import UIKit

class PopupVC: UIViewController {
    var recognizeString: String?
    
    @IBOutlet weak var btnCopyToClipboard: UIButton!
    private var instruction: PopUpInstruction!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (UserDefaults.standard.value(forKey: Keys.userPressInstructionPopup) == nil){
            setupInstruction()
        }
    }
    
    private func setupInstruction() {
        instruction = PopUpInstruction(parentViewController: self)
        instruction.btnCopy = btnCopyToClipboard
        instruction.startTour()
    }

    @IBAction func copyToClipboard(_ sender: Any) {
        guard let stringNumber = recognizeString else {return}
        //User can paste this number to anywhere they want
        UIPasteboard.general.string = stringNumber
        //Call card number
        let phoneCard = "*100*\(stringNumber)#"
        let callNo = "telprompt://\(phoneCard)"
        guard let url = URL(string:callNo) else { return }
        UIApplication.shared.openURL(url)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
