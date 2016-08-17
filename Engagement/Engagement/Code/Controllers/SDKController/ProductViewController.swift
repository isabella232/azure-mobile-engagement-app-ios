//
//  ProductViewController.swift
//  Engagement
//
//  Created by Microsoft on 17/02/2016.
//  Copyright © 2016 Microsoft. All rights reserved.
//

import UIKit

enum ProductViewType{
  case DataPush, Coupon
  
  var title: String{
    switch self{
    case .DataPush:
      return L10n.tr("product.discount.title")
    case .Coupon:
      return L10n.tr("product.title")
    }
  }
}

class ProductViewController: EngagementViewController {
  
  @IBOutlet weak var ibProductImage: UIImageView!
  @IBOutlet weak var ibProductName: UILabel!
  @IBOutlet weak var ibProductPrice: UILabel!
  @IBOutlet weak var ibRadioButton: UIButton!
  
  @IBOutlet weak var ibReductionButton: AzButton!
  
  var productViewType = ProductViewType.Coupon
  var discountApplied = false
  var discountRateInPercent = 0
  
  let formatter = NSNumberFormatter()
  
  init(productViewType : ProductViewType = .Coupon){
    super.init(nibName: nil, bundle: nil)
    self.productViewType = productViewType
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  //MARK: Overriding
  override func engagementActivityName() -> String! {
    return AnalyticsMonitor.Activities.ProductDiscount
  }
  
  //MARK: View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: #selector(ProductViewController.getDataPushValues(_:)),
      name: Config.Notifications.dataPushValuesUpdated,
      object: nil)
    
    self.title = L10n.tr("product.discount.title")
    
    formatter.numberStyle = .CurrencyStyle
    let toto = NSLocalizedString("product.name", comment: "")
    ibProductName.text = toto //L10n.tr("product.name")
    
    ibReductionButton.setBackgroundImage(UIColor.imageWithColor(UIColor(named: UIColor.Name.LightGrey)),
      forState: .Highlighted)
    
    ibProductName.font = UIFont(named: UIFont.AppFont.Light, size: 35)
    ibProductPrice.font = UIFont(named: UIFont.AppFont.Regular, size: 30)
    ibRadioButton.setBackgroundImage(UIColor.imageWithColor(UIColor(named: UIColor.Name.SecondaryOrange)),
      forState: .Normal)
    ibReductionButton.titleLabel?.font = UIFont(named: UIFont.AppFont.Bold, size: 17)
    ibReductionButton.titleLabel?.numberOfLines = 0
    ibReductionButton.titleLabel?.lineBreakMode = .ByWordWrapping
    
    if self.productViewType == .Coupon {
      let attributed = NSMutableAttributedString(string: "20% off on your purchase\n",
        attributes: [NSFontAttributeName : UIFont(named: UIFont.AppFont.Bold, size: 16)])
      attributed.appendAttributedString(NSAttributedString(string: "Use coupon code 59AXCD when checking out",
        attributes: [NSFontAttributeName : UIFont(named: UIFont.AppFont.Medium, size: 13)]))
      self.ibRadioButton.contentMode = .Left
      self.ibRadioButton.setAttributedTitle(attributed, forState: .Normal)
    }
    getDataPushValues(nil)
  }
  
  func getDataPushValues(notification: NSNotification?) {
    let defaults = NSUserDefaults.standardUserDefaults()
    discountApplied = defaults.boolForKey(Config.Product.DataPush.isDiscountAvailable)
    if defaults.objectForKey(Config.Product.DataPush.discountRateInPercent) != nil {
      let discountRateInPercentValue = defaults.integerForKey(Config.Product.DataPush.discountRateInPercent)
      discountRateInPercent = discountRateInPercentValue < 0 ? 0 : discountRateInPercentValue > 100 ? 100 : discountRateInPercentValue
    } else {
      discountRateInPercent = Config.Product.defaultReductionRatio()
    }
    updatePriceButtonStyle()
  }
  
  //MARK: Actions
  @IBAction func didTapReductionButton(sender: AnyObject) {
    self.discountApplied = !self.discountApplied
    
    AnalyticsMonitor.sendActivityNamed(self.discountApplied ? AnalyticsMonitor.Events.ProductDiscount.applyDiscount : AnalyticsMonitor.Events.ProductDiscount.removeDiscount, extras: nil)
    
    if self.discountApplied == false {
      let defaults = NSUserDefaults.standardUserDefaults()
      defaults.removeObjectForKey(Config.Product.DataPush.isDiscountAvailable)
      defaults.removeObjectForKey(Config.Product.DataPush.discountRateInPercent)
      defaults.synchronize()
      getDataPushValues(nil)
    } else {
      updatePriceButtonStyle()
    }
  }
  
  //MARK: Private methods
  private func updatePriceButtonStyle() {
    
    if self.productViewType == .DataPush {
      ibRadioButton.hidden = !self.discountApplied
      let title = String(discountRateInPercent) + "% off"
      let attributed = NSAttributedString(string: title,
        attributes: [NSFontAttributeName : UIFont(named: UIFont.AppFont.Bold, size: 16)])
      self.ibRadioButton.contentMode = .Center
      self.ibRadioButton.setAttributedTitle(attributed, forState: .Normal)
    } else {
      ibRadioButton.hidden = false
      ibReductionButton.hidden = true
    }
    
    if discountApplied == true {
      ibReductionButton.setTitle(L10n.tr("product.discount.remove.discount.title"), forState: .Normal)
      ibReductionButton.setBackgroundImage(UIColor.imageWithColor(UIColor(named: UIColor.Name.SecondaryPurple)),
        forState: .Normal)
      
      let price = NSMutableAttributedString(string: formatter.stringFromNumber(Config.Product.defaultPrice)!,
        attributes: [NSForegroundColorAttributeName : UIColor(named: UIColor.Name.GeneralText),
          NSStrikethroughStyleAttributeName : NSNumber(integer: NSUnderlineStyle.StyleSingle.rawValue)])
      let newPrice = NSMutableAttributedString(string: " " + formatter.stringFromNumber(Config.Product.defaultPrice - (Config.Product.defaultPrice * discountRateInPercent / 100))!,
        attributes: [NSForegroundColorAttributeName : UIColor(named: UIColor.Name.SecondaryOrange)])
      
      price.appendAttributedString(newPrice)
      
      ibProductPrice.attributedText = price
    } else {
      ibReductionButton.setTitle(L10n.tr("product.discount.apply.discount.title"), forState: .Normal)
      ibReductionButton.setBackgroundImage(UIColor.imageWithColor(UIColor(named: UIColor.Name.SecondaryOrange)),
        forState: .Normal)
      let price = NSMutableAttributedString(string: formatter.stringFromNumber(Config.Product.defaultPrice)!,
        attributes: [NSForegroundColorAttributeName : UIColor(named: UIColor.Name.GeneralText)])
      ibProductPrice.attributedText = price
    }
    
  }
  
}
