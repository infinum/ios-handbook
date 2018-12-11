## Demo manager and API call mocking

If the project you're working on requires you to build a demo version of your application or the API is not working at the moment (but you have some specification ready), your first thought might be to add an additional parameter to your API calls specifying whether the call should be executed or mocked. This would work, but also require a lot of copy-pasting, and every new API call you implement should follow this same logic. 

It would get tiring quickly, so we've decided to make something better - a `demo manager`.

Its responsibility should be two things:

* hooking onto every API call your application makes,
* filtering those API calls in the following way:
  * if it should be mocked -> read the response from stored file and forward it to the interactor
  * if it shouldn't be mocked -> make an API call to the server

For API call mocking we'll be using [OHTTPStubs](https://github.com/AliSoftware/OHHTTPStubs), a library designed to stub network requests by using method swizzling. It works with `NSURLConnection`, `NSURLSession`, `AFNetworking`, `Alamofire` or any networking frameworks that use Cocoa's URL Loading System, so it's perfect for our use case.

This is what it looks like in code, step-by-step.

```swift
import UIKit
import Alamofire
import OHHTTPStubs

class DemoManager {
    
    static var instance = DemoManager()
    
    var isEnabled: Bool {
        get { return !OHHTTPStubs.allStubs().isEmpty }
        set(newValue) {
            switch newValue {
            case true: setupStubResponses()
            case false: OHHTTPStubs.removeAllStubs()
            }
        }
    }
    
    private init() {}
    
}
```

Our demo manager here is a singleton, with one variable used for switching it on/off. This single point of entry allows us great flexibility - if we want to mock everything in the application, all we have to do is just set the `isEnabled` parameter to `true` once at the start. However, if we want more specificity, we can start API call mocking only when we get to the screen which still doesn't have an API implementation ready on the backend side, and turn it off when we leave this screen.

```swift
private extension DemoManager {
    
    func setupStubResponses() {

        stubSomething()
        stubUpdatingSomething()
        stubSomethingWithPagination()
        
    }

    func stubSomething() {

        stubResponse(
            containing: Router.Something.path,
            statusCode: 200,
            from: "something_mocked"
        )

    }

    func stubUpdatingSomething() {

        stubResponse(
            containing: Router.Transactions.updateCategoryPath,
            method: .patch,
            statusCode: 200
        )

    }

    func stubSomethingWithPagination() {

        stubResponse(
            containing: Router.PaginatedSomething.path,
            queryParamPart: "cursor=1",
            statusCode: 200,
            from: "something_paginated"
        )

    }
    
}
```

Here we can see the implementation of our `setupStubResponses()` method. 
It stubs three different API calls with responses from two json files - `something_mocked`, and `something_paginated`, while the third call is mocked with just a 200 code telling us that the call was successful. Each call, is mocked using the `stubResponse()` method with individual filtering parameters.

```swift
private extension DemoManager {
    
    func stubResponse(
        containing urlPart: String,
        queryParamPart: String? = nil,
        requiredHeaderValues: String?...,
        bodyPart: [String]? = nil,
        method: HTTPMethod? = .get,
        statusCode: Int32 = 200,
        from fileName: String? = nil
        ) {
        
        stub(
            condition: { (request: URLRequest) -> Bool in
                //Method
                if let method = method?.rawValue.uppercased(), request.httpMethod?.uppercased() != method { return false }

                //URL, query
                if !(request.url?.absoluteString.contains(urlPart) ?? false) { return false }
                if let part = queryParamPart, !(request.url?.absoluteString.contains(part) ?? false) { return false }

                //Body
                if let parts = bodyPart,
                    let data = request.httpBody,
                    let body = String(data: data, encoding: .utf8) {
                    let bodyPartsPresent = parts
                        .map { body.contains($0) }
                        .reduce(true, Bool.and)
                    if !bodyPartsPresent { return false }
                }
                
                //Headers
                let headers = request.allHTTPHeaderFields ?? [:]
                let headersOk = requiredHeaderValues
                    .compactMap { $0 }
                    .map { (headerValue) in return headers.contains { $0.value == headerValue } }
                    .reduce(true, Bool.and)
                
                if !headersOk { return false }

                return true
            },
            response: { _ -> OHHTTPStubsResponse in
                guard let _fileName = fileName else {
                    return OHHTTPStubsResponse(data: Data(), statusCode: statusCode, headers: nil)
                }
                
                let path = Bundle.main.path(forResource: _fileName, ofType: "json") ?? ""
                let headers = ["Content-Type": "application/json"]
                
                return fixture(filePath: path, status: statusCode, headers: headers)
            }
        )
    }
    
}
```

This method is where the magic happens. It calls OHTTPStubs's `stub()` method which does the API call mocking, using two closures - `condition` and `response`.

### Condition closure

If the condition closure returns `true`, the response closure will be executed and the API call will not be passed throught to the server, otherwise it will be executed normally.
In our implementation, we check whether several parameters of the API call are included to determine whether we should mock it:

* API call URL is the only required parameter in our `stubResponse()` implementation, and it should match the one in the call itself
* queryParamPart - optional parameter specifying the specific query parameter we need in the API call
* requiredHeaderValues - optional array of header values that are required to be in the call, otherwise it won't be mocked
* bodyPart - optional array of request body values
* method - optional parameter specifying request method, default is `GET`

If all our checks are successful, response closure is called for mocking the API call. Otherwise, the call shouldn't be mocked and it's forwarded to the server.

### Response closure

Response closure is used to create the mocked response, and it uses two parameters passed into the `stubResponse()` - `statusCode` and `fileName`. We load our mocked response from the file in our bundle using the specified file name and create the mocked response using the provided status code.

### Closing words

As you can see, demo manager has a wide variety of use, from showing everything your application has to offer without firing a single actual API call to making development faster when waiting for the API team to do their part.

One thing not mentioned above is the usefulness of OHTTPSStubs for writing tests - it can be used to write test covering both cases when the API is working as intended and to mock bad responses, and all you need for that is the `stubResponse()` implementation inside your testing environment.
