<div class="markdown-output__summary">
  Basic overview of networking and working with a REST API backend.
</div>

## Networking
If your app is going to communicate with a remote server, you will find the following list of [pods][7] useful:

* [Alamofire][1]—used for HTTP networking. On the off chance that you're actually starting an Objective-C based project, you'll be working with [AFNetworking][2] instead. Both of these libraries are developed by the same team who is responsible for [nshipster.com][3]—a site you should really keep in your bookmarks.
* [CodableAlamofire][4]—an extension for Alamofire that can convert [JSON][5] into Decodable objects. In almost all cases, the data you receive from the remote server will be in a JSON format. Again, in the unlikely event of starting an Objective-C based project, you'll probably use [JSONModel][6] or [Mantle][7].

## REST API and services
In almost all cases, the architecture of the web service your app is communicating with will be implemented using a RESTful architecture style. A simple and easy explanation of REST APIs can be found [here][8]. You can go [here][9] for a more theoretical description of REST.

When communicating with a RESTful API, it's quite easy to separate networking into services, which is precisely what we do. Services are PONSOs (plain old NSObject) that handle all API requests for one particular segment of the API. Here's an example of a service which handles a login action using CodableAlamofire:

```swift
class MenuService {

    @discardableResult
    func login(with username: String, password: String, completionHandler: @escaping LoginResponseBlock) -> DataRequest {
        let params: [String: String] = [
            "username": username,
            "password": password,
        ]
        let url: URL = URL(string: "https://example.com/login")!

        return Alamofire.request(
            url,
            method: .get,
            parameters: params
        ).validate().responseDecodableObject(completionHandler: completionHandler)
    }
    
}
```

Here, you can also see our standard pattern of handling API requests. The most elegant way is to have one method/function per an API request which accepts parameters necessary for the API request and completion block.

You might wonder why not use class methods for such requests. The answer is testability. Using instances for services means you can easily swap them for test classes which mock responses.

## Handling errors with Alamofire

When you use Alamofire, you can create your own method for validation. You just need to create an extension on DataRequest and implement custom logic for validation. For example:

```swift
import Alamofire

extension DataRequest {

    func customValidate() -> Self {
        return self.validate { _, response, data -> Request.ValidationResult in
            guard (400...599) ~= response.statusCode else { return .success }
            guard let data = data else { return .failure(MyAppGeneralError.generalResponseError) }

            guard let errorResponse = try? JSONDecoder().decode(MyAppResponseError.self, from: data) else {
                return .failure(MyAppGeneralError.generalResponseError)
            }

            if response.statusCode == 401 {
                return .failure(MyAppGeneralError.unauthorizedAccessError(errorResponse))
            }

            return .failure(MyAppGeneralError.responseError(errorResponse))
        }
    }

}
```

Then an API request can look like this:

```swift
Alamofire.request(url).customValidate().validate().response { (response) in
	// handle response
}
```

You can create more than one custom validation method and chain them when you are performing an API request. For example, you might have one method for each type of error that an API can return. In the example above, you can see `customValidate()` and the built-in `validate()` method in the chain. Keep in mind that you will get an error from the first method which returns `.failure` as the result.

## Model mapping
### Handling IDs

When you’re creating a model that’ll be mapped to a JSON response, and it contains some kind of identifier (for example, a user ID, business ID, account ID, etc.), please always map it to a string. Strings are not very restrictive, so if somebody decides to change the type of an identifier on the server side, you won't have any problems because of that. More and more backend developers use strings as identifiers, and it is a good idea to follow that trend.

### Optionals and default values

Properties should always be optional if the API may not return them. The following code shows a bad example of default values producing unwanted results.

```swift
struct LotoResult {
    let draw: Draw
    let drawingDate: Date
    let prizes: [Prize] = [Prize]()
    let numbers: [Int]
    let extraNumber: Int = 0
}
```

The `prizes` and `extraNumber` properties always have a value because they are set to empty array and zero by default. They will hold these values even if the API doesn’t return them. This is wrong because it hides the information that data do not exist in the case of the `prizes` property. It is even worse in the case of `extraNumber` because it is an incorrect value.

Generally, you should always mark properties as optional and handle the logic accordingly when handling the response. A correct example would be:

```swift
struct LotoResult {
    let draw: Draw
    let drawingDate: Date
    let prizes: [Prize]?
    let numbers: [Int]
    let extraNumber: Int?
}
```

[1]:	https://github.com/Alamofire/Alamofire
[2]:	https://github.com/AFNetworking/AFNetworking
[3]:	http://nshipster.com/
[4]:	https://github.com/Otbivnoe/CodableAlamofire
[5]:	http://www.json.org/
[6]:	https://github.com/icanzilb/JSONModel
[7]:	https://github.com/Mantle/Mantle
[8]:	http://searchsoa.techtarget.com/definition/REST
[9]:	ttps://en.wikipedia.org/wiki/Representational_state_transfer
<!--[7]:	https://cocoapods.org/-->
