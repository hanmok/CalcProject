
import UIKit
class HistoryRecordCell: UITableViewCell { // change it to : SwipeTableViewCell
    let colorList = ColorList()
    var stringLabel = UILabel()
    
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
            
            let isLightMode = userDefaultSetup.getIsLightModeOn()
            
            if isLightMode{//LightMode
                
                //date
                
                attributedText.append(NSAttributedString(string: dateValid + "\n", attributes: [.font: UIFont.systemFont(ofSize: fontSize.dateHistory[userDefaultSetup.getDeviceSize()]!), .paragraphStyle : styleLeft, .foregroundColor: colorList.textColorForDateLM] ))
//                attributedText.append(customAttributedString(string: dateValid + "\n", fontSize: fontSize.dateHistory[userDefaultSetup.getDeviceSize()]!, alignment: styleLeft, foregroundColor: colorList.textColorForDateLM))
               
                
                //\n
                attributedText.append(NSAttributedString(string: "\n", attributes: [ .font:UIFont.systemFont(ofSize: 5),  .paragraphStyle : styleRight]))
                
                //process
                if orientationPortrait && willbasicVCdisappear{
                    attributedText.append(NSAttributedString(string: processHisValid + "\n", attributes: [ .font: UIFont.systemFont(ofSize: fontSize.processHistoryPortrait[userDefaultSetup.getDeviceSize()]!),  .paragraphStyle : styleRight,  .foregroundColor: colorList.textColorForProcessLM] ))
                    
                    //\n
                    attributedText.append(NSAttributedString(string: "\n", attributes: [ .font:UIFont.systemFont(ofSize: 5),  .paragraphStyle : styleRight]))
                    //result
                    
                    attributedText.append(NSAttributedString(string:  " = " + resultValid, attributes: [ .font:UIFont.boldSystemFont(ofSize: fontSize.resultHistoryPortrait[userDefaultSetup.getDeviceSize()]!),  .paragraphStyle : styleRight,  .foregroundColor: colorList.textColorForResultLM]))
                    
                }else if !orientationPortrait && willbasicVCdisappear{
                    
                    //HistoryLandscape
                    attributedText.append(NSAttributedString(string: processHisLongValid + "\n", attributes: [ .font: UIFont.systemFont(ofSize: fontSize.processHistoryLandscape[userDefaultSetup.getDeviceSize()]!),  .paragraphStyle : styleRight,  .foregroundColor: colorList.textColorForProcessLM] ))
                    
                    //\n
                    attributedText.append(NSAttributedString(string: "\n", attributes: [ .font:UIFont.systemFont(ofSize: 5),  .paragraphStyle : styleRight]))
                    
                    //result
                    attributedText.append(NSAttributedString(string:  " = " + resultValid, attributes: [ .font:UIFont.boldSystemFont(ofSize: fontSize.resultHistoryLandscape[userDefaultSetup.getDeviceSize()]!),  .paragraphStyle : styleRight,  .foregroundColor: colorList.textColorForResultLM]))
                }else {
                    
                    //HistoryPortrait
                    attributedText.append(NSAttributedString(string: processCalcValid + "\n", attributes: [ .font: UIFont.systemFont(ofSize: fontSize.processBasicLandscape[userDefaultSetup.getDeviceSize()]!),  .paragraphStyle : styleRight,  .foregroundColor: colorList.textColorForProcessLM] ))
                    
                    //\n
                    attributedText.append(NSAttributedString(string: "\n", attributes: [ .font:UIFont.systemFont(ofSize: 5),  .paragraphStyle : styleRight]))
                    //result
                    
                    attributedText.append(NSAttributedString(string:  " = " + resultValid, attributes: [ .font:UIFont.boldSystemFont(ofSize: fontSize.resultBasicLandscape[userDefaultSetup.getDeviceSize()]!),  .paragraphStyle : styleRight,  .foregroundColor: colorList.textColorForResultLM]))
                }
                
            }else{ // DarkMode
                
                attributedText.append(NSAttributedString(string: dateValid + "\n", attributes: [ .font: UIFont.systemFont(ofSize: fontSize.dateHistory[userDefaultSetup.getDeviceSize()]!),  .paragraphStyle : styleLeft,  .foregroundColor: colorList.textColorForDateDM] ))
                
                //\n
                attributedText.append(NSAttributedString(string: "\n", attributes: [ .font:UIFont.systemFont(ofSize: 5),  .paragraphStyle : styleRight]))
                
                
                //process
                if orientationPortrait && willbasicVCdisappear{
                    
                    //HistoryPortrait
                    attributedText.append(NSAttributedString(string: processHisValid + "\n", attributes: [ .font: UIFont.systemFont(ofSize: fontSize.processHistoryPortrait[userDefaultSetup.getDeviceSize()]!),  .paragraphStyle : styleRight,  .foregroundColor: colorList.textColorForProcessDM] ))
                    
                    //\n
                    attributedText.append(NSAttributedString(string: "\n", attributes: [ .font:UIFont.systemFont(ofSize: 5),  .paragraphStyle : styleRight]))
                    
                    //result
                    attributedText.append(NSAttributedString(string:  " = " + resultValid, attributes: [ .font:UIFont.boldSystemFont(ofSize: fontSize.resultHistoryPortrait[userDefaultSetup.getDeviceSize()]!),  .paragraphStyle : styleRight,  .foregroundColor: colorList.textColorForResultDM]))
                    
                }else if !orientationPortrait && willbasicVCdisappear{
                    
                    //HistoryLandscape
                    attributedText.append(NSAttributedString(string: processHisLongValid + "\n", attributes: [ .font: UIFont.systemFont(ofSize: fontSize.processHistoryLandscape[userDefaultSetup.getDeviceSize()]!),  .paragraphStyle : styleRight,  .foregroundColor: colorList.textColorForProcessDM] ))
                    
                    //\n
                    attributedText.append(NSAttributedString(string: "\n", attributes: [ .font:UIFont.systemFont(ofSize: 5),  .paragraphStyle : styleRight]))
                    
                    //result
                    attributedText.append(NSAttributedString(string:  " = " + resultValid, attributes: [ .font:UIFont.boldSystemFont(ofSize: fontSize.resultHistoryLandscape[userDefaultSetup.getDeviceSize()]!),  .paragraphStyle : styleRight,  .foregroundColor: colorList.textColorForResultDM]))
                    
                }else {
                    
                    //calc
                    attributedText.append(NSAttributedString(string: processCalcValid + "\n", attributes: [ .font: UIFont.systemFont(ofSize: fontSize.processBasicLandscape[userDefaultSetup.getDeviceSize()]!),  .paragraphStyle : styleRight,  .foregroundColor: colorList.textColorForProcessDM] ))
                    
                    //\n
                    attributedText.append(NSAttributedString(string: "\n", attributes: [ .font:UIFont.systemFont(ofSize: 5),  .paragraphStyle : styleRight]))
                    
                    //result
                    attributedText.append(NSAttributedString(string:  " = " + resultValid, attributes: [ .font:UIFont.boldSystemFont(ofSize: fontSize.resultBasicLandscape[userDefaultSetup.getDeviceSize()]!),  .paragraphStyle : styleRight, .foregroundColor: colorList.textColorForResultDM]))
                }
            }
            stringLabel.attributedText = attributedText
            stringLabel.numberOfLines = 0
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
