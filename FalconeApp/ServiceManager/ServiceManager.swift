//
//  ServiceManager.swift
//  FalconeApp
//
//  Created by praveen on 3/2/19.
//  Copyright © 2019 hmm. All rights reserved.
//

import Foundation

class ServiceManager {
    
    func makeGetCall(url: String,
                     successHandler: @escaping SuccessBlock,
                     failureHandler: @escaping FailureBlock) {
        guard let url = URL(string: url) else {
            failureHandler("Invalid URL", nil)
            return
        }
        let urlRequest = URLRequest(url: url)
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            guard error == nil else {
                failureHandler(error, nil)
                return
            }
            guard let _ = data else {
                failureHandler("Unable to parse data", nil)
                return
            }
            successHandler(data, nil)
        }
        task.resume()
    }
    
    func makePostCall(url: String,
                      data: Data?,
                      successHandler: @escaping SuccessBlock,
                      failureHandler: @escaping FailureBlock) {
        guard let url = URL(string: url) else {
            print("Error: cannot create URL")
            return
        }
        var todosUrlRequest = URLRequest(url: url)
        todosUrlRequest.httpMethod = "POST"
        var httpHeaders = [String : String]()
        httpHeaders["Content-Type"] = "application/json"
        httpHeaders["Accept"] = "application/json"
        todosUrlRequest.allHTTPHeaderFields = httpHeaders
        if data != nil {
            todosUrlRequest.httpBody = data
        }
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: todosUrlRequest) {
            (data, response, error) in
            guard error == nil else {
                print("error calling POST on ")
                print(error!)
                return
            }
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            
            // parse the result as JSON, since that's what the API provides
            do {
                guard let receivedTodo = try JSONSerialization.jsonObject(with: responseData,
                                                                          options: []) as? [String: Any] else {
                                                                            print("Could not get JSON from responseData as dictionary")
                                                                            return
                }
                print("The todo is: " + receivedTodo.description)
                successHandler(data, nil)
            } catch  {
                print("error parsing response from POST on /todos")
                return
            }
        }
        task.resume()
    }
    
    
    
    
    
    
    
}


