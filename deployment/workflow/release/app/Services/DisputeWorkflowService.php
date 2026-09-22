<?php
namespace App\Services;
use App\Models\Dispute;
use App\Models\User;
class DisputeWorkflowService
{
    public function respond(Dispute $dispute, User $respondent, string $action, string $message): Dispute
    {
        $data = request()->validate(['version' => 'required|integer|min:0']);
        abort_unless(in_array($action, ['appeal', 'propose_resolution'], true), 422);
        return app(DisputeWorkflow::class)->act($dispute->id, $respondent, $action === 'appeal' ? 'appeal' : 'propose', $message, (int) $data['version']);
    }
    public function decide(Dispute $dispute, User $complainant, string $decision, ?string $message): Dispute
    {
        $data = request()->validate(['version' => 'required|integer|min:0']);
        abort_unless(in_array($decision, ['accept_resolution', 'request_other_solution'], true), 422);
        return app(DisputeWorkflow::class)->act($dispute->id, $complainant, $decision === 'accept_resolution' ? 'accept' : 'request_change', $message ?? '', (int) $data['version']);
    }
}
