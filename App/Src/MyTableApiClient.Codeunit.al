codeunit 50003 "My Table API Client"
{
    /// <summary>
    /// Example codeunit that shows how to consume a REST API from Business Central AL.
    /// The API is assumed to expose "My Table" records as JSON at a configurable base URL.
    ///
    /// Expected JSON shape for a single record:
    ///   {
    ///     "no":          "REC001",
    ///     "name":        "Office Chair",
    ///     "description": "Ergonomic office chair with lumbar support",
    ///     "quantity":    10,
    ///     "createdDate": "2026-01-05"
    ///   }
    ///
    /// Supported HTTP methods:
    ///   GET    /api/mytable          – Fetch all records (list)
    ///   GET    /api/mytable/{no}     – Fetch a single record by its No.
    ///   POST   /api/mytable          – Create a new record
    ///   PUT    /api/mytable/{no}     – Replace an existing record (full update)
    ///   PATCH  /api/mytable/{no}     – Partially update an existing record
    ///   DELETE /api/mytable/{no}     – Delete a record
    ///
    /// Replace the BaseUrlTok label with your actual API endpoint before use.
    /// </summary>

    var
        BaseUrlTok: Label 'https://api.example.com/api/mytable', Locked = true;

    // ── GET – list all records ────────────────────────────────────────────────

    /// <summary>
    /// Calls GET /api/mytable and upserts every returned record into My Table.
    /// Records that already exist are updated; new ones are inserted.
    /// </summary>
    procedure GetList()
    var
        MyTableRec: Record "My Table";
        ApiResponse: HttpResponseMessage;
        ApiResponseText: Text;
        RecordsJsonArray: JsonArray;
        RecordToken: JsonToken;
    begin
        SendRequest('GET', BaseUrl(), '', ApiResponse);
        EnsureSuccess(ApiResponse);

        ApiResponse.Content.ReadAs(ApiResponseText);
        if not RecordsJsonArray.ReadFrom(ApiResponseText) then
            Error('The API response could not be parsed as a JSON array.');

        foreach RecordToken in RecordsJsonArray do
            ApplyJsonToRecord(RecordToken.AsObject(), MyTableRec);

        Message('Fetched %1 record(s) from the API.', RecordsJsonArray.Count());
    end;

    // ── GET – single record ───────────────────────────────────────────────────

    /// <summary>
    /// Calls GET /api/mytable/{no} and populates MyTable with the returned data.
    /// Inserts the record if it does not yet exist locally; otherwise updates it.
    /// </summary>
    procedure GetRecord(No: Code[20]; var MyTable: Record "My Table")
    var
        ApiResponse: HttpResponseMessage;
        ApiResponseText: Text;
        RecordJsonObject: JsonObject;
    begin
        SendRequest('GET', BaseUrl() + '/' + No, '', ApiResponse);
        EnsureSuccess(ApiResponse);

        ApiResponse.Content.ReadAs(ApiResponseText);
        if not RecordJsonObject.ReadFrom(ApiResponseText) then
            Error('The API response could not be parsed as a JSON object.');

        ApplyJsonToRecord(RecordJsonObject, MyTable);
    end;

    // ── POST – create a new record ────────────────────────────────────────────

    /// <summary>
    /// Calls POST /api/mytable with the serialised record as the request body.
    /// Use this to create a brand-new record on the remote API.
    /// </summary>
    procedure CreateRecord(MyTable: Record "My Table")
    var
        ApiResponse: HttpResponseMessage;
    begin
        SendRequest('POST', BaseUrl(), RecordToJson(MyTable), ApiResponse);
        EnsureSuccess(ApiResponse);
        Message('Record ''%1'' created via the API.', MyTable."No.");
    end;

    // ── PUT – full replacement of a record ────────────────────────────────────

    /// <summary>
    /// Calls PUT /api/mytable/{no} with the full record as the request body.
    /// All fields are sent; the server replaces the existing resource entirely.
    /// </summary>
    procedure UpdateRecord(MyTable: Record "My Table")
    var
        ApiResponse: HttpResponseMessage;
    begin
        SendRequest('PUT', BaseUrl() + '/' + MyTable."No.", RecordToJson(MyTable), ApiResponse);
        EnsureSuccess(ApiResponse);
        Message('Record ''%1'' updated via the API (full replace).', MyTable."No.");
    end;

    // ── PATCH – partial update ────────────────────────────────────────────────

    /// <summary>
    /// Calls PATCH /api/mytable/{no} with a partial JSON payload.
    /// Only the fields present in PatchJson are modified on the server.
    ///
    /// Example – update only the quantity:
    ///   PatchRecord('REC001', '{"quantity": 42}');
    /// </summary>
    procedure PatchRecord(No: Code[20]; PatchJson: Text)
    var
        ApiResponse: HttpResponseMessage;
    begin
        SendRequest('PATCH', BaseUrl() + '/' + No, PatchJson, ApiResponse);
        EnsureSuccess(ApiResponse);
        Message('Record ''%1'' patched via the API.', No);
    end;

    // ── DELETE – remove a record ──────────────────────────────────────────────

    /// <summary>
    /// Calls DELETE /api/mytable/{no} to remove the record from the remote API.
    /// </summary>
    procedure DeleteRecord(No: Code[20])
    var
        ApiResponse: HttpResponseMessage;
    begin
        SendRequest('DELETE', BaseUrl() + '/' + No, '', ApiResponse);
        EnsureSuccess(ApiResponse);
        Message('Record ''%1'' deleted via the API.', No);
    end;

    // ── Private helpers ───────────────────────────────────────────────────────

    local procedure BaseUrl(): Text
    begin
        exit(BaseUrlTok);
    end;

    /// <summary>
    /// Builds and dispatches an HTTP request.
    /// Sets the Accept and (when a body is present) Content-Type headers automatically.
    /// Raises an error if the network call itself fails.
    /// </summary>
    local procedure SendRequest(HttpMethod: Text; EndpointUrl: Text; RequestBody: Text; var ApiResponse: HttpResponseMessage)
    var
        ApiHttpClient: HttpClient;
        ApiRequest: HttpRequestMessage;
        RequestContent: HttpContent;
        ApiRequestHeaders: HttpHeaders;
        RequestContentHeaders: HttpHeaders;
    begin
        ApiRequest.Method := HttpMethod;
        ApiRequest.SetRequestUri(EndpointUrl);

        ApiRequest.GetHeaders(ApiRequestHeaders);
        ApiRequestHeaders.Add('Accept', 'application/json');

        if RequestBody <> '' then begin
            RequestContent.WriteFrom(RequestBody);
            RequestContent.GetHeaders(RequestContentHeaders);
            if RequestContentHeaders.Contains('Content-Type') then
                RequestContentHeaders.Remove('Content-Type');
            RequestContentHeaders.Add('Content-Type', 'application/json');
            ApiRequest.Content := RequestContent;
        end;

        if not ApiHttpClient.Send(ApiRequest, ApiResponse) then
            Error('Failed to connect to the API at ''%1''.', EndpointUrl);
    end;

    /// <summary>
    /// Raises an error when the HTTP response status code indicates failure (not 2xx).
    /// The response body is included in the error message to aid troubleshooting.
    /// </summary>
    local procedure EnsureSuccess(var ApiResponse: HttpResponseMessage)
    var
        HttpStatusCode: Integer;
        ErrorResponseBody: Text;
    begin
        HttpStatusCode := ApiResponse.HttpStatusCode();
        if (HttpStatusCode >= 200) and (HttpStatusCode < 300) then
            exit;

        ApiResponse.Content.ReadAs(ErrorResponseBody);
        Error('API returned HTTP %1.\\Response body: %2', HttpStatusCode, ErrorResponseBody);
    end;

    /// <summary>
    /// Serialises a My Table record to a JSON object string.
    /// The "createdDate" field is formatted as ISO 8601 (YYYY-MM-DD).
    /// </summary>
    local procedure RecordToJson(MyTable: Record "My Table"): Text
    var
        RecordJsonObject: JsonObject;
        SerializedRecord: Text;
        CreatedDateText: Text;
    begin
        RecordJsonObject.Add('no', MyTable."No.");
        RecordJsonObject.Add('name', MyTable.Name);
        RecordJsonObject.Add('description', MyTable.Description);
        RecordJsonObject.Add('quantity', MyTable.Quantity);
        if MyTable."Created Date" <> 0D then
            CreatedDateText := Format(MyTable."Created Date", 0, 9);
        RecordJsonObject.Add('createdDate', CreatedDateText);
        RecordJsonObject.WriteTo(SerializedRecord);
        exit(SerializedRecord);
    end;

    /// <summary>
    /// Deserialises a JSON object into a My Table record.
    /// Inserts the record when it does not yet exist locally; otherwise updates it.
    /// Fields absent from the JSON object are left unchanged.
    /// </summary>
    local procedure ApplyJsonToRecord(RecordJsonObject: JsonObject; var MyTable: Record "My Table")
    var
        FieldValueToken: JsonToken;
        RecordNo: Code[20];
    begin
        if not RecordJsonObject.Get('no', FieldValueToken) then
            exit;
        RecordNo := CopyStr(FieldValueToken.AsValue().AsText(), 1, MaxStrLen(MyTable."No."));
        if RecordNo = '' then
            exit;

        if not MyTable.Get(RecordNo) then begin
            MyTable.Init();
            MyTable."No." := RecordNo;
        end;

        if RecordJsonObject.Get('name', FieldValueToken) then
            MyTable.Name := CopyStr(FieldValueToken.AsValue().AsText(), 1, MaxStrLen(MyTable.Name));
        if RecordJsonObject.Get('description', FieldValueToken) then
            MyTable.Description := CopyStr(FieldValueToken.AsValue().AsText(), 1, MaxStrLen(MyTable.Description));
        if RecordJsonObject.Get('quantity', FieldValueToken) then
            MyTable.Quantity := FieldValueToken.AsValue().AsInteger();
        if RecordJsonObject.Get('createdDate', FieldValueToken) then
            if FieldValueToken.AsValue().AsText() <> '' then
                Evaluate(MyTable."Created Date", FieldValueToken.AsValue().AsText(), 9);

        if not MyTable.Insert(true) then
            MyTable.Modify(true);
    end;
}
