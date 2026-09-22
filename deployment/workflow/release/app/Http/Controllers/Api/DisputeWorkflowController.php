<?php
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\DisputeWorkflow;
use Illuminate\Http\Request;

class DisputeWorkflowController extends Controller
{
    public function store(Request $request, int $dispute, DisputeWorkflow $workflow)
    {
        $data = $request->validate([
            'action' => 'required|in:propose,appeal,accept,request_change,decide',
            'message' => 'required_unless:action,accept|nullable|string|max:2000',
            'version' => 'required|integer|min:0',
        ]);
        $record = $workflow->act($dispute, $request->user(), $data['action'], $data['message'] ?? '', (int) $data['version']);
        return response()->json(['success' => true, 'data' => DisputeWorkflow::present($record, $request->user())]);
    }
}
