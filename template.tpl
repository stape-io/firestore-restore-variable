___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "MACRO",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Firestore reStore",
  "description": "Store data inside Firebase by identifiers (user_id, client_id, etc.). Restore data values in case they are found by identifiers. Useful for cookieless, cross-device, and cross-site tracking.",
  "containerContexts": [
    "SERVER"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "CHECKBOX",
    "name": "onlyRestore",
    "checkboxText": "Only restore data",
    "simpleValueType": true,
    "help": "It will prevent writing data to the Firestore. Useful if you want to only get data by identifiers."
  },
  {
    "type": "GROUP",
    "name": "identifiersGroup",
    "displayName": "List of identifiers",
    "groupStyle": "ZIPPY_OPEN",
    "subParams": [
      {
        "type": "SIMPLE_TABLE",
        "name": "identifiers",
        "simpleTableColumns": [
          {
            "defaultValue": "",
            "displayName": "Name",
            "name": "name",
            "type": "TEXT",
            "isUnique": true,
            "valueValidators": [
              {
                "type": "NON_EMPTY"
              }
            ]
          },
          {
            "defaultValue": "",
            "displayName": "Value",
            "name": "value",
            "type": "TEXT",
            "valueValidators": [
              {
                "type": "NON_EMPTY"
              }
            ]
          }
        ],
        "alwaysInSummary": true
      }
    ]
  },
  {
    "type": "GROUP",
    "name": "dataGroup",
    "displayName": "List of data that needs to be restored",
    "groupStyle": "ZIPPY_OPEN",
    "subParams": [
      {
        "type": "SIMPLE_TABLE",
        "name": "dataValues",
        "simpleTableColumns": [
          {
            "defaultValue": "",
            "displayName": "Name",
            "name": "name",
            "type": "TEXT",
            "isUnique": true,
            "valueValidators": [
              {
                "type": "NON_EMPTY"
              }
            ]
          },
          {
            "defaultValue": "",
            "displayName": "Value",
            "name": "value",
            "type": "TEXT",
            "valueValidators": [
              {
                "type": "NON_EMPTY"
              }
            ],
            "valueHint": "",
            "selectItems": [
              {
                "value": 1,
                "displayValue": "1"
              },
              {
                "value": 2,
                "displayValue": "2"
              }
            ]
          }
        ],
        "alwaysInSummary": true
      }
    ]
  },
  {
    "displayName": "Firebase Settings",
    "name": "firebaseGroup",
    "groupStyle": "ZIPPY_CLOSED",
    "type": "GROUP",
    "subParams": [
      {
        "type": "TEXT",
        "name": "firebaseProjectId",
        "displayName": "Firebase Project ID",
        "simpleValueType": true
      },
      {
        "type": "TEXT",
        "name": "firebasePath",
        "displayName": "Firebase Path",
        "simpleValueType": true,
        "help": "The variable uses Firebase to store data. You can choose any key for a document that will store the data values.",
        "valueValidators": [
          {
            "type": "NON_EMPTY"
          }
        ],
        "defaultValue": "stape/restore"
      }
    ]
  },
  {
    "displayName": "Logs Settings",
    "name": "logsGroup",
    "groupStyle": "ZIPPY_CLOSED",
    "type": "GROUP",
    "subParams": [
      {
        "type": "RADIO",
        "name": "logType",
        "radioItems": [
          {
            "value": "no",
            "displayValue": "Do not log"
          },
          {
            "value": "debug",
            "displayValue": "Log to console during debug and preview"
          },
          {
            "value": "always",
            "displayValue": "Always log to console"
          }
        ],
        "simpleValueType": true,
        "defaultValue": "debug"
      }
    ]
  }
]


___SANDBOXED_JS_FOR_SERVER___

const Firestore = require('Firestore');
const JSON = require('JSON');
const logToConsole = require('logToConsole');
const getRequestHeader = require('getRequestHeader');
const getContainerVersion = require('getContainerVersion');

const isLoggingEnabled = determinateIsLoggingEnabled();
const traceId = isLoggingEnabled ? getRequestHeader('trace-id') : undefined;

const identifiersValues = getIdentifiersValues(data.identifiers);
if (identifiersValues.length === 0) {
    return {};
}

let firebaseOptions = {limit: 1};
if (data.firebaseProjectId) firebaseOptions.projectId = data.firebaseProjectId;

if (isLoggingEnabled) {
    logToConsole(
      JSON.stringify({
          Name: 'FirestoreReStore',
          Type: 'Request',
          TraceId: traceId,
          EventName: 'FirestoreReStoreGet',
          RequestMethod: 'GET',
          RequestUrl: data.firebasePath,
          RequestBody: identifiersValues,
      })
    );
}

return Firestore.query(data.firebasePath, [['identifiersValues', 'array-contains-any', identifiersValues]], firebaseOptions)
  .then((documents) => {
      return restoreData(documents && documents.length > 0 ? documents[0] : {});
  }, () => {
      return restoreData({});
  });

