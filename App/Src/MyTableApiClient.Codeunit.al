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
        MyTable: Record "My Table";
        Response: HttpResponseMessage;
        ResponseText: Text;
        JArray: JsonArray;
        JToken: JsonToken;
    begin
        SendRequest('GET', BaseUrl(), '', Response);
        EnsureSuccess(Response);

        Response.Content.ReadAs(ResponseText);
        if not JArray.ReadFrom(ResponseText) then
            Error('The API response could not be parsed as a JSON array.');

        foreach JToken in JArray do
            ApplyJsonToRecord(JToken.AsObject(), MyTable);

        Message('Fetched %1 record(s) from the API.', JArray.Count());
    end;

    // ── GET – single record ───────────────────────────────────────────────────

    /// <summary>
    /// Calls GET /api/mytable/{no} and populates MyTable with the returned data.
    /// Inserts the record if it does not yet exist locally; otherwise updates it.
    /// </summary>
    procedure GetRecord(No: Code[20]; var MyTable: Record "My Table")
    var
        Response: HttpResponseMessage;
        ResponseText: Text;
        JObject: JsonObject;
    begin
        SendRequest('GET', BaseUrl() + '/' + No, '', Response);
        EnsureSuccess(Response);

        Response.Content.ReadAs(ResponseText);
        if not JObject.ReadFrom(ResponseText) then
            Error('The API response could not be parsed as a JSON object.');

        ApplyJsonToRecord(JObject, MyTable);
    end;

    // ── POST – create a new record ────────────────────────────────────────────

    /// <summary>
    /// Calls POST /api/mytable with the serialised record as the request body.
    /// Use this to create a brand-new record on the remote API.
    /// </summary>
    procedure CreateRecord(MyTable: Record "My Table")
    var
        Response: HttpResponseMessage;
    begin
        SendRequest('POST', BaseUrl(), RecordToJson(MyTable), Response);
        EnsureSuccess(Response);
        Message('Record ''%1'' created via the API.', MyTable."No.");
    end;

    // ── PUT – full replacement of a record ────────────────────────────────────

    /// <summary>
    /// Calls PUT /api/mytable/{no} with the full record as the request body.
    /// All fields are sent; the server replaces the existing resource entirely.
    /// </summary>
    procedure UpdateRecord(MyTable: Record "My Table")
    var
        Response: HttpResponseMessage;
    begin
        SendRequest('PUT', BaseUrl() + '/' + MyTable."No.", RecordToJson(MyTable), Response);
        EnsureSuccess(Response);
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
        Response: HttpResponseMessage;
    begin
        SendRequest('PATCH', BaseUrl() + '/' + No, PatchJson, Response);
        EnsureSuccess(Response);
        Message('Record ''%1'' patched via the API.', No);
    end;

    // ── DELETE – remove a record ──────────────────────────────────────────────

    /// <summary>
    /// Calls DELETE /api/mytable/{no} to remove the record from the remote API.
    /// </summary>
    procedure DeleteRecord(No: Code[20])
    var
        Response: HttpResponseMessage;
    begin
        SendRequest('DELETE', BaseUrl() + '/' + No, '', Response);
        EnsureSuccess(Response);
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
    local procedure SendRequest(Method: Text; Url: Text; Body: Text; var Response: HttpResponseMessage)
    var
        Client: HttpClient;
        Request: HttpRequestMessage;
        Content: HttpContent;
        RequestHeaders: HttpHeaders;
        ContentHeaders: HttpHeaders;
    begin
        Request.Method := Method;
        Request.SetRequestUri(Url);

        Request.GetHeaders(RequestHeaders);
        RequestHeaders.Add('Accept', 'application/json');

        if Body <> '' then begin
            Content.WriteFrom(Body);
            Content.GetHeaders(ContentHeaders);
            if ContentHeaders.Contains('Content-Type') then
                ContentHeaders.Remove('Content-Type');
            ContentHeaders.Add('Content-Type', 'application/json');
            Request.Content := Content;
        end;

        if not Client.Send(Request, Response) then
            Error('Failed to connect to the API at ''%1''.', Url);
    end;

    /// <summary>
    /// Raises an error when the HTTP response status code indicates failure (not 2xx).
    /// The response body is included in the error message to aid troubleshooting.
    /// </summary>
    local procedure EnsureSuccess(var Response: HttpResponseMessage)
    var
        StatusCode: Integer;
        ResponseBody: Text;
    begin
        StatusCode := Response.HttpStatusCode();
        if (StatusCode >= 200) and (StatusCode < 300) then
            exit;

        Response.Content.ReadAs(ResponseBody);
        Error('API returned HTTP %1.\\Response body: %2', StatusCode, ResponseBody);
    end;

    /// <summary>
    /// Serialises a My Table record to a JSON object string.
    /// The "createdDate" field is formatted as ISO 8601 (YYYY-MM-DD).
    /// </summary>
    local procedure RecordToJson(MyTable: Record "My Table"): Text
    var
        JObject: JsonObject;
        Result: Text;
        DateText: Text;
    begin
        JObject.Add('no', MyTable."No.");
        JObject.Add('name', MyTable.Name);
        JObject.Add('description', MyTable.Description);
        JObject.Add('quantity', MyTable.Quantity);
        if MyTable."Created Date" <> 0D then
            DateText := Format(MyTable."Created Date", 0, 9);
        JObject.Add('createdDate', DateText);
        JObject.WriteTo(Result);
        exit(Result);
    end;

    /// <summary>
    /// Deserialises a JSON object into a My Table record.
    /// Inserts the record when it does not yet exist locally; otherwise updates it.
    /// Fields absent from the JSON object are left unchanged.
    /// </summary>
    local procedure ApplyJsonToRecord(JObject: JsonObject; var MyTable: Record "My Table")
    var
        JToken: JsonToken;
        NoCode: Code[20];
    begin
        if not JObject.Get('no', JToken) then
            exit;
        NoCode := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(MyTable."No."));
        if NoCode = '' then
            exit;

        if not MyTable.Get(NoCode) then begin
            MyTable.Init();
            MyTable."No." := NoCode;
        end;

        if JObject.Get('name', JToken) then
            MyTable.Name := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(MyTable.Name));
        if JObject.Get('description', JToken) then
            MyTable.Description := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(MyTable.Description));
        if JObject.Get('quantity', JToken) then
            MyTable.Quantity := JToken.AsValue().AsInteger();
        if JObject.Get('createdDate', JToken) then
            if JToken.AsValue().AsText() <> '' then
                Evaluate(MyTable."Created Date", JToken.AsValue().AsText(), 9);

        if not MyTable.Insert(true) then
            MyTable.Modify(true);
    end;
}
