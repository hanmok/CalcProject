//
//  ResultViewController.swift
//  Calie
//
//  Created by Mac mini on 2022/07/18.
//  Copyright © 2022 Mac mini. All rights reserved.
//

// MARK: - 원 이 너무 많음. 화면에 따로 '단위: 원' 써주고, 금액만 써주는게 좋을 것 같아.

import Foundation
import UIKit
import SnapKit
import AudioToolbox
// cameraShutter: 1108


class ResultViewController: UIViewController {
    
    // MARK: - show toast
    let fontSize = FontSizes()
    let frameSize = FrameSizes()
    var userDefaultSetup = UserDefaultSetup()
    let localizedStrings = LocalizedStringStorage()
    
    private let indicator = UIActivityIndicatorView()
    
    var gathering: Gathering
    
    var viewModel: ResultViewModel

    let briefRowHeight: CGFloat = 65 // prev: 80
    let calculatedRowHeight: CGFloat = 50
    let headerHeight: CGFloat = 50
    
    var textToCopy = ""
    
    var addingDelegate: AddingUnitControllerDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppUtility.lockOrientation(.portrait)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AppUtility.lockOrientation(.all)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerTableView()
        setupLayout()
        setupAddTargets()
        
        view.backgroundColor = .white
    }
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isScrollEnabled = true
        scrollView.showsVerticalScrollIndicator = false
