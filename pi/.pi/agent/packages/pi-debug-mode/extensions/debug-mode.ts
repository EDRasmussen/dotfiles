import { createHash, randomUUID } from "node:crypto";
import { mkdir, readFile, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { basename, isAbsolute, join, resolve } from "node:path";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

type DebugPhase =
	| "instrumenting"
	| "awaiting_reproduction"
	| "analyzing"
	| "awaiting_approval"
	| "applying_fix"
	| "awaiting_verification"
	| "verifying"
	| "verified"
	| "cleaning"
	| "completed"
	| "cancelled";

interface Probe {
	id: string;
	file: string;
	purpose: string;
}

interface Proposal {
	rootCause: string;
	evidence: string[];
	fix: string;
	files: string[];
	confidence?: string;
}

interface DebugState {
	version: 1;
	runId: string;
	cwd: string;
	description: string;
	phase: DebugPhase;
	createdAt: string;
	updatedAt: string;
	logPath: string;
	manifestPath: string;
	instrumentedFiles: string[];
	probes: Probe[];
	proposal?: Proposal;
	fixFiles?: string[];
	verification?: string;
}

const STATE_ENTRY = "pi-debug-mode-state";
const TERMINAL_PHASES = new Set<DebugPhase>(["completed", "cancelled"]);
const DONE_PHRASES = new Set(["done", "i did it", "i reproduced it", "reproduced", "reproduction complete"]);
const APPROVE_PHRASES = new Set(["approve", "approved", "apply it", "apply the fix", "go ahead"]);

function timestamp(): string {
	return new Date().toISOString();
}

function unique(values: string[]): string[] {
	return [...new Set(values.filter(Boolean))];
}

function phaseLabel(phase: DebugPhase): string {
	return phase.replaceAll("_", " ");
}

function isDebugState(value: unknown): value is DebugState {
	if (!value || typeof value !== "object") return false;
	const state = value as Partial<DebugState>;
	return state.version === 1 && typeof state.runId === "string" && typeof state.phase === "string";
}

export default function debugModeExtension(pi: ExtensionAPI): void {
	let state: DebugState | undefined;

	function updateStatus(ctx: ExtensionContext): void {
		if (!state || TERMINAL_PHASES.has(state.phase)) {
			ctx.ui.setStatus("pi-debug-mode", undefined);
			ctx.ui.setWidget("pi-debug-mode", undefined);
			return;
		}

		ctx.ui.setStatus("pi-debug-mode", ctx.ui.theme.fg("warning", `debug: ${phaseLabel(state.phase)}`));
		ctx.ui.setWidget("pi-debug-mode", [
			`${ctx.ui.theme.fg("accent", "Debug")} ${state.runId}`,
			`${ctx.ui.theme.fg("muted", phaseLabel(state.phase))} · ${state.probes.length} probe(s)`,
		]);
	}

	async function writeManifest(current: DebugState): Promise<void> {
		await mkdir(resolve(current.manifestPath, ".."), { recursive: true });
		await writeFile(current.manifestPath, `${JSON.stringify(current, null, 2)}\n`, "utf8");
	}

	async function persist(ctx: ExtensionContext, next: DebugState): Promise<void> {
		state = { ...next, updatedAt: timestamp() };
		pi.appendEntry(STATE_ENTRY, state);
		await writeManifest(state);
		updateStatus(ctx);
	}

	async function setPhase(ctx: ExtensionContext, phase: DebugPhase, patch: Partial<DebugState> = {}): Promise<void> {
		if (!state) throw new Error("No active debug run. Start one with /debug <description>.");
		await persist(ctx, { ...state, ...patch, phase });
	}

	async function clearLog(): Promise<void> {
		if (!state) return;
		await mkdir(resolve(state.logPath, ".."), { recursive: true });
		await writeFile(state.logPath, "", "utf8");
	}

	function activeContext(): string | undefined {
		if (!state || TERMINAL_PHASES.has(state.phase)) return undefined;
		const proposal = state.proposal
			? `\nApproved proposal is NOT implied. Current proposed fix:\n${state.proposal.fix}`
			: "";
		return `[PI DEBUG MODE ACTIVE]\nRun: ${state.runId}\nPhase: ${state.phase}\nBug: ${state.description}\nRuntime log: ${state.logPath}\nManifest: ${state.manifestPath}\nInstrumentation marker: PI_DEBUG:${state.runId}\n\nFollow the available debug-mode skill exactly. Never apply a production fix unless the phase is applying_fix. Keep instrumentation through verification, then clean it up automatically after successful verification.${proposal}`;
	}

	function analysisPrompt(kind: "initial" | "verification"): string {
		if (!state) throw new Error("No active debug run.");
		if (kind === "initial") {
			return `[PI DEBUG MODE: ANALYZE REPRODUCTION]\nThe user reproduced the bug for run ${state.runId}. Analyze ${state.logPath} using runtime evidence. Correlate events by timestamps and correlation IDs, test every hypothesis, and inspect relevant source when needed. Do not edit production behavior and do not apply a fix. When ready, call debug_propose_fix with the root cause, concrete evidence, and a minimal proposed fix. The user must approve before any fix is applied.`;
		}
		return `[PI DEBUG MODE: VERIFY FIX]\nThe user completed the post-fix reproduction for run ${state.runId}. Analyze the fresh log at ${state.logPath} and determine whether the approved fix solved the reported bug without obvious regressions. Do not clean up yet. Call debug_report_verification with the result and evidence.`;
	}

	function approvalPrompt(notes?: string): string {
		if (!state?.proposal) throw new Error("There is no proposed fix to approve.");
		return `[PI DEBUG MODE: FIX APPROVED]\nThe user approved the proposed fix for run ${state.runId}.${notes ? `\nUser notes: ${notes}` : ""}\nApply only the minimal proposed production fix. Keep all PI_DEBUG:${state.runId} instrumentation in place for verification. Do not broaden the change. After applying the fix, call debug_mark_fix_applied with the production files changed. Then ask the user to rebuild and reproduce the original steps again.`;
	}

	function cleanupPrompt(reason: string): string {
		if (!state) throw new Error("No active debug run.");
		return `[PI DEBUG MODE: CLEANUP]\n${reason}\nRemove all temporary instrumentation for run ${state.runId}, including helpers, imports, calls, and comments marked PI_DEBUG:${state.runId}. Preserve the approved production fix and all unrelated user changes. Use ${state.manifestPath} to find instrumented files. After cleanup, call debug_mark_clean. Do not use git reset, checkout, restore, or any broad revert command.`;
	}

	async function beginAnalysis(ctx: ExtensionContext, kind: "initial" | "verification"): Promise<string> {
		if (!state) throw new Error("No active debug run.");
		const expected = kind === "initial" ? "awaiting_reproduction" : "awaiting_verification";
		if (state.phase !== expected) {
			throw new Error(`Debug run is ${phaseLabel(state.phase)}, not ${phaseLabel(expected)}.`);
		}
		await setPhase(ctx, kind === "initial" ? "analyzing" : "verifying");
		return analysisPrompt(kind);
	}

	pi.on("session_start", async (_event, ctx) => {
		state = undefined;
		for (const entry of ctx.sessionManager.getEntries()) {
			if (entry.type !== "custom" || entry.customType !== STATE_ENTRY) continue;
			if (isDebugState(entry.data)) state = entry.data;
		}
		updateStatus(ctx);
	});

	pi.on("before_agent_start", async () => {
		const content = activeContext();
		if (!content) return;
		return { message: { customType: "pi-debug-mode-context", content, display: false } };
	});

	pi.on("input", async (event, ctx) => {
		if (event.source === "extension" || !state) return { action: "continue" as const };
		const normalized = event.text.trim().toLowerCase().replace(/[.!]+$/, "");

		if (DONE_PHRASES.has(normalized) && state.phase === "awaiting_reproduction") {
			const text = await beginAnalysis(ctx, "initial");
			return { action: "transform" as const, text };
		}
		if (DONE_PHRASES.has(normalized) && state.phase === "awaiting_verification") {
			const text = await beginAnalysis(ctx, "verification");
			return { action: "transform" as const, text };
		}
		if (APPROVE_PHRASES.has(normalized) && state.phase === "awaiting_approval") {
			await setPhase(ctx, "applying_fix");
			return { action: "transform" as const, text: approvalPrompt() };
		}
		return { action: "continue" as const };
	});

	pi.registerCommand("debug", {
		description: "Start an evidence-driven debugging run",
		handler: async (args, ctx) => {
			const description = args.trim();
			if (!description) {
				ctx.ui.notify("Usage: /debug <bug description and reproduction steps>", "warning");
				return;
			}
			if (!ctx.isIdle()) {
				ctx.ui.notify("Wait for the agent to become idle before starting debug mode.", "warning");
				return;
			}
			if (state && !TERMINAL_PHASES.has(state.phase)) {
				ctx.ui.notify(`A debug run is already ${phaseLabel(state.phase)}. Use /debug-cleanup or /debug-cancel first.`, "warning");
				return;
			}

			const projectHash = createHash("sha256").update(ctx.cwd).digest("hex").slice(0, 8);
			const runId = `${new Date().toISOString().replace(/[:.]/g, "-")}-${randomUUID().slice(0, 8)}`;
			const runDir = join(tmpdir(), "pi-debug", `${basename(ctx.cwd)}-${projectHash}`, runId);
			const now = timestamp();
			const next: DebugState = {
				version: 1,
				runId,
				cwd: ctx.cwd,
				description,
				phase: "instrumenting",
				createdAt: now,
				updatedAt: now,
				logPath: join(runDir, "events.jsonl"),
				manifestPath: join(runDir, "manifest.json"),
				instrumentedFiles: [],
				probes: [],
			};
			await mkdir(runDir, { recursive: true });
			await writeFile(next.logPath, "", "utf8");
			await persist(ctx, next);

			pi.sendUserMessage(`[PI DEBUG MODE: START]\nBug report:\n${description}\n\nInvestigate this bug using the available debug-mode skill. Optimize for the shortest path to reliable runtime evidence. If one cause is strongly suggested by the source, test that cause directly with the minimum useful instrumentation; generate competing hypotheses only when genuine uncertainty remains. Append JSONL events to the exact absolute path ${next.logPath}. Do not attempt a production fix. Mark every temporary addition with PI_DEBUG:${runId}. When instrumentation is complete, call debug_mark_instrumented with all probes and modified files, then give concise rebuild and reproduction instructions.`);
		},
	});

	pi.registerCommand("debug-done", {
		description: "Continue after reproducing the bug or verifying a fix",
		handler: async (_args, ctx) => {
			try {
				if (!ctx.isIdle()) throw new Error("Wait for the agent to become idle first.");
				if (!state) throw new Error("No active debug run.");
				const kind = state.phase === "awaiting_verification" ? "verification" : "initial";
				const prompt = await beginAnalysis(ctx, kind);
				pi.sendUserMessage(prompt);
			} catch (error) {
				ctx.ui.notify(error instanceof Error ? error.message : String(error), "warning");
			}
		},
	});

	pi.registerCommand("debug-approve", {
		description: "Approve and apply the proposed fix",
		handler: async (args, ctx) => {
			try {
				if (!ctx.isIdle()) throw new Error("Wait for the agent to become idle first.");
				if (state?.phase !== "awaiting_approval") throw new Error("There is no fix awaiting approval.");
				const prompt = approvalPrompt(args.trim() || undefined);
				await setPhase(ctx, "applying_fix");
				pi.sendUserMessage(prompt);
			} catch (error) {
				ctx.ui.notify(error instanceof Error ? error.message : String(error), "warning");
			}
		},
	});

	pi.registerCommand("debug-cleanup", {
		description: "Remove instrumentation while preserving the production fix",
		handler: async (_args, ctx) => {
			try {
				if (!ctx.isIdle()) throw new Error("Wait for the agent to become idle first.");
				if (!state) throw new Error("No debug run to clean up.");
				await setPhase(ctx, "cleaning");
				pi.sendUserMessage(cleanupPrompt("The user requested cleanup."));
			} catch (error) {
				ctx.ui.notify(error instanceof Error ? error.message : String(error), "warning");
			}
		},
	});

	pi.registerCommand("debug-cancel", {
		description: "Cancel the current debugging run safely",
		handler: async (_args, ctx) => {
			if (!state || TERMINAL_PHASES.has(state.phase)) {
				ctx.ui.notify("No active debug run.", "info");
				return;
			}
			if (!ctx.isIdle()) {
				ctx.ui.notify("Wait for the agent to become idle first.", "warning");
				return;
			}
			await setPhase(ctx, "cleaning");
			pi.sendUserMessage(cleanupPrompt("The user cancelled the run. Remove its instrumentation safely."));
		},
	});

	pi.registerCommand("debug-status", {
		description: "Show the active debugging run",
		handler: async (_args, ctx) => {
			if (!state) {
				ctx.ui.notify("No debug run in this session.", "info");
				return;
			}
			ctx.ui.notify(
				`Run: ${state.runId}\nPhase: ${phaseLabel(state.phase)}\nProbes: ${state.probes.length}\nLog: ${state.logPath}\nManifest: ${state.manifestPath}`,
				"info",
			);
		},
	});

	pi.registerTool({
		name: "debug_mark_instrumented",
		label: "Debug instrumentation ready",
		description: "Record completed debug probes and pause for user reproduction. Call only after adding all runtime instrumentation.",
		parameters: Type.Object({
			files: Type.Array(Type.String({ description: "Instrumented source file path" })),
			probes: Type.Array(Type.Object({
				id: Type.String(),
				file: Type.String(),
				purpose: Type.String(),
			})),
		}),
		async execute(_id, params, _signal, _update, ctx) {
			if (!state) throw new Error("No active debug run.");
			if (state.phase !== "instrumenting") throw new Error(`Cannot mark instrumentation while phase is ${state.phase}.`);
			await clearLog();
			await setPhase(ctx, "awaiting_reproduction", {
				instrumentedFiles: unique([...state.instrumentedFiles, ...params.files]),
				probes: params.probes,
			});
			return {
				content: [{ type: "text", text: `Instrumentation ready. Ask the user to rebuild and reproduce, then run /debug-done or say “I reproduced it.” Runtime log: ${state.logPath}` }],
				details: { runId: state.runId, phase: state.phase, logPath: state.logPath, probes: state.probes },
			};
		},
	});

	pi.registerTool({
		name: "debug_propose_fix",
		label: "Propose debug fix",
		description: "Record an evidence-backed proposed fix without applying it. May be called directly from awaiting_reproduction when fresh runtime evidence is already available.",
		parameters: Type.Object({
			rootCause: Type.String(),
			evidence: Type.Array(Type.String()),
			fix: Type.String({ description: "Specific minimal fix to apply after approval" }),
			files: Type.Array(Type.String({ description: "Production files expected to change" })),
			confidence: Type.Optional(Type.String()),
		}),
		async execute(_id, params, _signal, _update, ctx) {
			if (!state) throw new Error("No active debug run.");
			if (state.phase !== "analyzing" && state.phase !== "awaiting_reproduction") {
				throw new Error(`Cannot propose a fix while phase is ${state.phase}.`);
			}
			const proposal: Proposal = { ...params, files: unique(params.files) };
			await setPhase(ctx, "awaiting_approval", { proposal });
			return {
				content: [{ type: "text", text: "Fix recorded but not applied. Present the root cause, evidence, exact proposed change, risks, and verification plan. Ask the user to run /debug-approve or say “approve”." }],
				details: { runId: state.runId, phase: state.phase, proposal },
			};
		},
	});

	pi.registerTool({
		name: "debug_mark_fix_applied",
		label: "Debug fix applied",
		description: "Record that the user-approved production fix was applied and pause for verification.",
		parameters: Type.Object({ files: Type.Array(Type.String()) }),
		async execute(_id, params, _signal, _update, ctx) {
			if (!state) throw new Error("No active debug run.");
			if (state.phase !== "applying_fix") throw new Error(`Cannot mark a fix while phase is ${state.phase}.`);
			await clearLog();
			await setPhase(ctx, "awaiting_verification", { fixFiles: unique(params.files) });
			return {
				content: [{ type: "text", text: "Approved fix applied. Ask the user to rebuild and repeat the original reproduction, then run /debug-done or say “I reproduced it.”" }],
				details: { runId: state.runId, phase: state.phase, files: state.fixFiles },
			};
		},
	});

	pi.registerTool({
		name: "debug_report_verification",
		label: "Report debug verification",
		description: "Report whether post-fix runtime evidence verifies the approved fix. May be called directly from awaiting_verification when fresh evidence is already available.",
		parameters: Type.Object({
			fixed: Type.Boolean(),
			evidence: Type.Array(Type.String()),
			explanation: Type.String(),
		}),
		async execute(_id, params, _signal, _update, ctx) {
			if (!state) throw new Error("No active debug run.");
			if (state.phase !== "verifying" && state.phase !== "awaiting_verification") {
				throw new Error(`Cannot report verification while phase is ${state.phase}.`);
			}
			const verification = `${params.explanation}\n${params.evidence.map((item) => `- ${item}`).join("\n")}`;
			if (params.fixed) {
				await setPhase(ctx, "cleaning", { verification });
				return {
					content: [{ type: "text", text: `Fix verified. Immediately remove all instrumentation marked PI_DEBUG:${state.runId}, preserving the production fix and unrelated changes, then call debug_mark_clean. Do not ask the user to request cleanup.` }],
					details: { runId: state.runId, phase: state.phase, fixed: true, evidence: params.evidence },
				};
			}
			await setPhase(ctx, "instrumenting", { verification, proposal: undefined });
			return {
				content: [{ type: "text", text: "Fix was not verified. Explain the evidence, refine the hypotheses and instrumentation, then call debug_mark_instrumented in a later turn. Do not silently broaden the production fix." }],
				details: { runId: state.runId, phase: state.phase, fixed: false, evidence: params.evidence },
			};
		},
	});

	pi.registerTool({
		name: "debug_mark_clean",
		label: "Debug cleanup complete",
		description: "Verify and record that all instrumentation for the active run has been removed.",
		parameters: Type.Object({}),
		async execute(_id, _params, _signal, _update, ctx) {
			if (!state) throw new Error("No active debug run.");
			if (state.phase !== "cleaning") throw new Error(`Cannot finish cleanup while phase is ${state.phase}.`);
			const marker = `PI_DEBUG:${state.runId}`;
			const remaining: string[] = [];
			for (const file of state.instrumentedFiles) {
				const path = isAbsolute(file) ? file : resolve(state.cwd, file);
				try {
					const content = await readFile(path, "utf8");
					if (content.includes(marker)) remaining.push(file);
				} catch {
					// Deleted temporary helper files are considered clean.
				}
			}
			const search = await pi.exec(
				"rg",
				[
					"-l", "--hidden", "--fixed-strings",
					"--glob", "!.git/**", "--glob", "!node_modules/**", "--glob", "!bin/**",
					"--glob", "!obj/**", "--glob", "!dist/**", "--glob", "!build/**", "--glob", "!target/**",
					marker, ".",
				],
				{ cwd: state.cwd },
			);
			if (search.code === 0) remaining.push(...search.stdout.split("\n").map((line) => line.trim()).filter(Boolean));
			const uniqueRemaining = unique(remaining);
			if (uniqueRemaining.length > 0) throw new Error(`Instrumentation markers remain in: ${uniqueRemaining.join(", ")}`);
			await setPhase(ctx, "completed");
			return {
				content: [{ type: "text", text: "Debug cleanup verified. Summarize the retained production fix and verification evidence." }],
				details: { runId: state.runId, phase: state.phase },
			};
		},
	});
}
