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

## Recharge revision 2: native guards restored

The previous hook at `433ac017` could jump over the recent/pending-shot
predicate AND the .5 second post-shot delay into native charge bookkeeping.
A local cleared shift flag does not prove the prior DT shot has finished
processing. A regression fixture reproduces premature charge on that old
implementation; it does not emulate a server correction or prove the cause
of the user's video. The clip itself is kept outside the repository.

The default is now `unsafe_dt_recharge=0`. With this setting, the recharge
site remains byte-for-byte native even when the independent fire guard is
installed. DT itself remains GS. Head points, HC guard and braking arithmetic
are unchanged by this fix.

The optional legacy INI key `unsafe_dt_recharge=1` now hooks `433ac024`, AFTER
native `433b888d` returns false and its original TEST/JNZ permits recharge.
The CALL/TEST/JNZ bytes at `433ac017..433ac023` are never patched. The alternative
enters `433ac16d` so native cooldown comparison remains authoritative too.
Only the aim/peek gate can be bypassed. Native ring/budget logic, recharge
command marking, increment and module callbacks still execute normally.

Additional opt-in conditions: same observed command/context, DT mode 1,
no release/pending shift, no attack/choke, valid charge bounds, no movement,
jump or duck buttons (`0x79e`), exactly zero finite forward/side/upmove, and
local m_fFlags indicating grounded/non-ducking. Flags use the same resolved
netvar contract as the existing GS stop helper; player is the native saved
local-player pointer at frame+18. No new unverified velocity/ack field is read.
Zero movement INPUT does not prove zero physical velocity; this is why native
pending-shot and cooldown checks must also remain. This optional policy is
not proven safe in gameplay and stays off by default. Old INI files enabling
it cannot restore the previous unconditional bypass.

## Installation and validation

Three JMP shims save GPR, EFLAGS and the complete FXSAVE state; restore state
before replaying original instructions. HC CALL uses the native RET 12 ABI.
All six sites and the native pending-shot bytes are validated before mutation;
installed sites roll back on flush failure. Disabled recharge/HC sites stay native.
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
prints its counters. `recharge_overrides` now counts aim-gate bypasses; the native cooldown may
still reject charge afterwards. It does not count completed recharge or time to fire. Both INI switches are independent.
