<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Dispute;
use App\Models\Task;
use App\Services\DisputeWorkflowService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

class DisputeController extends Controller
{
    public function index(Request $request)
    {
        $filters = $request->validate([
            'page' => 'sometimes|integer|min:1',
            'per_page' => 'sometimes|integer|min:1|max:50',
            'status' => 'sometimes|in:open,in_review,resolved,closed',
            'type' => 'sometimes|in:payment,quality,no_show,communication,other',
        ]);
        $id = (int) $request->user()->id;
        $query = Dispute::query()
            ->where(fn ($builder) => $builder->where('complainant_id', $id)
                ->orWhere('respondent_id', $id))
            ->with([
                'task:id,title,title_translations',
                'complainant:id,name',
                'respondent:id,name',
                'actions.actor:id,name,role',
            ]);

        foreach (['status', 'type'] as $field) {
            if (isset($filters[$field])) {
                $query->where($field, $filters[$field]);
            }
        }

        return response()->json([
            'success' => true,
            'data' => $query->orderByDesc('id')
                ->paginate($filters['per_page'] ?? 15),
        ]);
    }

    public function show(Request $request, Dispute $dispute)
    {
        abort_unless(in_array((int) $request->user()->id, [
            (int) $dispute->complainant_id,
            (int) $dispute->respondent_id,
        ], true), 403);

        $dispute->load([
            'task:id,title,title_translations',
            'complainant:id,name',
            'respondent:id,name',
            'actions.actor:id,name,role',
        ]);

        return response()->json(['success' => true, 'data' => $dispute]);
    }

    public function evidence(Request $request, Dispute $dispute, int $index)
    {
        $user = $request->user();
        abort_unless($user->role === 'admin' || in_array((int) $user->id, [
            (int) $dispute->complainant_id,
            (int) $dispute->respondent_id,
        ], true), 403);

        $file = ($dispute->evidence ?? [])[$index] ?? null;
        abort_unless(is_array($file) && isset($file['path'], $file['name']), 404);

        return Storage::disk('local')->download(
            $file['path'],
            $file['name'],
            ['Content-Type' => $file['mime'] ?? 'application/octet-stream']
        );
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'task_id' => 'required|integer|exists:tasks,id',
            'respondent_id' => 'required|integer|exists:users,id',
            'type' => 'required|in:payment,quality,no_show,communication,other',
            'subject' => 'required|string|max:255',
            'description' => 'required|string|max:1000',
            'additional_info' => 'nullable|string|max:500',
            'evidence' => 'sometimes|array|max:5',
            'evidence.*' => 'required|file|mimes:jpg,jpeg,png,pdf|max:5120',
        ]);
        $user = $request->user();
        abort_unless(in_array($user->role, ['client', 'tasker'], true), 403);

        $paths = [];
        try {
            $dispute = DB::transaction(function () use ($data, $request, $user, &$paths) {
                $task = Task::query()->lockForUpdate()->findOrFail($data['task_id']);
                $id = (int) $user->id;
                $respondent = (int) $data['respondent_id'];
                $client = (int) $task->client_id;
                $tasker = (int) $task->assigned_tasker_id;

                abort_unless(
                    $client > 0 && $tasker > 0 && $client !== $tasker
                    && (($id === $client && $user->role === 'client' && $respondent === $tasker)
                        || ($id === $tasker && $user->role === 'tasker' && $respondent === $client)),
                    403
                );

                $exists = Dispute::query()
                    ->where('task_id', $task->id)
                    ->whereIn('status', ['open', 'in_review'])
                    ->where(function ($query) use ($id, $respondent): void {
                        $query->where(function ($pair) use ($id, $respondent): void {
                            $pair->where('complainant_id', $id)
                                ->where('respondent_id', $respondent);
                        })->orWhere(function ($pair) use ($id, $respondent): void {
                            $pair->where('complainant_id', $respondent)
                                ->where('respondent_id', $id);
                        });
                    })
                    ->exists();
                abort_if($exists, 409, 'An active dispute already exists for this task.');

                $evidence = [];
                foreach ($request->file('evidence', []) as $file) {
                    $path = $file->store('dispute_evidence', 'local');
                    if ($path === false) {
                        throw new \RuntimeException('Unable to store evidence.');
                    }
                    $paths[] = $path;
                    $evidence[] = [
                        'path' => $path,
                        'name' => $file->getClientOriginalName(),
                        'mime' => $file->getMimeType(),
                        'size' => $file->getSize(),
                    ];
                }

                return Dispute::query()->create([
                    'task_id' => $task->id,
                    'complainant_id' => $id,
                    'respondent_id' => $respondent,
                    'type' => $data['type'],
                    'subject' => $data['subject'],
                    'description' => $data['description'],
                    'additional_info' => $data['additional_info'] ?? null,
                    'evidence' => $evidence,
                    'status' => 'open',
                ]);
            });
        } catch (\Throwable $error) {
            Storage::disk('local')->delete($paths);
            throw $error;
        }

        return response()->json(['success' => true, 'data' => $dispute], 201);
    }

    public function respond(
        Request $request,
        Dispute $dispute,
        DisputeWorkflowService $workflow
    ) {
        $data = $request->validate([
            'action' => 'required|in:appeal,propose_resolution',
            'message' => 'required|string|max:2000',
        ]);

        return response()->json([
            'success' => true,
            'data' => $workflow->respond(
                $dispute,
                $request->user(),
                $data['action'],
                $data['message']
            ),
            'message' => __('disputes.workflow.response_saved'),
        ]);
    }

    public function decide(
        Request $request,
        Dispute $dispute,
        DisputeWorkflowService $workflow
    ) {
        $data = $request->validate([
            'decision' => 'required|in:accept_resolution,request_other_solution',
            'message' => 'nullable|required_if:decision,request_other_solution|string|max:2000',
        ]);

        return response()->json([
            'success' => true,
            'data' => $workflow->decide(
                $dispute,
                $request->user(),
                $data['decision'],
                $data['message'] ?? null
            ),
            'message' => __('disputes.workflow.decision_saved'),
        ]);
    }
}

