
import UIKit
class HistoryRecordCell: UITableViewCell { // change it to : SwipeTableViewCell
    let colorList = ColorList()
    var stringLabel = UILabel()
    var titleLabel = UILabel()
    
    let userDefaultSetup = UserDefaultSetup()
    let fontSize = FontSizes()
    var portraitMode = true
    
    let viewWillTransitionNotification = Notification.Name(rawValue: NotificationKey.viewWilltransitionNotification.rawValue)
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: "HistoryRecordReuseIdentifier")
        createObservers()
        
        addSubview(stringLabel)
        addSubview(titleLabel)
        
        setupProcessAndResultLabelConstraints()
        setupColor(isLightModeOn: userDefaultSetup.getIsLightModeOn())
    }
    
    
    func createObservers(){
        NotificationCenter.default.addObserver(self, selector : #selector(HistoryRecordCell.detectOrientation(notification:)), name : viewWillTransitionNotification, object: nil)
    }
    
    @objc func detectOrientation(notification : NSNotification){
        guard let orientationCheck = notification.userInfo?["orientation"] as? Bool? else{ print("there's an error in detectOrientation form cell")
            
            return
        }
        
        if let check = orientationCheck{
            portraitMode = check ? true : false // portraitMode not used.
        }
        
        NotificationCenter.default.removeObserver(self, name: viewWillTransitionNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupProcessAndResultLabelConstraints(){
        stringLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 5, paddingLeft: 30, paddingBottom: 10, paddingRight: 10)
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 5, paddingLeft: 30, paddingBottom: 10, paddingRight: 10)
        titleLabel.backgroundColor = .clear
    }
    
    
    func configure(with historyRecord : HistoryRecord, orientationPortrait : Bool, willbasicVCdisappear : Bool){
       
        
        if let processHisLongValid = historyRecord.processStringHisLong,
           let processHisValid = historyRecord.processStringHis,
           let processCalcValid = historyRecord.processStringCalc,
           let resultValid = historyRecord.resultString,
           let dateValid = historyRecord.dateString{
           
            let styleRight = NSMutableParagraphStyle()
            styleRight.alignment = NSTextAlignment.right
            
            let styleLeft = NSMutableParagraphStyle()
            styleLeft.alignment = NSTextAlignment.left
            
            let attributedText = NSMutableAttributedString(string: "", attributes: [ .font: UIFont.systemFont(ofSize: 1)])
            let titleAttributedText = NSMutableAttributedString(string: "", attributes: [ .font: UIFont.systemFont(ofSize: 1)])
            
            let isLightMode = userDefaultSetup.getIsLightModeOn()
            
            if isLightMode{//LightMode
                
                // date
                attributedText.append(NSAttributedString(string: dateValid + "\n", attributes: [.font: UIFont.systemFont(ofSize: fontSize.dateHistory[userDefaultSetup.getDeviceSize()]!), .paragraphStyle : styleLeft, .foregroundColor: colorList.textColorForDateLM] ))
                
                titleAttributedText.append(NSAttributedString(string: historyRecord.titleLabel ?? "" + "\n" , attributes: [.font: UIFont.systemFont(ofSize: fontSize.dateHistory[userDefaultSetup.getDeviceSize()]! + 3), .paragraphStyle : styleRight, .foregroundColor: colorList.textColorForResultLM] ))
                
                //\n
                attributedText.append(NSAttributedString(string: "\n", attributes: [ .font:UIFont.systemFont(ofSize: 5),  .paragraphStyle : styleRight]))
                
                titleAttributedText.append(NSAttributedString(string: "\n", attributes: [ .font:UIFont.systemFont(ofSize: 2),  .paragraphStyle : styleRight]))

                //process
                if orientationPortrait && willbasicVCdisappear{
                    attributedText.append(NSAttributedString(string: processHisValid + "\n", attributes: [ .font: UIFont.systemFont(ofSize: fontSize.processHistoryPortrait[userDefaultSetup.getDeviceSize()]!),  .paragraphStyle : styleRight,  .foregroundColor: colorList.textColorForProcessLM] ))
                    
                    titleAttributedText.append(NSAttributedString(string: processHisValid + "\n", attributes: [ .font: UIFont.systemFont(ofSize: fontSize.processHistoryPortrait[userDefaultSetup.getDeviceSize()]!),  .paragraphStyle : styleRight,  .foregroundColor: UIColor.clear] ))
                    
                    //\n
                    attributedText.append(NSAttributedString(string: "\n", attributes: [ .font:UIFont.systemFont(ofSize: 5),  .paragraphStyle : styleRight]))
                    
                    titleAttributedText.append(NSAttributedString(string: "\n", attributes: [ .font:UIFont.systemFont(ofSize: 5),  .paragraphStyle : styleRight]))
                    //result
                    attributedText.append(NSAttributedString(string:  " = " + resultValid, attributes: [ .font:UIFont.boldSystemFont(ofSize: fontSize.resultHistoryPortrait[userDefaultSetup.getDeviceSize()]!),  .paragraphStyle : styleRight,  .foregroundColor: colorList.textColorForResultLM]))
                    
                    titleAttributedText.append(NSAttributedString(string:  " = " + resultValid, attributes: [ .font:UIFont.boldSystemFont(ofSize: fontSize.resultHistoryPortrait[userDefaultSetup.getDeviceSize()]!), .paragraphStyle : styleRight,  .foregroundColor: UIColor.clear]))
                    
                }else if !orientationPortrait && willbasicVCdisappear{
                    
                    //HistoryLandscape
                    attributedText.append(NSAttributedString(string: processHisLongValid + "\n", attributes: [ .font: UIFont.systemFont(ofSize: fontSize.processHistoryLandscape[userDefaultSetup.getDeviceSize()]!),  .paragraphStyle : styleRight,  .foregroundColor: colorList.textColorForProcessLM] ))
                    
                    titleAttributedText.append(NSAttributedString(string: processHisLongValid + "\n", attributes: [ .font: UIFont.systemFont(ofSize: fontSize.processHistoryLandscape[userDefaultSetup.getDeviceSize()]!),  .paragraphStyle : styleRight,  .foregroundColor: UIColor.clear] ))
                    
                    //\n
                    attributedText.append(NSAttributedString(string: "\n", attributes: [ .font:UIFont.systemFont(ofSize: 5),  .paragraphStyle : styleRight]))
                    
                    titleAttributedText.append(NSAttributedString(string: "\n", attributes: [ .font:UIFont.systemFont(ofSize: 5),  .paragraphStyle : styleRight]))
                    //result
                    attributedText.append(NSAttributedString(string:  " = " + resultValid, attributes: [ .font:UIFont.boldSystemFont(ofSize: fontSize.resultHistoryLandscape[userDefaultSetup.getDeviceSize()]!),  .paragraphStyle : styleRight,  .foregroundColor: colorList.textColorForResultLM]))
                    titleAttributedText.append(NSAttributedString(string:  " = " + resultValid, attributes: [ .font:UIFont.boldSystemFont(ofSize: fontSize.resultHistoryLandscape[userDefaultSetup.getDeviceSize()]!),  .paragraphStyle : styleRight,  .foregroundColor: UIColor.clear]))
                }else {
                    
                    //HistoryPortrait
                    attributedText.append(NSAttributedString(string: processCalcValid + "\n", attributes: [ .font: UIFont.systemFont(ofSize: fontSize.processBasicLandscape[userDefaultSetup.getDeviceSize()]!),  .paragraphStyle : styleRight,  .foregroundColor: colorList.textColorForProcessLM] ))
                    
                    titleAttributedText.append(NSAttributedString(string: processCalcValid + "\n", attributes: [ .font: UIFont.systemFont(ofSize: fontSize.processBasicLandscape[userDefaultSetup.getDeviceSize()]!),  .paragraphStyle : styleRight,  .foregroundColor: UIColor.clear] ))
                    
                    //\n
                    attributedText.append(NSAttributedString(string: "\n", attributes: [ .font:UIFont.systemFont(ofSize: 5),  .paragraphStyle : styleRight]))
                    
                    titleAttributedText.append(NSAttributedString(string: "\n", attributes: [ .font:UIFont.systemFont(ofSize: 5),  .paragraphStyle : styleRight]))
                    //result
                    
                    attributedText.append(NSAttributedString(string:  " = " + resultValid, attributes: [ .font:UIFont.boldSystemFont(ofSize: fontSize.resultBasicLandscape[userDefaultSetup.getDeviceSize()]!),  .paragraphStyle : styleRight,  .foregroundColor: colorList.textColorForResultLM]))
                    
                    titleAttributedText.append(NSAttributedString(string:  " = " + resultValid, attributes: [ .font:UIFont.boldSystemFont(ofSize: fontSize.resultBasicLandscape[userDefaultSetup.getDeviceSize()]!),  .paragraphStyle : styleRight,  .foregroundColor: UIColor.clear]))
                }
                
            }else{ // DarkMode
                // date
                attributedText.append(NSAttributedString(string: dateValid + "\n", attributes: [ .font: UIFont.systemFont(ofSize: fontSize.dateHistory[userDefaultSetup.getDeviceSize()]!),  .paragraphStyle : styleLeft,  .foregroundColor: colorList.textColorForDateDM] ))
                
                titleAttributedText.append(NSAttributedString(string: historyRecord.titleLabel ?? "" + "\n" , attributes: [.font: UIFont.systemFont(ofSize: fontSize.dateHistory[userDefaultSetup.getDeviceSize()]! + 3), .paragraphStyle : styleRight, .foregroundColor: colorList.textColorForResultDM] ))
                
                //\n
                attributedText.append(NSAttributedString(string: "\n", attributes: [ .font:UIFont.systemFont(ofSize: 5),  .paragraphStyle : styleRight]))
                
                titleAttributedText.append(NSAttributedString(string: "\n", attributes: [ .font:UIFont.systemFont(ofSize: 2),  .paragraphStyle : styleRight]))
                //process
                if orientationPortrait && willbasicVCdisappear{
                    
                    //HistoryPortrait
                    attributedText.append(NSAttributedString(string: processHisValid + "\n", attributes: [ .font: UIFont.systemFont(ofSize: fontSize.processHistoryPortrait[userDefaultSetup.getDeviceSize()]!),  .paragraphStyle : styleRight,  .foregroundColor: colorList.textColorForProcessDM] ))
                    
                    titleAttributedText.append(NSAttributedString(string: processHisValid + "\n", attributes: [ .font: UIFont.systemFont(ofSize: fontSize.processHistoryPortrait[userDefaultSetup.getDeviceSize()]!),  .paragraphStyle : styleRight,  .foregroundColor: UIColor.clear] ))
                    
                    //\n
                    attributedText.append(NSAttributedString(string: "\n", attributes: [ .font:UIFont.systemFont(ofSize: 5),  .paragraphStyle : styleRight]))
                    
                    titleAttributedText.append(NSAttributedString(string: "\n", attributes: [ .font:UIFont.systemFont(ofSize: 5),  .paragraphStyle : styleRight]))
                    
                    //result
                    attributedText.append(NSAttributedString(string:  " = " + resultValid, attributes: [ .font:UIFont.boldSystemFont(ofSize: fontSize.resultHistoryPortrait[userDefaultSetup.getDeviceSize()]!),  .paragraphStyle : styleRight,  .foregroundColor: colorList.textColorForResultDM]))
                    
                    titleAttributedText.append(NSAttributedString(string:  " = " + resultValid, attributes: [ .font:UIFont.boldSystemFont(ofSize: fontSize.resultHistoryPortrait[userDefaultSetup.getDeviceSize()]!), .paragraphStyle : styleRight,  .foregroundColor: UIColor.clear]))
                    
                }else if !orientationPortrait && willbasicVCdisappear{
                    
                    //HistoryLandscape
                    attributedText.append(NSAttributedString(string: processHisLongValid + "\n", attributes: [ .font: UIFont.systemFont(ofSize: fontSize.processHistoryLandscape[userDefaultSetup.getDeviceSize()]!),  .paragraphStyle : styleRight,  .foregroundColor: colorList.textColorForProcessDM] ))
                    
                    titleAttributedText.append(NSAttributedString(string: processHisLongValid + "\n", attributes: [ .font: UIFont.systemFont(ofSize: fontSize.processHistoryLandscape[userDefaultSetup.getDeviceSize()]!),  .paragraphStyle : styleRight,  .foregroundColor: UIColor.clear] ))
                    
                    //\n
                    attributedText.append(NSAttributedString(string: "\n", attributes: [ .font:UIFont.systemFont(ofSize: 5),  .paragraphStyle : styleRight]))
                    
                    titleAttributedText.append(NSAttributedString(string: "\n", attributes: [ .font:UIFont.systemFont(ofSize: 5),  .paragraphStyle : styleRight]))
                    
                    //result
                    attributedText.append(NSAttributedString(string:  " = " + resultValid, attributes: [ .font:UIFont.boldSystemFont(ofSize: fontSize.resultHistoryLandscape[userDefaultSetup.getDeviceSize()]!),  .paragraphStyle : styleRight,  .foregroundColor: colorList.textColorForResultDM]))
                    
                    titleAttributedText.append(NSAttributedString(string:  " = " + resultValid, attributes: [ .font:UIFont.boldSystemFont(ofSize: fontSize.resultHistoryLandscape[userDefaultSetup.getDeviceSize()]!),  .paragraphStyle : styleRight,  .foregroundColor: UIColor.clear]))
                    
                }else {
                    
                    //calc
                    attributedText.append(NSAttributedString(string: processCalcValid + "\n", attributes: [ .font: UIFont.systemFont(ofSize: fontSize.processBasicLandscape[userDefaultSetup.getDeviceSize()]!),  .paragraphStyle : styleRight,  .foregroundColor: colorList.textColorForProcessDM] ))
                    
                    titleAttributedText.append(NSAttributedString(string: processCalcValid + "\n", attributes: [ .font: UIFont.systemFont(ofSize: fontSize.processBasicLandscape[userDefaultSetup.getDeviceSize()]!),  .paragraphStyle : styleRight,  .foregroundColor: UIColor.clear] ))
                    
                    //\n
                    attributedText.append(NSAttributedString(string: "\n", attributes: [ .font:UIFont.systemFont(ofSize: 5),  .paragraphStyle : styleRight]))
                    
                    titleAttributedText.append(NSAttributedString(string: "\n", attributes: [ .font:UIFont.systemFont(ofSize: 5),  .paragraphStyle : styleRight]))
                    //result
                    attributedText.append(NSAttributedString(string:  " = " + resultValid, attributes: [ .font:UIFont.boldSystemFont(ofSize: fontSize.resultBasicLandscape[userDefaultSetup.getDeviceSize()]!),  .paragraphStyle : styleRight, .foregroundColor: colorList.textColorForResultDM]))
                    
                    titleAttributedText.append(NSAttributedString(string:  " = " + resultValid, attributes: [ .font:UIFont.boldSystemFont(ofSize: fontSize.resultBasicLandscape[userDefaultSetup.getDeviceSize()]!),  .paragraphStyle : styleRight,  .foregroundColor: UIColor.clear]))
                }
            }
            stringLabel.attributedText = attributedText
            stringLabel.numberOfLines = 0
            titleLabel.attributedText = titleAttributedText
            titleLabel.numberOfLines = 0

        }
    }
    
    func setupColor(isLightModeOn : Bool){
        print("colorSetup in cell controller called")
        
        if isLightModeOn{
            backgroundColor = colorList.bgColorForEmptyAndNumbersLM
            layer.borderColor = CGColor(srgbRed: 0.7, green: 0.7, blue: 0.7, alpha: 0.1)
        }else{
            backgroundColor = colorList.bgColorForEmptyAndNumbersDM
            layer.borderColor = CGColor(srgbRed: 0.7, green: 0.7, blue: 0.7, alpha: 0.5)
        }
        layer.borderWidth = 0.23
    }
}
