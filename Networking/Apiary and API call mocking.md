## What is Apiary? 

Apiary is that tool that lets you build your API extremely fast, allows you to build functional API in a single day, sometimes even a few hours. 

## How does it work?

You can look at Apiary like an online collection of `JSON` responses with a bit more power. You get some base URL and all you have to do is define `endpoints` and their `response`. Example of one such response can be seen below :

```json

## Some API Endpoint [/apiEndpoint]

### GET some information [GET]

+ Response 200 (application/json)

        [
            {
                "information": "Favourite programming language?",
                "published_at": "2015-08-05T08:40:51.620Z",
                "choices": [
                    {
                        "choice": "Swift",
                        "votes": 1
                    }
                ]
            }
        ]

### POST some information [POST]

+ Response 201 (application/json)

    + Headers

            Location: /collection/2

    + Body

            {
                "information": "Favourite programming language?",
                "published_at": "2015-08-05T08:40:51.620Z",
                "choices": [
                    {
                        "choice": "Swift",
                        "votes": 2
                    } 
                ]
            }

```
Apiary usually uses `API Blueprint`, a powerful high-level API description language for web APIs, more details on that can be found [here](https://apiblueprint.org).


## Why Apiary ?

Here are some of reasons why you might want to add apiary to your project: 

* **Easy to learn**, not just for developers, but for testers also

* **Multiplatform sync**, once written API can be used for iOS, Android or Web 

* **Time-saving**, takes only **1** person to setup mock for multiple platforms

* **Documentation!** As you write your responses, apiary will automatically generate great documentation

* **Traffic inspector** - one click away from all of the API traffic

* **Easy changes**, no need to rebuild project to apply changes, just edit apiary

* **Improves testability**, QA can go through most test cases without support of the backend

* Because it is **awesome**
  

## Know your limits

Here are some of the limitations of apiary:

* **You need network connection** - no internet, no mocking

* **Backend Speed**, Apiary is usually very fast so developers might get a wrong feeling about some response times

* **Changes**, if the app has to update some value, it might be a bit harder to mock

* **Editing by hand**, all the mocks are just one large JSON file

* **Merging**, multiple people editing at the same time

* **Privacy**, responses are publically available, clients might dislike that, this is the reason why you will need to ask your clients to use apiary

## Apiary setup

Step 1 

* Visit [Apiary.io](https://apiary.io), sign up and enter your information.

Step 2

* Give your API a name, your project name should be fine, and pick API format; You can choose between `Api Blueprint` and `Swagger`. If you are not sure which format to pick, just go with the default.

Step 3

* Already Done? Almost. Now navigate to `Inspector`. Here you can see all of the latest requests, however at the moment that will probably be empty. Right now you should see something like this: `Listening at https://some-private-link-here.com` . Now copy that link!

Step 4

* Go back to `Editor`. Replace `HOST: https://polls.apiblueprint.org/` with `HOST: https://that-private-link-you-just-copied.com`

At this moment setup is done and you should end up with something like this:
 
![Default](https://i.imgur.com/BHfNWfT.png)

[ 1 ] = Base URL

[ 2 ] = API Endpoint

[ 3 ] = Method that will be used, `GET` / `POST` / `DELETE` ...

[ 4 ] = In case you liked Apiary and want to create a bigger team.

[ 5 ] = Save button, you should press it after every change

[ 6 ] = Add up to 5 people to project for free

[ 7 ] = Navigation between multiple APIs

Now all you have to do is add a bunch of endpoints along with their responses and voila, you have your API mock :)

## Connecting you app with apiary

First of all there are multiple ways to connect apiary with your app, you can use mocking for the whole app or only a few screens. In the example below will be shown how to set up a mock for the whole app.


Step 1:

* If you don't already have add some enum that will represent your `base` URLs and add your **mock** URL

```swift
enum Base: String { 
        case api = "https://backend.project.com/something/api" 
        case mock = "https://private-4d7af-project18.apiary-mock.com" 
    }
```

Step 2:

* Add singleton that will control current base url 

```swift
class Selection {
        static let current = Selection()
        
        private(set) var base: Constants.AppUrl.Base = .api 
    }
```

Step 3:

* Add some button on login screen, and click have following line executed

```swift
    Selection.current = .mock

    //Login
```
* But don't forget to hide that button on production

```swift
#if STORE 
    mockLoginButton.isHidden = true
#endif
```

And that should be it, now your app is ready for some mocking

## Closing words

There is much more that Apiary can offer you, these are just basics. All of the above is possible to do with a free version, however, there is also a paid version that provides much more functionality. For more info about Apiary click here [here](https://apiary.io/how-apiary-works).