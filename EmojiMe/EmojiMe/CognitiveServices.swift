//
//  CognitiveServices.swift
//  Social Tagger
//
//  Created by Alexander Repty on 16.05.16.
//  Copyright © 2016 maks apps. All rights reserved.
//

import Foundation
import UIKit

/**
 Possible values for detected emotions in images.
 */
enum CognitiveServicesEmotion: String {
    case Anger
    case Contempt
    case Disgust
    case Fear
    case Happiness
    case Neutral
    case Sadness
    case Surprise
}

/**
 *  Wrapper type for an emotioni result. Specifies the frame of the face in the image's coordinate space and the most
 *  likely emotion.
 */
struct CognitiveServicesEmotionResult {
    let frame: CGRect
    let emotion: CognitiveServicesEmotion
}

/// Result closure type for callbacks.
typealias EmotionResult = ([CognitiveServicesEmotionResult]?, NSError?) -> (Void)

//MARK: Subscription key and Endpoint URL reside here!!!
/// Fill in your API key here after getting it from https://www.microsoft.com/cognitive-services/en-US/subscriptions
let CognitiveServicesEmotionAPIKey = ""
let CognitiveServicesEmotionEndpointURL = ""


/// Caseless enum of available HTTP methods.
/// See https://dev.projectoxford.ai/docs/services/5639d931ca73072154c1ce89/operations/563b31ea778daf121cc3a5fa for details
enum CognitiveServicesHTTPMethod {
    static let POST = "POST"
}

/// Caseless enum of available HTTP header keys.
/// See https://dev.projectoxford.ai/docs/services/5639d931ca73072154c1ce89/operations/563b31ea778daf121cc3a5fa for details
enum CognitiveServicesHTTPHeader {
    static let SubscriptionKey = "Ocp-Apim-Subscription-Key"
    static let ContentType = "Content-Type"
}

/// Caseless enum of available HTTP content types.
/// See https://dev.projectoxford.ai/docs/services/5639d931ca73072154c1ce89/operations/563b31ea778daf121cc3a5fa for details
enum CognitiveServicesHTTPContentType {
    static let JSON = "application/json"
    static let OctetStream = "application/octet-stream"
    static let FormData = "multipart/form-data"
}

/// Caseless enum of available JSON dictionary keys for the service's reply.
/// See https://dev.projectoxford.ai/docs/services/5639d931ca73072154c1ce89/operations/563b31ea778daf121cc3a5fa for details
enum CognitiveServicesKeys {
    static let Name = "name"
    static let Confidence = "confidence"
    static let FaceRectangle = "faceRectangle"
    static let FaceAttributes = "faceAttributes"
    static let Height = "height"
    static let Left = "left"
    static let Top = "top"
    static let Width = "width"
    static let Anger = "anger"
    static let Contempt = "contempt"
    static let Disgust = "disgust"
    static let Fear = "fear"
    static let Happiness = "happiness"
    static let Neutral = "neutral"
    static let Sadness = "sadness"
    static let Surprise = "surprise"
}

/// Caseless enum of available Face Attributes.
/// See https://westus.dev.cognitive.microsoft.com/docs/services/563879b61984550e40cbbe8d/operations/563879b61984550f30395236 for details
enum FaceAttributes {
    static let age = "age"
    static let gender = "gender"
    static let headPose = "headPose"
    static let smile = "smile"
    static let facialHair = "facialHair"
    static let glasses = "glasses"
    static let emotion = "emotion"
    static let hair = "hair"
    static let makeup = "makeup"
    static let occlusion = "occlusion"
    static let accessories = "accessories"
    static let blur = "blur"
    static let exposure = "exposure"
    static let noise = "noise"
}

/// Caseless enum of available request parameters.
/// See https://westus.dev.cognitive.microsoft.com/docs/services/563879b61984550e40cbbe8d/operations/563879b61984550f30395236 for details
enum RequestParams {
    static let FaceId = "returnFaceId"
    static let FaceLandmarks = "returnFaceLandmarks"
    static let FaceAttributes = "returnFaceAttributes"
    static let RecognitionModel = "recognitionModel"
    static let RecognitionModelBoolean = "returnRecognitionModel"
    static let DetectionModel = "detectionModel"
}

/// Lowest level results for both face rectangles and emotion scores. A hit represents one face and its range of emotions.
typealias EmotionReplyHit = Dictionary<String, AnyObject>
/// Wrapper type for an array of hits (i.e. faces). This is the top-level JSON object.
typealias EmotionReplyType = Array<EmotionReplyHit>

/// Caseless enum of various configuration parameters.
/// See https://dev.projectoxford.ai/docs/services/56f91f2d778daf23d8ec6739/operations/56f91f2e778daf14a499e1fa for details
enum CognitiveServicesConfiguration {
    static let EmotionURL = CognitiveServicesEmotionEndpointURL
    static let JPEGCompressionQuality = 0.9 as CGFloat
}

class CognitiveServicesManager: NSObject {
    
