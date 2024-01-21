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
                    EventName: 'FirestoreReStorePost',
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
                    EventName: 'FirestoreReStorePost',
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
