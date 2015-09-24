//
// InfoViewController.swift
//

import UIKit

class InfoViewController : UIViewController {
    @IBOutlet weak var _nameLabel : UILabel!
    @IBOutlet weak var _versionLabel: UILabel!
    
    @IBOutlet weak var _purchaseButton: UIButton!
    @IBOutlet weak var _helpButton: UIButton!
    @IBOutlet weak var _facebookButton: UIButton!
    @IBOutlet weak var _sendMailButton: UIButton!
    
    class func instantiate() -> UINavigationController {
        return UIStoryboard(name: "InfoView", bundle:nil).instantiateInitialViewController() as! UINavigationController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("Info", comment: "")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem:.Done, target:self, action:"doneAction:")

        if (AppDelegate.isFreeVersion()) {
            _nameLabel.text = "CashFlow Free"
        } else {
            _purchaseButton.hidden = true
        }
        
        let version: String = AppDelegate.appVersion()
        _versionLabel.text = "Version \(version)"
        
        _setButtonTitle(_purchaseButton, title: _L("Purchase Standard Version"))
        _setButtonTitle(_helpButton, title: _L("Show help page"))
        _setButtonTitle(_facebookButton, title: _L("Open facebook page"))
        _setButtonTitle(_sendMailButton, title: _L("Send support mail"))
    }
    
    func _setButtonTitle(button: UIButton, title: String) {
        button.setTitle(title, forState: .Normal)
        button.setTitle(title, forState: .Highlighted)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func doneAction(sender: AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func webButtonTapped() {
        AppDelegate.trackEvent("help", action:"push", label:"help", value:0)
        let url = NSURL(string: NSLocalizedString("HelpURL", comment:""))
        UIApplication.sharedApplication().openURL(url!)
    }
    
    @IBAction func facebookButtonTapped() {
        AppDelegate.trackEvent("help", action:"push", label:"facebook", value:0)
        let url = NSURL(string: "http://facebook.com/CashFlowApp")
        UIApplication.sharedApplication().openURL(url!)
    }
    
    @IBAction func purchaseStandardVerion() {
        AppDelegate.trackEvent("help", action:"push", label:"purchase", value:0)
        let url = NSURL(string: "https://itunes.apple.com/jp/app/cashflow/id290776107?mt=8&uo=4")
        //var url = NSURL(string: "http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=290776107&mt=8")
        UIApplication.sharedApplication().openURL(url!)
    }
    
    @IBAction func sendSupportMail() {
        AppDelegate.trackEvent("help", action:"push", label:"sendmail", value:0)
        
        let m = SupportMail.getInstance()
        if (!m.sendMail(self)) {
            let v = UIAlertView(title: "Error", message: "Can't send mail", delegate: nil, cancelButtonTitle: "OK")
            v.show()
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return isIpad();
    }
}
