---
name: debug-mode
description: Runs evidence-driven debugging for reproducible bugs by forming hypotheses, adding temporary runtime probes, waiting for reproduction, analyzing JSONL logs, proposing a fix for approval, verifying it, and cleaning up. Use when the user invokes /debug or an active PI DEBUG MODE run is present.
---

# Debug Mode

Use runtime evidence instead of guessing. The extension owns the workflow state; follow its current phase and use its `debug_*` tools for transitions.

## Non-negotiable rules

1. Do not change production behavior while investigating.
2. Do not apply a fix before the user explicitly approves it with `/debug-approve` or an equivalent approval phrase.
3. Add only probes that distinguish concrete hypotheses.
4. Runtime logging must never crash or materially alter the application.
5. Never log credentials, tokens, cookies, authorization headers, personal data, or complete request bodies.
6. Keep every probe until the fix has been verified, then clean it up automatically.
7. During cleanup, remove only this run's instrumentation. Never use `git reset`, `git checkout`, `git restore`, or a broad revert.
8. Do not ask the user to invoke a transition command when their latest message plus fresh runtime logs already prove that transition happened.

## Investigation and instrumentation

1. Read only enough code to identify the likely execution path.
2. Choose the shortest evidence strategy:
   - If the source strongly suggests one cause, test that single hypothesis directly.
   - If two nearby boundaries are plausible, add a probe on each side.
   - Generate several competing hypotheses only for genuinely ambiguous, timing-dependent, or distributed bugs.
3. Add the minimum useful instrumentation. Prefer 1-3 probes for a localized bug; exceed that only when the execution path requires it.
4. Stop exploring once the probes can confirm the likely cause or identify the boundary where behavior diverges.
5. Prefer the project's existing logging facilities when they can write to the required file without global configuration changes. Otherwise add a tiny language-appropriate helper using the standard library.
6. Append one JSON object per line to the exact absolute runtime log path supplied by the extension.

Each event should include as many of these as are relevant:

```json
{
  "timestamp": "ISO-8601 timestamp",
  "runId": "extension run id",
  "probeId": "stable probe id",
  "location": "source file and logical location",
  "pid": "process id",
  "correlationId": "request/job/entity/operation id",
  "data": {}
}
```

Capture only the data needed to decide the current hypothesis: relevant boundaries, decisions, state transitions, identifiers, timing, or errors—not giant object dumps. Truncate strings and collections. Serialize defensively. Swallow logging failures. Avoid expensive work and never evaluate an expression twice merely to log it.

Mark every temporary import, helper, block, and probe with the exact marker supplied by the extension. Prefer paired markers around blocks:

```text
PI_DEBUG:<run-id>:START:<probe-or-helper-id>
PI_DEBUG:<run-id>:END:<probe-or-helper-id>
```

Use comments valid for the project's language. If a whole temporary file is created, put the marker in that file and include the file in `debug_mark_instrumented`.

When ready, call `debug_mark_instrumented` with every instrumented file and probe. Then give concrete rebuild/restart and reproduction instructions. Stop and wait for the user.

## Log analysis

After reproduction:

If the user's latest message is itself produced by the instrumented workflow, or fresh log events clearly show that reproduction occurred, analyze immediately and call `debug_propose_fix` directly. Do not ask the user to also run `/debug-done`. The command remains a fallback for applications whose reproduction does not send a message to Pi.

1. Check that the log exists and contains events from the active run.
2. Use targeted reads, searches, sorting, or small scripts rather than dumping a huge log into context.
3. Correlate by operation identifiers, timestamps, process IDs, and entity IDs.
4. For every hypothesis, state whether evidence supports, rejects, or fails to test it.
5. Distinguish observed facts from inference.
6. If evidence is insufficient, add or refine probes and ask for another reproduction. Do not invent a diagnosis.
7. If evidence identifies a root cause, call `debug_propose_fix` with concrete log evidence and the smallest reasonable fix.

After `debug_propose_fix`, concisely explain the root cause, decisive runtime evidence, proposed change, meaningful risk, and verification plan. Do not narrate discarded investigative steps unless they matter.

Do not edit the production implementation. Ask the user to run `/debug-approve` or say `approve`.

## Applying an approved fix

Only while the extension says the phase is `applying_fix`:

1. Apply the approved minimal fix.
2. Do not opportunistically refactor nearby code.
3. Keep all runtime probes.
4. Run focused build or static checks when practical.
5. Call `debug_mark_fix_applied` with production files changed.
6. Ask the user to rebuild and repeat the original reproduction exactly.

## Verification

Analyze the fresh post-fix log and call `debug_report_verification`. If the user's latest message or fresh logs already demonstrate the post-fix reproduction, call it directly from `awaiting_verification`; do not ask for `/debug-done` as an extra acknowledgement.

A successful verification requires runtime evidence consistent with the proposed causal explanation, not merely the absence of an exception in an empty log. If the fix fails, explain why and return to hypotheses/instrumentation. Any materially different fix needs a new proposal and explicit user approval.

## Cleanup

After `debug_report_verification` confirms the fix, clean up immediately in the same agent run. Do not ask the user to run `/debug-cleanup`. That command remains available for manual or early cleanup.

1. Read the manifest.
2. Remove this run's marked probes, helpers, temporary imports, and temporary files.
3. Preserve the approved production fix and unrelated changes.
4. Search the instrumented files for the exact run marker.
5. Call `debug_mark_clean`. If it reports remaining markers, remove them and retry.
6. Summarize the retained fix and verification result.