//        scrollView.backgroundColor = .magenta
        scrollView.backgroundColor = .white
        return scrollView
    }()
    
    private let dismissBtn = UIButton().then {
        
        let imageView = UIImageView(image: UIImage(systemName: "chevron.left")!)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .black
        $0.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        
    }
    
    private let takingCaptureBtn = UIButton().then {
        let imageView = UIImageView(image: UIImage(systemName: "camera.viewfinder")!)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .black
        $0.addSubview(imageView)
        
//        $0.backgroundColor = .magenta
        
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        }
    }
    
    private let copyBtn = UIButton().then {
        let imageView = UIImageView(image: UIImage(systemName: "doc.on.doc.fill")!)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .black
        $0.addSubview(imageView)
        
//        $0.backgroundColor = .cyan
        
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        }
    }
    
    private let briefHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.width - 16, height: 50)).then {
        
        let infoLabel = UILabel().then {
            $0.attributedText = NSAttributedString(string: "개인별 지출 현황", attributes: [.font: UIFont.systemFont(ofSize: 22, weight: .regular)])
        }
        
        $0.addSubview(infoLabel)
        infoLabel.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        let bottomLineView = UIView().then {
            $0.backgroundColor = UIColor(white: 0.25, alpha: 0.9)
            $0.layer.cornerRadius = 2
            $0.clipsToBounds = true
        }
        
        infoLabel.addSubview(bottomLineView)
        bottomLineView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(3)
        }
    }
    
    private let calculatedResultHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.width - 100, height: 50)).then {
        
        let infoLabel = UILabel().then {
            $0.attributedText = NSAttributedString(string: "정산 결과", attributes: [.font: UIFont.systemFont(ofSize: 26, weight: .regular)])
        }
        
        $0.addSubview(infoLabel)
        infoLabel.snp.makeConstraints { make in
//            make.leading.top.trailing.bottom.equalToSuperview()
            make.leading.top.trailing.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        
        let bottomLineView = UIView().then {
            $0.backgroundColor = UIColor(white: 0.25, alpha: 0.9)
            $0.layer.cornerRadius = 2
            
            $0.clipsToBounds = true
        }
        
        infoLabel.addSubview(bottomLineView)
        bottomLineView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(5)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        let calculatedTableHeight: CGFloat = CGFloat(viewModel.calculatedResultTuples.count * Int(self.calculatedRowHeight) + Int(self.headerHeight))
        let personalTableHeight: CGFloat = CGFloat(viewModel.overallPayInfos.count * Int(self.briefRowHeight) + Int(self.headerHeight))
        
//        scrollView.contentSize = CGSize(width: view.frame.size.width, height: calculatedTableHeight + personalTableHeight + 290)
        
        scrollView.contentSize = CGSize(width: view.frame.size.width, height: calculatedTableHeight + personalTableHeight + 84 + 30 + 30)
        
//        scrollView.contentSize = CGSize(width: 1000, height: 3000)
    }
    
    private func setupLayout() {
        
        view.addSubview(scrollView)

        scrollView.snp.makeConstraints { make in
            make.leading.top.trailing.bottom.equalToSuperview()
        }
        

        [
            dismissBtn, titleLabel, takingCaptureBtn, copyBtn,
            briefInfoTableView,
//            dividerView,
            calculatedInfoTableView
        ].forEach { self.scrollView.addSubview($0)}
        
        scrollView.isScrollEnabled = true
        
        dismissBtn.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.leading.equalToSuperview().offset(10)
            make.width.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(50)
            make.centerY.equalTo(dismissBtn.snp.centerY)
        }
        
        
        takingCaptureBtn.snp.makeConstraints { make in
            make.centerY.equalTo(dismissBtn.snp.centerY)
            make.leading.equalToSuperview().offset(screenWidth - 50)
            make.width.height.equalTo(30)
        }
        
        copyBtn.snp.makeConstraints { make in
            make.centerY.equalTo(dismissBtn.snp.centerY)
            make.trailing.equalTo(takingCaptureBtn.snp.leading).offset(-10)
            make.width.height.equalTo(24)
        }
    
        calculatedInfoTableView.snp.makeConstraints { make in
            make.top.equalTo(dismissBtn.snp.bottom).offset(30)
            make.leading.equalTo(scrollView.snp.leading).offset(16)
            make.width.greaterThanOrEqualTo(scrollView.snp.width).offset(-32)
            make.height.equalTo(viewModel.calculatedResultTuples.count * Int(self.calculatedRowHeight) + Int(self.headerHeight))
        }
        
        briefInfoTableView.snp.makeConstraints { make in
            make.leading.equalTo(scrollView.snp.leading).offset(16)
            make.width.greaterThanOrEqualTo(scrollView.snp.width).offset(-32)
            make.top.equalTo(calculatedInfoTableView.snp.bottom).offset(40)
            make.height.equalTo(viewModel.overallPayInfos.count * Int(self.briefRowHeight) + Int(self.headerHeight))
        }
    }
    
    private func setupAddTargets() {
        dismissBtn.addTarget(self, action: #selector(dismissTapped), for: .touchUpInside)
        
        copyBtn.addTarget(self, action: #selector(copyBtnTapped(_:)), for: .touchUpInside)
        takingCaptureBtn.addTarget(self, action: #selector(captureBtnTapped(_:)), for: .touchUpInside)
    }
    
    @objc func copyBtnTapped(_ sender: UIButton) {
        print("copy Btn Tapped")
        
        UIPasteboard.general.string = textToCopy
        // FIXME: TEXT 크기가 너무 작음;; 나중에 수정하자아
        self.toastHelper(msg: self.localizedStrings.copyComplete, wRatio: 0.5, hRatio: 0.06)
    }
    
    @objc func captureBtnTapped(_ sender: UIButton) {
        print("capture Btn Tapped")
//        indicator.startAnimating()
        saveScrollViewImage()
    }
    
    @objc func dismissTapped(_ sender: UIButton) {
        addingDelegate?.dismissChildVC()
        self.navigationController?.popViewController(animated: true)
    }
    
    init(gathering: Gathering) {
        self.gathering = gathering
        self.viewModel = ResultViewModel(gathering: gathering)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Properties
    
    private let titleLabel = UILabel().then {
        $0.text = "정산 결과"
        $0.textAlignment = .center
        $0.textColor = .black
        $0.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
    }
    
    private let dividerView = UIView()
    
    private let briefInfoTableView = UITableView().then {
        $0.isScrollEnabled = false
    }
    
    private let calculatedInfoTableView = UITableView().then {
        $0.isScrollEnabled = false
    }
    
    
    private func registerTableView() {
        briefInfoTableView.register(ResultBriefInfoTableCell.self, forCellReuseIdentifier: ResultBriefInfoTableCell.identifier)
        briefInfoTableView.delegate = self
        briefInfoTableView.dataSource = self
        briefInfoTableView.rowHeight = self.briefRowHeight
        briefInfoTableView.separatorStyle = .singleLine
        
        briefInfoTableView.tableHeaderView = briefHeaderView
        
        calculatedInfoTableView.register(CalculatedResultTableCell.self, forCellReuseIdentifier: CalculatedResultTableCell.identifier)
        calculatedInfoTableView.delegate = self
        calculatedInfoTableView.dataSource = self
        calculatedInfoTableView.rowHeight = self.calculatedRowHeight
        calculatedInfoTableView.separatorStyle = .none
        
        calculatedInfoTableView.tableHeaderView = calculatedResultHeaderView
    }
}


extension ResultViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == briefInfoTableView {
            return viewModel.overallPayInfos.count
        } else if tableView == calculatedInfoTableView {
            textToCopy = ""
            return viewModel.calculatedResultTuples.count
        }
        
        return 0
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == briefInfoTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: ResultBriefInfoTableCell.identifier, for: indexPath) as! ResultBriefInfoTableCell
            cell.personCostInfo = viewModel.overallPayInfos[indexPath.row]
            cell.isUserInteractionEnabled = false
            return cell
            
            
        } else if tableView == calculatedInfoTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: CalculatedResultTableCell.identifier, for: indexPath) as! CalculatedResultTableCell
            cell.isUserInteractionEnabled = false
            
            cell.exchangeInfo = viewModel.calculatedResultTuples[indexPath.row]
            print("cell.exchangeInfo: \(cell.exchangeInfo)")
            let correspondingText = convertExchangeInfoIntoString(exchangeInfo: viewModel.calculatedResultTuples[indexPath.row])
            textToCopy += correspondingText
            return cell
        }
      
        return UITableViewCell()
    }
    
    func convertExchangeInfoIntoString(exchangeInfo: ResultTupleWithName) -> String {
        
        let (from, to, amt) = exchangeInfo
        
        let convertedAmt = amt.convertIntoCurrencyUnit(isKorean: userDefaultSetup.isKorean)
        
        let postPosition = getCorrectPostPosition(from: from)
        
        var ret: String
        
        if userDefaultSetup.isKorean {
         ret = from + postPosition + " " + to + "에게 " + convertedAmt + "을 보내주세요.\n\n"
        } else {
         ret = from + " should send " + convertedAmt + " to " + to
        }
        
        return ret
    }
    
    func getCorrectPostPosition(from name: String) -> String {
    print("josa Testing started ")
        
//    let text = "소방관"
        let text = name
        print("postPosition text: \(text)")
        guard let text = text.last else {  fatalError() }
        let val = UnicodeScalar(String(text))?.value
        guard let value = val else { return "는" }
        
    // 값
        print("value: \(value)")
        print("0xac00: \(0xac00)")
        // 모음 하나만 있는 경우는 어떻게 처리되지 ??
        if value < 0xac00 { return "는" } // 영어인 경우 필터
        let x = (value - 0xac00) / 28 / 21
        let y = ((value - 0xac00) / 28) % 21
        let z = (value - 0xac00) % 28 // 없을 경우 z 는 0
        
//    print("x: \(x), y: \(y), z: \(z)")
//        print(x,y,z)//“안” -> 11 0 4
        
    // 값 -> Character
        
        let i = UnicodeScalar(0x1100 + x) //초성
        let j = UnicodeScalar(0x1161 + y) //중성
        let k = UnicodeScalar(0x11a6 + 1 + z) //종성, 만약 없으면 항상 \u{11A7} 가 나옴
    // 관
    
//        U+1100부터 U+115E까지는 초성, U+1161부터 U+11A7까지는 중성, U+11A8부터 U+11FF까지는 종성
    
        // z == 0 -> 받침 없음 -> '를'  '는'
        // z != 0 -> 받침 있음 -> '을', '은'
        // 은, 는
    
    let appending = z != 0 ? "은" : "는"
        
    // 받침 ㅇ -> 을 이
    // 받침 X ->  를 가
    // 을 / 를
        
    return appending
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.headerHeight
    }
}




