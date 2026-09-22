<?php

namespace App\Services;

use App\Models\Dispute;
use App\Models\DisputeAction;
use App\Models\User;
use App\Notifications\DisputeWorkflowNotification;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class DisputeWorkflowService
{
    public function respond(Dispute $dispute, User $respondent, string $action, string $message): Dispute
    {
        if ((int) $dispute->respondent_id !== (int) $respondent->id) {
            abort(403);
        }
        if (! in_array($action, DisputeAction::RESPONDENT_ACTIONS, true)) {
            throw ValidationException::withMessages(['action' => __('disputes.workflow.invalid_action')]);
        }

        $updated = DB::transaction(function () use ($dispute, $respondent, $action, $message): Dispute {
            $locked = Dispute::query()->lockForUpdate()->findOrFail($dispute->id);
            if (! in_array($locked->status, ['open', 'in_review'], true)) {
                throw ValidationException::withMessages(['action' => __('disputes.workflow.closed')]);
            }
            if ($locked->actions()->whereIn('action', DisputeAction::COMPLAINANT_ACTIONS)->latest()->exists()) {
                throw ValidationException::withMessages(['action' => __('disputes.workflow.already_decided')]);
            }

            $locked->actions()->create([
                'actor_id' => $respondent->id,
                'action' => $action,
                'message' => $message,
            ]);
            $locked->update([
                'status' => $action === 'appeal' ? 'in_review' : 'open',
                'admin_notes' => $action === 'appeal' ? $message : $locked->admin_notes,
            ]);

            return $locked->fresh(['actions.actor']);
        });

        $updated->complainant?->notify(new DisputeWorkflowNotification(
            $updated,
            __('disputes.workflow.notification_response_title'),
            $action === 'appeal'
                ? __('disputes.workflow.notification_appeal_body')
                : __('disputes.workflow.notification_proposal_body')
        ));

        if ($action === 'appeal') {
            $this->notifyModerators($updated, __('disputes.workflow.notification_intervention_body'));
        }

        return $updated;
    }

    public function decide(Dispute $dispute, User $complainant, string $decision, ?string $message): Dispute
    {
        if ((int) $dispute->complainant_id !== (int) $complainant->id) {
            abort(403);
        }
        if (! in_array($decision, DisputeAction::COMPLAINANT_ACTIONS, true)) {
            throw ValidationException::withMessages(['decision' => __('disputes.workflow.invalid_decision')]);
        }

        $updated = DB::transaction(function () use ($dispute, $complainant, $decision, $message): Dispute {
            $locked = Dispute::query()->lockForUpdate()->findOrFail($dispute->id);
            if (! in_array($locked->status, ['open', 'in_review'], true)) {
                throw ValidationException::withMessages(['decision' => __('disputes.workflow.closed')]);
            }

            $proposal = $locked->actions()->where('action', 'propose_resolution')->latest()->first();
            if (! $proposal) {
                throw ValidationException::withMessages(['decision' => __('disputes.workflow.no_proposal')]);
            }
            $alreadyDecided = $locked->actions()
                ->whereIn('action', DisputeAction::COMPLAINANT_ACTIONS)
                ->where('id', '>', $proposal->id)
                ->exists();
            if ($alreadyDecided) {
                throw ValidationException::withMessages(['decision' => __('disputes.workflow.already_decided')]);
            }

            $locked->actions()->create([
                'actor_id' => $complainant->id,
                'action' => $decision,
                'message' => $message,
                'metadata' => ['proposal_action_id' => $proposal->id],
            ]);

            if ($decision === 'accept_resolution') {
                $locked->update([
                    'status' => 'resolved',
                    'resolution' => $proposal->message,
                    'resolved_at' => now(),
                ]);
            } else {
                $locked->update([
                    'status' => 'in_review',
                    'admin_notes' => $message,
                    'resolved_at' => null,
                ]);
            }

            return $locked->fresh(['actions.actor']);
        });

        $updated->respondent?->notify(new DisputeWorkflowNotification(
            $updated,
            __('disputes.workflow.notification_decision_title'),
            $decision === 'accept_resolution'
                ? __('disputes.workflow.notification_accepted_body')
                : __('disputes.workflow.notification_other_solution_body')
        ));

        if ($decision === 'request_other_solution') {
            $this->notifyModerators($updated, __('disputes.workflow.notification_intervention_body'));
        }

        return $updated;
    }

    private function notifyModerators(Dispute $dispute, string $body): void
    {
        $query = User::query()->where('role', 'admin');
        if ($dispute->admin_id) {
            $query->whereKey($dispute->admin_id);
        }

        $query->eachById(fn (User $admin) => $admin->notify(
            new DisputeWorkflowNotification(
                $dispute,
                __('disputes.workflow.notification_intervention_title'),
                $body
            )
        ));
    }
}

