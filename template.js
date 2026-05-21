const Firestore = require('Firestore');
const JSON = require('JSON');

/*==============================================================================
==============================================================================*/

const identifiersValues = getIdentifiersValues(data.identifiers);
if (identifiersValues.length === 0) {
  return {};
}

let firebaseOptions = { limit: 1 };
if (data.firebaseProjectId) firebaseOptions.projectId = data.firebaseProjectId;

return Firestore.query(
  data.firebasePath,
  [['identifiersValues', 'array-contains-any', identifiersValues]],
  firebaseOptions
).then(
  (documents) => {
    return restoreData(documents && documents.length > 0 ? documents[0] : {});
  },
  () => {
    return restoreData({});
  }
);

/*==============================================================================
  Vendor related functions
==============================================================================*/

function restoreData(document) {
  let storedData = document.data || {};
  let dataToStore = {};

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
    data: dataToStore
  };

  return Firestore.write(document.id || data.firebasePath, objectToStore, firebaseOptions).then(
    () => dataToStore,
    () => dataToStore
  );
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

/*==============================================================================
  Helpers
==============================================================================*/

function getObjectLength(object) {
  let length = 0;

  for (let key in object) {
    if (object.hasOwnProperty(key)) {
      ++length;
    }
  }
  return length;
}