extension ResultViewController {
    
    // TODO: Hide nav Views when capture.
    
    func saveScrollViewImage() {
        if let image = snapshot() {
            if let data = image.pngData() {
                let filename = getDocumentsDirectory().appendingPathComponent("copy.png")
                
                do {
                    try data.write(to: filename)
                    let activityController = UIActivityViewController(activityItems: [data], applicationActivities: nil)
                    
//                    indicator.stopAnimating()
                    
                    Timer.scheduledTimer(withTimeInterval: 0.53, repeats: false) { _ in
                        self.present(activityController, animated: true, completion: nil)
                    }

                    
                } catch let error {
                    print("error saving file \(error.localizedDescription)")
                }
            }
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//        print("")
        print("getDocumentsDirectory called")
        return paths[0]
    }
    
    
    private func hideTopViews() {
        dismissBtn.isHidden = true
        titleLabel.isHidden = true
        copyBtn.isHidden = true
        takingCaptureBtn.isHidden = true
    }
    
    private func showTopViews() {
        dismissBtn.isHidden = false
        titleLabel.isHidden = false
        copyBtn.isHidden = false
        takingCaptureBtn.isHidden = false
    }
    
    private func moveUpCollectionViews() {
        
//        calculatedInfoTableView
        
        calculatedInfoTableView.snp.updateConstraints { make in
            make.top.equalTo(dismissBtn.snp.bottom)
            make.leading.equalTo(scrollView.snp.leading).offset(16)
            make.width.greaterThanOrEqualTo(scrollView.snp.width).offset(-32)
            make.height.equalTo(viewModel.calculatedResultTuples.count * Int(self.calculatedRowHeight) + Int(self.headerHeight))
        }
        
        briefInfoTableView.snp.updateConstraints { make in
            make.leading.equalTo(scrollView.snp.leading).offset(16)
            make.width.greaterThanOrEqualTo(scrollView.snp.width).offset(-32)
            make.top.equalTo(calculatedInfoTableView.snp.bottom).offset(40)
            make.height.equalTo(viewModel.overallPayInfos.count * Int(self.briefRowHeight) + Int(self.headerHeight))
        }
    }
    
    private func moveDownCollectionViews() {
        calculatedInfoTableView.snp.updateConstraints { make in
            make.top.equalTo(dismissBtn.snp.bottom).offset(30)
            make.leading.equalTo(scrollView.snp.leading).offset(16)
            make.width.greaterThanOrEqualTo(scrollView.snp.width).offset(-32)
            make.height.equalTo(viewModel.calculatedResultTuples.count * Int(self.calculatedRowHeight) + Int(self.headerHeight))
        }
        
        briefInfoTableView.snp.updateConstraints { make in
            make.leading.equalTo(scrollView.snp.leading).offset(16)
            make.width.greaterThanOrEqualTo(scrollView.snp.width).offset(-32)
            make.top.equalTo(calculatedInfoTableView.snp.bottom).offset(40)
            make.height.equalTo(viewModel.overallPayInfos.count * Int(self.briefRowHeight) + Int(self.headerHeight))
        }
    }
    
    private func updateWithAnimation() {
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func playCaptureSound() {
        AudioServicesPlaySystemSound(1108)
    }
    // TODO: get correct scrollView frame without top infos
    func snapshot() -> UIImage?
    {
        
        
        // update for 0.3s
        
        hideTopViews()
        moveUpCollectionViews()
        updateWithAnimation()

        
        Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { _ in
            self.scrollView.alpha = 0.2
            UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveLinear, .autoreverse]) {
                self.scrollView.alpha = 1.0
                self.playCaptureSound()
            }
        }
          
        
        UIGraphicsBeginImageContext(scrollView.contentSize)
        
        let savedContentOffset = scrollView.contentOffset
        let savedFrame = scrollView.frame
        
        scrollView.contentOffset = CGPoint.zero
        scrollView.frame = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.contentSize.height)
        
