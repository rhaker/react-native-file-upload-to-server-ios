# react-native-file-upload-to-server-ios

This is a wrapper for react-native that uploads a file in the app documents directory to an external server. This a stripped down, dead simple version of react-native-file-upload by booxood (github.com/booxood/react-native-file-upload). If you want more control over the upload configuration (e.g. setting mimeType or the base directory of the upload file) please use react-native-file-upload.

# Additional Notes

You can use this package together with my other react-native packages. A typical workflow could be:

1) Check if file exists to upload - use react-native-check-file-exists-ios

2) If file does not exist, create blank file - use react-native-create-new-file-ios (then edit the file in your app)

3) Once file exists, you can upload using this package

# Add it to your project

npm install react-native-file-upload-to-server-ios --save

In XCode, in the project navigator, right click Libraries ➜ Add Files to [your project's name]

Go to node_modules ➜ react-native-file-upload-to-server-ios and add RNFileUploadToServer.xcodeproj

In XCode, in the project navigator, select your project. Add libRNFileUploadToServer.a to your project's Build Phases ➜ Link Binary With Libraries

Click RNFileUploadToServer.xcodeproj in the project navigator and go the Build Settings tab. Make sure 'All' is toggled on (instead of 'Basic'). Look for Header Search Paths and make sure it contains both $(SRCROOT)/../react-native/React and $(SRCROOT)/../../React - mark both as recursive.

Run your project (Cmd+R)

Setup trouble?

If you get stuck, take a look at Brent Vatne's blog. His blog is my go to reference for this stuff.

# Api Setup

var {

    RNFileUploadToServer

} = require('NativeModules');

var uploadObject = {

    filename: 'MyFile.txt',

    uploadUrl: 'http:/www.goldiespeak.com/upload.php',

    // optional - key:value pairs for file metadata
    fields: {
        //'parameter1': 'value1',
        //'parameter2': 'value2',
        //'parameter3': 'value3',
    },
};

RNFileUploadToServer.uploadFile(

    uploadObject,

    function errorCallback(results) {

        console.log('Upload Error: ' + results['errMsg']);

    },

    function successCallback(results) {

        console.log('Upload Success:' + results['successMsg']);

    }
);

# Error Callback

The following will cause an error callback (use the console.log to see the specific message):

1) File name not set in javascript

2) Upload url is not valid (less than 3 characters)

3) Server upload status other than a 200 response

# Server Handling

Once the file is uploaded, you can process it on the server.

In php, you can use a var_dump($_FILES) to get details on the file. The parameters can be handled as basic post values. For example, in php, $_POST['parameter1']

In php, the name of the file becomes the $_FILE identifier. So if you upload MyFile.txt, the handle becomes $['MyFile_txt'].

# Acknowledgements

Special thanks to booxood and the work done on react-native-file-upload. Brent Vatne for his posts on creating a react native packager. Some portions of this code have been based on answers from stackoverflow. This package also owes a special thanks to the tutorial by Jay Garcia at Modus Create on how to create a custom react native module.