    /**
     Retrieves scores for a range of emotions and calls the completion closure with the most suitable one.
     
     - parameter image:      The image to analyse.
     - parameter completion: Callback closure.
     */
    func retrievePlausibleEmotionsForImage(_ image: UIImage, completion: @escaping EmotionResult) {
        assert(CognitiveServicesEmotionAPIKey.count > 0, "Please set the value of the API key variable (CognitiveServicesEmotionAPIKey) before attempting to use the application.")
        assert(CognitiveServicesEmotionEndpointURL.count > 0, "Please set the value of the URL Endpoint variable (CognitiveServicesEmotionEndpointURL) before attempting to use the application.")
        
        var mutableURL = URLComponents(string: CognitiveServicesConfiguration.EmotionURL)!
        mutableURL.path = "/face/v1.0/detect"
        
        mutableURL.queryItems = [
            URLQueryItem(name: RequestParams.FaceAttributes, value: FaceAttributes.emotion)
        ]
        
        //let url = URL(string: CognitiveServicesConfiguration.EmotionURL)
        let request = NSMutableURLRequest(url: mutableURL.url!)

        // The subscription key is always added as an HTTP header field.
        request.addValue(CognitiveServicesEmotionAPIKey, forHTTPHeaderField: CognitiveServicesHTTPHeader.SubscriptionKey)
        // We need to specify that we're sending the image as binary data, since it's possible to supply a JSON-wrapped URL instead.
        request.addValue(CognitiveServicesHTTPContentType.OctetStream, forHTTPHeaderField: CognitiveServicesHTTPHeader.ContentType)
        
        // Convert the image reference to a JPEG binary to submit to the service. If this ends up being over 4 MB, it'll throw an error
        // on the server side. In a production environment, you would check for this condition and handle it gracefully (either reduce
        // the quality, resize the image or prompt the user to take an action).
        let requestData = image.jpegData(compressionQuality: 0.9)
        request.httpBody = requestData
        request.httpMethod = CognitiveServicesHTTPMethod.POST
        
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            if let error = error {
                // In case of an error, handle it immediately and exit without doing anything else.
                completion(nil, error as NSError)
                return
            }
            
            if let data = data {
                do {
                    let collectionObject = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
                    var result = [CognitiveServicesEmotionResult]()
                    
                    if let array = collectionObject as? EmotionReplyType {
                        // This is an array of hits, i.e. faces with associated emotions. We iterate through it and
                        // try to get a complete set of coordinates and the most suitable emotion rating for every one.
                        for hit in array {
                            // See if all necessary coordinates for a rectangle are there and create a native data type
                            // with the information.
                            var resolvedFrame: CGRect? = nil
                            if
                                let frame = hit[CognitiveServicesKeys.FaceRectangle] as? Dictionary<String, Int>,
                                let top = frame[CognitiveServicesKeys.Top],
                                let left = frame[CognitiveServicesKeys.Left],
                                let height = frame[CognitiveServicesKeys.Height],
                                let width = frame[CognitiveServicesKeys.Width]
                            {
                                resolvedFrame = CGRect(x: left, y: top, width: width, height: height)
                            }
                            
                            // Store all face attributes in an array
                            let faceAttributes = hit[CognitiveServicesKeys.FaceAttributes]
                            
                            // Find all the available emotions and see which is the highest scoring one.
                            var emotion: CognitiveServicesEmotion? = nil
                            if
                                let emotions = faceAttributes?[FaceAttributes.emotion] as? Dictionary<String, Double>,
                                let anger = emotions[CognitiveServicesKeys.Anger],
                                let contempt = emotions[CognitiveServicesKeys.Contempt],
                                let disgust = emotions[CognitiveServicesKeys.Disgust],
                                let fear = emotions[CognitiveServicesKeys.Fear],
                                let happiness = emotions[CognitiveServicesKeys.Happiness],
                                let neutral = emotions[CognitiveServicesKeys.Neutral],
                                let sadness = emotions[CognitiveServicesKeys.Sadness],
                                let surprise = emotions[CognitiveServicesKeys.Surprise]
                            {
                                var maximumValue = 0.0
                                for value in [anger, contempt, disgust, fear, happiness, neutral, sadness, surprise] {
                                    if value <= maximumValue {
                                        continue
                                    }
                                    
                                    maximumValue = value
                                }
                                
                                if anger == maximumValue {
                                    emotion = .Anger
                                } else if contempt == maximumValue {
                                    emotion = .Contempt
                                } else if disgust == maximumValue {
                                    emotion = .Disgust
                                } else if fear == maximumValue {
                                    emotion = .Fear
                                } else if happiness == maximumValue {
                                    emotion = .Happiness
                                } else if neutral == maximumValue {
                                    emotion = .Neutral
                                } else if sadness == maximumValue {
                                    emotion = .Sadness
                                } else if surprise == maximumValue {
                                    emotion = .Surprise
                                }
                            }
                            
                            // If we have both a rectangle and an emotion, we have enough information to store this as
                            // a result set and eventually return it to the caller.
                            if let frame = resolvedFrame, let emotion = emotion {
                                result.append(CognitiveServicesEmotionResult(frame: frame, emotion: emotion))
                            }
                        }
                    }
                    
                    completion(result, nil)
                    return
                }
                catch _ {
                    completion(nil, error! as NSError)
                    return
                }
            } else {
                completion(nil, nil)
                return
            }
        }
        
        task.resume()
    }
}
