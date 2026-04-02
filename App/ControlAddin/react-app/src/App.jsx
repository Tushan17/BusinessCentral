import { useState, useEffect } from 'react';
import './App.css';

/* ------------------------------------------------------------------
   Business Central bridge helpers
   Microsoft.Dynamics.NAV.InvokeExtensibilityMethod is injected by BC
   at runtime.  A no-op stub lets the app run in a regular browser too.
   ------------------------------------------------------------------ */
const BC = {
  invoke(method, args = []) {
    if (
      window.Microsoft &&
      window.Microsoft.Dynamics &&
      window.Microsoft.Dynamics.NAV
    ) {
      window.Microsoft.Dynamics.NAV.InvokeExtensibilityMethod(method, args);
    } else {
      console.log('[BC stub] InvokeExtensibilityMethod:', method, args);
    }
  },
};

/* ------------------------------------------------------------------
   These functions are called by BC (AL procedures exposed on the addin)
   and must be attached to window so AL can reach them.
   ------------------------------------------------------------------ */
function registerBCCallbacks(setRecord, setStatus) {
  window.BCAddin = {
    LoadRecord(json) {
      try {
        const data = typeof json === 'string' ? JSON.parse(json) : json;
        setRecord(data);
        setStatus('Record loaded from Business Central.');
      } catch {
        setStatus('Error parsing record data.');
      }
    },
    SetStatus(msg) {
      setStatus(msg);
    },
  };
}

/* ------------------------------------------------------------------ */

function RecordCard({ record, onSave, onNavigate }) {
  const [form, setForm] = useState({ ...record });

  useEffect(() => {
    setForm({ ...record });
  }, [record]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setForm((prev) => ({ ...prev, [name]: value }));
  };

  return (
    <div className="card">
      <h2>Main Table Record</h2>

      <div className="field-row">
        <label>No.</label>
        <input name="No" value={form.No ?? ''} onChange={handleChange} />
      </div>

      <div className="field-row">
        <label>Name</label>
        <input name="Name" value={form.Name ?? ''} onChange={handleChange} />
      </div>

      <div className="field-row">
        <label>Description</label>
        <input
          name="Description"
          value={form.Description ?? ''}
          onChange={handleChange}
        />
      </div>

      <div className="field-row">
        <label>Amount</label>
        <input
          name="Amount"
          type="number"
          value={form.Amount ?? ''}
          onChange={handleChange}
        />
      </div>

      <div className="field-row">
        <label>Entry Date</label>
        <input
          name="EntryDate"
          type="date"
          value={form.EntryDate ?? ''}
          onChange={handleChange}
        />
      </div>

      <div className="actions">
        <button className="btn primary" onClick={() => onSave(form)}>
          Save
        </button>
        <button className="btn secondary" onClick={() => onNavigate(form.No)}>
          Open in BC
        </button>
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------ */

export default function App() {
  const [record, setRecord] = useState({
    No: '',
    Name: '',
    Description: '',
    Amount: '',
    EntryDate: '',
  });
  const [status, setStatus] = useState('Waiting for Business Central…');

  useEffect(() => {
    // Register callbacks so BC can call window.BCAddin.LoadRecord(json)
    registerBCCallbacks(setRecord, setStatus);

    // Tell BC the addin is ready
    BC.invoke('ControlAddInReady');
  }, []);

  const handleSave = (formData) => {
    BC.invoke('OnSaveRecord', [JSON.stringify(formData)]);
    setStatus('Save request sent to Business Central.');
  };

  const handleNavigate = (no) => {
    BC.invoke('OnNavigateToRecord', [no]);
  };

  return (
    <div className="app">
      <header className="app-header">
        <span className="app-title">BC React Dashboard</span>
        <span className="status-badge">{status}</span>
      </header>

      <main>
        <RecordCard
          record={record}
          onSave={handleSave}
          onNavigate={handleNavigate}
        />
      </main>
    </div>
  );
}

