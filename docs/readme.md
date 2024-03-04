# Readme

Here you will find some documentation of endpoints and assets that could help you to automated some process in creation of databases, etc.

## Index

- [Schema](#schema)
- [Endpoints: ](#endpoints-)
    - - [Signup](#signup)
    - - [Login](#login)
    - - [List of Ingested Document](#list-of-ingested-document-)
    - - [Add a Document to be ingested](#add-a-document-to-be-ingested-)
    - - [Add a Youtube video to be ingested](#add-a-youtube-video-to-be-ingested)
    - - [Chunks request](#chunks-request-)
    - - [Delete Ingested Documents (Actually embeddings)](#delete-ingested-documents-actually-embeddings-)
    - - [Train a TF-IDF model from a .csv file](#train-a-tf-idf-model-from-a-csv-file-)
    - - [Train a Random Forest model from a .csv file](#train-a-random-forest-model-from-a-csv-file-)
    - - [Evaluate trained models](#train-a-random-forest-model-from-a-csv-file-)
    - - [Download Files](#download-files)
    - - [One Group specific information](#one-group-specific-information)
    - - [List of all Groups of users](#list-of-all-groups-of-users)
    - - [List of all Files registered on DB](#list-of-all-files-registered-on-db)
    - - [List of all Files registered for an specific user](#list-of-all-files-registered-for-an-specific-user)
    - - [List of all Groups of a specific user v1](#list-of-all-groups-of-a-specific-user-v1)
    - - [List of all Groups of a specific user v2](#list-of-all-groups-of-a-specific-user-v2)
    - - [Add an user to a Group](#add-an-user-to-a-group)
    - - [Delete an user from a Group](#delete-an-user-from-a-group)
    - - [Add a new Group](#add-a-new-group)
    - - [Delete a Group](#delete-a-group)
    - - [Change the name of the Group](#change-the-name-of-the-group)
    - - [Link an user's file to a group](#link-an-users-file-to-a-group)
    - - [Un-link an user's file from a group](#un-link-an-users-file-from-a-group)
    - - [LLM semantic search](#llm-semantic-search)
- [Structure Folder: ](#structure-folder)
- [Vector Stores](#vector-stores)
- [Change limit of file's size to be recieved by the API](#change-limit-of-files-size-to-be-recieved-by-the-api)
- [Using Relational DB with Python and Flask-sqlAlchemy](#using-relational-db-with-python-and-flask-sqlalchemy)
    - - [Querying data using Python and SQL Alchemy (SELECT)](#querying-data-using-python-and-sql-alchemy-select)
    - - [Inserting data](#inserting-data)
    - - [Updating data](#updating-data)
    - - [Delete data](#delete-data)
    - - [ONE to MANY relationship](#one-to-many-relationship)
    - - [MANY to MANY relationship](#many-to-many-relationship)
    - - [Adding an endpoint](#adding-an-endpoint)
    - - [Using the admin](#using-the-admin)

## Schema

This is the database Schema, and how is related users, groups of users and embeddings into a relational DB.

<img src="./schema.png" alt="Database Schema"/>

## Endpoints <div id="endpoints"></div>

Note that some of the endpoints will need the Embedding installation to work properly.

### Signup

Endpoint: `/signup`
Method: `POST`
Content-Type: `application/json`
Response: 201 (created)
body:

```json
{
    "username": "metantonio", 
    "password": "123", 
    "name": "Antonio", 
    "email": "antonio.martinez@qlx.com",
    "gender": "Male",
    "lastname":"Martínez",
    "name": "Antonio",
    "password": "123",
    "phone": "12345678",
    "username": "metantonio"    
}
```

You should see the user created correctly into the DB, with password encrypted:
<img src="./frontend/correct_user.jpeg" alt="Ingested docs example"/>

### Login

Endpoint: `/login`
Method: `POST`
Content-Type: `application/json`
Response: 200 (ok)
body:

```json
{
    "username": "metantonio", 
    "password": "123" 
}
```

You can login with your email too:

```json
{
    "username": "antonio.martinez@qlx.com", 
    "password": "123" 
}
```

You will get a response with the `email` and `token` fields in json format. Token is related to the user's id in database. You need to give the token into the headers for be able to use a protected endpoint.

Headers:

```json
{
    "Authorization": "Bearer <token>"
}
```

### List of Ingested Document <div id="list-ingested"></div>

Lists already ingested Documents including their Document ID and metadata. Those IDs can be used to filter the context used to create responses. Please, check how to install LLM Embeddings because it's necessary to use this endpoint.

<img src="./list_ingested_docs_request.png" alt="Ingested docs example"/>

### Add a Document to be ingested <div id="add-ingested"></div>

Ingests and processes a file, storing its chunks to be used as context. This is a protected endpoint! because it's related to the user id, and for this `you must login first`.

Most common document
formats are supported, but you may be prompted to install an extra dependency to
manage a specific file type.

A file can generate different Documents (for example a PDF generates one Document per page). All Documents IDs are returned in the response, together with the extracted Metadata (which is later used to improve context retrieval). Those IDs can be used to filter the context used to create responses that could be use to ask to a LLM. . Please, check how to install LLM Embeddings because it's necessary to use this endpoint. This endpoint can receive a bunch of files, `sum of all files should not be more than 50 MB`. And backend should be generating embeddings while request is being processed. 

<img src="./ingestion_request.png" alt="Ingestion request"/>

Note: Optional parameters:
`group_context_filter`: is a list of groups IDs. The files ingested will be linked automatically with groups

Example of embedding generation printed on terminal:

```bash
Parsing nodes: 100%|█| 1/1 [00:00<00:0
Generating embeddings: 100%|█| 7/7 [00
Generating embeddings: 0it [00:00, ?it/Generating embeddings: 0it [00:00, ?it/s]
Parsing nodes: 100%|█| 1/1 [00:00<00:0
Generating embeddings: 100%|█| 8/8 [00 
Generating embeddings: 0it [00:00, ?it/Generating embeddings: 0it [00:00, ?it/s]
Parsing nodes: 100%|█| 1/1 [00:00<00:0
Generating embeddings:   0%| | 0/9 [00
```

Note: Recently i added another endpoint to be able to ingest documents `without login`. `Endpoint: /v1/ingest/file/no-jwt`. But this actions will not create the embedding's register into the relational DB because there is not an user related to the upload. Also, this non-protected endpoint only can accept one file ingestion and not a bunch of files.

### Add a Youtube video to be ingested

Actually what this does is scrape the transcription of a video on youtube, it always will try to obtain the manual transcription in english if exists, if don't it will take the automatic generated transcription, and will create a .txt file on the server to ingest the vector store. `It is a protected endpoint`

Endpoint: `/v1/ingest/youtube-transcript`
Method: `POST`
Response: 201 (OK)
Authorization: "Bearer `<JWT>`"
Content-Type: `application/json`

body:

```json
{
  "url": "https://www.youtube.com/watch?v=idwKHQEw78g"
}
```

response:

```json
{
    "data": [
        {
            "doc_id": "1e9d890b-3863-4352-8898-894052307c22",
            "doc_metadata": {
                "file_name": "https://www.youtube.com/watch?v=idwKHQEw78g"
            },
            "object": "ingest.document"
        }
    ],
    "model": "qlx-gpt",
    "object": "list"
}
```

### Chunks request <div id="chunks"></div>

Given a `text`, returns the most relevant chunks from the ingested documents. Note that this is a protected endpoint.

The returned information can be used to generate prompts that can be passed to a LLM. Note: it is usually a very fast API, because only the Embeddings model is involved, not the LLM. The returned information contains the relevant chunk `text` together with the source `document` it is coming from. It also contains a **score** (from 0.0 to 1.0) that can be used to compare different results. 

Optional parameters:

- The max number of chunks to be returned is set using the `limit`: Integer. By default is 10.

- Previous and next chunks (pieces of text that appear right before or after in the document) can be fetched by using the `prev_next_chunks` field. It can be passed as parameter (Optional). Integer. By default is 0.

- The documents being used can be filtered using the `context_filter` and passing the document IDs to be used. Ingested documents IDs can be found using `v1/ingest/list` endpoint. If you want all ingested documents to be used, remove `context_filter` altogether. The `context_filter` refers to a list of docs_id (as string). It can be passed as parameter (Optional).

- The documents being used can be filtered by group using the `group_context_filter`and passing the groups IDs to be used as a list.

- Note: The idea of `context_filter` is to limitate the documents to be checked by an user. For this i created a context_filter table, where the doc_id of a document will be linked to an user and/or group of users. All the logic for this is managed by the backend.

Please, check how to install LLM Embeddings because it's necessary to use this endpoint.

<img src="./chunks_request.png" alt="Chunks retrieval"/>

Note: For `unprotected endpoint` (that will retrieve chunks of any file) use `Endpoint: /chunks/no_jwt`

### Delete Ingested Documents (Actually embeddings) <div id="delete-ingested"></div>

Delete the specified ingested Document. Note that `this is a protected endpoint`.

Given a `description` and `model` to use, it evaluate the ML model and bring a result

Endpoint: `/v1/ingest/<doc_id>`
Method: `DELETE`
Response: 200 (OK)
Authorization: "Bearer `<JWT>`"

The `doc_id` can be obtained from the `GET /ingest/list` endpoint. The document will be effectively deleted from your storage context.

Remember, that in case of long text, pdf, etc... a `doc_id` refers to an embedding, that normally is only just 1 page of the actual document, so yes, every page of one pdf file will have a diferent `doc_id`.

You must send the `doc_id` in the url.

Please, check how to install LLM Embeddings because it's necessary to use this endpoint.

Example:

<img src="./delete_ingested_doc_request.png" alt="Delete ingested documents"/>

Note: I created a non-protected endpoint: `/v1/ingest/no_jwt/<doc_id>`, it will delete the document from the vector DB but not the register of the embeddings on the relational DB

### Train a TF-IDF model from a .csv file <div id="train-tf-model"></div>

Train a TF-IDF model (vector representation) from a csv file

<img src="./train_csv_request.png" alt="Train TF-IDF from a csv file"/>

### Train a Random Forest model from a .csv file <div id="train-rf-model"></div>

Train a Random Forest model (decision tree) from a csv file

<img src="./train_rf_request.png" alt="Train RF from a csv file"/>

### Evaluate trained models <div id="evaluate-models"></div>

Given a `description` and `model` to use, it evaluate the ML model and bring a result

Endpoint: `/evaluate-model`
Method: `POST`
Response: 201 (created)
body:

```json
{
    "description":"bovines",
    "model":"example.csv"
}
```

Response:

```json
{
    "message": "Model Trained",
    "table": [
        {
            "Code": 102210010,
            "Country": "US",
            "Description": "CATTLE, LIVE, PUREBRED BREEDING MALE, DAIRY",
            "NAICS": "11211X",
            "SITC": 111,
            "Similarity Percentage": 67.9884232129472,
            "USDA": 0,
            "Unit": "NO",
            "Unit2": NaN,
            "Year": 2023,
            "abbreviatn": "CATTLE, LIVE, PUREBRED BREEDING MALE, DAIRY",
            "end_use": 10140,
            "hitech": 0
        }
    ]
}
```

### Download Files

This is a protected endpoint, so you must send the Bearer JWT.
Endpoint: `/user/download/<name>`

Where `<name>` should be replaced by the name of the file. If the user uploaded the file and the file exist in the structure of the `upload` folder, then it will be downloaded.

check that the `upload` folder structure is:

```css
Project
│
└───upload
│   ├───1
│   │   │   ...
│   │   │
│   ├───2
│   │   │   ...
│   │   ...

```

Where 1, 2, etc.. are the user's ids in the relational dabatase. It can be changed to save the files in another service and just save the url into the database.

### One Group specific information

Endpoint: `/groups/<int:id>`
Method: `GET`
Response: 200 (ok)

Example Response (is a dictionary).

```json
{
    "id": 1,
    "list_files": [
        {
            "doc_id": "bbbd0052-db10-43e4-9b43-bdc79ecd5ccb",
            "id": 5,
            "name_file": "scheduleb_2024_c06.pdf",
            "page": 1,
            "path": "C:\\Users\\anton\\OneDrive\\Documentos\\Antonio\\Boilerplates\\description_model\\upload\\1\\scheduleb_2024_c06.pdf",
            "user_id": 1
        },
        {
            "doc_id": "b939d593-80fb-438c-abe9-b0235189b191",
            "id": 6,
            "name_file": "scheduleb_2024_c06.pdf",
            "page": 2,
            "path": "C:\\Users\\anton\\OneDrive\\Documentos\\Antonio\\Boilerplates\\description_model\\upload\\1\\scheduleb_2024_c06.pdf",
            "user_id": 1
        },
        {
            "doc_id": "2e95cc03-d1ee-4b91-93bd-060a12be9e5e",
            "id": 7,
            "name_file": "scheduleb_2024_c06.pdf",
            "page": 3,
            "path": "C:\\Users\\anton\\OneDrive\\Documentos\\Antonio\\Boilerplates\\description_model\\upload\\1\\scheduleb_2024_c06.pdf",
            "user_id": 1
        }
    ],
    "list_users": [
        1,
        2
    ],
    "name": "Friends"
}
```

Note: Replace the `<id>` with the group's id.

### List of all Groups of users

Endpoint: `/list-groups`
Method: `GET`
Response: 200 (ok)

Example response (is a list):

```json
[
    {
        "id": 1,
        "list_files": [
            {
                "doc_id": "2cf6e52e-03e0-427b-929a-c38180eea97c",
                "id": 1,
                "name_file": "scheduleballchapters.pdf",
                "path": "upload/1/scheduleballchapters.pdf",
                "user_id": 1
            }
        ],
        "list_users": [
            1
        ],
        "name": "Friends"
    }
]
```

Note: Of course, a group have to be created, an Embedding linked to a file must be registered on the DB.

### List of all Files registered on DB

This endpoint will show a file registered and all the group's ids where it belongs, these groups will be able to download the file.Some files could exist but not registered on DB.

Endpoint: `/list-files-embeddings`
Method: `GET`
Response: 200 (ok)

Example response (is a list):

```json
[
    {
        "doc_id": "2cf6e52e-03e0-427b-929a-c38180eea97c",
        "id": 1,
        "list_groups": [
            1
        ],
        "name_file": "scheduleballchapters.pdf",
        "path": "upload/1/scheduleballchapters.pdf",
        "user_id": 1
    }
]
```

### List of all Files registered for an specific user

It's a `protected endpoint`.

This endpoint will show a file registered and all the group's ids where it belongs, these groups will be able to download the file.Some files could exist but not registered on DB.

Endpoint: `/list-files-embeddings/user`
Method: `GET`
Response: 200 (ok)

Example response (is a list):

```json
[
    {
        "doc_id": "2cf6e52e-03e0-427b-929a-c38180eea97c",
        "id": 1,
        "list_groups": [
            1
        ],
        "name_file": "scheduleballchapters.pdf",
        "path": "upload/1/scheduleballchapters.pdf",
        "user_id": 1,
        "page":2
    }
]
```

### List of all Groups of a specific user v1

This endpoint will all the groups where a specific user belongs.

Endpoint: `/list-groups/user/<id>`
Method: `GET`
Response: 200 (ok)

replace the `<id>` with the user's id.

### List of all Groups of a specific user v2

This endpoint will all the groups where a specific user belongs. It's a `protected endpoint`.

Endpoint: `/list-groups/user`
Method: `GET`
Header: "Authorization": "Bearer <token>"
Response: 200 (ok)

### Add an user to a Group

This endpoint will add an user to a Group. It's a `protected endpoint`.

Endpoint: `/list-groups/edit-user`
Method: `POST`
Header: "Authorization": "Bearer <token>"
Content-Type: application/json
Response: 201 (created)

body: 

```json
{
    "username":"antonio",
    "group_id": 1
}
```

Note: can send an email instead of username, into the `username` key.

### Delete an user from a Group

This endpoint will delete an user from a Group. It's a `protected endpoint`.

Endpoint: `/list-groups/edit-user`
Method: `DELETE`
Header: "Authorization": "Bearer <token>"
Content-Type: application/json
Response: 200 (ok)

body: 

```json
{
    "username":"antonio",
    "group_id": 1
}
```

Note: can send an email instead of username, into the `username` key.

### Add a new Group

This endpoint will add a Group. It's a `protected endpoint`.

Endpoint: `/list-groups/edit-group`
Method: `POST`
Header: "Authorization": "Bearer <token>"
Content-Type: application/json
Response: 201 (created)

body: 

```json
{
    "name":"name of the new group"
}
```

### Delete a Group

This endpoint will add a Group. It's a `protected endpoint`.

Endpoint: `/list-groups/edit-group`
Method: `DELETE`
Header: "Authorization": "Bearer <token>"
Content-Type: application/json
Response: 200 (ok)

body: 

```json
{
    "group_id": 1
}
```

### Change the name of the group

This endpoint will add a Group. It's a `protected endpoint`.

Endpoint: `/groups`
Method: `PUT`
Header: "Authorization": "Bearer <token>"
Content-Type: application/json
Response: 200 (ok)

body: 

```json
{
    "group_id": 1,
    "name": "New name here"
}
```

### Link an user's file to a group

This endpoint will link an existing ingested file and registed embedding to a Group. It's a `protected endpoint`.

Endpoint: `/list-files-embeddings/user/group/edit`
Method: `POST`
Header: "Authorization": "Bearer <token>"
Content-Type: application/json
Response: 200 (ok)

body: 

```json
{
    "group_id": 1,
    "file_name": "the Book.pdf"
}
```

### Un-link an user's file from a group

This endpoint will un-link an existing ingested file and registed embedding to a Group. This will not delete the file, just un-link it. It's a `protected endpoint`.

Endpoint: `/list-files-embeddings/user/group/edit`
Method: `DELETE`
Header: "Authorization": "Bearer <token>"
Content-Type: application/json
Response: 200 (ok)

body: 

```json
{
    "group_id": 1,
    "file_name": "the Book.pdf"
}
```

### LLM semantic search

Given a prompt, a LLM will retrieve the most accurrate answers to the user, looking into the files that a specific user has access. It's a `protected endpoint`.

Note: By default, this will use the CPU (very slow depending of the hardware). For use GPU go to the <a href="./gpu/">`GPU folder`</a> to see instructions for installation. Note that, in order to be constant was a good idea to use the <a href="https://platform.openai.com/docs/api-reference/chat/object">OpenAI format</a>

Endpoint: `/completions`
Method: `POST`
Header: "Authorization": "Bearer <token>"
Content-Type: application/json
Response: 200 (ok)

body: 

```json
{
    "prompt": "Give me the most accurrate code for smarthphones"
}
```

optional parameters on body:

```json
{
    "prompt": "Give me the most accurrate code for smarthphones",
    "group_context_filter": [1, 4], /* (optional) This will only take documents on these groups to make the semantic search, if this parameter is activated, then the context_filter parameter should not be used */
    "context_filter":["e5cfbbdd-6f39-409b-8e5c-3c03bc340c9b", "69c0b775-e6fc-4435-985c-2eb3d262da74"] /* (optional) This will only take documents on list of IDs of documents, if this parameter is activated, then the group_context_filter parameter should not be used */
}
```


example of response:

```json
{
    "created": 1707431047,
    "id": "e992f4b2-5e2d-4731-a191-79dbd95f104c",
    "model": "qlx-gpt",
    "object": "completion",
    "choices": [
        {
            "delta": null,
            "finish_reason": "stop",
            "index": 0,
            "message": {
                "content": " Based on the context information provided, the most accurate Harmonized System (HS) code for smartphones is 8517.13.00. This code falls under Heading 8517 which covers \"Telephone sets, including smartphones and other telephones for cellular networks or other wireless networks.\" The specific subheading 13 refers to \"Smartphones.\"",
                "role": "assistant"
            },
            "sources": [
                {
                    "document": {
                        "doc_id": "e5cfbbdd-6f39-409b-8e5c-3c03bc340c9b",
                        "doc_metadata": {
                            "doc_id": "e5cfbbdd-6f39-409b-8e5c-3c03bc340c9b",
                            "file_name": "hts_c85.pdf",
                            "original_text": "Other:......................................................................... 8519.81.41 35% Free ..................\nTelephone answering machines ...................... 05 No.\n",
                            "page_label": "38",
                            "window": "Rates of Duty Unit\nof\nQuantityArticle Descr iptionStat.\n Suf-\nfixHeading/\nSubheading 2 1\nSpecial Gener al\nSoundrecording orreproducing apparatus: 8519\nApparatus operated bycoins,banknotes, bankcards,\ntokensorbyothermeansofpayment..................................00 8519.20.00\n35% Free8/No.............\nTurntables (record-decks): 8519.30\nWithautomatic recordchanging mechanism ............... 00 8519.30.10 35% Free(A,AU,B,BH,\nCL,CO,D,E,IL,\nJO,KR,MA,OM,\nP,PA,PE,S,SG)3.9%8/No.............\nOther................................................................................. 00 8519.30.20 35% Free No.............\nOtherapparatus:\nUsingmagnetic, opticalorsemiconductor media: 8519.81\nSoundreproducing only:\nTranscribing machines ...................................... 00 8519.81.10 35% Free8/No.............\nCassette-type tapeplayers:\nDesigned exclusively formotor-vehicle\ninstallation ....................................................00 8519.81.20\n35% Free No.............\nOther............................................................. 00 8519.81.25 35% Free No.............\nOther:.................................................................. 8519.81.30 35% Free5/..................\nOpticaldisc(including compact disc)\nplayers..........................................................10\nNo.\n Other............................................................. 20 No.\n Other:......................................................................... 8519.81.41 35% Free ..................\nTelephone answering machines ...................... 05 No.\n Magnetic taperecorders incorporating sound\nreproducing apparatus ......................................10\nNo.\n Opticaldiscrecorders ....................................... 20 No.\n"
                        },
                        "object": "ingest.document"
                    },
                    "next_texts": null,
                    "object": "context.chunk",
                    "previous_texts": null,
                    "score": 0.6863110807241749,
                    "text": "Rates of Duty Unit\nof\nQuantityArticle Descr iptionStat.\n Suf-\nfixHeading/\nSubheading 2 1\nSpecial Gener al\nSoundrecording orreproducing apparatus: 8519\nApparatus operated bycoins,banknotes, bankcards,\ntokensorbyothermeansofpayment..................................00 8519.20.00\n35% Free8/No.............\nTurntables (record-decks): 8519.30\nWithautomatic recordchanging mechanism ............... 00 8519.30.10 35% Free(A,AU,B,BH,\nCL,CO,D,E,IL,\nJO,KR,MA,OM,\nP,PA,PE,S,SG)3.9%8/No.............\nOther................................................................................. 00 8519.30.20 35% Free No.............\nOtherapparatus:\nUsingmagnetic, opticalorsemiconductor media: 8519.81\nSoundreproducing only:\nTranscribing machines ...................................... 00 8519.81.10 35% Free8/No.............\nCassette-type tapeplayers:\nDesigned exclusively formotor-vehicle\ninstallation ....................................................00 8519.81.20\n35% Free No.............\nOther............................................................. 00 8519.81.25 35% Free No.............\nOther:.................................................................. 8519.81.30 35% Free5/..................\nOpticaldisc(including compact disc)\nplayers..........................................................10\nNo.\n Other............................................................. 20 No.\n Other:......................................................................... 8519.81.41 35% Free ..................\nTelephone answering machines ...................... 05 No.\n Magnetic taperecorders incorporating sound\nreproducing apparatus ......................................10\nNo.\n Opticaldiscrecorders ....................................... 20 No.\n"
                },
                {
                    "document": {
                        "doc_id": "69c0b775-e6fc-4435-985c-2eb3d262da74",
                        "doc_metadata": {
                            "doc_id": "69c0b775-e6fc-4435-985c-2eb3d262da74",
                            "file_name": "hts_c85.pdf",
                            "original_text": "For the pur poses of heading 8517, the ter m “smar tphones”  means telephones f or cellular netw orks, equipped with a mobile\noperating system designed to perf orm the functions of an automatic data processing machine such as do wnloading and r unning\nmultiple applications sim ultaneously , including third-par ty applications , and whether or not integ rating other f eatures such as\ndigital camer as and na vigational aid systems .\n",
                            "page_label": "1",
                            "window": "Heading 8509 co vers only the f ollowing electromechanical machines of the kind commonly used f or domestic pur poses:\n(a) Floor polishers , food g rinders and mix ers, and fr uit or v egetab le juice e xtractors , of an y weight;\n(b) Other machines pro vided the w eight of such machines does not e xceed 20 kg, e xclusiv e of e xtra interchangeab le par ts or\ndetachab le auxiliar y devices .\n The heading does not, ho wever, apply to f ans or v entilating or recycling hoods incor porating a f an, whether or not fitted with filters\n(heading 8414), centr ifugal clothes dr yers (heading 8421), dishw ashing machines (heading 8422), household w ashing machines\n(heading 8450), roller or other ironing machines (heading 8420 or 8451), se wing machines (heading 8452), electr ic scissors\n(heading 8467) or to electrother mic appliances (heading 8516).\n 5.  For the pur poses of heading 8517, the ter m “smar tphones”  means telephones f or cellular netw orks, equipped with a mobile\noperating system designed to perf orm the functions of an automatic data processing machine such as do wnloading and r unning\nmultiple applications sim ultaneously , including third-par ty applications , and whether or not integ rating other f eatures such as\ndigital camer as and na vigational aid systems .\n 6.  For the pur poses of heading 8523:\n(a) \"Solid-state non-v olatile stor age de vices \"(f or example ,\"flash memor y cards\" or \"flash electronic stor age cards\") are stor age\ndevices with a connecting soc ket, compr ising in the same housing one or more flash memor ies (f or example , \"FLASH\nE²PR OM\") in the f orm of integ rated circuits mounted on a pr inted circuit board. "
                        },
                        "object": "ingest.document"
                    },
                    "next_texts": null,
                    "object": "context.chunk",
                    "previous_texts": null,
                    "score": 0.6484644596077237,
                    "text": "Heading 8509 co vers only the f ollowing electromechanical machines of the kind commonly used f or domestic pur poses:\n(a) Floor polishers , food g rinders and mix ers, and fr uit or v egetab le juice e xtractors , of an y weight;\n(b) Other machines pro vided the w eight of such machines does not e xceed 20 kg, e xclusiv e of e xtra interchangeab le par ts or\ndetachab le auxiliar y devices .\n The heading does not, ho wever, apply to f ans or v entilating or recycling hoods incor porating a f an, whether or not fitted with filters\n(heading 8414), centr ifugal clothes dr yers (heading 8421), dishw ashing machines (heading 8422), household w ashing machines\n(heading 8450), roller or other ironing machines (heading 8420 or 8451), se wing machines (heading 8452), electr ic scissors\n(heading 8467) or to electrother mic appliances (heading 8516).\n 5.  For the pur poses of heading 8517, the ter m “smar tphones”  means telephones f or cellular netw orks, equipped with a mobile\noperating system designed to perf orm the functions of an automatic data processing machine such as do wnloading and r unning\nmultiple applications sim ultaneously , including third-par ty applications , and whether or not integ rating other f eatures such as\ndigital camer as and na vigational aid systems .\n 6.  For the pur poses of heading 8523:\n(a) \"Solid-state non-v olatile stor age de vices \"(f or example ,\"flash memor y cards\" or \"flash electronic stor age cards\") are stor age\ndevices with a connecting soc ket, compr ising in the same housing one or more flash memor ies (f or example , \"FLASH\nE²PR OM\") in the f orm of integ rated circuits mounted on a pr inted circuit board. "
                },
                {
                    "document": {
                        "doc_id": "d528cb1c-b527-4ea9-a8db-e0bbbfae7f08",
                        "doc_metadata": {
                            "doc_id": "d528cb1c-b527-4ea9-a8db-e0bbbfae7f08",
                            "file_name": "scheduleb_2024_c85.pdf",
                            "original_text": "- - - - Other:\n8519.81.4105 - - - - - Telephone answering machines No.\n",
                            "page_label": "18",
                            "window": "- - - - - Cassette-type tape players:\n8519.81.2000 - - - - - - Designed exclusively for motor-vehicle installation No.\n 8519.81.2500 - - - - - - Other No.\n 8519.81.3000 - - - - - Other No.\n - - - - Other:\n8519.81.4105 - - - - - Telephone answering machines No.\n 8519.81.4110 - - - - - Magnetic tape recorders incorporating sound reproducing \napparatus, other than telephone answering machines No.\n 8519.81.4120 - - - - - Optical disc recorders No.\n"
                        },
                        "object": "ingest.document"
                    },
                    "next_texts": null,
                    "object": "context.chunk",
                    "previous_texts": null,
                    "score": 0.6396457534335221,
                    "text": "- - - - - Cassette-type tape players:\n8519.81.2000 - - - - - - Designed exclusively for motor-vehicle installation No.\n 8519.81.2500 - - - - - - Other No.\n 8519.81.3000 - - - - - Other No.\n - - - - Other:\n8519.81.4105 - - - - - Telephone answering machines No.\n 8519.81.4110 - - - - - Magnetic tape recorders incorporating sound reproducing \napparatus, other than telephone answering machines No.\n 8519.81.4120 - - - - - Optical disc recorders No.\n"
                },
                {
                    "document": {
                        "doc_id": "75d501f6-247b-45c2-bda2-deeec937730f",
                        "doc_metadata": {
                            "doc_id": "75d501f6-247b-45c2-bda2-deeec937730f",
                            "file_name": "hts_c85.pdf",
                            "original_text": "Suf-\nfixHeading/\nSubheading 2 1\nSpecial Gener al\nTelephone sets,including smartphones andothertelephones\nforcellularnetworks orforotherwireless networks; other\napparatus forthetransmission orreception ofvoice,images\norotherdata,including apparatus forcommunication inawired\norwireless network(suchasalocalorwideareanetwork),\notherthantransmission orreception apparatus ofheading\n8443,8525,8527or8528;partsthereof:8517\nTelephone sets,including smartphones andother\ntelephones forcellularnetworks orforotherwireless\nnetworks :\nLinetelephone setswithcordless handsets ................. 00 8517.11.00 35% Free8/No.............\nSmartphones ................................................................... 00 8517.13.00 35% Free No.............\nOthertelephones forcellularnetworks orforother\nwireless networks ............................................................8517.14.00\n35% Free ..................\nRadiotelephones designed forinstallation inmotor\nvehicles forthePublicCellular\nRadiotelecommunication Service...........................20\nNo.\n",
                            "page_label": "36",
                            "window": "Rates of Duty Unit\nof\nQuantityArticle Descr iptionStat.\n Suf-\nfixHeading/\nSubheading 2 1\nSpecial Gener al\nTelephone sets,including smartphones andothertelephones\nforcellularnetworks orforotherwireless networks; other\napparatus forthetransmission orreception ofvoice,images\norotherdata,including apparatus forcommunication inawired\norwireless network(suchasalocalorwideareanetwork),\notherthantransmission orreception apparatus ofheading\n8443,8525,8527or8528;partsthereof:8517\nTelephone sets,including smartphones andother\ntelephones forcellularnetworks orforotherwireless\nnetworks :\nLinetelephone setswithcordless handsets ................. 00 8517.11.00 35% Free8/No.............\nSmartphones ................................................................... 00 8517.13.00 35% Free No.............\nOthertelephones forcellularnetworks orforother\nwireless networks ............................................................8517.14.00\n35% Free ..................\nRadiotelephones designed forinstallation inmotor\nvehicles forthePublicCellular\nRadiotelecommunication Service...........................20\nNo.\n Otherradiotelephones designed forthePublic\nCellularRadiotelecommunication Service.............50\nNo.\n Other.......................................................................... 80 No.\n"
                        },
                        "object": "ingest.document"
                    },
                    "next_texts": null,
                    "object": "context.chunk",
                    "previous_texts": null,
                    "score": 0.6380401786564524,
                    "text": "Rates of Duty Unit\nof\nQuantityArticle Descr iptionStat.\n Suf-\nfixHeading/\nSubheading 2 1\nSpecial Gener al\nTelephone sets,including smartphones andothertelephones\nforcellularnetworks orforotherwireless networks; other\napparatus forthetransmission orreception ofvoice,images\norotherdata,including apparatus forcommunication inawired\norwireless network(suchasalocalorwideareanetwork),\notherthantransmission orreception apparatus ofheading\n8443,8525,8527or8528;partsthereof:8517\nTelephone sets,including smartphones andother\ntelephones forcellularnetworks orforotherwireless\nnetworks :\nLinetelephone setswithcordless handsets ................. 00 8517.11.00 35% Free8/No.............\nSmartphones ................................................................... 00 8517.13.00 35% Free No.............\nOthertelephones forcellularnetworks orforother\nwireless networks ............................................................8517.14.00\n35% Free ..................\nRadiotelephones designed forinstallation inmotor\nvehicles forthePublicCellular\nRadiotelecommunication Service...........................20\nNo.\n Otherradiotelephones designed forthePublic\nCellularRadiotelecommunication Service.............50\nNo.\n Other.......................................................................... 80 No.\n"
                }
            ]
        }
    ]    
}
```

## Structure Folder

The folder structure for the Flask-Python server is the following:

```css
Project
│   .gitignore
│   .env
│   poetry.lock
│   pycodestyle.cfg
│   pyproject.toml
│   webpack.prod.js
│   settings-docker.yaml
│   settings-local.yaml
│   settings-mock.yaml
│   settings-sagemaker.yaml
│   settings-vllm.yaml
│   settings.yaml
│   setup.py
│
└───src
│   │   __init__.py
│   │   admin.py
│   │   commands.py
│   │   db.py
│   │   main.py
│   │   run.py
│   │   utilsm.py
│   │   wsgi.py
│   │
│   ├───components
│   │   │   __init__.py
│   │   │   constants.py
│   │   │   di.py
│   │   │   paths.py
│   │   │
│   │   │───embeddings
│   │   │   │   __init__.py
│   │   │   │   embedding_component.py
│   │   │   │
│   │   │   │───custom
│   │   │   │   │   __init__.py
│   │   │   │   │   sagemaker.py
│   │   │   │   │
│   │   │───ingest
│   │   │   │   __init__.py
│   │   │   │   ingest_component.py  
│   │   │   │   ingest_helper.py  
│   │   │   │
│   │   │───llm
│   │   │   │   __init__.py
│   │   │   │   llm_component.py
│   │   │   │   prompt_helper.py
│   │   │   │
│   │   │───node_store
│   │   │   │   __init__.py
│   │   │   │   node_store_component.py
│   │   │   │
│   │   │───open_ai
│   │   │   │   __init__.py
│   │   │   │   openai_models.py
│   │   │   │  
│   │   │   │───extensions
│   │   │   │   │   __init__.py
│   │   │   │   │   context_filter.py
│   │   │   │   │ 
│   │   │───vector_store
│   │   │   │   __init__.py
│   │   │   │   batched_chroma.py
│   │   │   │   vector_store_component.py
│   │   │   │   
│   ├───modelos
│   │   │   __init__.py
│   │   │   user.py
│   │   │   group_users.py
│   │   │   pivot_groupusers.py
│   │   │   embedding_file.py
│   │   │   pivot_groupembeddings.py
│   │   │
│   ├───routes
│   │   │   __init__.py
│   │   │   embeddings.py
│   │   │   group_users.py
│   │   │   machine_learning.py
│   │   │   user.py
│   │   │
│   │   │───chunks
│   │   │   │   __init__.py
│   │   │   │   chunks_router.py
│   │   │   │   chunks_service.py
│   │   │
│   │   │───ingest
│   │   │   │   __init__.py
│   │   │   │   ingest_router.py
│   │   │   │   ingest_service.py
│   │   │   │   ingest_watcher.py
│   │   │
│   │   │───chat
│   │   │   │   __init__.py
│   │   │   │   chat_router.py
│   │   │   │   chat_service.py
│   │   │
│   │   │───completions
│   │   │   │   __init__.py
│   │   │   │   completions_router.py
│   │   │
│   ├───scripts
│   │   │   __init__.py
│   │   │   ingest_folder.py
│   │   │   utils.py
│   │   │
│   ├───settings
│   │   │   __init__.py
│   │   │   settings_loader.py
│   │   │   settings.py
│   │   │   yaml.py
│   │   │
│   │───utils
│   │   │   __init__.py
│   │   │   typing.py
│   │   │   
└───docs
│
└───upload
   
│
└───migrations
│
└───local_data 
│   │
│   ├───vectorDB
    
```

## Vector stores

"One of the most common ways to store and search over unstructured data is to embed it and store the resulting embedding vectors, and then at query time to embed the unstructured query and retrieve the embedding vectors that are 'most similar' to the embedded query. A vector store takes care of storing embedded data and performing vector search for you." - [LangChain Documentation](https://python.langchain.com/docs/modules/data_connection/vectorstores/)

<img src="https://python.langchain.com/assets/images/vector_stores-125d1675d58cfb46ce9054c9019fea72.jpg" alt="Vector stores diagram"/>

Backend supports Chroma and QDrant vector databases. By default, QDrant is being used, and that is because it supports asynchronous operations.

Note: QDrant vector database use port `6333` and connection string `http://localhost:6333` by default. That means that database and Backend are in the same hardware device or instance.

## Change limit of file's size to be recieved by the API

Endpoints to recieve files to be ingested or recieve .csv file to be trained have a limit of 50 MB by the API. You can change this parameter at `main.py` file:

```python
# Max Size (50 MB in this example)
app.config['MAX_CONTENT_LENGTH'] = 50 * 1024 * 1024  # 50 MB
```

## Using Relational DB with Python and Flask-sqlAlchemy

### Querying data using Python and SQL Alchemy (SELECT)

Assuming you have a Person object in your models.py file.

```python
# get all the people
people_query = Person.query.all()

# get only the ones named "Joe"
people_query = Person.query.filter_by(name='Joe')

# map the results and your list of people  inside of the all_people variable
all_people = list(map(lambda x: x.serialize(), people_query))

# get just one person
user1 = Person.query.get(person_id)
```

### Inserting data

Assuming you have a Person object in your models.py file.

```python
user1 = Person(username="my_super_username", email="my_super@email.com")
db.session.add(user1)
db.session.commit()
```

### Updating data

```python
user1 = Person.query.get(person_id)
if user1 is None:
    raise APIException('User not found', status_code=404)

if "username" in body:
    user1.username = body["username"]
if "email" in body:
    user1.email = body["email"]
db.session.commit()
```
 
### Delete data
 
```python
user1 = Person.query.get(person_id)
if user1 is None:
    raise APIException('User not found', status_code=404)
db.session.delete(user1)
db.session.commit()
```

### ONE to MANY relationship
A one to many relationship places a foreign key on the child table referencing the parent. 
Relationship() is then specified on the parent, as referencing a collection of items represented by the child:

```py
class Parent(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(80), nullable=False)
    children = db.relationship('Child', lazy=True)

    def __repr__(self):
        return f'<Parent {self.name}>'

    def serialize(self):
        return {
            "id": self.id,
            "name": self.name,
            "children": list(map(lambda x: x.serialize(), self.children))
        }

class Child(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(80), nullable=False)
    parent_id = db.Column(db.Integer, db.ForeignKey("Parent.id"))
    
    def __repr__(self):
        return '<Child {self.name}>
        
    def serialize(self):
        return {
            "id": self.id,
            "name": self.name
        }
```

### MANY to MANY relationship
Many to Many adds an association table between two classes. The association table is indicated by the secondary argument to relationship(). Usually, the Table uses the MetaData object associated with the declarative base class, so that the ForeignKey directives can locate the remote tables with which to link:

```py
association_table = Table('association', Base.metadata,
    Column("sister_id", Integer, ForeignKey("Sister.id")),
    Column("brother_id", Integer, ForeignKey("Brother.id"))
)

class Sister(db.Model):
    id = db.Column(Integer, primary_key=True)
    name = db.Column(String(80), nullable=False)
    brothers = relationship("Brother",
                    secondary=association_table
                    back_populates="sisters") # this line is so it updates the field when Sister is updated
                    
    def __ref__(self):
        return f'<Sister {self.name}>'
        
    def serialize(self):
        return {
            "id": self.id,
            "name": self.name,
            "brothers": list(map(lambda x: x.serialize(), self.brothers))
        }

class Brother(db.Model):
    id = db.Column(Integer, primary_key=True)
    name = db.Column(String(80), nullable=False)
    sisters = relationship("Sister",
                    secondary=association_table
                    back_populates="brothers")
                    
    def __ref__(self):
        return f'<Brother {self.name}>'
        
    def serialize(self):
        return {
            "id": self.id,
            "name": self.name,
            "sisters": list(map(lambda x: x.serialize(), self.sisters))
        }
```

Note: If `association_table` needs to be in a diferent file (for scalability), then i recommend convert it into a Python Class. Usually i name these cases as `pivot_tableName.py`. Check the `/src/modelos` folder

### Adding an endpoint

For each endpoint you will need to have:
1. One `@app` decorator that specifies the path for the expoint.
    - You can have parameters in the url like this `<int:person_id>`
    - You can specify what methods can be called on that endpoint like this `methods=['PUT', 'GET']`
    - You can obtain parameters from the request's body as json `body = request.get_json()`
2. The method what will execute when that endpoint is called (in this case `get_single_person`), the name of the method does not matter but it cannot be repeated.
3. Inside the method you can speficy what logic to execute of each type of request using `if request.method == 'PUT'`
4. You have to return always a json and a status code (200,400,404, etc.)

```python
#Un-protected endpoint
@app.route('/person/<int:person_id>', methods=['PUT', 'GET'])
def get_single_person(person_id):
    """
    Single person
    """
    body = request.get_json() #{ 'username': 'new_username'}
    if request.method == 'PUT':
        user1 = Person.query.get(person_id)
        user1.username = body.username
        db.session.commit()
        return jsonify(user1.serialize()), 200
    if request.method == 'GET':
        user1 = Person.query.get(person_id)
        return jsonify(user1.serialize()), 200

    return "Invalid Method", 404

#Protected endpoint (user's id in database is encrypted in the JWT)
@app.route('/person/', methods=['PUT', 'GET'])
@jwt_required()
def get_single_person_protected():
    """
    Single person
    """
    body = request.get_json() #{ 'username': 'new_username'}
    person_id = get_jwt_identity() #only this user will be able to do the PUT and GET method of this endpoint
    if request.method == 'PUT':
        user1 = Person.query.get(person_id)
        user1.username = body.username
        db.session.commit()
        return jsonify(user1.serialize()), 200
    if request.method == 'GET':
        user1 = Person.query.get(person_id)
        return jsonify(user1.serialize()), 200

    return "Invalid Method", 404
```

Note: The `JWT` is generated by the API when the user make a login. JWT should be saved by the client side.

### Using the admin

You can add your models to the admin, that way you will be able to manage them without any extra code.

To add a new model into the admin, just open the `src/admin.py` file and add this line inside the `setup_admin` function.

```python
admin.add_view(ModelView(YourModelName, db.session))
```

Note: Make sure you import the model on the top of the file