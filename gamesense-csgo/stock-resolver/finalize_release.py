"""Add Windows evidence to the exact tested ZIP, validate and refresh hashes."""
from pathlib import Path
import hashlib
import json
import os
import sys
import tempfile
import zipfile

archive, evidence = map(Path, sys.argv[1:])
report = json.loads(evidence.read_text())
assert report['abi']['actual_packaged_x86_dll_loaded'] is True
assert report['legacy_patch_guards'] == [0, 8] and report['injector_cli_checked'] is True
assert report['native_driver']['production_native_driver'] is True
assert report['native_driver']['external_lua_required'] is False
assert report['native_driver']['native_feedback_bridge'] and report['native_driver']['feedback_events_checked']
assert report['feedback_archive_checked']
assert report['source_bootstrap_regression']['unchanged_handler_test']
assert report['source_bootstrap_regression']['source_frame_callbacks_verified']
assert report['native_driver']['source_frame_callbacks_verified']
with tempfile.TemporaryDirectory() as temp:
    folder = Path(temp)
    with zipfile.ZipFile(archive) as source:
        for name in source.namelist():
            assert not Path(name).is_absolute() and '..' not in Path(name).parts
        source.extractall(folder)
    original = json.loads((folder / 'SHA256SUMS.json').read_text())
    for name, digest in original.items():
        assert hashlib.sha256((folder / name).read_bytes()).hexdigest() == digest, name
    info = json.loads((folder / 'build_info.json').read_text())
    assert info['source_commit'] == os.environ['GITHUB_SHA']
    assert info['external_lua_required'] is False and not list(folder.rglob('*.lua'))
    accuracy = json.loads((folder / 'reports/stock_resolver_accuracy_validation.json').read_text())
    assert accuracy['actual_native_threshold_comparisons'] >= 21 and accuracy['actual_gs_stop_cases'] >= 36
    assert accuracy['dt_release_and_burst_preserved'] and accuracy['recharge_instructions_unchanged']
    assert accuracy['fresh_hc_metadata_preserved']
    dt = json.loads((folder / 'reports/stock_resolver_dt_validation.json').read_text())
    assert dt['checks'] >= 24 and dt['native_budget_arithmetic_executed']
    assert dt['maximum_jobs'] == 64 and dt['seed_bank'] == 128
    assert dt['queued_DT_latch_tested'] and dt['thresholds_and_recharge_unchanged']
    fast = json.loads((folder / 'reports/stock_resolver_dt_fast_validation.json').read_text())
    assert fast['checks'] >= 55 and fast['same_64_sample_arithmetic'] and fast['GPR_and_FP_preserved']
    assert fast['stack_scope_and_thread_isolation'] and fast['native_traces_reduced'] is False
    for mode in ('0', '1'):
        pair = fast['shim_retired_instructions'][mode]
        assert pair['fast']['instructions'] < pair['reference']['instructions']
        assert pair['fast']['fp_save_restore'] == 0 and pair['fast']['os_calls'] == []
    feedback = json.loads((folder / 'reports/stock_resolver_feedback_validation.json').read_text())
    assert feedback['checks'] >= 27 and feedback['same_record_required'] and feedback['unknown_does_not_penalize']
    assert feedback['DT_ambiguity_skips_learning'] and feedback['single_head_does_not_reinforce']
    hook = json.loads((folder / 'reports/stock_resolver_feedback_hook_validation.json').read_text())
    assert hook['checks'] >= 10 and hook['actual_native_shot_replay_executed'] and hook['native_aim_fire_tick_field_executed']
    (folder / 'reports' / evidence.name).write_bytes(evidence.read_bytes())
    hashes = {str(p.relative_to(folder)): hashlib.sha256(p.read_bytes()).hexdigest()
              for p in sorted(folder.rglob('*')) if p.is_file() and p.name != 'SHA256SUMS.json'}
    (folder / 'SHA256SUMS.json').write_text(json.dumps(hashes, indent=2) + '\n')
    with zipfile.ZipFile(archive, 'w', zipfile.ZIP_DEFLATED, compresslevel=9) as output:
        for p in sorted(folder.rglob('*')):
            if p.is_file(): output.write(p, str(p.relative_to(folder)))
print('Final release validated: original DLL bytes preserved, Windows evidence added.')
