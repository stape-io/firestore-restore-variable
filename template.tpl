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
    "help": "Only reads the stored data. Nothing is written to Firestore, so documents are neither created nor updated.\n\u003cbr/\u003e\u003cbr/\u003e\nUseful if you only want to get the stored data by identifiers."
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
        "alwaysInSummary": true,
        "help": "Values that identify the user, e.g. \u003ci\u003euser_id\u003c/i\u003e or \u003ci\u003eclient_id\u003c/i\u003e.\n\u003cul\u003e\n\u003cli\u003e\u003cb\u003eName\u003c/b\u003e: label of the identifier. A stored identifier with the same name gets its value updated.\u003c/li\u003e\n\u003cli\u003e\u003cb\u003eValue\u003c/b\u003e: the identifier value, usually a variable.\u003c/li\u003e\n\u003c/ul\u003e\nA stored document is found if it contains \u003cb\u003eany\u003c/b\u003e of these values, regardless of the identifier name (Firestore \u003ci\u003earray-contains-any\u003c/i\u003e query). Identifiers that aren\u0027t stored yet are added to the document.\n\u003cbr/\u003e\u003cbr/\u003e\nRows with an empty value are ignored. If all values are empty, the variable returns an empty object without reading or writing anything.",
        "displayName": "List of identifiers"
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
            ]
          }
        ],
        "alwaysInSummary": true,
        "help": "Data to store and restore. The variable returns an object with these names as keys, e.g. \u003ci\u003e{\"email\": \"...\", \"phone\": \"...\"}\u003c/i\u003e.\n\u003cul\u003e\n\u003cli\u003e\u003cb\u003eName\u003c/b\u003e: key of the data in the returned object and in the stored document.\u003c/li\u003e\n\u003cli\u003e\u003cb\u003eValue\u003c/b\u003e: the current value, usually a variable.\u003c/li\u003e\n\u003c/ul\u003e\nFor each row:\n\u003cul\u003e\n\u003cli\u003eIf the value is a \u003cb\u003enumber\u003c/b\u003e, a \u003cb\u003eboolean\u003c/b\u003e (including \u003ci\u003e0\u003c/i\u003e and \u003ci\u003efalse\u003c/i\u003e) or \u003cb\u003enon-empty text\u003c/b\u003e, it\u0027s returned and stored.\u003c/li\u003e\n\u003cli\u003eOtherwise (e.g. no value, \u003ci\u003enull\u003c/i\u003e or empty text), the stored value (if any) is returned instead.\u003c/li\u003e\n\u003c/ul\u003e\nEvery write replaces the whole document, so data whose name is removed from this list is removed from the document on the next write.",
        "displayName": "List of data that needs to be restored"
      }
    ]
  },
  {
    "displayName": "Firestore Settings",
    "name": "firebaseGroup",
    "groupStyle": "ZIPPY_CLOSED",
    "type": "GROUP",
    "subParams": [
      {
        "type": "TEXT",
        "name": "firebasePath",
        "displayName": "Firestore Collection Path",
        "simpleValueType": true,
        "help": "Path to the Firestore \u003cb\u003ecollection\u003c/b\u003e that stores the data, e.g. \u003ci\u003estape\u003c/i\u003e or \u003ci\u003eusers/123/restore\u003c/i\u003e (subcollection). Must not start or end with a \u003ci\u003e/\u003c/i\u003e.\n\u003cbr/\u003e\u003cbr/\u003e\nEach user gets their own document with a randomly generated ID, which is found later by its identifiers.\n\u003cbr/\u003e\u003cbr/\u003e\n\u003cb\u003eNote:\u003c/b\u003e it must be a collection path (odd number of segments). Document paths, e.g. \u003ci\u003estape/restore\u003c/i\u003e, are invalid: the variable logs an error and returns the current values without reading or writing.",
        "valueValidators": [
          {
            "type": "NON_EMPTY"
          },
          {
            "type": "REGEX",
            "args": [
              "^[^/]+(/[^/]+/[^/]+)*$"
            ],
            "errorMessage": "Enter a collection path: an odd number of segments separated by \"/\", e.g. \"stape\" or \"users/123/restore\". It must not start or end with \"/\"."
          }
        ],
        "defaultValue": "stape"
      },
      {
        "type": "TEXT",
        "name": "firebaseProjectId",
        "displayName": "GCP Project ID",
        "simpleValueType": true,
        "help": "ID of the Google Cloud (GCP) project that contains the Firestore database, e.g. \u003ci\u003emy-project-123\u003c/i\u003e. It\u0027s the same as the Firebase project ID.\n\u003cbr/\u003e\u003cbr/\u003e\nUse the project \u003cb\u003eID\u003c/b\u003e, not the project name or number. You can find it in the \u003ca href\u003d\"https://console.cloud.google.com/home/dashboard\"\u003eGoogle Cloud console\u003c/a\u003e dashboard or in the Firebase console under \u003ci\u003eProject settings\u003c/i\u003e.\n\u003cbr/\u003e\u003cbr/\u003e\nIf empty, the project from the \u003ci\u003eGOOGLE_CLOUD_PROJECT\u003c/i\u003e environment variable of the server container is used. If the container runs on Google Cloud, it\u0027s already set.\n\u003cbr/\u003e\u003cbr/\u003e\n\u003cb\u003eRequired\u003c/b\u003e when \u003ci\u003eUse custom database\u003c/i\u003e or \u003ci\u003eAdd TTL field\u003c/i\u003e is enabled.",
        "valueValidators": [
          {
            "type": "NON_EMPTY",
            "enablingConditions": [
              {
                "paramName": "useCustomDatabase",
                "paramValue": true,
                "type": "EQUALS"
              },
              {
                "paramName": "useTtl",
                "paramValue": true,
                "type": "EQUALS"
              }
            ]
          }
        ]
      },
      {
        "type": "CHECKBOX",
        "name": "useCustomDatabase",
        "checkboxText": "Use custom database",
        "simpleValueType": true,
        "help": "Read from and write to a named Firestore database instead of the \u003ci\u003e(default)\u003c/i\u003e one.\n\u003cbr/\u003e\u003cbr/\u003e\nThe \u003ca href\u003d\"https://developers.google.com/tag-platform/tag-manager/server-side/api#firestore\"\u003ebuilt-in \u003ci\u003eFirestore\u003c/i\u003e API\u003c/a\u003e only supports the default database, so enabling this sends the query and the write through the \u003ca href\u003d\"https://firebase.google.com/docs/firestore/use-rest-api\"\u003eFirestore REST API\u003c/a\u003e instead. It uses the same Google credentials as the built-in API.\n\u003cbr/\u003e\u003cbr/\u003e\nRequires the \u003cb\u003eGCP Project ID\u003c/b\u003e field.",
        "subParams": [
          {
            "type": "TEXT",
            "name": "databaseId",
            "displayName": "Database ID",
            "simpleValueType": true,
            "help": "ID of the Firestore database, e.g. \u003ci\u003emy-database\u003c/i\u003e. See the \u003ca href\u003d\"https://firebase.google.com/docs/firestore/manage-databases#database_id\"\u003edatabase ID rules\u003c/a\u003e:\n\u003cul\u003e\n\u003cli\u003eOnly lowercase letters, numbers and hyphens (\u003ci\u003e-\u003c/i\u003e).\u003c/li\u003e\n\u003cli\u003eStarts with a letter and ends with a letter or number.\u003c/li\u003e\n\u003cli\u003e4 to 63 characters.\u003c/li\u003e\n\u003cli\u003eMust not look like a UUID.\u003c/li\u003e\n\u003c/ul\u003e",
            "enablingConditions": [
              {
                "paramName": "useCustomDatabase",
                "paramValue": true,
                "type": "EQUALS"
              }
            ],
            "valueValidators": [
              {
                "type": "NON_EMPTY"
              },
              {
                "type": "REGEX",
                "args": [
                  "^(?![0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$)[a-z][a-z0-9-]{2,61}[a-z0-9]$"
                ],
                "errorMessage": "Invalid database ID. Use 4 to 63 lowercase letters, numbers or hyphens, starting with a letter and ending with a letter or number. It must not look like a UUID."
              }
            ]
          }
        ]
      },
      {
        "type": "CHECKBOX",
        "name": "useTtl",
        "checkboxText": "Add TTL field",
        "simpleValueType": true,
        "help": "Adds an expiration date field to the stored document, so Firestore can delete it automatically using a \u003ca href\u003d\"https://firebase.google.com/docs/firestore/ttl\"\u003eTTL (time-to-live) policy\u003c/a\u003e.\n\u003cbr/\u003e\u003cbr/\u003e\nThe field is written as a Firestore \u003cb\u003eTimestamp\u003c/b\u003e (\u003ci\u003eDate and time\u003c/i\u003e) value, set to the current time plus the \u003ci\u003eTTL value\u003c/i\u003e. The built-in \u003ci\u003eFirestore\u003c/i\u003e API can\u0027t write Timestamp values, so enabling this sends the query and the write through the \u003ca href\u003d\"https://firebase.google.com/docs/firestore/use-rest-api\"\u003eFirestore REST API\u003c/a\u003e instead. It requires the \u003cb\u003eGCP Project ID\u003c/b\u003e field.\n\u003cbr/\u003e\u003cbr/\u003e\n\u003cb\u003eImportant:\u003c/b\u003e\n\u003cul\u003e\n\u003cli\u003eThe expiration date is renewed every time the variable writes the document, so it counts from the last write.\u003c/li\u003e\n\u003cli\u003eCreate a TTL policy for this collection group and field name in the Google Cloud console. Without it, nothing is deleted.\u003c/li\u003e\n\u003cli\u003eExpired documents are typically deleted within 24 hours after their expiration date, not immediately. Until then, the variable doesn\u0027t restore their data and overwrites them on the next write.\u003c/li\u003e\n\u003cli\u003eDeleting a document via TTL doesn\u0027t delete its subcollections.\u003c/li\u003e\n\u003c/ul\u003e",
        "subParams": [
          {
            "type": "TEXT",
            "name": "ttlFieldName",
            "displayName": "TTL field name",
            "simpleValueType": true,
            "help": "Name of the document field that stores the expiration date. It must match the field name of the TTL policy.\n\u003cbr/\u003e\u003cbr/\u003e\nUse letters, numbers and underscores only, not starting with a number. Names starting and ending with two underscores (e.g. \u003ci\u003e__name__\u003c/i\u003e) are reserved by Firestore. Don\u0027t use \u003ci\u003eidentifiers\u003c/i\u003e, \u003ci\u003eidentifiersValues\u003c/i\u003e or \u003ci\u003edata\u003c/i\u003e, which the variable already uses.",
            "enablingConditions": [
              {
                "paramName": "useTtl",
                "paramValue": true,
                "type": "EQUALS"
              }
            ],
            "valueValidators": [
              {
                "type": "NON_EMPTY"
              },
              {
                "type": "REGEX",
                "args": [
                  "^(?!__.*__$)(?!(identifiers|identifiersValues|data)$)[A-Za-z_][A-Za-z0-9_]*$"
                ],
                "errorMessage": "Use letters, numbers and underscores only, not starting with a number. Names starting and ending with two underscores are reserved. \"identifiers\", \"identifiersValues\" and \"data\" are used by the variable."
              }
            ],
            "defaultValue": "expiresAt"
          },
          {
            "type": "TEXT",
            "name": "ttlValue",
            "displayName": "TTL value (seconds)",
            "simpleValueType": true,
            "help": "Time, in \u003cb\u003eseconds\u003c/b\u003e, until the document expires, counted from the last time the variable writes it. E.g. \u003ci\u003e86400\u003c/i\u003e \u003d 1 day, \u003ci\u003e2592000\u003c/i\u003e \u003d 30 days.\n\u003cbr/\u003e\u003cbr/\u003e\nMust be a whole number greater than 0, and the expiration date must be before the year 10000.",
            "enablingConditions": [
              {
                "paramName": "useTtl",
                "paramValue": true,
                "type": "EQUALS"
              }
            ],
            "valueValidators": [
              {
                "type": "NON_EMPTY"
              },
              {
                "type": "POSITIVE_NUMBER"
              }
            ]
          }
        ]
      }
    ]
  }
]


