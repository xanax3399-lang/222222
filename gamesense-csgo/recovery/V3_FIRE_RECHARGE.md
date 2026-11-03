# V3 firing and DT recharge contract

CS:GO Legacy 8802 only. Raw core SHA256:
`bbb5ee98d00db63dfc5c454b238d5edd3f809976686be226dbc5f6ae55018b07`.
Mode 6 / launcher 3 only; mode 2 and the frozen v2 release are unchanged.
These are independently written GS policies, not a recovered full NL port.

## Late geometry check

The rage function `4334f55f` calls native HC `4341b4c2` at `43354b55`,
then retries alternate points at `43354b9a` and `43354bd3`. All three are hooked.
Its native ABI is ECX=context, stack=(weapon context, selected candidate,
probability output), RET 12. The wrapper calls it normally and records the
eye at weapon+DC and target at candidate+C, per thread and command.
Native HC already rejects zero probability at `43354c30`; duplicating this
unconditionally would add expensive work without a new decision.

Later, `4335595d..4335596a` can change weapon+E4 (eye height) after that HC.
The native automatic attack commit is `43355ddf..43355e04`, not the temporary
IN_ATTACK writes in prediction. At that commit, if the same command, candidate
and weapon are still selected and eye/target changed, repeat the native HC with
its original context. A finite result in [0,1] that is zero or fails native HC
clears the native frame's allow-fire byte (+22). Native TEST/JZ takes its normal
no-fire path, without attack or shot bookkeeping. Existing manual attack is
left to native processing. Native `0x4000` HC fast-path semantics are retained.
Missing/invalid samples fail open. Never alter already transmitted commands.

This is a sampled client estimate. It cannot prove the server will miss, solve
desync, or guarantee a hit. It covers the observed eye/point change; it does
not introduce a full new prediction, resolver, or spread system.

## Native DT state and release exception

The object vtable is `4346edd4`, with pre/recharge `433abc86` and post/burst
`4336663f`. Its address is dynamic. `4347df34` is constructor CODE, not a global
state pointer. The observer at `433abe72` runs after native hotkey selection,
checks that vtable, and binds state to the native command (+24 in that frame).
Native mode 1 has the double-shot command generation; inactive mode 0 with a
remaining charge flushes it in `4336663f`. A falling edge from mode 1 exempts
that command from cancellation, including repeated visits. An inactive charged
object and bit 8 (native queued shift) are also exempt. These are state-machine
exceptions, not a timer based on keyboard polling. Bit 8 clears on the native
prediction completion path `43359efc`, which sets the .5 second cooldown too.
Snapshots on another thread, stale command or foreign candidate fail open.

## Unsafe recharge

The hook replaces the recent-shot CALL at `433ac017`. Eligible mode-1 recharge
enters `433ac182`, the original ring/budget bookkeeping. It bypasses:

- pending/recent-shot predicate `433b888d`;
- native aim/peek gate starting `433ac024`;
- post-shot cooldown at context+124 (`433ac16d..433ac17c`).

Native connection/hotkey selection, choke and attack checks before this hook
remain. The callback additionally requires command identity, a valid vtable,
mode 1, no release/queued shift, no attack buttons, charge < desired, desired
1..15 and desired < native capacity 7..64. It changes no context fields.
At `433ac224` native GS marks its recharge command; `433ac22b` alone increments
the native charge count. Native completion bookkeeping, module callbacks and
capacity logic execute unchanged. Do not patch tick counts or charge globals
from a separate fabricated counter. Native recharge can consume command time;
unsafe behavior during exposure is explicitly requested and its combat benefit
has not been measured here.

## Installation and validation

Three JMP shims save GPR, EFLAGS and the complete FXSAVE state; restore state
before replaying original instructions. HC CALL uses the native RET 12 ABI.
All six sites are validated before mutation and rollback on flush failure.
Storage/allocation/protection failures leave all sites original. Installation
precedes VM/CRC preparation; tests ensure no VM range overlaps the hooks.

`tests/validate_fire_bridge.py` executes the compiled production bridge, real
native attack commit and native recharge tail, including native recent-shot
predicate, cooldown, aim gate, choke and ring/completion bookkeeping. GUI-selected
mode, engine globals and normal HC outcomes are controlled fixtures. Native HC
100% fast path and missing-entity exit execute too. Tests cover key release,
pending shift, manual fire, stale/thread state, nonfinite output, mode 2 and
disabled configuration. Normal scene tracing and a CS:GO session remain untested.

`skeet_v3_fire_status` is a separate 84-byte version-1 export. Launcher menu 5
prints its counters. `recharge_overrides` counts entering the native bookkeeping,
not completed recharge or improved time to fire. Both INI switches are independent.