        scrollView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        scrollView.contentOffset = savedContentOffset
        scrollView.frame = savedFrame
        
        UIGraphicsEndImageContext()
        
        Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { timer in
            self.showTopViews()
            self.moveDownCollectionViews()
            self.updateWithAnimation()
        }

        
        return image
    }
    
//    func snapshotWithAnimation() -> UIImage?
//    {
//
//        UIView.animate(withDuration: 0.1) {
//            self.hideTopViews()
//            self.moveUpCollectionViews()
//
//            UIView.animate(withDuration: 0.3) {
//                self.view.layoutIfNeeded()
//            }
//
//        } completion: { bool in
//            if bool {
//                UIGraphicsBeginImageContext(self.scrollView.contentSize)
//
//                let savedContentOffset = self.scrollView.contentOffset
//                let savedFrame = self.scrollView.frame
//
//                self.scrollView.contentOffset = CGPoint.zero
//                self.scrollView.frame = CGRect(x: 0, y: 0, width: self.scrollView.contentSize.width, height: self.scrollView.contentSize.height)
//
//                scrollView.layer.render(in: UIGraphicsGetCurrentContext()!)
//                let image = UIGraphicsGetImageFromCurrentImageContext()
//
//                self.scrollView.contentOffset = savedContentOffset
//                self.scrollView.frame = savedFrame
//
//                UIGraphicsEndImageContext()
//
//
//                    self.showTopViews()
//                    self.moveDownCollectionViews()
//
//                UIView.animate(withDuration: 0.3) {
//                    self.view.layoutIfNeeded()
//                }
//
//
//                return image
//            }
//        }
//    }
    
    func snapshot2() -> UIImage?
    {
//        UIGraphicsBeginImageContext(scrollView.contentSize)
//        UIGraphicsBeginImageContext(scrollView.contentSize - 150)
        UIGraphicsBeginImageContext(CGSize(width: scrollView.frame.width, height: scrollView.frame.height - 150))
        
//        let savedContentOffset = scrollView.contentOffset
//        let savedContentOffset = scrollView.contentOffset
        let savedContentOffset = CGPoint(x: 0, y: 150)
//        let savedFrame = scrollView.frame
        let savedFrame = CGRect(x: 0, y: 150, width: scrollView.frame.width, height: scrollView.frame.height - 150)
        
//        scrollView.contentOffset = CGPoint.zero
        scrollView.contentOffset = CGPoint(x: 0, y: 150)
        
//        scrollView.frame = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.contentSize.height)
        scrollView.frame = CGRect(x: 0, y: 150, width: scrollView.contentSize.width, height: scrollView.contentSize.height - 150)
        
        scrollView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        scrollView.contentOffset = savedContentOffset
        scrollView.frame = savedFrame
        
        UIGraphicsEndImageContext()
        
        return image
    }
}