___SANDBOXED_JS_FOR_SERVER___

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
                  },
                  {
                    "type": 1,
                    "string": "databaseId"
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
                  },
                  {
                    "type": 1,
                    "string": "(default)"
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
        "publicId": "use_google_credentials",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedScopes",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "https://www.googleapis.com/auth/datastore"
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
        "publicId": "send_http",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedUrls",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "urls",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "https://firestore.googleapis.com/*"
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
  }
]


___TESTS___

scenarios:
- name: '[Default mode] Restores stored data, merges identifiers and overwrites the
    matched document'
  code: |-
    const calls = mockFirestore(() => resolved([storedDocument()]));
    const mockData = createMockData({ firebaseProjectId: 'my-project' });

    runCode(mockData).then((result) => {
      assertThat(result).isEqualTo({ email: 'old@example.com', phone: '+200' });
      assertThat(calls.query).isEqualTo([
        {
          path: 'stape',
          conditions: [['identifiersValues', 'array-contains-any', ['u1', 'c1']]],
          options: { limit: 1, projectId: 'my-project' }
        }
      ]);
      assertThat(calls.write).isEqualTo([
        {
          path: 'stape/doc123',
          input: {
            identifiers: [
              { name: 'user_id', value: 'u1' },
              { name: 'email', value: 'old@example.com' },
              { name: 'client_id', value: 'c1' }
            ],
            identifiersValues: ['u1', 'old@example.com', 'c1'],
            data: { email: 'old@example.com', phone: '+200' }
          },
          options: { limit: 1, projectId: 'my-project' }
        }
      ]);
      assertApi('sendHttpRequest').wasNotCalled();
    });
