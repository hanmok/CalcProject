//
//  CustomNumberPadController.swift
//  Calie
//
//  Created by Mac mini on 2022/05/04.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import UIKit
import SnapKit
import Then
import AudioToolbox

protocol CustomNumberPadDelegate: AnyObject {
    
    ///  "완료"
    func numberPadViewShouldReturn()
    
    /// number
    func numberPadView(updateWith numTextInput: String) // include delete Action

    func completeAction()
}

class CustomNumberPadController: UIViewController {
    
    let colorList = ColorList()
    
    public var numberText = "0" {
        didSet {
            numberText.applyNumberFormatter()
        }
    }
    
    var deletionTerm = 0.5
    let deletionPausedAt = 2.35
    let deletionTimeForInitialState = 2.5
    
    var deletionForFasterTrigger = Timer()
    var deletionTimerForPause = Timer()
    var deletionTimerForInitialSetup = Timer()
    var deletionTimerForFaster = Timer()
    static let colorList = ColorList()
    
    weak var numberPadDelegate: CustomNumberPadDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.frame = CGRect(x: 0, y: 0, width: UIScreen.width, height: 370)
        
        setupLayout()
        setupAddTargets()
        view.backgroundColor = .blue
    }
    
    
    
    
    private let num0 = NumberButton("0")
    private let num00 = NumberButton("00")
    private let num000 = NumberButton("000")
    private let num1 = NumberButton("1")
    private let num2 = NumberButton("2")
    private let num3 = NumberButton("3")
    private let num4 = NumberButton("4")
    private let num5 = NumberButton("5")
    private let num6 = NumberButton("6")
    private let num7 = NumberButton("7")
    private let num8 = NumberButton("8")
    private let num9 = NumberButton("9")
    
    private let deleteBtn = UIButton()

    
    private let deleteImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.tintColor = .black
        $0.image = UIImage(systemName: "delete.left")
    }
    
    
    private let inputBar = UIView().then {
        $0.backgroundColor = UIColor.bgColorForExtrasMiddle
    }
    
    private let completeBtn = UIButton().then {
        $0.backgroundColor = .bgColorForExtrasLM
    }
    
    private let completeLabel = UILabel().then {
        $0.text = "완료"
        $0.textAlignment = .center
        $0.textColor = UIColor.black
    }
    
    private func setupAddTargets() {
        [num7, num8, num9,
         num4, num5, num6,
        num1, num2, num3,
        num0, num00, num000
        ].forEach { $0.addTarget(self, action: #selector(appendToNumberText(_:)), for: .touchUpInside)
            
            $0.addTarget(self, action: #selector(changeColor(_:)), for: .touchDown)
            
            $0.addTarget(self, action: #selector(turnIntoOriginalColor(_:)), for: .touchUpInside)
            
            $0.addTarget(self, action: #selector(turnIntoOriginalColor(_:)), for: .touchDragExit)
            $0.addTarget(self, action: #selector(makeBtnSound), for: .touchDown)
        }
        
        completeBtn.addTarget(self, action: #selector(completeTapped(_:)), for: .touchUpInside)
        
        
        
        deleteBtn.addTarget(self, action: #selector(deleteTapped(_:)), for: .touchUpInside)

        deleteBtn.addTarget(self, action: #selector(applyTappedView(_:)), for: .touchDown)
        
        deleteBtn.addTarget(self, action: #selector(applyTappedView(_:)), for: .touchUpInside)
        
        deleteBtn.addTarget(self, action: #selector(applyOriginalDeleteView(_:)), for: .touchDragExit)
        
        // Detail Delete action
        deleteBtn.addTarget(self, action: #selector(handleDeletePressedDown), for: .touchDown)
        
        deleteBtn.addTarget(self, action: #selector(handleDeleteTapped), for: .touchUpInside)
        deleteBtn.addTarget(self, action: #selector(handleDeleteDragOutAction), for: .touchDragExit)
        
        deleteBtn.addTarget(self, action: #selector(turnIntoOriginalColor), for: .touchUpInside)
        
        deleteBtn.addTarget(self, action: #selector(turnIntoOriginalColor), for: .touchDragExit)
    }
    
    @objc func handleDeleteDragOutAction(sender : UIButton){ // deleteDragOut
        invalidateAllTimers()
    }
    
    
    @objc func didDragOutDelete() {
        
        invalidateAllTimers()
    }
    
    
    @objc func handleDeletePressedDown(sender : UIButton){

        if deletionTerm == 0.5 {
            deleteAction()
        }
        
        // after 0.5s, make deleteSpeed 0.1 (5times faster)
        deletionForFasterTrigger = Timer.scheduledTimer(timeInterval: deletionTerm, target: self, selector: #selector(deleteFaster), userInfo: nil, repeats: false)
        // pauseDelete
        deletionTimerForPause = Timer.scheduledTimer(timeInterval: deletionPausedAt, target: self, selector: #selector(pauseDelete), userInfo: nil, repeats: false)
        //initialSetup
        deletionTimerForInitialSetup = Timer.scheduledTimer(timeInterval: deletionTimeForInitialState, target: self, selector: #selector(didPressedDeleteLong), userInfo: nil, repeats: false)
    }
    
    @objc func handleDeleteTapped(sender : UIButton){
        invalidateAllTimers()
        deletionTerm = 0.5
    }
    
    @objc public func didPressedDeleteLong() { // initialSetup
//        clear()
        numberText = ""
        
        deletionTerm = 0.5
        
        deletionForFasterTrigger.invalidate()
        deletionTimerForFaster.invalidate()
        deletionTimerForInitialSetup.invalidate()
    }
    
    private func invalidateAllTimers() {
        deletionForFasterTrigger.invalidate()
        deletionTimerForFaster.invalidate()
        deletionTimerForPause.invalidate()
        deletionTimerForInitialSetup.invalidate()
    }
    
    @objc func deleteFaster() {
        deletionTerm = 0.1
        deletionTimerForFaster = Timer.scheduledTimer(timeInterval: deletionTerm, target: self, selector: #selector(deleteTapped(_:)), userInfo: nil, repeats: true)
    }
    
    @objc func pauseDelete(){
        deletionForFasterTrigger.invalidate()
        deletionTimerForFaster.invalidate()
    }
    
    @objc func changeColor(_ sender: NumberButton) {

        sender.backgroundColor = colorList.bgColorForExtrasLM
    }
    
    @objc func makeBtnSound() {
        AudioServicesPlaySystemSound(1104)
    }
    
    @objc func turnIntoOriginalColor(_ sender: UIButton) {
        if sender is NumberButton {
            sender.backgroundColor = .black
        } else { // delete btn
            //            print("deleteBtn tapped")
            DispatchQueue.main.async {
                self.deleteImageView.image = UIImage(systemName: "delete.left")
            }
        }
    }
    
    @objc func completeTapped(_ sender: UIButton) {
        print("complete Tapped!!1")
        numberPadDelegate?.completeAction()
        
        numberPadDelegate?.numberPadViewShouldReturn()
        numberText = ""
    }
    
    
    @objc func applyTappedView(_ sender: UIButton) {
        applyTappedState()
    }
    
    private func applyTappedState() {
        DispatchQueue.main.async {
            self.deleteImageView.image = UIImage(systemName: "delete.left.fill")
        }
    }
    
    @objc func applyOriginalDeleteView(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.deleteImageView.image = UIImage(systemName: "delete.left")
        }
    }
    
    
    @objc func deleteTapped(_ sender: UIButton) {
        print("delete Tapped!!2")
        deleteAction()
    }
    
    private func deleteAction() {
        
        if numberText != "" {
            makeBtnSound()
            numberText.removeLast()
        }
        
        numberPadDelegate?.numberPadView(updateWith: numberText)
        
        applyTappedState()
//        deleteImageView.image = UIImage(systemName: "delete.left.fill")
//        applyTappedView(<#T##sender: UIButton##UIButton#>)
    }
    
    
    @objc func appendToNumberText(_ sender: NumberButton) {
        print("tapped Btn wrapper: \(sender.wrapperString)")
        numberText += sender.wrapperString
//        if numberText
        // FIXME: Test..
        numberText = numberText.replacingOccurrences(of: ".", with: ",")
        print("numberText:\(numberText)")
        
        numberPadDelegate?.numberPadView(updateWith: numberText)
        // update textFields belong to Controllers which conforms NumberPadDelegate
    }
    
    private func setupLayout() {
        
        view.addSubview(inputBar)
        inputBar.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
            make.top.equalToSuperview()
        }
        
        [
         deleteBtn].forEach { self.inputBar.addSubview($0) }
    
        deleteBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.width.equalToSuperview().dividedBy(3)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        deleteBtn.addSubview(deleteImageView)
        deleteImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().dividedBy(1.7)
            make.height.equalToSuperview().dividedBy(1.7)
        }
        
        let hor3Stack = UIStackView(arrangedSubviews: [num7, num8, num9])
        let hor2Stack = UIStackView(arrangedSubviews: [num4, num5, num6])
        let hor1Stack = UIStackView(arrangedSubviews: [num1, num2, num3])
        let hor0Stack = UIStackView(arrangedSubviews: [num0, num00, num000])
        
        [hor0Stack, hor1Stack, hor2Stack, hor3Stack].forEach {
            view.addSubview($0)
            $0.distribution = .fillEqually
            $0.spacing = 0
            $0.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(60)
            }
        }
        
        hor3Stack.snp.makeConstraints { make in
            make.top.equalTo(deleteBtn.snp.bottom)
        }
        
        hor2Stack.snp.makeConstraints { make in
            make.top.equalTo(hor3Stack.snp.bottom)
        }
        
        hor1Stack.snp.makeConstraints { make in
            make.top.equalTo(hor2Stack.snp.bottom)
        }
        
        hor0Stack.snp.makeConstraints { make in
            make.top.equalTo(hor1Stack.snp.bottom)
        }
        
        
        // The bottom
        view.addSubview(completeBtn)
        completeBtn.snp.makeConstraints { make in
            make.top.equalTo(hor0Stack.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(70)
        }
        
        completeBtn.addSubview(completeLabel)
        completeLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalToSuperview().offset(5)
            make.height.equalTo(40)
        }
    }
    
    private func setupLayoutBottom() {

        let hor3Stack = UIStackView(arrangedSubviews: [num7, num8, num9])
        let hor2Stack = UIStackView(arrangedSubviews: [num4, num5, num6])
        let hor1Stack = UIStackView(arrangedSubviews: [num1, num2, num3])
        let hor0Stack = UIStackView(arrangedSubviews: [num0, num00, num000])
        
        [hor0Stack, hor1Stack, hor2Stack, hor3Stack].forEach {
            view.addSubview($0)
            $0.distribution = .fillEqually
            $0.spacing = 0
            $0.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(60)
            }
        }
        // The bottom
        view.addSubview(completeBtn)
        completeBtn.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(70)
        }
        
        
        hor0Stack.snp.makeConstraints { make in
            make.bottom.equalTo(completeBtn.snp.top)
        }
        hor1Stack.snp.makeConstraints { make in
            make.bottom.equalTo(hor0Stack.snp.top)
        }
        hor2Stack.snp.makeConstraints { make in
            make.bottom.equalTo(hor1Stack.snp.top)
        }
        hor3Stack.snp.makeConstraints { make in
            make.bottom.equalTo(hor2Stack.snp.top)
        }
        
        view.addSubview(inputBar)
        inputBar.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
            make.bottom.equalTo(hor3Stack.snp.top)
        }
        
        inputBar.addSubview(deleteBtn)
        deleteBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.width.equalTo(60)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
