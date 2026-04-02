controladdin "React Addin"
{
    // Paths are relative to the app root (where app.json lives).
    // The React app is built to App/ControlAddin/dist/ via Vite.
    StartupScript = 'ControlAddin/dist/index.js';
    StyleSheets = 'ControlAddin/dist/index.css';

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