- name: '[Default mode] Creates a new document in the collection when nothing is found,
    even if the write fails'
  code: |-
    [
      { query: () => resolved([]), write: () => resolved('stape/new') },
      { query: () => resolved([]), write: rejected }
    ].forEach((scenario) => {
      const calls = mockFirestore(scenario.query, scenario.write);

      runCode(createMockData()).then((result) => {
        assertThat(result).isEqualTo({ phone: '+200' });
        assertThat(calls.write).isEqualTo([
          {
            path: 'stape',
            input: {
              identifiers: [
                { name: 'user_id', value: 'u1' },
                { name: 'client_id', value: 'c1' }
              ],
              identifiersValues: ['u1', 'c1'],
              data: { phone: '+200' }
            },
            options: { limit: 1 }
          }
        ]);
      });
    });

    assertApi('sendHttpRequest').wasNotCalled();
- name: '[Default mode] Returns the current values without writing when the query
    fails'
  code: |-
    const calls = mockFirestore(rejected);

    runCode(createMockData()).then((result) => {
      assertThat(result).isEqualTo({ phone: '+200' });
      assertThat(calls.query.length).isEqualTo(1);
      assertThat(calls.write).isEqualTo([]);
    });

    assertApi('sendHttpRequest').wasNotCalled();
- name: '[Default mode] Does not write when only restoring or when there is no data
    to store'
  code: |-
    [
      {
        overrides: { onlyRestore: true },
        query: () => resolved([storedDocument()]),
        expected: { email: 'old@example.com', phone: '+200' }
      },
      {
        overrides: { dataValues: [{ name: 'email', value: '' }] },
        query: () => resolved([]),
        expected: {}
      }
    ].forEach((scenario) => {
      const calls = mockFirestore(scenario.query);

      runCode(createMockData(scenario.overrides)).then((result) => {
        assertThat(result).isEqualTo(scenario.expected);
        assertThat(calls.query.length).isEqualTo(1);
        assertThat(calls.write).isEqualTo([]);
      });
    });
