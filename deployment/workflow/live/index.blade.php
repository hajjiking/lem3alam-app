@extends('disputes.layout')
@section('title', __('disputes.title'))

@section('dispute-content')
<div class="mb-6 flex flex-wrap items-center justify-between gap-4">
    <div>
        <h1 class="text-2xl font-bold">{{ __('disputes.title') }}</h1>
        <p class="mt-2 text-sm text-slate-500">{{ __('disputes.list_intro') }}</p>
    </div>
    <a class="ui-btn ui-btn-primary" href="{{ localized_route('disputes.create') }}">{{ __('disputes.submit_title') }} ＋</a>
</div>

@if(session('success'))
    <div class="mb-5 rounded-xl border border-emerald-200 bg-emerald-50 p-4 text-sm font-semibold text-emerald-700 dark:border-emerald-900/40 dark:bg-emerald-900/20 dark:text-emerald-200">{{ session('success') }}</div>
@endif

<div class="space-y-5">
@forelse($disputes as $dispute)
    @php
        $actions = $dispute->actions->sortBy('created_at')->values();
        $proposal = $actions->where('action', 'propose_resolution')->last();
        $decision = $proposal ? $actions->where('id', '>', $proposal->id)->whereIn('action', ['accept_resolution', 'request_other_solution'])->last() : null;
        $isRespondent = (int) auth()->id() === (int) $dispute->respondent_id;
        $isComplainant = (int) auth()->id() === (int) $dispute->complainant_id;
        $canRespond = $isRespondent && in_array($dispute->status, ['open', 'in_review'], true) && !$actions->whereIn('action', ['appeal', 'propose_resolution'])->count();
        $canDecide = $isComplainant && $proposal && !$decision && in_array($dispute->status, ['open', 'in_review'], true);
    @endphp
    <article class="ui-card overflow-hidden">
        <div class="p-5">
            <div class="flex flex-wrap justify-between gap-3">
                <h2 class="font-semibold">#D-{{ str_pad($dispute->id, 4, '0', STR_PAD_LEFT) }} · {{ $dispute->subject }}</h2>
                <span class="rounded-full bg-blue-50 px-3 py-1 text-xs font-medium text-[color:var(--primary)] dark:bg-blue-950/30">{{ __('disputes.'.$dispute->status) }}</span>
            </div>
            <p class="mt-2 text-xs text-slate-500">{{ __('disputes.task_reference', ['id' => $dispute->task_id]) }} · {{ $dispute->task?->title }} · {{ $dispute->created_at->locale(app()->getLocale())->translatedFormat('d M Y') }}</p>
            <p class="mt-4 whitespace-pre-wrap break-words text-sm text-slate-600 dark:text-slate-300">{{ $dispute->description }}</p>

            @if($dispute->resolution)
                <p class="mt-4 rounded-lg bg-emerald-50 p-3 text-sm text-emerald-800 dark:bg-emerald-900/20 dark:text-emerald-200"><strong>{{ __('disputes.resolution') }}</strong> {{ $dispute->resolution }}</p>
            @endif

            <ul class="mt-3 flex flex-wrap gap-3">
                @foreach($dispute->evidence ?? [] as $file)
                    @if(is_array($file) && isset($file['id']))
                        <li><a class="text-xs text-[color:var(--primary)] underline" href="{{ localized_route('disputes.download', ['dispute' => $dispute->id, 'file' => $file['id']]) }}">{{ $file['name'] }}</a></li>
                    @endif
                @endforeach
            </ul>
        </div>

        <section class="border-t p-5" style="border-color:var(--border);background:var(--surface-muted)">
            <h3 class="font-bold">{{ __('disputes.workflow.title') }}</h3>

            @if($actions->isNotEmpty())
                <ol class="mt-4 space-y-3">
                    @foreach($actions as $action)
                        <li class="flex gap-3">
                            <span class="mt-1 h-2.5 w-2.5 shrink-0 rounded-full bg-blue-600"></span>
                            <div class="min-w-0">
                                <div class="text-sm font-semibold">{{ __('disputes.workflow.actions.'.$action->action) }}</div>
                                @if($action->message)<p class="mt-1 whitespace-pre-wrap text-sm text-slate-600 dark:text-slate-300">{{ $action->message }}</p>@endif
                                <div class="mt-1 text-xs text-slate-500">{{ $action->actor?->name }} · {{ $action->created_at?->locale(app()->getLocale())->diffForHumans() }}</div>
                            </div>
                        </li>
                    @endforeach
                </ol>
            @elseif(!$isRespondent)
                <p class="mt-3 text-sm text-slate-500">{{ __('disputes.workflow.waiting_respondent') }}</p>
            @endif

            @if($canRespond)
                <form method="POST" action="{{ localized_route('disputes.respond', $dispute) }}" class="mt-5 rounded-xl border bg-white p-4 dark:bg-slate-950" style="border-color:var(--border)">
                    @csrf
                    <p class="text-sm font-semibold">{{ __('disputes.workflow.respond_prompt') }}</p>
                    <div class="mt-3 grid gap-2 sm:grid-cols-2">
                        <label class="flex cursor-pointer items-start gap-2 rounded-lg border p-3" style="border-color:var(--border)"><input type="radio" name="action" value="propose_resolution" required class="mt-1"><span class="text-sm font-semibold">{{ __('disputes.workflow.propose_resolution') }}</span></label>
                        <label class="flex cursor-pointer items-start gap-2 rounded-lg border p-3" style="border-color:var(--border)"><input type="radio" name="action" value="appeal" required class="mt-1"><span class="text-sm font-semibold">{{ __('disputes.workflow.appeal') }}</span></label>
                    </div>
                    <textarea name="message" required maxlength="2000" rows="4" class="ui-input mt-3 w-full" placeholder="{{ __('disputes.workflow.response_message') }}"></textarea>
                    <button type="submit" class="ui-btn ui-btn-primary mt-3">{{ __('disputes.workflow.send_response') }}</button>
                </form>
            @endif

            @if($canDecide)
                <div class="mt-5 rounded-xl border border-blue-200 bg-blue-50 p-4 text-sm text-blue-900 dark:border-blue-900/50 dark:bg-blue-950/20 dark:text-blue-100">
                    <strong>{{ __('disputes.workflow.proposal') }}</strong>
                    <p class="mt-2 whitespace-pre-wrap">{{ $proposal->message }}</p>
                </div>
                <form method="POST" action="{{ localized_route('disputes.decide', $dispute) }}" class="mt-3 rounded-xl border bg-white p-4 dark:bg-slate-950" style="border-color:var(--border)">
                    @csrf
                    <p class="text-sm font-semibold">{{ __('disputes.workflow.complainant_prompt') }}</p>
                    <div class="mt-3 grid gap-2 sm:grid-cols-2">
                        <label class="flex cursor-pointer items-start gap-2 rounded-lg border p-3" style="border-color:var(--border)"><input type="radio" name="decision" value="accept_resolution" required class="mt-1"><span class="text-sm font-semibold">{{ __('disputes.workflow.accept_resolution') }}</span></label>
                        <label class="flex cursor-pointer items-start gap-2 rounded-lg border p-3" style="border-color:var(--border)"><input type="radio" name="decision" value="request_other_solution" required class="mt-1"><span class="text-sm font-semibold">{{ __('disputes.workflow.request_other_solution') }}</span></label>
                    </div>
                    <textarea name="message" maxlength="2000" rows="3" class="ui-input mt-3 w-full" placeholder="{{ __('disputes.workflow.decision_message') }}"></textarea>
                    <button type="submit" class="ui-btn ui-btn-primary mt-3">{{ __('disputes.workflow.send_decision') }}</button>
                </form>
            @endif

            @if($dispute->status === 'in_review')
                <p class="mt-4 rounded-xl border border-amber-200 bg-amber-50 p-3 text-sm font-semibold text-amber-800 dark:border-amber-900/40 dark:bg-amber-900/20 dark:text-amber-200">{{ __('disputes.workflow.under_moderator_review') }}</p>
            @elseif($dispute->status === 'resolved' && $decision?->action === 'accept_resolution')
                <p class="mt-4 rounded-xl border border-emerald-200 bg-emerald-50 p-3 text-sm font-semibold text-emerald-800 dark:border-emerald-900/40 dark:bg-emerald-900/20 dark:text-emerald-200">{{ __('disputes.workflow.resolved_by_agreement') }}</p>
            @endif
        </section>
    </article>
@empty
    <div class="ui-card p-12 text-center"><h2 class="font-semibold">{{ __('disputes.empty_title') }}</h2><p class="mt-2 text-slate-500">{{ __('disputes.empty_help') }}</p></div>
@endforelse
</div>

<div class="mt-6">{{ $disputes->links('disputes.pagination') }}</div>
@endsection

