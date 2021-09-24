
import UIKit
class HistoryRecordCell: UITableViewCell { // change it to : SwipeTableViewCell
    let colorList = ColorList()
    var stringLabel = UILabel()
    //    let userDefault = UserDefaultSetup()
    
    let userDefaultSetup = UserDefaultSetup()
    let fontSize = FontSizes()
    var isOrientationPortrait = true
    
    let viewWillTransitionNotification = Notification.Name(rawValue: viewWilltransitionNotificationKey)
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        
        
        print("override init in cell controller called")
        super.init(style: style, reuseIdentifier: "HistoryRecordReuseIdentifier")
        createObservers()
        
        addSubview(stringLabel)
        
        setProcessAndResultLabelConstraints()
        colorSetup(isLightModeOn: userDefaultSetup.getIsLightModeOn())
    }
    
    
    func createObservers(){
        NotificationCenter.default.addObserver(self, selector : #selector(HistoryRecordCell.orientationDetector(notification:)), name : viewWillTransitionNotification, object: nil)
    }
    @objc func orientationDetector(notification : NSNotification){
        print("orientationDetector function called")
        guard let orientationCheck = notification.userInfo?["orientation"] as? Bool? else{ print("there's an error in orientationDetector form cell")
            //            print("notificationdetector orientation : \(notification.userInfo?["orientation"]) ?? 000 ")
            
            return
        }
        //        print("orientationCheck : \(orientationCheck)")
        print("typeOfOrientationCheck : \(type(of: orientationCheck))")
        
        
        if let check = orientationCheck{
            isOrientationPortrait = check ? true : false
            print("isOrientationPortraitInCell : \(isOrientationPortrait)")
        }
        //        isOrientationPortrait = Bool(orientationCheck)
        
        NotificationCenter.default.removeObserver(self, name: viewWillTransitionNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setProcessAndResultLabelConstraints(){
        print("constraints in cell controller called")
        stringLabel.translatesAutoresizingMaskIntoConstraints = false
        stringLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        stringLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        stringLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30 ).isActive = true
        stringLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
    }
    
    
    func configure(with historyRecord : HistoryRecord, orientationPortrait : Bool, willbasicVCdisappear : Bool){
        print("configure in cell controller called")
        
        if let processHisLongValid = historyRecord.processStringHisLong,
           let processHisValid = historyRecord.processStringHis,
           let processCalcValid = historyRecord.processStringCalc,
           let resultValid = historyRecord.resultString,
           let dateValid = historyRecord.dateString{
            print("TF Detector orientation, didbasicVCdisappeared : \(orientationPortrait), \(willbasicVCdisappear)")
            
            let styleRight = NSMutableParagraphStyle()
            styleRight.alignment = NSTextAlignment.right
            
            let styleLeft = NSMutableParagraphStyle()
            styleLeft.alignment = NSTextAlignment.left
            
            let attributedText = NSMutableAttributedString(string: "", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 1)])
            
            let isLightMode = userDefaultSetup.getIsLightModeOn()
            
            if isLightMode{//LightMode
                
                //date
                
                attributedText.append(NSAttributedString(string: dateValid + "\n", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize.dateHistory[userDefaultSetup.getUserDeviceSizeInfo()]!), NSAttributedString.Key.paragraphStyle : styleLeft, NSAttributedString.Key.foregroundColor: colorList.textColorForDateBM] ))
                
                
                //\n
                attributedText.append(NSAttributedString(string: "\n", attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 5), NSAttributedString.Key.paragraphStyle : styleRight]))
                
                //process
                if orientationPortrait && willbasicVCdisappear{
                    attributedText.append(NSAttributedString(string: processHisValid + "\n", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize.processHistoryPortrait[userDefaultSetup.getUserDeviceSizeInfo()]!), NSAttributedString.Key.paragraphStyle : styleRight, NSAttributedString.Key.foregroundColor: colorList.textColorForProcessBM] ))
                    
                    //\n
                    attributedText.append(NSAttributedString(string: "\n", attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 5), NSAttributedString.Key.paragraphStyle : styleRight]))
                    //result
                    
                    attributedText.append(NSAttributedString(string:  " = " + resultValid, attributes: [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: fontSize.resultHistoryPortrait[userDefaultSetup.getUserDeviceSizeInfo()]!), NSAttributedString.Key.paragraphStyle : styleRight, NSAttributedString.Key.foregroundColor: colorList.textColorForResultBM]))
                    
                }else if !orientationPortrait && willbasicVCdisappear{
                    
                    //HistoryLandscape
                    attributedText.append(NSAttributedString(string: processHisLongValid + "\n", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize.processHistoryLandscape[userDefaultSetup.getUserDeviceSizeInfo()]!), NSAttributedString.Key.paragraphStyle : styleRight, NSAttributedString.Key.foregroundColor: colorList.textColorForProcessBM] ))
                    
                    //\n
                    attributedText.append(NSAttributedString(string: "\n", attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 5), NSAttributedString.Key.paragraphStyle : styleRight]))
                    
                    //result
                    attributedText.append(NSAttributedString(string:  " = " + resultValid, attributes: [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: fontSize.resultHistoryLandscape[userDefaultSetup.getUserDeviceSizeInfo()]!), NSAttributedString.Key.paragraphStyle : styleRight, NSAttributedString.Key.foregroundColor: colorList.textColorForResultBM]))
                }else {
                    
                    //HistoryPortrait
                    attributedText.append(NSAttributedString(string: processCalcValid + "\n", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize.processBasicLandscape[userDefaultSetup.getUserDeviceSizeInfo()]!), NSAttributedString.Key.paragraphStyle : styleRight, NSAttributedString.Key.foregroundColor: colorList.textColorForProcessBM] ))
                    
                    //\n
                    attributedText.append(NSAttributedString(string: "\n", attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 5), NSAttributedString.Key.paragraphStyle : styleRight]))
                    //result
                    
                    attributedText.append(NSAttributedString(string:  " = " + resultValid, attributes: [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: fontSize.resultBasicLandscape[userDefaultSetup.getUserDeviceSizeInfo()]!), NSAttributedString.Key.paragraphStyle : styleRight, NSAttributedString.Key.foregroundColor: colorList.textColorForResultBM]))
                }
                
                
                
                
                
                
                
            }else{ // DarkMode
                
                attributedText.append(NSAttributedString(string: dateValid + "\n", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize.dateHistory[userDefaultSetup.getUserDeviceSizeInfo()]!), NSAttributedString.Key.paragraphStyle : styleLeft, NSAttributedString.Key.foregroundColor: colorList.textColorForDateDM] ))
                
                //\n
                attributedText.append(NSAttributedString(string: "\n", attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 5), NSAttributedString.Key.paragraphStyle : styleRight]))
                
                
                //process
                if orientationPortrait && willbasicVCdisappear{
                    
                    //HistoryPortrait
                    attributedText.append(NSAttributedString(string: processHisValid + "\n", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize.processHistoryPortrait[userDefaultSetup.getUserDeviceSizeInfo()]!), NSAttributedString.Key.paragraphStyle : styleRight, NSAttributedString.Key.foregroundColor: colorList.textColorForProcessDM] ))
                    
                    //\n
                    attributedText.append(NSAttributedString(string: "\n", attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 5), NSAttributedString.Key.paragraphStyle : styleRight]))
                    
                    //result
                    attributedText.append(NSAttributedString(string:  " = " + resultValid, attributes: [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: fontSize.resultHistoryPortrait[userDefaultSetup.getUserDeviceSizeInfo()]!), NSAttributedString.Key.paragraphStyle : styleRight, NSAttributedString.Key.foregroundColor: colorList.textColorForResultDM]))
                    
                }else if !orientationPortrait && willbasicVCdisappear{
                    
                    //HistoryLandscape
                    attributedText.append(NSAttributedString(string: processHisLongValid + "\n", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize.processHistoryLandscape[userDefaultSetup.getUserDeviceSizeInfo()]!), NSAttributedString.Key.paragraphStyle : styleRight, NSAttributedString.Key.foregroundColor: colorList.textColorForProcessDM] ))
                    
                    //\n
                    attributedText.append(NSAttributedString(string: "\n", attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 5), NSAttributedString.Key.paragraphStyle : styleRight]))
                    
                    //result
                    attributedText.append(NSAttributedString(string:  " = " + resultValid, attributes: [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: fontSize.resultHistoryLandscape[userDefaultSetup.getUserDeviceSizeInfo()]!), NSAttributedString.Key.paragraphStyle : styleRight, NSAttributedString.Key.foregroundColor: colorList.textColorForResultDM]))
                    
                }else {
                    
                    //calc
                    attributedText.append(NSAttributedString(string: processCalcValid + "\n", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize.processBasicLandscape[userDefaultSetup.getUserDeviceSizeInfo()]!), NSAttributedString.Key.paragraphStyle : styleRight, NSAttributedString.Key.foregroundColor: colorList.textColorForProcessDM] ))
                    
                    //\n
                    attributedText.append(NSAttributedString(string: "\n", attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 5), NSAttributedString.Key.paragraphStyle : styleRight]))
                    
                    //result
                    attributedText.append(NSAttributedString(string:  " = " + resultValid, attributes: [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: fontSize.resultBasicLandscape[userDefaultSetup.getUserDeviceSizeInfo()]!), NSAttributedString.Key.paragraphStyle : styleRight, NSAttributedString.Key.foregroundColor: colorList.textColorForResultDM]))
                }
            }
            stringLabel.attributedText = attributedText
            stringLabel.numberOfLines = 0
        }
    }
    
    func colorSetup(isLightModeOn : Bool){
        print("colorSetup in cell controller called")
        
        if isLightModeOn{
            backgroundColor = colorList.bgColorForEmptyAndNumbersBM
            layer.borderColor = CGColor(srgbRed: 0.7, green: 0.7, blue: 0.7, alpha: 0.1)
        }else{
            backgroundColor = colorList.bgColorForEmptyAndNumbersDM
            layer.borderColor = CGColor(srgbRed: 0.7, green: 0.7, blue: 0.7, alpha: 0.5)
        }
        
        layer.borderWidth = 0.23
    }
}