- name: '[Default mode] Stores finite numbers and booleans and restores stored zero
    and false'
  code: |-
    const document = storedDocument();
    document.data.data = { zero: 0, no: false, count: 7, yes: true, text: 'kept', ratio: 0.5 };
    const calls = mockFirestore(() => resolved([document]));
    const mockData = createMockData({
      dataValues: [
        { name: 'zero', value: '' },
        { name: 'no', value: undefined },
        { name: 'count', value: 0 },
        { name: 'yes', value: false },
        { name: 'text', value: null },
        { name: 'amount', value: 5 },
        { name: 'flag', value: true },
        { name: 'ratio', value: 0 / 0 },
        { name: 'infinite', value: 1 / 0 }
      ]
    });
    const expected = {
      zero: 0,
      no: false,
      count: 0,
      yes: false,
      text: 'kept',
      amount: 5,
      flag: true,
      ratio: 0.5
    };

    runCode(mockData).then((result) => {
      assertThat(result).isEqualTo(expected);
      assertThat(calls.write[0].input.data).isEqualTo(expected);
    });
- name: '[Early Exit] Returns an empty object without reading or writing when all
    identifier values are empty, even with an invalid path'
  code: |-
    [
      { identifiers: [{ name: 'user_id', value: '' }] },
      { identifiers: [] },
      { identifiers: undefined },
      { identifiers: [], firebasePath: 'stape/restore' }
    ].forEach((overrides) => {
      const calls = mockFirestore(() => resolved([storedDocument()]));

      const result = runCode(createMockData(overrides));

      assertThat(result).isEqualTo({});
      assertThat(calls.query).isEqualTo([]);
      assertThat(calls.write).isEqualTo([]);
    });

    assertApi('sendHttpRequest').wasNotCalled();
