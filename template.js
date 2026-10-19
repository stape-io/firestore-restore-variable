const encodeUriComponent = require('encodeUriComponent');
const Firestore = require('Firestore');
const getGoogleAuth = require('getGoogleAuth');
const getRequestHeader = require('getRequestHeader');
const getTimestampMillis = require('getTimestampMillis');
const getType = require('getType');
const JSON = require('JSON');
const logToConsole = require('logToConsole');
const makeNumber = require('makeNumber');
const makeString = require('makeString');
const Math = require('Math');
const Object = require('Object');
const sendHttpRequest = require('sendHttpRequest');

/*==============================================================================
==============================================================================*/

const identifiersValues = getIdentifiersValues(data.identifiers);
if (identifiersValues.length === 0) {
  return {};
}

// Firestore.query() and Firestore.write() only support the default database and can't write Timestamp values (needed for TTL).
const useRestApi = data.useTtl || data.useCustomDatabase;
const ttlFieldName = data.ttlFieldName || 'expiresAt';

const invalidReason = getInvalidReason(data);
if (invalidReason) {
  logError('Restore', '🛑 [ERROR] Data was not restored.', invalidReason);

  // Same output as before this validation existed: the current values, without reading or writing.
  return getDataToRestore({});
}

const firebaseOptions = { limit: 1 };
if (data.firebaseProjectId) firebaseOptions.projectId = data.firebaseProjectId;

const query = useRestApi
  ? queryWithRestApi(identifiersValues)
  : Firestore.query(
      data.firebasePath,
      [['identifiersValues', 'array-contains-any', identifiersValues]],
      firebaseOptions
    ).then((documents) => (documents && documents.length > 0 ? documents[0] : {}));

// A failed query must not be treated as a new user: writing would create a duplicate document for an existing user.
// So it returns the current values without writing.
return query.then(
  (document) => (document ? restoreData(document) : getDataToRestore({})),
  () => getDataToRestore({})
);

/*==============================================================================
  Vendor related functions
==============================================================================*/

function getInvalidReason(data) {
  const pathSegments = getType(data.firebasePath) === 'string' ? data.firebasePath.split('/') : [];
  if (pathSegments.length % 2 === 0 || pathSegments.indexOf('') !== -1) {
    return (
      'Firestore Collection Path must point to a collection (odd number of segments). Value: ' +
      data.firebasePath
    );
  }
  if (useRestApi && !data.firebaseProjectId) {
    return 'GCP Project ID is required when TTL or a custom database is used.';
  }
  if (data.useCustomDatabase && !data.databaseId) {
    return 'Database ID is required when a custom database is used.';
  }
  if (data.useTtl && !(makeNumber(data.ttlValue) > 0)) {
    return 'TTL value must be a positive number. Value: ' + data.ttlValue;
  }
  // Firestore Timestamps can't be later than 9999-12-31T23:59:59.999999999Z.
  if (data.useTtl && getTimestampMillis() + makeNumber(data.ttlValue) * 1000 > 253402300799999) {
    return (
      'TTL value is too large. The expiration date must be before the year 10000. Value: ' +
      data.ttlValue
    );
  }
}

function restoreData(document) {
  const storedData = document.data || {};
  const dataToStore = getDataToRestore(storedData);

  if (getObjectLength(dataToStore) === 0 || data.onlyRestore) {
    return dataToStore;
  }

  const mergedIdentifiers = mergeIdentifiers(storedData.identifiers, data.identifiers);
  const objectToStore = {
    identifiers: mergedIdentifiers,
    identifiersValues: getIdentifiersValues(mergedIdentifiers),
    data: dataToStore
  };

  const write = useRestApi
    ? writeWithRestApi(document.id, objectToStore)
    : Firestore.write(document.id || data.firebasePath, objectToStore, firebaseOptions);

  return write.then(
    () => dataToStore,
    () => dataToStore
  );
}

// Finite numbers, booleans and non-empty strings or arrays are the current values. Anything else falls back to the stored value.
function getDataToRestore(storedData) {
  const dataToStore = {};

  if (data.dataValues && data.dataValues.length > 0) {
    data.dataValues.forEach(function (dataObject) {
      const item = dataObject.value;
      const itemType = getType(item);
      const storedItem = storedData.data ? storedData.data[dataObject.name] : undefined;

      // item - item is 0 only for finite numbers: NaN and Infinity serialize to null, which Firestore rejects.
      if (
        (itemType === 'number' && item - item === 0) ||
        itemType === 'boolean' ||
        (item && item.length > 0)
      ) {
        dataToStore[dataObject.name] = item;
      } else if (['undefined', 'null'].indexOf(getType(storedItem)) === -1 && storedItem !== '') {
        dataToStore[dataObject.name] = storedItem;
      }
    });
  }

  return dataToStore;
}

