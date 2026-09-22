<?php
namespace App\Services;

use App\Models\Dispute;
use App\Models\User;
use App\Models\DisputeAction;
use Illuminate\Support\Facades\DB;

class DisputeWorkflow
{
    public static function canModerate(User $user): bool
    {
        return $user->hasPermission('manage_disputes');
    }

    public static function actions(Dispute $dispute, User $user): array
    {
        if (in_array($dispute->status, ['resolved', 'closed'], true)) return [];
        $participant = in_array((int) $user->id, [(int) $dispute->complainant_id, (int) $dispute->respondent_id], true);
        $state = self::state($dispute);
        if (!$participant && self::canModerate($user) && $state === 'escalated') return ['decide'];
        if ((int) $user->id === (int) $dispute->respondent_id && $state === 'awaiting_response') return ['propose', 'appeal'];
        if ((int) $user->id === (int) $dispute->complainant_id && $state === 'awaiting_acceptance') return ['accept', 'request_change'];
        return [];
    }

    public static function history(Dispute $dispute): array
    {
        $names = ['propose_resolution' => 'propose', 'accept_resolution' => 'accept', 'request_other_solution' => 'request_change', 'moderator_decision' => 'decide'];
        return $dispute->actions()->with('actor:id,name')->orderBy('id')->get()->map(fn ($item) => [
            'action' => $names[$item->action] ?? $item->action, 'message' => $item->message ?? '',
            'actor_id' => $item->actor_id, 'actor_name' => $item->actor?->name ?? '', 'created_at' => $item->created_at?->toIso8601String(),
        ])->all();
    }

    public static function state(Dispute $dispute): string
    {
        if (in_array($dispute->status, ['resolved', 'closed'], true)) return 'resolved';
        $history = self::history($dispute);
        if (count(array_filter($history, fn ($item) => in_array($item['action'], ['appeal', 'request_change'], true))) >= 2) return 'escalated';
        $last = $history === [] ? null : $history[array_key_last($history)]['action'];
        return $last === 'propose' ? 'awaiting_acceptance' : 'awaiting_response';
    }

    public static function present(Dispute $dispute, User $user): array
    {
        $data = $dispute->toArray();
        $data['allowed_actions'] = self::actions($dispute, $user);
        $data['workflow_state'] = self::state($dispute);
        $data['workflow_history'] = self::history($dispute);
        $data['workflow_version'] = count($data['workflow_history']);
        return $data;
    }

    public function act(int $id, User $user, string $action, string $message, int $version): Dispute
    {
        $updated = DB::transaction(function () use ($id, $user, $action, $message, $version) {
            $dispute = Dispute::lockForUpdate()->findOrFail($id);
            abort_unless(in_array($action, self::actions($dispute, $user), true), 403);
            abort_if($dispute->actions()->count() !== $version, 409, 'The dispute has changed. Refresh before responding.');
            $history = self::history($dispute);
            $entry = ['action' => $action, 'message' => trim($message), 'actor_id' => (int) $user->id,
                'actor_name' => $user->name, 'created_at' => now()->toIso8601String()];
            if ($action === 'propose') {
                $dispute->status = 'open';
            } elseif (in_array($action, ['appeal', 'request_change'], true)) {
                $previousObjections = collect($history)->filter(fn ($item) => in_array($item['action'], ['appeal', 'request_change'], true))->count();
                $dispute->status = $previousObjections === 0 ? 'open' : 'in_review';
            } else {
                $dispute->status = 'resolved';
                $dispute->resolved_at = now();
                if ($action === 'accept') {
                    $proposal = collect($history)->last(fn ($item) => $item['action'] === 'propose');
                    $dispute->resolution = $proposal['message'] ?? '';
                } else {
                    $dispute->resolution = trim($message);
                    $dispute->admin_id = $user->id;
                }
            }
            $names = ['propose' => 'propose_resolution', 'accept' => 'accept_resolution', 'request_change' => 'request_other_solution', 'decide' => 'moderator_decision'];
            $dispute->actions()->create(['actor_id' => $user->id, 'action' => $names[$action] ?? $action, 'message' => $entry['message']]);
            $dispute->save();
            return $dispute;
        });
        // Notification failure must not report a persisted action as a failed submission.
        if (class_exists(\App\Notifications\DisputeWorkflowNotification::class)) {
            try {
                $ids = [$updated->complainant_id, $updated->respondent_id];
                $recipients = User::whereIn('id', $ids)->where('id', '!=', $user->id)->get();
                if (self::state($updated) === 'escalated') {
                    $recipients = $recipients->merge(User::where('role', 'admin')->get()->filter(fn ($person) => self::canModerate($person)));
                }
                foreach ($recipients->unique('id') as $person) {
                    $person->notify(new \App\Notifications\DisputeWorkflowNotification($updated, __('dispute_workflow.history'), __('dispute_workflow.'.$action)));
                }
            } catch (\Throwable $error) { report($error); }
        }
        return $updated;
    }
}