- name: '[Validation] Returns the current values without reading or writing when the
    path is not a collection'
  code: |-
    ['stape/restore', 'a/b/c/d', '/stape', 'stape/', 'a//b', '', undefined, 123].forEach(
      (firebasePath) => {
        const calls = mockFirestore(() => resolved([storedDocument()]));

        const result = runCode(createMockData({ firebasePath: firebasePath }));

        assertThat(result).isEqualTo({ phone: '+200' });
        assertThat(calls.query).isEqualTo([]);
        assertThat(calls.write).isEqualTo([]);
      }
    );

    assertApi('sendHttpRequest').wasNotCalled();
- name: '[Validation] Returns the current values without any request when GCP Project
    ID or Database ID is missing, or TTL value is invalid or goes past the year 9999'
  code: |-
    [
      { useTtl: true, ttlValue: '60' },
      { useCustomDatabase: true, databaseId: 'analytics-db' },
      { firebaseProjectId: 'my-project', useCustomDatabase: true, databaseId: '' },
      { firebaseProjectId: 'my-project', useCustomDatabase: true, databaseId: undefined },
      { firebaseProjectId: 'my-project', useTtl: true, ttlValue: '0' },
      { firebaseProjectId: 'my-project', useTtl: true, ttlValue: '-5' },
      { firebaseProjectId: 'my-project', useTtl: true, ttlValue: 'abc' },
      { firebaseProjectId: 'my-project', useTtl: true, ttlValue: '' },
      { firebaseProjectId: 'my-project', useTtl: true, ttlValue: '1e30' },
      { firebaseProjectId: 'my-project', useTtl: true, ttlValue: '251642278717' }
    ].forEach((overrides) => {
      const calls = mockFirestore(() => resolved([storedDocument()]));

      const result = runCode(createMockData(overrides));

      assertThat(result).isEqualTo({ phone: '+200' });
      assertThat(calls.query).isEqualTo([]);
      assertThat(calls.write).isEqualTo([]);
    });

    assertApi('sendHttpRequest').wasNotCalled();
- name: '[REST API] Custom database queries and patches the matched document'
  code: |-
    const firestoreCalls = mockFirestore(() => resolved([]));
    const httpCalls = mockHttp([
      () => runQueryResponse(restDocument()),
      () => resolved({ statusCode: 200, body: '{}' })
    ]);
    const mockData = createMockData({
      firebaseProjectId: 'my-project',
      useCustomDatabase: true,
      databaseId: 'analytics-db'
    });

    runCode(mockData).then((result) => {
      assertThat(result).isEqualTo({ email: 'old@example.com', phone: '+200' });
      assertThat(httpCalls).isEqualTo([
        {
          url: documentsUrl('analytics-db') + ':runQuery',
          options: requestOptions('POST'),
          body: {
            structuredQuery: {
              from: [{ collectionId: 'stape' }],
              where: {
                fieldFilter: {
                  field: { fieldPath: 'identifiersValues' },
                  op: 'ARRAY_CONTAINS_ANY',
                  value: { arrayValue: { values: [{ stringValue: 'u1' }, { stringValue: 'c1' }] } }
                }
              },
              limit: 1
            }
          }
        },
        {
          url: documentsUrl('analytics-db') + '/stape/doc123',
          options: requestOptions('PATCH'),
          body: {
            fields: {
              identifiers: {
                arrayValue: {
                  values: [
                    restIdentifier('user_id', 'u1'),
                    restIdentifier('email', 'old@example.com'),
                    restIdentifier('client_id', 'c1')
                  ]
                }
              },
              identifiersValues: {
                arrayValue: {
                  values: [
                    { stringValue: 'u1' },
                    { stringValue: 'old@example.com' },
                    { stringValue: 'c1' }
                  ]
                }
              },
              data: {
                mapValue: {
                  fields: {
                    email: { stringValue: 'old@example.com' },
                    phone: { stringValue: '+200' }
                  }
                }
              }
            }
          }
        }
      ]);
      assertThat(firestoreCalls.query).isEqualTo([]);
      assertThat(firestoreCalls.write).isEqualTo([]);
      assertApi('getGoogleAuth').wasCalledWith({
        scopes: ['https://www.googleapis.com/auth/datastore']
      });
    });