function restoreData(document) {
    let storedData = document.data || {};
    let dataToStore = {};


    if (isLoggingEnabled) {
        logToConsole(
          JSON.stringify({
              Name: 'FirestoreReStore',
              Type: 'Response',
              TraceId: traceId,
              EventName: 'FirestoreReStoreGet',
              ResponseStatusCode: 200,
              ResponseHeaders: {},
              ResponseBody: storedData,
          })
        );
    }

    if (data.dataValues && data.dataValues.length > 0) {
        data.dataValues.forEach(function (dataObject) {
            let item = dataObject.value;

            if (item && item.length > 0) {
                dataToStore[dataObject.name] = item;
            } else if (storedData.data && storedData.data[dataObject.name]) {
                dataToStore[dataObject.name] = storedData.data[dataObject.name];
            }
        });
    }

    if (getObjectLength(dataToStore) === 0 || data.onlyRestore) {
        return dataToStore;
    }

    let mergedIdentifiers = mergeIdentifiers(storedData.identifiers, data.identifiers);
    let objectToStore = {
        identifiers: mergedIdentifiers,
        identifiersValues: getIdentifiersValues(mergedIdentifiers),
        data: dataToStore,
    };

    if (isLoggingEnabled) {
        logToConsole(
          JSON.stringify({
              Name: 'FirestoreReStore',
              Type: 'Request',
              TraceId: traceId,
              EventName: 'FirestoreReStorePost',
              RequestMethod: 'POST',
              RequestUrl: data.firebasePath,
              RequestBody: objectToStore,
          })
        );
    }

    return Firestore.write(document.id || data.firebasePath, objectToStore, firebaseOptions)
      .then(() => {
          if (isLoggingEnabled) {
              logToConsole(
                JSON.stringify({
                    Name: 'FirestoreReStore',
                    Type: 'Response',
                    TraceId: traceId,
                    EventName: 'FirestoreReStorePOST',
                    ResponseStatusCode: 200,
                    ResponseHeaders: {},
                    ResponseBody: {},
                })
              );
          }

          return dataToStore;
      }, function () {
          if (isLoggingEnabled) {
              logToConsole(
                JSON.stringify({
                    Name: 'FirestoreReStore',
                    Type: 'Response',
                    TraceId: traceId,
                    EventName: 'FirestoreReStorePOST',
                    ResponseStatusCode: 500,
                    ResponseHeaders: {},
                    ResponseBody: {},
                })
              );
          }

          return dataToStore;
      });
}

function getIdentifiersValues(identifiers) {
    let identifiersValues = [];

    if (identifiers && identifiers.length > 0) {
        identifiers.forEach(function (identifier) {
            if (identifier.value) {
                identifiersValues.push(identifier.value);
            }
        });
    }

    return identifiersValues;
}

function mergeIdentifiers(oldIdentifiers, newIdentifiers) {
    let identifiers = [];

    if (oldIdentifiers && oldIdentifiers.length > 0) {
        identifiers = oldIdentifiers;
    }

    if (newIdentifiers && newIdentifiers.length > 0) {
        newIdentifiers.forEach(function (newIdentifier) {
            let identifierFound = false;

            identifiers.forEach(function (identifier) {
                if (identifier.name === newIdentifier.name && newIdentifier.value) {
                    identifier.value = newIdentifier.value;
                    identifierFound = true;
                }
            });

            if (!identifierFound && newIdentifier.value) {
                identifiers.push(newIdentifier);
            }
        });
    }

    return identifiers;
}

function getObjectLength(object) {
    let length = 0;

    for (let key in object) {
        if (object.hasOwnProperty(key)) {
            ++length;
        }
    }
    return length;
}

function determinateIsLoggingEnabled() {
    const containerVersion = getContainerVersion();
    const isDebug = !!(containerVersion && (containerVersion.debugMode || containerVersion.previewMode));

    if (!data.logType) {
        return isDebug;
    }

    if (data.logType === 'no') {
        return false;
    }

    if (data.logType === 'debug') {
        return isDebug;
    }

    return data.logType === 'always';
}


___SERVER_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "access_firestore",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedOptions",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "projectId"
                  },
                  {
                    "type": 1,
                    "string": "path"
                  },
                  {
                    "type": 1,
                    "string": "operation"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "*"
                  },
                  {
                    "type": 1,
                    "string": "*"
                  },
                  {
                    "type": 1,
                    "string": "read_write"
                  }
                ]
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "read_request",
        "versionId": "1"
      },
      "param": [
        {
          "key": "headerWhitelist",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "headerName"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "trace-id"
                  }
                ]
              }
            ]
          }
        },
        {
          "key": "headersAllowed",
          "value": {
            "type": 8,
            "boolean": true
          }
        },
        {
          "key": "requestAccess",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "headerAccess",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "queryParameterAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "all"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "read_container_data",
        "versionId": "1"
      },
      "param": []
    },
    "isRequired": true
  }
]


___TESTS___

scenarios: []


___NOTES___

Created on 15/01/2024, 17:29:11


