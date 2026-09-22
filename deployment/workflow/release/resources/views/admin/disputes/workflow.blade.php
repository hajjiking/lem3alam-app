@extends('admin.layouts.app')
@section('title', __('dispute_workflow.history'))
@section('content')
<div class="container-fluid">
<h1>{{ __('dispute_workflow.history') }}</h1>
@if($errors->any())<div class="alert alert-danger">{{ $errors->first() }}</div>@endif
@foreach($disputes as $dispute)
<div class="card mb-3"><div class="card-body">
<h2>{{ $dispute->subject }}</h2><p>{{ $dispute->description }}</p>
@foreach(\App\Services\DisputeWorkflow::history($dispute) as $entry)
<div class="border rounded p-2 mb-2"><strong>{{ $entry['actor_name'] }} — {{ __('dispute_workflow.'.$entry['action']) }}</strong><p>{{ $entry['message'] }}</p></div>
@endforeach
@if(in_array('decide', \App\Services\DisputeWorkflow::actions($dispute, auth('admin')->user()), true))
<form method="POST" action="{{ route('admin.disputes.workflow.decide', $dispute) }}">
@csrf <input type="hidden" name="version" value="{{ $dispute->actions()->count() }}">
<label>{{ __('dispute_workflow.decide') }}</label><textarea name="resolution" required maxlength="2000" class="form-control"></textarea>
<button class="btn btn-primary mt-2">{{ __('dispute_workflow.decide') }}</button>
</form>
@else<p>{{ __('dispute_workflow.waiting') }}</p>@endif
</div></div>
@endforeach
{{ $disputes->links() }}
</div>
@endsection