- name: '[REST API] TTL creates a document with POST in a subcollection of the default
    database, falling back to expiresAt'
  code: |-
    const httpCalls = mockHttp([
      () => runQueryResponse(),
      () => resolved({ statusCode: 200, body: '{}' })
    ]);
    const mockData = createMockData({
      firebasePath: 'users/u 1/restore',
      firebaseProjectId: 'my-project',
      databaseId: 'stale-db',
      useTtl: true,
      ttlFieldName: '',
      ttlValue: '86400'
    });

    runCode(mockData).then((result) => {
      assertThat(result).isEqualTo({ phone: '+200' });
      assertThat(httpCalls.length).isEqualTo(2);
      assertThat(httpCalls[0].url).isEqualTo(documentsUrl('(default)') + '/users/u%201:runQuery');
      assertThat(httpCalls[0].body.structuredQuery.from).isEqualTo([{ collectionId: 'restore' }]);
      assertThat(httpCalls[1].url).isEqualTo(documentsUrl('(default)') + '/users/u%201/restore');
      assertThat(httpCalls[1].options).isEqualTo(requestOptions('POST'));
      assertThat(httpCalls[1].body.fields.data).isEqualTo({
        mapValue: { fields: { phone: { stringValue: '+200' } } }
      });
      assertThat(httpCalls[1].body.fields.expiresAt).isEqualTo({
        timestampValue: '2025-10-10T15:01:23.045Z'
      });
    });
- name: '[REST API] TTL ignores the data of an expired document and overwrites it
    with a new expiration date'
  code: |-
    [
      { ttlField: { timestampValue: '2025-10-09T15:01:23.045Z' }, expected: { phone: '+200' } },
      { ttlField: { timestampValue: '2025-10-09T15:01:23Z' }, expected: { phone: '+200' } },
      { ttlField: { timestampValue: '2025-10-09T15:01:23.045000Z' }, expected: { phone: '+200' } },
      { ttlField: { timestampValue: '2025-10-09T15:01:22.999999999Z' }, expected: { phone: '+200' } },
      {
        ttlField: { timestampValue: '2025-10-09T15:01:23.046Z' },
        expected: { email: 'old@example.com', phone: '+200' }
      },
      {
        ttlField: { timestampValue: '2025-10-09T15:01:23.045001Z' },
        expected: { email: 'old@example.com', phone: '+200' }
      },
      {
        ttlField: { timestampValue: '2025-10-09T15:01:24Z' },
        expected: { email: 'old@example.com', phone: '+200' }
      },
      { ttlField: undefined, expected: { email: 'old@example.com', phone: '+200' } }
    ].forEach((scenario) => {
      const httpCalls = mockHttp([
        () => runQueryResponse(restDocument(scenario.ttlField ? { deleteAt: scenario.ttlField } : {})),
        () => resolved({ statusCode: 200, body: '{}' })
      ]);
      const mockData = createMockData({
        firebaseProjectId: 'my-project',
        useTtl: true,
        ttlFieldName: 'deleteAt',
        ttlValue: '60'
      });

      runCode(mockData).then((result) => {
        assertThat(result).isEqualTo(scenario.expected);
        assertThat(httpCalls[1].url).isEqualTo(documentsUrl('(default)') + '/stape/doc123');
        assertThat(httpCalls[1].options).isEqualTo(requestOptions('PATCH'));
        assertThat(httpCalls[1].body.fields.deleteAt).isEqualTo({
          timestampValue: '2025-10-09T15:02:23.045Z'
        });
        assertThat(httpCalls[1].body.fields.expiresAt).isUndefined();
      });
    });
- name: '[REST API] TTL accepts the last value before the year 10000'
  code: |-
    const httpCalls = mockHttp([
      () => runQueryResponse(),
      () => resolved({ statusCode: 200, body: '{}' })
    ]);
    const mockData = createMockData({
      firebaseProjectId: 'my-project',
      useTtl: true,
      ttlValue: '251642278716'
    });

    runCode(mockData).then((result) => {
      assertThat(result).isEqualTo({ phone: '+200' });
      assertThat(httpCalls.length).isEqualTo(2);
      assertThat(httpCalls[1].body.fields.expiresAt).isEqualTo({
        timestampValue: '9999-12-31T23:59:59.045Z'
      });
    });
