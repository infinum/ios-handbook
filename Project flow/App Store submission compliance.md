## Does your app use encryption?

​Since all of our apps make API calls through the secure HTTPS protocol, while submitting the app to the app store review, we should fill out a short yes/no form about encryption usage to be compliant with Apple App Store guidelines. You can find more info about it in this [article](https://medium.com/@cocoanetics/itunes-connect-encryption-info-425549800870).

​	In short, there are two approaches for filling this form. Through the .plist in the project (preferred way) and by answering two questions on the app submit for the review.

### Add `ITSAppUsesNonExemptEncryption` in Info.plist

The easiest way to handle this is by adding a new `ITSAppUsesNonExemptEncryption` key with the `bool` value `NO` . Keep in mind that this is double negation (the app uses **non exempt** encryption) and to Apple, HTTPS is exempt encryption. If this is added to your .plist, you will not have to check the answers shown in the next title while sending the app to the app store review.

### Answer two questions on the app review submission

If you don't want to add `ITSAppUsesNonExemptEncryption`, you will have to answer two questions with `Yes` on every app review submission.

The first question is whether your app uses any encryption:
![export-compliance-1](/img/export-compliance-1.png)

The second one is whether this encryption is an exempt one:
![export-compliance-1](/img/export-compliance-2.png)
