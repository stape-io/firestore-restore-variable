# Firestore reStore Variable for Google Tag Manager Server Container

The **Firestore reStore Variable** for Google Tag Manager Server Container allows you to connect to a Firestore database and dynamically fetch specific documents or collections based on user identifiers. It is ideal for use cases where you need to restore data values in GTM tags, triggers, and variables, particularly in cookieless, cross-device, and cross-site tracking scenarios.

This variable retrieves data from Firestore based on a list of identifiers (such as `user_id` or `client_id`) and restores the parameters specified in the list of the data to be restored.

**How it works:**

- The variable looks for a document in the collection that contains **any** of the identifier values.
- For each data row, a number, a boolean (including `0` and `false`) or non-empty text is returned and stored. Otherwise (e.g. no value, `null` or empty text), the stored value is returned, if any.
- The document is then updated with the merged identifiers and the data. If no document is found, a new one with a randomly generated ID is created, so each user gets their own document.
- If the lookup fails (e.g. a timeout or a Firestore error), the current values are returned and nothing is written, so an existing user doesn't get a duplicate document.

**Features:**

- **Only restore data** - read the stored data without writing anything to Firestore.
- **GCP Project ID** - read and write a Google Cloud project other than the one the server container runs in.
- **Use custom database** - read and write a named Firestore database instead of the `(default)` one.
- **Add TTL field** - add an expiration date field so Firestore can delete the document automatically with a [TTL policy](https://firebase.google.com/docs/firestore/ttl).

### Firestore Collection Path

The **Firestore Collection Path** must point to a **collection** (odd number of segments), e.g. `stape` (default) or `users/123/restore`. It must not start or end with a `/`.

Document paths (even number of segments) are invalid. With one, the variable logs an error and returns the current values without reading or writing Firestore. Up to the previous version, the default value was the document path `stape/restore`: with it, data was never restored and every write overwrote the same document. If your variable still uses it, change it to a collection path, e.g. `stape`.

### Custom database and TTL

The built-in GTM `Firestore` API only supports the `(default)` database and can't write Timestamp values. When **Use custom database** or **Add TTL field** is enabled, the variable queries and writes through the [Firestore REST API](https://firebase.google.com/docs/firestore/use-rest-api) instead, using the same Google credentials. In this mode, the **GCP Project ID** field is required (and the **Database ID** for a custom database), and failed requests are logged to the sGTM console. If the Database ID or GCP Project ID resolves to an empty value at runtime, the variable logs an error and doesn't read or write Firestore, instead of falling back to the `(default)` database.

**Add TTL field:**

- The field is written as a Firestore Timestamp (`Date and time`) value, set to the current time plus the **TTL value (seconds)**.
- The expiration date can't be later than the year 9999 (the maximum Firestore Timestamp). A larger TTL value logs an error and nothing is read or written.
- The expiration date is renewed every time the variable writes the document, so it counts from the last write.
- The field name is configurable and defaults to `expiresAt`. It must match the field of the TTL policy.
- [Create a TTL policy](https://firebase.google.com/docs/firestore/ttl#create_ttl_policy) for the collection group and field in the Google Cloud console. Without it, nothing is deleted.
- Expired documents are typically deleted within 24 hours after their expiration date. Until then, the variable doesn't restore their data and overwrites them on the next write.

## Useful Links

- [Firestore reStore Variable in the Template Gallery](https://tagmanager.google.com/gallery/#/owners/stape-io/templates/firestore-restore-variable)
- [Firestore reStore Variable Solution](https://stape.io/solutions/firestore-restore-variable)
- [Building a Custom CDP and enriching event data using Server-Side GTM](https://stape.io/blog/building-a-custom-cdp-and-enriching-event-data-using-server-side-gtm)


## Open Source

The **Firestore reStore Variable** for GTM Server is developed and maintained by the [Stape Team](https://stape.io/) under the Apache 2.0 license.

### GTM Gallery Status
🟢 [Listed](https://tagmanager.google.com/gallery/#/owners/stape-io/templates/firestore-restore-variable)