- name: '[REST API] Restores every Firestore value type like the built-in API'
  code: |-
    const storedValues = {
      text: { stringValue: 'x' },
      decimal: { doubleValue: 1.5 },
      flag: { booleanValue: true },
      integer: { integerValue: '42' },
      date: { timestampValue: '2025-01-01T00:00:00Z' },
      bytes: { bytesValue: 'AQID' },
      reference: { referenceValue: 'projects/p/databases/(default)/documents/a/b' },
      location: { geoPointValue: { latitude: 1, longitude: 2 } },
      list: { arrayValue: { values: [{ stringValue: 'a' }, { doubleValue: 2 }] } },
      emptyList: { arrayValue: {} },
      object: { mapValue: { fields: { nested: { stringValue: 'y' } } } }
    };
    const document = restDocument();
    document.fields.data = { mapValue: { fields: storedValues } };
    const httpCalls = mockHttp([() => runQueryResponse(document)]);
    const mockData = createMockData({
      onlyRestore: true,
      useCustomDatabase: true,
      databaseId: 'analytics-db',
      firebaseProjectId: 'my-project',
      dataValues: Object.keys(storedValues).map((name) => ({ name: name, value: '' }))
    });

    runCode(mockData).then((result) => {
      assertThat(result).isEqualTo({
        text: 'x',
        decimal: 1.5,
        flag: true,
        integer: '42',
        date: '2025-01-01T00:00:00Z',
        bytes: 'AQID',
        reference: 'projects/p/databases/(default)/documents/a/b',
        location: '{"latitude":1,"longitude":2}',
        list: ['a', 2],
        emptyList: [],
        object: { nested: 'y' }
      });
      assertThat(httpCalls.length).isEqualTo(1);
    });
- name: '[REST API] Returns the current values without writing when the query fails'
  code: |-
    [
      () => resolved({ statusCode: 500, body: '{"error":{}}' }),
      () => resolved({ statusCode: 200, body: '<html>Bad Gateway</html>' }),
      () => resolved({ statusCode: 200, body: '[{"document":' }),
      rejected
    ].forEach((queryResponse) => {
      const httpCalls = mockHttp([queryResponse]);
      const mockData = createMockData({
        firebaseProjectId: 'my-project',
        useCustomDatabase: true,
        databaseId: 'analytics-db'
      });

      runCode(mockData).then((result) => {
        assertThat(result).isEqualTo({ phone: '+200' });
        assertThat(httpCalls.length).isEqualTo(1);
      });
    });
- name: '[REST API] Returns the data when the write fails'
  code: |-
    [() => resolved({ statusCode: 500, body: '{"error":{}}' }), rejected].forEach(
      (writeResponse) => {
        const httpCalls = mockHttp([() => runQueryResponse(), writeResponse]);
        const mockData = createMockData({
          firebaseProjectId: 'my-project',
          useCustomDatabase: true,
          databaseId: 'analytics-db'
        });

        runCode(mockData).then((result) => {
          assertThat(result).isEqualTo({ phone: '+200' });
          assertThat(httpCalls.length).isEqualTo(2);
          assertThat(httpCalls[1].url).isEqualTo(documentsUrl('analytics-db') + '/stape');
          assertThat(httpCalls[1].options).isEqualTo(requestOptions('POST'));
        });
      }
    );
