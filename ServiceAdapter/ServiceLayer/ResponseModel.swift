//
//  ResponseModel.swift
//  Demo
//
//  Created by neeraj on 07/06/18.
//  Copyright © 2018 neeraj. All rights reserved.
//

import Foundation

struct ResponseModel {
    var requestName:String
    var _status:String?
    var status:String? {
        set { _status = newValue }
        get { return _status }
    }
    var error:String?
    var data: Any?
    
    init(requestName: String) {
        self.requestName = requestName
    }

}
