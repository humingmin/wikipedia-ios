import UIKit
import MobileCoreServices
import CoreSpotlight

public extension NSURL {
    @available(iOS 9.0, *)
    func searchableItemAttributes() -> CSSearchableItemAttributeSet? {
        guard wmf_isWikiResource else {
            return nil
        }
        let searchableItem = CSSearchableItemAttributeSet(itemContentType: kUTTypeInternetLocation as String)
        searchableItem.keywords = ["Wikipedia","Wikimedia","Wiki"] + wmf_title.componentsSeparatedByString(" ")
        searchableItem.title = wmf_title
        searchableItem.displayName = wmf_title
        searchableItem.identifier = NSURL.wmf_desktopURLForURL(self).absoluteString
        searchableItem.relatedUniqueIdentifier = NSURL.wmf_desktopURLForURL(self).absoluteString
        return searchableItem
    }
}

public extension MWKArticle {
    @available(iOS 9.0, *)
    func searchableItemAttributes() -> CSSearchableItemAttributeSet {
        let searchableItem = url.searchableItemAttributes() ??
                CSSearchableItemAttributeSet(itemContentType: kUTTypeInternetLocation as String)

        searchableItem.subject = entityDescription
        searchableItem.contentDescription = summary()
        if (imageURL != nil) {
            if let url = NSURL(string: imageURL) {
                searchableItem.thumbnailData = WMFImageController.sharedInstance().diskDataForImageWithURL(url);
            }
        }
        return searchableItem
    }
}

@available(iOS 9.0, *)

public class WMFSavedPageSpotlightManager: NSObject {
    
    let dataStore: MWKDataStore
    var savedPageList: MWKSavedPageList {
        return dataStore.savedPageList
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    public required init(dataStore: MWKDataStore) {
        self.dataStore = dataStore
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(WMFSavedPageSpotlightManager.didUpdateItem(_:)), name: MWKItemUpdatedNotification, object: nil)
    }
    
    public func reindexSavedPages() {
        self.savedPageList.enumerateItemsWithBlock { (item, stop) in
            self.addToIndex(item.url)
        }
    }
    
    func didUpdateItem(notification: NSNotification){
        if let url = notification.userInfo?[MWKURLKey] as? NSURL {
            if self.savedPageList.isSaved(url){
                addToIndex(url)
            }else{
                removeFromIndex(url)
            }
        }
    }
    
    func addToIndex(url: NSURL) {
        if let article = dataStore.existingArticleWithURL(url) {
            

            let searchableItemAttributes = article.searchableItemAttributes()
            searchableItemAttributes.keywords?.append("Saved")
            
            let item = CSSearchableItem(uniqueIdentifier: NSURL.wmf_desktopURLForURL(url).absoluteString, domainIdentifier: "org.wikimedia.wikipedia", attributeSet: searchableItemAttributes)
            item.expirationDate = NSDate.distantFuture()
            
            CSSearchableIndex.defaultSearchableIndex().indexSearchableItems([item]) { (error: NSError?) -> Void in
                if let error = error {
                    DDLogError("Indexing error: \(error.localizedDescription)")
                } else {
                    DDLogVerbose("Search item successfully indexed!")
                }
            }
        }
    }
    
    func removeFromIndex(url: NSURL) {
        CSSearchableIndex.defaultSearchableIndex().deleteSearchableItemsWithIdentifiers([NSURL.wmf_desktopURLForURL(url).absoluteString!]) { (error: NSError?) -> Void in
            if let error = error {
                DDLogError("Deindexing error: \(error.localizedDescription)")
            } else {
                DDLogVerbose("Search item successfully removed!")
            }
            
        }
    }

}