setup: |-
  const JSON = require('JSON');
  const Object = require('Object');
  const Promise = require('Promise');

  const NOW = 1760022083045; // 2025-10-09T15:01:23.045Z
  mock('getTimestampMillis', NOW);
  mock('getGoogleAuth', () => 'mockedGoogleAuth');
  mock('getRequestHeader', () => 'trace-id-123');

  const resolved = (value) => Promise.create((resolve) => resolve(value));
  const rejected = () => Promise.create((resolve, reject) => reject({ reason: 'failed' }));

  const mockFirestore = (query, write) => {
    const calls = { query: [], write: [] };
    mockObject('Firestore', {
      query: (path, conditions, options) => {
        calls.query.push({ path: path, conditions: conditions, options: options });
        return query();
      },
      write: (path, input, options) => {
        calls.write.push({ path: path, input: input, options: options });
        return write ? write() : resolved(path);
      }
    });
    return calls;
  };

  const mockHttp = (responses) => {
    const calls = [];
    mock('sendHttpRequest', (url, options, body) => {
      calls.push({ url: url, options: options, body: JSON.parse(body) });
      return responses[calls.length - 1]();
    });
    return calls;
  };

  // Document as returned by Firestore.query().
  const storedDocument = () => ({
    id: 'stape/doc123',
    data: {
      identifiers: [
        { name: 'user_id', value: 'u1' },
        { name: 'email', value: 'old@example.com' }
      ],
      identifiersValues: ['u1', 'old@example.com'],
      data: { email: 'old@example.com', phone: '+100' }
    }
  });

  const restIdentifier = (name, value) => ({
    mapValue: { fields: { name: { stringValue: name }, value: { stringValue: value } } }
  });

  // Same document as returned by the Firestore REST API.
  const restDocument = (extraFields) => {
    const document = {
      name: 'projects/my-project/databases/(default)/documents/stape/doc123',
      fields: {
        identifiers: {
          arrayValue: {
            values: [restIdentifier('user_id', 'u1'), restIdentifier('email', 'old@example.com')]
          }
        },
        identifiersValues: {
          arrayValue: { values: [{ stringValue: 'u1' }, { stringValue: 'old@example.com' }] }
        },
        data: {
          mapValue: {
            fields: { email: { stringValue: 'old@example.com' }, phone: { stringValue: '+100' } }
          }
        }
      }
    };
    Object.keys(extraFields || {}).forEach((key) => {
      document.fields[key] = extraFields[key];
    });
    return document;
  };

  const runQueryResponse = (document) =>
    resolved({
      statusCode: 200,
      body: JSON.stringify(
        document
          ? [{ document: document, readTime: '2025-10-09T15:01:23.045Z' }]
          : [{ readTime: '2025-10-09T15:01:23.045Z' }]
      )
    });

  const documentsUrl = (databaseId) =>
    'https://firestore.googleapis.com/v1/projects/my-project/databases/' + databaseId + '/documents';

  const requestOptions = (method) => ({
    method: method,
    headers: { 'Content-Type': 'application/json' },
    authorization: 'mockedGoogleAuth'
  });

  const createMockData = (overrides) => {
    const mockData = {
      onlyRestore: false,
      identifiers: [
        { name: 'user_id', value: 'u1' },
        { name: 'client_id', value: 'c1' }
      ],
      dataValues: [
        { name: 'email', value: '' },
        { name: 'phone', value: '+200' }
      ],
      firebasePath: 'stape',
      firebaseProjectId: '',
      useCustomDatabase: false,
      databaseId: '',
      useTtl: false,
      ttlFieldName: 'expiresAt',
      ttlValue: ''
    };
    Object.keys(overrides || {}).forEach((key) => {
      mockData[key] = overrides[key];
    });
    return mockData;
  };


___NOTES___

2026-10-15 - Change Notes:
  - Add "Add TTL field" option (configurable field name, defaults to expiresAt; TTL value in seconds) that writes the expiration date as a Firestore Timestamp, so documents can be deleted by a Firestore TTL policy, and ignores the data of expired documents Firestore hasn't deleted yet. Firestore.write() can't write Timestamp values, so this option queries and writes through the Firestore REST API
  - Add "Use custom database" option to read from and write to a named Firestore database through the Firestore REST API, since the Firestore API only supports the (default) database. GCP Project ID is required when either option is enabled, and so is the Database ID for a custom database. Invalid configuration (including a TTL that would expire after the year 9999) logs an error and returns the current values without reading or writing. With both options disabled, the variable still uses Firestore.query() and Firestore.write()
  - Fix: Firestore.query() only accepts collection paths, so the former default path "stape/restore" (a document path) never restored data and every write overwrote the same document. The field is now "Firestore Collection Path" (default "stape"), validated in the UI. A document path logs an error and returns the current values without reading or writing, as before
  - Support number and boolean values (including 0 and false) in the data to be restored, and return the current values without writing when the Firestore lookup fails, so an existing user doesn't get a duplicate document. Errors from REST API requests are logged
  - Rename "Firebase Project ID" to "GCP Project ID" and improve the help texts of all fields

2026-05-21 Change Notes:
 - Console logging removal.

Created on 15/01/2024, 17:29:11

