<div class="markdown-output__summary">
  Basic overview of networking and working with a REST API backend.
</div>

## Networking
If your app is going to communicate with a remote server you will find useful the following list of [pods][7]:

* [Alamofire][1] - used for HTTP networking. On the off-chance that you're actually starting an Objective-C based project you'll be working with [AFNetworking][2] instead. Both of these libraries are developed by the same team who are responsible for [nshipster.com][3] - a site you should really keep in your bookmarks.
* [Unbox][4] - a [JSON][5] parser. In almost all cases the data you receive from the remote server will be in a JSON format. Again in the unlikely event of starting an Objective-C based project you'll probably use [JSONModel][6] or [Mantle][7].
* [UnboxedAlamofire][8] - utility extensions for Alamofire + Unbox.
* [Wrap][9] - a JSON encoding library. Useful for transforming models into JSON objects.

## REST API and services
In almost all cases the architecture of the web service your app is communicating with will be implemented using a RESTful architecture style. A simple and easy explanation of REST APIs can be found [here][10]. For a more theoretical description of REST you can go [here][11].

When communicating with RESTful API it's quite easy to separate networking into services which is precisely what we do. Services are PONSOs (plain old NSObject) which handle all API requests for one particular segment of the API. Here's an example of a service which handles a login action using UnboxedAlamofire:

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
        ).validate().responseObject(completionHandler: completionHandler)
    }
    
}
```

Here you can also see our standard pattern of handling API requests. The most elegant way is to have one method/function per API request which accepts parameters needed for the API request and completion block.

You might wonder why not use class methods for such requests. The answer is testability. Using instances for services means you can easily swap them with test classes which mock responses.

## Error handling with Alamofire

When you use Alamofire, you can create your own method for validation. You just need to create an extension on DataRequest and implement custom logic for validation. For example:

```swift
import Alamofire

extension DataRequest {

    func customValidate() -> Self {
        return validate { (request, response, data) -> Request.ValidationResult in
            // custom validation logic
            guard let error: CustomError = try? unbox(data: data) else {
                return .success
            }
            return .failure(error)
        }
    }

}
```

Then an API request can look like:

```swift
Alamofire.request(url).customValidate().validate().response { (response) in
	// handle response
}
```

You can create more than one custom validation method and you can chain them when you are performing an API request. For example, you might have one method for each type of the error that an API can return. In the example above, you can see `customValidate()` and built-in `validate()` methods in the chain. Keep in mind that you will get an error from the first method which has returned `.failure` as the result.

## Model mapping
### Handling IDs

When you’re creating a model that’ll be mapped to a JSON response, and it contains some kind of identifier (for example user ID, business ID, account ID, etc.), please always map it to a String. String is not so restrictive type and if somebody decides to change a type of an identifier on a server side, you won't have any problem with that. More and more backend developers use strings as identifiers and it is a good idea to follow that trend.

### Optionals and default values

Properties should always be optional if the API may not return them. Following code shows bad example where default values can produce unwanted results.

```swift
struct LotoResult {
    let draw: Draw
    let drawingDate: Date
    let prizes: [Prize] = [Prize]()
    let numbers: [Int]
    let extraNumber: Int = 0
}
```

Properties `prizes` and `extraNumber` always have a value because they are set to empty array and zero respectively by default. They will hold these values even if the API doesn’t return them. This is wrong because it hides the information that data do not exist in case of `prizes` property. In case of `extraNumber` it is even worse because it is an incorrect value.

Generally, you should always mark properties as optional and handle the logic accordingly when handling the response. Correct example would be:

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
[4]:	https://github.com/JohnSundell/Unbox
[5]:	http://www.json.org/
[6]:	https://github.com/icanzilb/JSONModel
[7]:	https://github.com/Mantle/Mantle
[8]:	https://github.com/serejahh/UnboxedAlamofire
[9]:	https://github.com/JohnSundell/Wrap
[10]:	http://searchsoa.techtarget.com/definition/REST
[11]:	https://en.wikipedia.org/wiki/Representational_state_transfer
<!--[7]:	https://cocoapods.org/-->