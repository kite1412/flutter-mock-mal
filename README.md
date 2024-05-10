# About
An unofficial MAL client for android, Jikan also used to leverage some features that's not available on MAL official api. Developed by kite1412 for non-commercial purpose.

# Installation
Before installing the application, you should have your own MAL API client and configure it within project. If you don't have an existing client yet, refer to https://myanimelist.net/apiconfig to create one. This is required for OAuth 2.0 authorization purpose, as sharing client credentials is not possible due to security reasons.

After creating your MAL API client, here are the steps to install the application to your device. 
1. Under /android/app/src/main/kotlin/com/nrr/anime_gallery/ directory, create a Kotlin file, there are no constraints on file naming.
2. Create a constant variable 'clientId' with string data type.
3. Assign the variable with your MAL API client id.
4. In the project's root directory, run 'flutter install'. Make sure there's a connected device where flutter installs the application to.  
