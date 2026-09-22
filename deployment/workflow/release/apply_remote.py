from pathlib import Path
import shutil,datetime,subprocess,os
root=Path('/www/wwwroot/lem3alam.ma')
stage=Path(__file__).resolve().parent
backup=Path('/var/backups/lem3alam-deployments')/('workflow-'+datetime.datetime.now().strftime('%Y%m%d-%H%M%S'))
backup.mkdir(parents=True,mode=0o700)
changes={}
for file in stage.rglob('*'):
 if file.is_file() and str(file.relative_to(stage)).startswith(('app/','resources/')): changes[str(file.relative_to(stage))]=file.read_text()
p='app/Http/Controllers/Api/DisputeController.php';s=(root/p).read_text();s=s.replace('use App\\Services\\DisputeWorkflowService;', 'use App\\Services\\DisputeWorkflowService;\nuse App\\Services\\DisputeWorkflow;')
s=s.replace("->where(fn ($builder) => $builder->where('complainant_id', $id)\n                ->orWhere('respondent_id', $id))", "->when(!DisputeWorkflow::canModerate($request->user()), fn ($q) => $q->where(fn ($builder) => $builder->where('complainant_id', $id)->orWhere('respondent_id', $id)))")
s=s.replace("->paginate($filters['per_page'] ?? 15),", "->paginate($filters['per_page'] ?? 15)->through(fn ($d) => DisputeWorkflow::present($d, $request->user())),")
s=s.replace("abort_unless(in_array((int) $request->user()->id,", "abort_unless(DisputeWorkflow::canModerate($request->user()) || in_array((int) $request->user()->id,")
s=s.replace("return response()->json(['success' => true, 'data' => $dispute]);", "return response()->json(['success' => true, 'data' => DisputeWorkflow::present($dispute, $request->user())]);")
s=s.replace("$user->role === 'admin' ||", "DisputeWorkflow::canModerate($user) ||")
assert '->through(' in s
changes[p]=s
p='routes/api.php';s=(root/p).read_text();anchor="        // Disputes";assert anchor in s
s=s.replace(anchor,"        Route::post('/disputes/{dispute}/actions', [\\App\\Http\\Controllers\\Api\\DisputeWorkflowController::class, 'store']);\n"+anchor,1);changes[p]=s
p='resources/views/disputes/index.blade.php';s=(root/p).read_text();lines=s.splitlines()
for i,line in enumerate(lines):
 if '$canRespond =' in line: lines[i]="        $canRespond = in_array('propose', \\App\\Services\\DisputeWorkflow::actions($dispute, auth()->user()), true);"
 if '$canDecide =' in line: lines[i]="        $canDecide = in_array('accept', \\App\\Services\\DisputeWorkflow::actions($dispute, auth()->user()), true);"
s='\n'.join(lines)+'\n';s=s.replace('@csrf','@csrf <input type="hidden" name="version" value="{{ $dispute->actions()->count() }}">');changes[p]=s
p='routes/web.php';s=(root/p).read_text();anchor="        Route::middleware('admin.permission:manage_disputes')->group(function () {";assert anchor in s
s=s.replace(anchor,anchor+"\n            Route::get('disputes/workflow', [\\App\\Http\\Controllers\\Admin\\DisputeWorkflowController::class, 'index'])->name('disputes.workflow');\n            Route::post('disputes/{dispute}/workflow-decision', [\\App\\Http\\Controllers\\Admin\\DisputeWorkflowController::class, 'decide'])->name('disputes.workflow.decide');",1);changes[p]=s
p='resources/views/admin/disputes/index.blade.php';s=(root/p).read_text();anchor="@section('content')";assert anchor in s
s=s.replace(anchor,anchor+"\n<a class=\"btn btn-primary m-3\" href=\"{{ route('admin.disputes.workflow') }}\">{{ __('dispute_workflow.decide') }}</a>",1);changes[p]=s
# Older status controls must not bypass participant acceptance or escalation.
p='app/Http/Controllers/Admin/DisputeManagementController.php';s=(root/p).read_text();anchor='    public function updateStatus(Request $request, Dispute $dispute): JsonResponse\n    {';assert anchor in s
s=s.replace(anchor,anchor+"\n        abort(422, 'Use the dispute workflow decision page to record a reasoned final decision.');",1);changes[p]=s
p='app/Http/Controllers/Api/AdminController.php';s=(root/p).read_text();anchor='    public function resolveDispute(Request $request, Dispute $dispute)\n    {';assert anchor in s
s=s.replace(anchor,anchor+"\n        abort(422, 'Use the dispute actions endpoint with a version and decision message.');",1);changes[p]=s
# Validate every generated PHP source before touching live files.
for name,content in changes.items():
 target=stage/'validated'/name;target.parent.mkdir(parents=True,exist_ok=True);target.write_text(content)
 if name.endswith('.php') and not name.endswith('.blade.php'): subprocess.run(['php','-l',str(target)],check=True)
for name in changes:
 file=root/name
 if file.exists():
  dest=backup/name;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(file,dest)
for name,content in changes.items():
 target=root/name;target.parent.mkdir(parents=True,exist_ok=True)
 source=stage/'validated'/name
 shutil.copyfile(source,target)
 shutil.chown(target,user='www',group='www');os.chmod(target,0o644)
print('BACKUP='+str(backup))
