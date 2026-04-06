controladdin "React Addin"
{
    // BC loads the full HTML page (which includes <div id="root">, the JS bundle,
    // and the CSS) into the control addin frame. This is required for React to have
    // a mount point; using StartupScript alone provides no root element.
    HtmlFiles = 'ControlAddin/dist/index.html';

    // ------------------------------------------------------------
    // Events – fired from JavaScript with
    //   Microsoft.Dynamics.NAV.InvokeExtensibilityMethod(name, args)
    // ------------------------------------------------------------

    /// <summary>Raised when the React add-in has finished loading.</summary>
    event ControlAddInReady();

    /// <summary>Raised when the user clicks Save inside the React dashboard.</summary>
    event OnSaveRecord(RecordJson: Text);

    /// <summary>Raised when the user clicks "Open in BC" for a record.</summary>
    event OnNavigateToRecord(RecordNo: Text);

    // ------------------------------------------------------------
    // Procedures – callable from AL to push data into the React app.
    //   They map to window.BCAddin.<Method>(args) in JavaScript.
    // ------------------------------------------------------------

    /// <summary>Pass a JSON-serialised Main Table record to the React dashboard.</summary>
    procedure LoadRecord(RecordJson: Text);

    /// <summary>Display an arbitrary status message in the React dashboard.</summary>
    procedure SetStatus(Message: Text);
}
