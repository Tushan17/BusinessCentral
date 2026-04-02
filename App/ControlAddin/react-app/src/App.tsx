import { useState, useEffect, ChangeEvent } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Badge, type BadgeProps } from '@/components/ui/badge';
import {
  Card,
  CardContent,
  CardFooter,
  CardHeader,
  CardTitle,
} from '@/components/ui/card';
import { SaveIcon, ExternalLinkIcon, RefreshCwIcon } from 'lucide-react';

/* ------------------------------------------------------------------
   Types
   ------------------------------------------------------------------ */
interface MainRecord {
  No: string;
  Name: string;
  Description: string;
  Amount: string;
  EntryDate: string;
}

interface StatusState {
  text: string;
  variant: BadgeProps['variant'];
}

/* ------------------------------------------------------------------
   Business Central bridge helpers
   Microsoft.Dynamics.NAV.InvokeExtensibilityMethod is injected by BC
   at runtime.  A no-op stub lets the app run in a regular browser too.
   ------------------------------------------------------------------ */
declare global {
  interface Window {
    Microsoft?: {
      Dynamics?: {
        NAV?: {
          InvokeExtensibilityMethod: (method: string, args: unknown[]) => void;
        };
      };
    };
    BCAddin?: {
      LoadRecord: (json: string | MainRecord) => void;
      SetStatus: (msg: string) => void;
    };
  }
}

const BC = {
  invoke(method: string, args: unknown[] = []): void {
    if (window.Microsoft?.Dynamics?.NAV) {
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
function registerBCCallbacks(
  setRecord: React.Dispatch<React.SetStateAction<MainRecord>>,
  setStatus: React.Dispatch<React.SetStateAction<StatusState>>,
): void {
  window.BCAddin = {
    LoadRecord(json: string | MainRecord) {
      try {
        const data: MainRecord = typeof json === 'string' ? JSON.parse(json) : json;
        setRecord(data);
        setStatus({ text: 'Record loaded from Business Central.', variant: 'secondary' });
      } catch {
        setStatus({ text: 'Error parsing record data.', variant: 'destructive' });
      }
    },
    SetStatus(msg: string) {
      setStatus({ text: msg, variant: 'secondary' });
    },
  };
}

/* ------------------------------------------------------------------ */

interface RecordCardProps {
  record: MainRecord;
  onSave: (data: MainRecord) => void;
  onNavigate: (no: string) => void;
}

function RecordCard({ record, onSave, onNavigate }: RecordCardProps) {
  const [form, setForm] = useState<MainRecord>({ ...record });

  const handleChange = (e: ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setForm((prev) => ({ ...prev, [name]: value }));
  };

  return (
    <Card className="w-full max-w-lg">
      <CardHeader>
        <CardTitle className="text-lg">Main Table Record</CardTitle>
      </CardHeader>

      <CardContent className="space-y-4">
        <div className="grid grid-cols-[120px_1fr] items-center gap-3">
          <Label htmlFor="field-no">No.</Label>
          <Input
            id="field-no"
            name="No"
            value={form.No ?? ''}
            onChange={handleChange}
            placeholder="Record number"
          />
        </div>

        <div className="grid grid-cols-[120px_1fr] items-center gap-3">
          <Label htmlFor="field-name">Name</Label>
          <Input
            id="field-name"
            name="Name"
            value={form.Name ?? ''}
            onChange={handleChange}
            placeholder="Name"
          />
        </div>

        <div className="grid grid-cols-[120px_1fr] items-center gap-3">
          <Label htmlFor="field-desc">Description</Label>
          <Input
            id="field-desc"
            name="Description"
            value={form.Description ?? ''}
            onChange={handleChange}
            placeholder="Description"
          />
        </div>

        <div className="grid grid-cols-[120px_1fr] items-center gap-3">
          <Label htmlFor="field-amount">Amount</Label>
          <Input
            id="field-amount"
            name="Amount"
            type="number"
            value={form.Amount ?? ''}
            onChange={handleChange}
            placeholder="0.00"
          />
        </div>

        <div className="grid grid-cols-[120px_1fr] items-center gap-3">
          <Label htmlFor="field-date">Entry Date</Label>
          <Input
            id="field-date"
            name="EntryDate"
            type="date"
            value={form.EntryDate ?? ''}
            onChange={handleChange}
          />
        </div>
      </CardContent>

      <CardFooter className="flex gap-2">
        <Button onClick={() => onSave(form)}>
          <SaveIcon className="mr-1 h-4 w-4" />
          Save
        </Button>
        <Button variant="outline" onClick={() => onNavigate(form.No)}>
          <ExternalLinkIcon className="mr-1 h-4 w-4" />
          Open in BC
        </Button>
      </CardFooter>
    </Card>
  );
}

/* ------------------------------------------------------------------ */

export default function App() {
  const [record, setRecord] = useState<MainRecord>({
    No: '',
    Name: '',
    Description: '',
    Amount: '',
    EntryDate: '',
  });
  const [status, setStatus] = useState<StatusState>({
    text: 'Waiting for Business Central…',
    variant: 'secondary',
  });

  useEffect(() => {
    // Register callbacks so BC can call window.BCAddin.LoadRecord(json)
    registerBCCallbacks(setRecord, setStatus);

    // Tell BC the addin is ready
    BC.invoke('ControlAddInReady');
  }, []);

  const handleSave = (formData: MainRecord): void => {
    BC.invoke('OnSaveRecord', [JSON.stringify(formData)]);
    setStatus({ text: 'Save request sent to Business Central.', variant: 'default' });
  };

  const handleNavigate = (no: string): void => {
    BC.invoke('OnNavigateToRecord', [no]);
  };

  const handleReload = (): void => {
    BC.invoke('ControlAddInReady');
    setStatus({ text: 'Reload requested…', variant: 'secondary' });
  };

  return (
    <div className="min-h-screen bg-muted/40">
      {/* Header */}
      <header className="bg-primary text-primary-foreground px-4 py-2 flex items-center gap-3">
        <span className="text-base font-semibold flex-1">BC React Dashboard</span>
        <Badge variant={status.variant} className="max-w-xs truncate text-xs">
          {status.text}
        </Badge>
        <Button
          variant="ghost"
          size="icon"
          className="text-primary-foreground hover:bg-primary/80 hover:text-primary-foreground h-7 w-7"
          onClick={handleReload}
          title="Reload record from BC"
        >
          <RefreshCwIcon className="h-4 w-4" />
        </Button>
      </header>

      {/* Main */}
      <main className="p-6">
        <RecordCard
          key={record.No}
          record={record}
          onSave={handleSave}
          onNavigate={handleNavigate}
        />
      </main>
    </div>
  );
}