// MARK: - Print ScrollView ;;

//extension ResultViewController {
//    func onPrintReceipt(from view: UIScrollView, onPrintFailed: @escaping () -> Void) {
//        let screenshot = view.toImage()
//
//        if (screenshot == nil) {
//            onPrintFailed()
//            return
//        }
//
//        let printController = UIPrintInteractionController.shared
//        let printInfo = UIPrintInfo(dictionary: [:])
//        printInfo.outputType = UIPrintInfo.OutputType.general
//        printInfo.orientation = UIPrintInfo.Orientation.portrait
//        printInfo.jobName = "Print"
//        printController.printInfo = printInfo
//        printController.showsPageRange = true
//        printController.printingItem = screenshot
//
//        printController.present(animated: true) { (controller, completed, error) in
//            if(!completed && error != nil){
//                onPrintFailed()
//            }
//        }
//    }
//}
//
//
//
//
//
//import UIKit
//extension UIScrollView {
//    func toImage() -> UIImage? {
//        UIGraphicsBeginImageContext(contentSize)
//
//        let savedContentOffset = contentOffset
//        let savedFrame = frame
//        let saveVerticalScroll = showsVerticalScrollIndicator
//        let saveHorizontalScroll = showsHorizontalScrollIndicator
//
//        showsVerticalScrollIndicator = false
//        showsHorizontalScrollIndicator = false
//        contentOffset = CGPoint.zero
//        frame = CGRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height)
//
//        layer.render(in: UIGraphicsGetCurrentContext()!)
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//
//        contentOffset = savedContentOffset
//        frame = savedFrame
//        showsVerticalScrollIndicator = saveVerticalScroll
//        showsHorizontalScrollIndicator = saveHorizontalScroll
//
//        UIGraphicsEndImageContext()
//
//        return image
//    }
//}


extension ResultViewController {
    func toastHelper(msg: String, wRatio: Float, hRatio: Float) {
        showToast(message: msg,
                  defaultWidthSize: self.frameSize.showToastHeightSize[self.userDefaultSetup.deviceSize] ?? 667,
                  defaultHeightSize: self.frameSize.showToastHeightSize[self.userDefaultSetup.deviceSize] ?? 667,
                  widthRatio: wRatio, heightRatio: hRatio,
                  fontsize: self.fontSize.showToastTextSize[self.userDefaultSetup.deviceSize] ?? 13)
    }
    
}
