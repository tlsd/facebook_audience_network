import Foundation
import Flutter
import FBAudienceNetwork

class FacebookAudienceNetworkRewardedVideoAdPlugin: NSObject, FBRewardedVideoAdDelegate {
    let channel: FlutterMethodChannel
    var rewardedVideoAd: FBRewardedVideoAd!
    
    init(_channel: FlutterMethodChannel) {
        print("FacebookAudienceNetworkRewardedVideoAdPlugin > init")
        
        channel = _channel
        
        super.init()
        
        channel.setMethodCallHandler { (call, result) in
            switch call.method{
            case "loadRewardedAd":
                print("FacebookAudienceNetworkRewardedVideoAdPlugin > loadRewardedVideoAd")
                result(self.loadAd(call))
            case "showRewardedAd":
                print("FacebookAudienceNetworkRewardedVideoAdPlugin > showRewardedVideoAd")
                result(self.showAD(call))
            case "destroyRewardedAd":
                print("FacebookAudienceNetworkRewardedVideoAdPlugin > destroyRewardedVideoAd")
                result(self.destroyAd())
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        
        print("FacebookAudienceNetworkRewardedVideoAdPlugin > init > end")
    }
    
    
    func loadAd(_ call: FlutterMethodCall) -> Bool {
        if nil == self.rewardedVideoAd || !self.rewardedVideoAd.isAdValid {
            print("FacebookAudienceNetworkRewardedVideoAdPlugin > loadAd > create")
            let args: NSDictionary = call.arguments as! NSDictionary
            let id: String = args["id"] as! String
            self.rewardedVideoAd = FBRewardedVideoAd.init(placementID: id)
            self.rewardedVideoAd.delegate = self
        }
        self.rewardedVideoAd.load()
        return true
    }
    
    func showAD(_ call: FlutterMethodCall) -> Bool {
        if !self.rewardedVideoAd.isAdValid {
            print("FacebookAudienceNetworkRewardedVideoAdPlugin > showAD > not AdVaild")
            return false
        }
        let args: NSDictionary = call.arguments as! NSDictionary
        let delay: Int = args["delay"] as! Int
        
        //MARK:- Need to remove because it' already called with delay.
        //self.rewardedVideoAd.show(fromRootViewController: UIApplication.shared.keyWindow?.rootViewController)
        
        print("@@@ delay %d", delay)
        
        if 0 < delay {
            let time = DispatchTime.now() + .seconds(delay)
            DispatchQueue.main.asyncAfter(deadline: time) {
                self.rewardedVideoAd.show(fromRootViewController: (UIApplication.shared.keyWindow?.rootViewController)!)
            }
        } else {
            self.rewardedVideoAd.show(fromRootViewController: (UIApplication.shared.keyWindow?.rootViewController!)!)
        }
        return true
    }
    
    func destroyAd() -> Bool {
        if nil == self.rewardedVideoAd {
            return false
        } else {
            rewardedVideoAd.delegate = nil
            rewardedVideoAd = nil
        }
        return true
    }
    
    
    /**
     Sent after an ad in the FBRewardedVideoAd object is clicked. The appropriate app store view or
     app browser will be launched.
     
     @param rewardedVideoAd An FBRewardedVideoAd object sending the message.
     */
    func rewardedVideoAdDidClick(_ rewardedVideoAd: FBRewardedVideoAd) {
        print("RewardedVideoAdView > rewardedVideoAdDidClick")
        
        let placement_id: String = rewardedVideoAd.placementID
        let invalidated: Bool = rewardedVideoAd.isAdValid
        let arg: [String: Any] = [
            FANConstant.PLACEMENT_ID_ARG: placement_id,
            FANConstant.INVALIDATED_ARG: invalidated,
        ]
        self.channel.invokeMethod(FANConstant.CLICKED_METHOD, arguments: arg)
    }
    
    /**
     Sent after an FBRewardedVideoAd object has been dismissed from the screen, returning control
     to your application.
     
     @param rewardedVideoAd An FBRewardedVideoAd object sending the message.
     */
    func rewardedVideoAdDidClose(_ rewardedVideoAd: FBRewardedVideoAd) {
        print("RewardedVideoAdView > rewardedVideoAdDidClose")
        //Add event for RewardedVideo dismissed.
        let placement_id: String = rewardedVideoAd.placementID
        let invalidated: Bool = rewardedVideoAd.isAdValid
        let arg: [String: Any] = [
            FANConstant.PLACEMENT_ID_ARG: placement_id,
            FANConstant.INVALIDATED_ARG: invalidated,
        ]
        self.channel.invokeMethod(FANConstant.REWARDED_VIDEO_CLOSED_METHOD, arguments: arg)
    }
    
    /**
     Sent immediately before an FBRewardedVideoAd object will be dismissed from the screen.
     
     @param rewardedVideoAd An FBRewardedVideoAd object sending the message.
     */
    func rewardedVideoAdWillClose(_ rewardedVideoAd: FBRewardedVideoAd) {
        print("RewardedVideoAdView > rewardedVideoAdWillClose")
    }
    
    /**
     Sent when an FBRewardedVideoAd successfully loads an ad.
     
     @param rewardedVideoAd An FBRewardedVideoAd object sending the message.
     */
    func rewardedVideoAdDidLoad(_ rewardedVideoAd: FBRewardedVideoAd) {
        print("RewardedVideoAdView > rewardedVideoAdDidLoad")
        
        let placement_id: String = rewardedVideoAd.placementID
        let invalidated: Bool = rewardedVideoAd.isAdValid
        let arg: [String: Any] = [
            FANConstant.PLACEMENT_ID_ARG: placement_id,
            FANConstant.INVALIDATED_ARG: invalidated,
        ]
        self.channel.invokeMethod(FANConstant.LOADED_METHOD, arguments: arg)
    }
    
    /**
     Sent when an FBRewardedVideoAd failes to load an ad.
     
     @param rewardedVideoAd An FBRewardedVideoAd object sending the message.
     @param error An error object containing details of the error.
     */
    func rewardedVideoAd(_ rewardedVideoAd :FBRewardedVideoAd, didFailWithError error: Error) {
        print("RewardedVideoAdView > rewardedVideoAd failed")
        print(error.localizedDescription)
        
        let placement_id: String = rewardedVideoAd.placementID
        let invalidated: Bool = rewardedVideoAd.isAdValid
        let arg: [String: Any] = [
            FANConstant.PLACEMENT_ID_ARG: placement_id,
            FANConstant.INVALIDATED_ARG: invalidated,
        ]
        self.channel.invokeMethod(FANConstant.ERROR_METHOD, arguments: arg)
    }
    
    /**
     Sent immediately before the impression of an FBRewardedVideoAd object will be logged.
     
     @param rewardedVideoAd An FBRewardedVideoAd object sending the message.
     */
    func rewardedVideoAdVideoComplete(_ rewardedVideoAd: FBRewardedVideoAd) {
        print("RewardedVideoAdView > rewardedVideoAdVideoComplete")
        
        let placement_id: String = rewardedVideoAd.placementID
        let invalidated: Bool = rewardedVideoAd.isAdValid
        let arg: [String: Any] = [
            FANConstant.PLACEMENT_ID_ARG: placement_id,
            FANConstant.INVALIDATED_ARG: invalidated,
        ]
        self.channel.invokeMethod(FANConstant.REWARDED_VIDEO_COMPLETE_METHOD, arguments: arg)
    }
}
