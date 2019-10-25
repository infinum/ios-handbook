## Does your app use encryption?  
​	As all of our apps make API calls through the secure HTTPS protocol, while submitting the app to the app store review we should fill short yes/no form about encryption usage to be compliant with Apple App Store guidelines. More about this you can find in this [article](https://medium.com/@cocoanetics/itunes-connect-encryption-info-425549800870).

​	In short, there are two approaches for filling this form. Through the .plist in the project (preferred way) and by answering two questions on the app submit for the review.

### Add `ITSAppUsesNonExemptEncryption` in Info.plist

The easiest way for handling this is by adding new `ITSAppUsesNonExemptEncryption` key with `bool` value `NO` . Keep in mind that this is double negation (the app uses **non exempt** encryption) and by Apple, HTTPS is exempt encryption. When this is added to your .plist, while sending the app to the app store review, you will not have to check the answers shown in the next title.



### Answer two questions on the app review submission

If you don't want to add `ITSAppUsesNonExemptEncryption`, then you will have to answer two questions with `Yes` on every app review submission. 

First question is if your app uses any encryption:
![export-compliance-1](/img/export-compliance-1.png)

Second one is if this encryption is exempt one:
![export-compliance-1](/img/export-compliance-2.png)