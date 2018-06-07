//
//  ServiceAdapter.swift
//  Demo
//
//  Created by neeraj on 07/06/18.
//  Copyright © 2018 neeraj. All rights reserved.
//

import Foundation

class ServiceAdapter: NSObject, URLSessionDelegate {
    
    var dataTask: URLSessionDataTask?
    let SERVICE_PREFIX = WebService.SERVICE_PREFIX
	
	func initiateGetRequest(_ requestName:String, needAuth:Bool = false, queryString:String = "", completion: @escaping (ResponseModel) -> Void) {
        
        let requestURL = SERVICE_PREFIX + requestName + "?\(queryString)"
        guard let encodedURL = requestURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }//Throw Error Here

		getRequest(encodedURL, requestName: requestName, needAuth: needAuth, completion: completion)
    }
	
	private func getRequest(_ getRequestURL:String, requestName:String, needAuth:Bool, completion: @escaping (ResponseModel) -> Void) {
        
        guard let url = URL(string: getRequestURL) else { return } // Throw Error here
		let request = NSMutableURLRequest(url: url, cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 10.0)
		request.httpMethod = "GET"
        let session = URLSession.shared
        var responseModel = ResponseModel(requestName: requestName)
        dataTask = session.dataTask(with: request as URLRequest) { data, response, error in

            if error != nil {
                responseModel.status = ServiceResponseMessage.FAILURE
                responseModel.error = ServiceResponseMessage.NETWORK_FAILURE
                completion(responseModel)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
				if(httpResponse.statusCode == 200) {
                    
                    responseModel.status = ServiceResponseMessage.SUCCESS
                    guard let responseData = data else { return } // Throw Error from 
                    do {
                        responseModel.data = try self.parseResult(responseData)
                    } catch GenericErrors.parsingError {
                        print("Parsing Error occured")
                    }  catch {
                        print("Error occured")
                    }
                    
				} else if(httpResponse.statusCode == 401) {
                    
                    responseModel.status = ServiceResponseMessage.FAILURE
                    responseModel.error = ServiceResponseMessage.SERVER_ERROR
				} else {

                    responseModel.status = ServiceResponseMessage.FAILURE
                    responseModel.error = ServiceResponseMessage.INVALID_DATA
				}
			} else {
                
                responseModel.status = ServiceResponseMessage.FAILURE
                responseModel.error = ServiceResponseMessage.NETWORK_FAILURE
			}
			
            completion(responseModel)
			self.suspendDataService()
        }
		dataTask?.resume()
    }
	
    private func suspendDataService() {
        dataTask?.suspend()
    }
    
    private func parseResult (_ data: Data) throws -> Any {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
            
            if let dataDict = jsonObject as? NSDictionary {
                return dataDict
            }
                
            if let dataArray = jsonObject as? NSArray {
                return dataArray
            }
        } catch {
                throw GenericErrors.parsingError
            }
        throw GenericErrors.parsingError
    }
}

extension NSMutableData {
	
	func appendString(_ string: String) {
        guard let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true) else { return }
		append(data) //Throw error from return
	}
}