function getIdentifiersValues(identifiers) {
  const identifiersValues = [];

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

// Resolves to the matched document, {} when nothing matches, or undefined when the query failed.
function queryWithRestApi(identifiersValues) {
  const pathSegments = data.firebasePath.split('/');
  const collectionId = pathSegments.pop();
  const parentPath = pathSegments.length > 0 ? '/' + encodePath(pathSegments.join('/')) : '';

  const body = {
    structuredQuery: {
      from: [{ collectionId: collectionId }],
      where: {
        fieldFilter: {
          field: { fieldPath: 'identifiersValues' },
          op: 'ARRAY_CONTAINS_ANY',
          value: toFirestoreValue(identifiersValues)
        }
      },
      limit: 1
    }
  };

  return sendFirestoreRequest(getDocumentsUrl() + parentPath + ':runQuery', 'POST', body).then(
    (result) => {
      // The response is an array. When nothing matches, its only item has no "document" key.
      const responseBody = makeString(result.body).trim();
      const isJsonArray =
        isSuccess(result) &&
        responseBody.indexOf('[') === 0 &&
        responseBody.lastIndexOf(']') === responseBody.length - 1;
      const response = isJsonArray ? JSON.parse(responseBody) : undefined;
      if (getType(response) !== 'array') {
        logError('Query', '🛑 [ERROR] Firestore query failed.', getResponseReason(result));
        return;
      }
      const match = response.filter((item) => item.document)[0];
      return match ? toDocument(match.document) : {};
    },
    (error) => {
      logError('Query', '🛑 [ERROR] Firestore query failed.', JSON.stringify(error));
    }
  );
}

function writeWithRestApi(documentPath, objectToStore) {
  const fields = toFirestoreValue(objectToStore).mapValue.fields;

  if (data.useTtl) {
    const expiresAtMs = getTimestampMillis() + Math.round(makeNumber(data.ttlValue) * 1000);
    fields[ttlFieldName] = {
      timestampValue: convertTimestampToISO(expiresAtMs)
    };
  }

  // Existing document: PATCH without updateMask replaces it, like Firestore.write() without merge.
  // New document: POST to the collection creates it with an auto-generated ID.
  return sendFirestoreRequest(
    getDocumentsUrl() + '/' + encodePath(documentPath || data.firebasePath),
    documentPath ? 'PATCH' : 'POST',
    { fields: fields }
  ).then(
    (result) => {
      if (!isSuccess(result)) {
        logError('Write', '🛑 [ERROR] Document was not written.', getResponseReason(result));
      }
    },
    (error) => {
      logError('Write', '🛑 [ERROR] Document was not written.', JSON.stringify(error));
    }
  );
}

function sendFirestoreRequest(url, method, body) {
  return sendHttpRequest(
    url,
    {
      method: method,
      headers: { 'Content-Type': 'application/json' },
      authorization: getGoogleAuth({ scopes: ['https://www.googleapis.com/auth/datastore'] })
    },
    JSON.stringify(body)
  );
}

function getDocumentsUrl() {
  return (
    'https://firestore.googleapis.com/v1/projects/' +
    enc(data.firebaseProjectId) +
    '/databases/' +
    enc(data.useCustomDatabase ? data.databaseId : '(default)') +
    '/documents'
  );
}

// Same shape as the documents returned by Firestore.query(): id is the path relative to "/documents/".
function toDocument(firestoreDocument) {
  const name = firestoreDocument.name;
  const id = name.slice(name.indexOf('/documents/') + '/documents/'.length);
  const fields = firestoreDocument.fields || {};

  if (data.useTtl) {
    const ttlField = fields[ttlFieldName];
    // Expired documents are returned until Firestore deletes them. Ignore their data but keep the id to overwrite them.
    if (
      ttlField &&
      ttlField.timestampValue &&
      padTimestampFraction(ttlField.timestampValue) <=
        padTimestampFraction(convertTimestampToISO(getTimestampMillis()))
    ) {
      return { id: id };
    }
  }

  return { id: id, data: fromFirestoreValue({ mapValue: { fields: fields } }) };
}

// Same type mapping as Firestore.write(), so data is stored identically in both modes.
function toFirestoreValue(value) {
  const type = getType(value);
  if (type === 'boolean') return { booleanValue: value };
  if (type === 'number') return { doubleValue: value };
  if (type === 'string') return { stringValue: value };
  if (type === 'array') return { arrayValue: { values: value.map(toFirestoreValue) } };
  if (type === 'object') {
    const fields = {};
    Object.keys(value).forEach((key) => {
      fields[key] = toFirestoreValue(value[key]);
    });
    return { mapValue: { fields: fields } };
  }
  return { nullValue: null };
}

// Same type mapping as Firestore.query(), so data is restored identically in both modes.
function fromFirestoreValue(value) {
  const type = Object.keys(value)[0];
  const typeValue = value[type];
  if (type === 'mapValue') {
    const fields = typeValue.fields || {};
    const object = {};
    Object.keys(fields).forEach((key) => {
      object[key] = fromFirestoreValue(fields[key]);
    });
    return object;
  }
  if (type === 'arrayValue') return (typeValue.values || []).map(fromFirestoreValue);
  if (type === 'geoPointValue') return JSON.stringify(typeValue);
  if (['integerValue', 'timestampValue', 'bytesValue', 'referenceValue'].indexOf(type) !== -1) {
    return makeString(typeValue);
  }
  return typeValue;
}

/*==============================================================================
  Helpers
==============================================================================*/

function getObjectLength(object) {
  let length = 0;

  for (const key in object) {
    if (object.hasOwnProperty(key)) {
      ++length;
    }
  }
  return length;
}

function convertTimestampToISO(timestamp) {
  const msPerDay = 86400000;
  const isLeapYear = (y) => (y % 4 === 0 && y % 100 !== 0) || y % 400 === 0;
  const pad = (value, length) => {
    let result = makeString(value);
    while (result.length < length) result = '0' + result;
    return result;
  };

  let days = Math.floor(timestamp / msPerDay);
  let msOfDay = timestamp - days * msPerDay;

  let year = 1970;
  while (days >= (isLeapYear(year) ? 366 : 365)) {
    days = days - (isLeapYear(year) ? 366 : 365);
    year++;
  }

  const daysInMonth = [31, isLeapYear(year) ? 29 : 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  let month = 0;
  while (days >= daysInMonth[month]) {
    days = days - daysInMonth[month];
    month++;
  }

  const hours = Math.floor(msOfDay / 3600000);
  msOfDay = msOfDay - hours * 3600000;
  const minutes = Math.floor(msOfDay / 60000);
  msOfDay = msOfDay - minutes * 60000;
  const seconds = Math.floor(msOfDay / 1000);
  const milliseconds = msOfDay - seconds * 1000;

  return (
    year +
    '-' +
    pad(month + 1, 2) +
    '-' +
    pad(days + 1, 2) +
    'T' +
    pad(hours, 2) +
    ':' +
    pad(minutes, 2) +
    ':' +
    pad(seconds, 2) +
    '.' +
    pad(milliseconds, 3) +
    'Z'
  );
}

// Firestore returns 0, 3, 6 or 9 fractional digits. Padding to 9 makes the UTC timestamps comparable as strings.
function padTimestampFraction(timestamp) {
  const parts = makeString(timestamp).split('Z')[0].split('.');
  let fraction = parts[1] || '';
  while (fraction.length < 9) fraction = fraction + '0';
  return parts[0] + '.' + fraction + 'Z';
}

function encodePath(path) {
  return path
    .split('/')
    .map((segment) => enc(segment))
    .join('/');
}

function enc(value) {
  if (['null', 'undefined'].indexOf(getType(value)) !== -1) value = '';
  return encodeUriComponent(makeString(value));
}

function isSuccess(result) {
  return result.statusCode >= 200 && result.statusCode < 300;
}

function getResponseReason(result) {
  return 'Status code: ' + result.statusCode + '. Response body: ' + result.body;
}

function logError(eventName, message, reason) {
  log({
    Name: 'FirestoreReStore',
    Type: 'Message',
    EventName: eventName,
    Message: message,
    Reason: reason
  });
}

function log(rawDataToLog) {
  rawDataToLog.TraceId = getRequestHeader('trace-id');
  logToConsole(JSON.stringify(rawDataToLog));
}
