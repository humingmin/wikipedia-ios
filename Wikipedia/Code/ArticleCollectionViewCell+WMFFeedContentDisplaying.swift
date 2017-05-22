import Foundation

public extension ArticleCollectionViewCell {
    public func configure(article: WMFArticle, contentGroup: WMFContentGroup, displayType: WMFFeedDisplayType, layoutOnly: Bool) {
        let imageWidthToRequest = imageView.frame.size.width < 300 ? traitCollection.wmf_nearbyThumbnailWidth : traitCollection.wmf_leadImageWidth // 300 is used to distinguish between full-width images and thumbnails. Ultimately this (and other thumbnail requests) should be updated with code that checks all the available buckets for the width that best matches the size of the image view. 
        if displayType != .mainPage, let imageURL = article.imageURL(forWidth: imageWidthToRequest) {
            isImageViewHidden = false
            if !layoutOnly {
                imageView.wmf_setImage(with: imageURL, detectFaces: true, onGPU: true, failure: { [weak self] (error) in self?.isImageViewHidden = true }, success: { })
            }
        } else {
            isImageViewHidden = true
        }
        let articleLanguage = (article.url as NSURL?)?.wmf_language
        titleLabel.text = article.displayTitle
        switch displayType {
        case .pageWithPreview:
            backgroundColor = .white
            imageViewDimension = 196
            isSaveButtonHidden = false
            titleTextStyle = .body
            titleFontFamily = .georgia
            descriptionTextStyle = ArticleCollectionViewCell.defaultDescriptionTextStyle
            descriptionLabel.text = article.capitalizedWikidataDescription
            extractLabel?.text = article.snippet
        case .continueReading:
            backgroundColor = .white
            imageViewDimension = 150
            extractLabel?.text = nil
            isSaveButtonHidden = true
            titleTextStyle = .body
            titleFontFamily = .georgia
            descriptionTextStyle = ArticleCollectionViewCell.defaultDescriptionTextStyle
            descriptionLabel.text = article.capitalizedWikidataDescriptionOrSnippet
            extractLabel?.text = nil
        case .relatedPagesSourceArticle:
            backgroundColor = .wmf_lightGrayCellBackground
            imageViewDimension = 150
            extractLabel?.text = nil
            isSaveButtonHidden = true
            titleTextStyle = .body
            titleFontFamily = .georgia
            descriptionTextStyle = ArticleCollectionViewCell.defaultDescriptionTextStyle
            descriptionLabel.text = article.capitalizedWikidataDescriptionOrSnippet
            extractLabel?.text = nil
        case .relatedPages:
            backgroundColor = UIColor.white
            imageViewDimension = ArticleCollectionViewCell.defaultImageViewDimension
            isSaveButtonHidden = false
            titleTextStyle = .body
            titleFontFamily = .system
            descriptionTextStyle = ArticleCollectionViewCell.defaultDescriptionTextStyle
            descriptionLabel.text = article.capitalizedWikidataDescriptionOrSnippet
            extractLabel?.text = nil
        case .mainPage:
            backgroundColor = .white
            imageViewDimension = ArticleCollectionViewCell.defaultImageViewDimension
            isSaveButtonHidden = true
            titleTextStyle = .body
            titleFontFamily = .system
            descriptionTextStyle = ArticleCollectionViewCell.defaultDescriptionTextStyle
            descriptionLabel.text = article.capitalizedWikidataDescription ?? WMFLocalizedString("explore-main-page-description", value: "Main page of Wikimedia projects", comment: "Main page description that shows when the main page lacks a Wikidata description.")
            extractLabel?.text = nil
        case .page:
            fallthrough
        default:
            backgroundColor = .white
            imageViewDimension = 40
            isSaveButtonHidden = true
            titleTextStyle = .subheadline
            titleFontFamily = .system
            descriptionTextStyle = .footnote
            descriptionLabel.text = article.capitalizedWikidataDescriptionOrSnippet
            extractLabel?.text = nil
        }
        
        titleLabel.accessibilityLanguage = articleLanguage
        descriptionLabel.accessibilityLanguage = articleLanguage
        extractLabel?.accessibilityLanguage = articleLanguage
        articleSemanticContentAttribute = MWLanguageInfo.semanticContentAttribute(forWMFLanguage: articleLanguage)
        setNeedsLayout()
    }
}
