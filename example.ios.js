/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 */
'use strict';

var {
    RNFileUploadToServer
} = require('NativeModules');


var {
  AppRegistry,
  StyleSheet,
  Text,
  View,
} = React;

var testComp = React.createClass({
  componentDidMount() {
    var uploadObject = {
        filename: 'MyFile.txt',
        uploadUrl: 'http:/www.example.com/upload.php',
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
  },
  render: function() {
    return (
      <View style={styles.container}>
        <Text style={styles.welcome}>
          Check Upload Status - View Xcode Log
        </Text>
        <Text style={styles.instructions}>
          File Upload - Log == "Upload Success"
        </Text>
        <Text style={styles.instructions}>
          Error - Log == "Upload Error"
        </Text>
        <Text style={styles.instructions}>
          Press Cmd+R to reload,{'\n'}
          Cmd+D or shake for dev menu
        </Text>
      </View>
    );
  }
});

var styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
});

AppRegistry.registerComponent('testComp', () => testComp);
