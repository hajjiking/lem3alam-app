<?php
namespace App\Http\Controllers\Admin;
use App\Http\Controllers\Controller;
use App\Models\Dispute;
use App\Services\DisputeWorkflow;
use Illuminate\Http\Request;
class DisputeWorkflowController extends Controller
{
    public function index()
    {
        abort_unless(DisputeWorkflow::canModerate(auth('admin')->user()), 403);
        return view('admin.disputes.workflow', ['disputes' => Dispute::where('status', 'in_review')->with(['complainant', 'respondent'])->latest()->paginate(15)]);
    }
    public function decide(Request $request, Dispute $dispute)
    {
        $data = $request->validate(['resolution' => 'required|string|max:2000', 'version' => 'required|integer|min:0']);
        app(DisputeWorkflow::class)->act($dispute->id, auth('admin')->user(), 'decide', $data['resolution'], (int) $data['version']);
        return back();
    }
}
