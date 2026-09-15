# GEO Compliance Report — Istio Troubleshooting Guides

## Summary Table

| File | 🔴 | 🟡 | 🟢 | Top Issue |
|------|:--:|:--:|:--:|-----------|
| 03-00-network-connectivity.md | 1 | 3 | 5 | No H1→H2 hierarchy; content starts before first heading |
| 03-05-increase-verbosity-of-ingress-logs.md | 0 | 3 | 6 | Non-standard `> ### Note:` callout; mega log block hurts density |
| 03-10-503-no-access.md | 1 | 3 | 5 | Broken placeholder `{ISTIO_INGRESS_GATEWAY_POD_NAME}` in kubectl command |
| 03-20-connection-refused.md | 0 | 2 | 6 | Solution bullets, not numbered steps; cause needs one extra sentence |
| 03-30-istio-no-sidecar.md | 1 | 2 | 6 | Unclosed string literal in kubectl command (line 98) |
| 03-40-incompatible-istio-sidecar-version.md | 0 | 2 | 6 | Missing blank line after H1; "allows you to" pattern |
| 03-45-jobs-cant-finish.md | 0 | 2 | 7 | Code fence missing language tag (line 20); cause is dense |
| 03-46-init-containers-cant-access-network.md | 0 | 2 | 7 | Code fence missing language tag (line 20); annotation value inconsistency |
| 03-50-recovering-from-unintentional-istio-removal.md | 1 | 2 | 6 | Non-standard `>### Note:` callout; intro before Symptom heading |
| 03-60-404-on-istio-gateway.md | 0 | 2 | 5 | Cause sentence 40 words — exceeds density threshold |
| 03-65-403-if-host-header-contains-port.md | 0 | 1 | 7 | Solution defers fix to reader without numbered steps |
| 03-70-reconciliation-fails-on-istio-install.md | 1 | 2 | 5 | "Symptoms" plural heading — inconsistent with all other guides |
| 03-80-cannot-connect-to-hana-db.md | 0 | 2 | 6 | Cause paragraph 54 words — exceeds density threshold |
| 03-90-istio-cert-unknown.md | 1 | 3 | 4 | "Remedy" heading instead of "Solution" — inconsistent terminology |
| 03-95-uneven-load-balancing-with-destination-rules.md | 0 | 1 | 8 | Minor: sentence at line 11 is 26 words |

---

## 03-00-network-connectivity.md

**Document:** Network Connectivity - Diagnostics
**Scope:** Full document

| Category | Rating | Finding |
|----------|:------:|---------|
| Structure | 🔴 | Fix: Document opens with 3 lines of body text before the first heading (`## 1. Global Analysis`). There is no `## Symptom`, `## Cause`, or `## Solution` structure — atypical for a troubleshooting guide. The intro paragraph should either become a `## Overview` section or be removed. |
| Writing Style | 🟡 | Review: Line 3 — "If you're having trouble" uses a contraction. Prefer "If you have trouble". Line 3 also uses "don't know" — prefer "do not know". |
| Explicit Context | 🟡 | Review: Line 3 — "The issues may not be directly related to Istio" — "the issues" is ambiguous. Specify: "The connectivity issues may not be caused by Istio configuration." |
| Information Density | 🟡 | Review: Line 49 — "A deny rule without the **ports** field on an HTTP-based **hosts** rule can block all TCP traffic, not just HTTP." — 22 words, borderline. Acceptable, but watch for compound conditions. |
| Terminology Consistency | 🟢 | Pass: "AuthorizationPolicy", "DestinationRule", "PeerAuthentication" used consistently throughout. |
| Modular Information Units | 🟢 | Pass: Each numbered section covers one resource type. |
| Procedural Logic | 🟢 | Pass: Each section has list/describe commands followed by "What to look for" guidance. |
| Answer-First Content | 🟢 | Pass: Each section opens with what that resource type affects. |
| User Intent Alignment | 🟢 | Pass: Diagnostic guide structure matches troubleshooting intent well. |
| Authority and Evidence | 🟢 | Pass: Links to Istio upstream docs for each resource type. |
| Summaries and Extractable Answers | 🟢 | Pass: "What to look for" bullets are easily extractable. |
| Metadata and Structured Signals | 🟢 | Pass: "Istio" and resource names mentioned throughout. |
| Correctness Signals | 🟢 | Pass: No suspicious substitutions detected. |
| Explicit Relationships | 🟢 | Pass: Cause-and-effect described for each resource type. |

**Top 3 Issues:**
1. No Symptom/Cause/Solution structure — AI crawlers cannot map this to a troubleshooting query.
2. Ambiguous "the issues" reference at line 3.
3. Contraction "If you're" / "don't know" — prefer formal register.

---

## 03-05-increase-verbosity-of-ingress-logs.md

**Document:** Increase Verbosity of the Istio Ingress Logs
**Scope:** Full document

| Category | Rating | Finding |
|----------|:------:|---------|
| Writing Style | 🟡 | Review: Line 3 — "In order to diagnose" — wordy. Replace with "To diagnose". Line 10 — "With Istio, you can enable access logging by the Telemetry custom resource (CR)" — "With Istio" is a filler opener. Rewrite: "Enable access logging using the Telemetry CR." |
| Structure | 🟡 | Review: Line 90–92 — `> ### Note:` is non-standard callout. Use `> [!NOTE]`. |
| Information Density | 🟡 | Review: Lines 68–87 — the raw trace log block (20 lines) is unformatted output with no annotation. Consider trimming to the key line (`UNSUPPORTED_PROTOCOL`) and noting the full log is illustrative. |
| Terminology Consistency | 🟢 | Pass: "Istio Ingress Gateway", "Ingress log", "Telemetry CR" used consistently. |
| Modular Information Units | 🟢 | Pass: Two sections (access logs, trace logs) each cover one log level. |
| Explicit Context | 🟢 | Pass: Each section explains what the log type provides and when to use it. |
| Procedural Logic | 🟢 | Pass: Commands are followed by expected output. Cause-trigger-effect shown for the TLS example. |
| Answer-First Content | 🟢 | Pass: Access log defined immediately in section opening. |
| User Intent Alignment | 🟢 | Pass: Content maps directly to the title's intent. |
| Authority and Evidence | 🟢 | Pass: Real example log output provided for both log levels. |
| Summaries and Extractable Answers | 🟢 | Pass: "The effect is immediate" and "very useful for diagnosing problems in lower layers" are concise takeaways. |
| Metadata and Structured Signals | 🟢 | Pass: "Istio Ingress Gateway", "Telemetry CR", "istio-system" all explicit. |
| Correctness Signals | 🟢 | Pass: No suspicious substitutions detected. |

**Top 3 Issues:**
1. `> ### Note:` non-standard callout — use `> [!NOTE]`.
2. "In order to" opener — replace with "To".
3. Raw trace log block is very long with no annotation — consider trimming.

---

## 03-10-503-no-access.md

**Document:** Can't Access a Kyma Endpoint (503 status code)
**Scope:** Full document

| Category | Rating | Finding |
|----------|:------:|---------|
| Correctness Signals | 🔴 | Fix: Line 40 — `kubectl get -n istio-system {ISTIO_INGRESS_GATEWAY_POD_NAME} -o jsonpath=...` — `kubectl get` requires a resource type before the name. The command as written is syntactically invalid. Should be `kubectl get pod -n istio-system {ISTIO_INGRESS_GATEWAY_POD_NAME} -o jsonpath=...`. |
| Structure | 🟡 | Review: Line 30 — tab section uses `#### **kubectl**` and `#### **Kyma Dashboard**` headings but there is no `<!-- tabs:start -->` / `<!-- tabs:end -->` wrapper shown — the `<!-- tabs:end -->` at line 67 has no matching start. Check if this is a rendering issue. |
| Writing Style | 🟡 | Review: Line 2 — `<!-- open-source-only -->` comment appears after the H1. If this content is only for open-source, the heading should be visible but the comment should precede the H1. |
| Explicit Context | 🟡 | Review: Line 52/65 — "verify if the **spec.enableKymaGateway** field of your APIGateway custom resource is set to `true`" — this references `APIGateway`, not `Istio`. Context switch is unexplained. Add a sentence explaining the relationship. |
| Terminology Consistency | 🟢 | Pass: "Istio Ingress Gateway", "istio-proxy" used consistently. |
| Modular Information Units | 🟢 | Pass: Restart step separated from deeper investigation steps. |
| Procedural Logic | 🟢 | Pass: Steps are numbered and ordered logically. |
| Answer-First Content | 🟢 | Pass: Cause stated immediately after Symptom. |
| User Intent Alignment | 🟢 | Pass: 503 error maps directly to the title. |
| Authority and Evidence | 🟢 | Pass: Link to Gardener certificates guide provided. |
| Summaries and Extractable Answers | 🟢 | Pass: Cause sentence is concise and extractable. |
| Metadata and Structured Signals | 🟢 | Pass: "Kyma", "Istio Ingress Gateway", "istio-system" explicit. |
| Explicit Relationships | 🟢 | Pass: Certificate corruption → port 80/443 not used → restart trigger explained. |

**Top 3 Issues:**
1. Invalid `kubectl get` command at line 40 — missing resource type.
2. `<!-- tabs:end -->` with no matching `<!-- tabs:start -->`.
3. Unexplained `APIGateway` reference in an Istio troubleshooting guide.

---

## 03-20-connection-refused.md

**Document:** Connection Refused Errors
**Scope:** Full document

| Category | Rating | Finding |
|----------|:------:|---------|
| Procedural Logic | 🟡 | Review: Solution is two unordered bullets, not numbered steps. These are alternatives, but the reader gets no guidance on which to try first. Add a lead sentence: "Choose one of the following based on whether you want to disable mTLS or allow permissive mode." |
| Explicit Relationships | 🟡 | Review: Line 9 — "every element of the service mesh must have an Istio sidecar with a valid TLS certificate" — does not explain what happens to elements without a sidecar (they get refused). Add: "Services without a sidecar cannot participate in mTLS and their connections are refused by mesh-enabled services." |
| Structure | 🟢 | Pass: Clean Symptom/Cause/Solution structure. |
| Modular Information Units | 🟢 | Pass: Single-cause, single-solution document — well-scoped. |
| Terminology Consistency | 🟢 | Pass: "mTLS", "DestinationRule", "PeerAuthentication" used consistently. |
| Writing Style | 🟢 | Pass: Concise, factual, no buzzwords. |
| Answer-First Content | 🟢 | Pass: Cause immediately explains the mTLS default. |
| User Intent Alignment | 🟢 | Pass: Maps exactly to the connection refused symptom. |
| Authority and Evidence | 🟢 | Pass: Links to Istio DestinationRule and PeerAuthentication docs. |
| Summaries and Extractable Answers | 🟢 | Pass: Cause sentence is a clean extractable answer. |
| Metadata and Structured Signals | 🟢 | Pass: "Istio", "mTLS", "service mesh" all named. |
| Information Density | 🟢 | Pass: All sentences are under 20 words. |
| Correctness Signals | 🟢 | Pass: No suspicious substitutions detected. |
| Explicit Context | 🟢 | Pass: Actors (service with/without sidecar) clearly named. |

**Top 3 Issues:**
1. Solution bullets give no guidance on which option to choose first.
2. Cause doesn't explain what actually happens to the refused connection.

---

## 03-30-istio-no-sidecar.md

**Document:** Istio Sidecar Proxy Injection Issues
**Scope:** Full document

| Category | Rating | Finding |
|----------|:------:|---------|
| Correctness Signals | 🔴 | Fix: Line 98 — `kubectl get pod {POD} -n default -o=jsonpath='{.metadata.labels.sidecar\.istio\.io/inject}'` — the closing single quote is missing from the jsonpath string. The command will fail as written. Add `'` after the closing `}`. |
| Writing Style | 🟡 | Review: Line 18 — "Find out which Pods do not have Istio sidecar proxy injection enabled and why." — "Find out" is informal. Replace with "Identify which Pods do not have Istio sidecar proxy injection enabled." |
| Information Density | 🟡 | Review: Line 9 — "By default, the Istio module does not automatically inject an Istio sidecar proxy into any Pods you create. To inject a Pod with an Istio sidecar proxy, you must explicitly enable injection for the Pod's Deployment or for the entire namespace." — 47 words across two sentences. Split further: (1) default behavior, (2) how to enable, (3) what to do if still not injected. |
| Structure | 🟢 | Pass: Symptom/Cause/Solution with sub-sections for each check scope. |
| Modular Information Units | 🟢 | Pass: Three sub-procedures clearly separated. |
| Terminology Consistency | 🟢 | Pass: "Istio sidecar proxy", "sidecar.istio.io/inject" consistent throughout. |
| Procedural Logic | 🟢 | Pass: Each sub-procedure is numbered with expected output shown. |
| Answer-First Content | 🟢 | Pass: Three conditions for non-injection listed up front in Cause. |
| User Intent Alignment | 🟢 | Pass: Covers all scopes (all namespaces, one namespace, one pod). |
| Authority and Evidence | 🟢 | Pass: Script linked from GitHub; tutorial linked for enabling injection. |
| Summaries and Extractable Answers | 🟢 | Pass: Cause bullet list is directly extractable. |
| Metadata and Structured Signals | 🟢 | Pass: "Istio module", "Kyma", namespace/label names explicit. |
| Explicit Relationships | 🟢 | Pass: Three injection-blocking conditions clearly enumerated. |
| Explicit Context | 🟢 | Pass: Tab structure distinguishes Kyma Dashboard from kubectl paths. |

**Top 3 Issues:**
1. Unclosed string literal in kubectl jsonpath command (line 98) — command fails on copy-paste.
2. "Find out" informal phrasing — replace with "Identify".
3. 47-word opening of Cause section — split into 3 sentences.

---

## 03-40-incompatible-istio-sidecar-version.md

**Document:** Incompatible Istio Sidecar Version After the Istio Module's Update
**Scope:** Full document

| Category | Rating | Finding |
|----------|:------:|---------|
| Structure | 🟡 | Review: Line 1–2 — `<!-- open-source-only -->` comment immediately followed by `# Incompatible...` with no blank line. Minor formatting, but `## Symptom` heading also lacks a blank line after `## Cause` at line 11. Add blank lines after each heading for consistent rendering. |
| Writing Style | 🟡 | Review: Line 13 — "Istio Operator's `ProxySidecarReconcilation` component performs a rollout for most common workload types ensuring that..." — 24-word sentence. Split: (1) what the component does, (2) what it ensures. Also note: `ProxySidecarReconcilation` appears to have a typo (missing 'i') — verify against the actual component name `ProxySidecarReconciliation`. |
| Terminology Consistency | 🟢 | Pass: "Istio module", "Istio CR", "ProxySidecarRestartSucceeded" used consistently. |
| Modular Information Units | 🟢 | Pass: Single symptom, single cause, single solution. |
| Procedural Logic | 🟢 | Pass: Numbered steps with expected output in YAML. |
| Answer-First Content | 🟢 | Pass: Symptom message quoted exactly; cause explained immediately. |
| User Intent Alignment | 🟢 | Pass: Title matches the warning state symptom precisely. |
| Authority and Evidence | 🟢 | Pass: Exact YAML condition output shown as evidence. |
| Summaries and Extractable Answers | 🟢 | Pass: Cause paragraph is a clean extractable explanation. |
| Metadata and Structured Signals | 🟢 | Pass: "Istio module", "Kyma dashboard", "kyma-system" all named. |
| Information Density | 🟢 | Pass: Most sentences under 20 words. |
| Correctness Signals | 🟢 | Pass: Possible typo in component name `ProxySidecarReconcilation` — verify spelling. |
| Explicit Context | 🟢 | Pass: Affected workload types named explicitly (Job, unmanaged ReplicaSet, standalone Pod). |
| Explicit Relationships | 🟢 | Pass: Cause-effect chain from upgrade → rollout → manual restart clearly described. |

**Top 3 Issues:**
1. Possible typo: `ProxySidecarReconcilation` — verify it should be `ProxySidecarReconciliation`.
2. 24-word sentence at line 13 — split into two.
3. Missing blank lines after headings.

---

## 03-45-jobs-cant-finish.md

**Document:** Pods Created by Jobs Can't Finish
**Scope:** Full document

| Category | Rating | Finding |
|----------|:------:|---------|
| Procedural Logic | 🟡 | Review: Line 20 — YAML example code fence has no language tag (` ``` ` with no `yaml`). Add ` ```yaml ` for correct syntax highlighting. |
| Information Density | 🟡 | Review: Line 8 — Cause paragraph is 63 words in two sentences. Split into three: (1) default native sidecar behavior since 1.22, (2) what the annotation does, (3) consequence for Jobs. |
| Structure | 🟢 | Pass: Clean Symptom/Cause/Solution/Related Links structure. |
| Modular Information Units | 🟢 | Pass: Single cause, two-branch solution (check initContainer vs container). |
| Terminology Consistency | 🟢 | Pass: "native sidecar", "istio-proxy", "initContainer" used consistently. |
| Writing Style | 🟢 | Pass: Factual, precise, no buzzwords. |
| Answer-First Content | 🟢 | Pass: Solution opens with the check to perform before branching. |
| User Intent Alignment | 🟢 | Pass: Title describes the symptom exactly; document resolves it. |
| Authority and Evidence | 🟢 | Pass: Link to related concept doc provided. YAML example shown. |
| Summaries and Extractable Answers | 🟢 | Pass: Final paragraph explains the expected result after fix. |
| Metadata and Structured Signals | 🟢 | Pass: "Istio module 1.22", version and product named. |
| Explicit Relationships | 🟢 | Pass: Regular container lifecycle vs native sidecar lifecycle clearly contrasted. |
| Correctness Signals | 🟢 | Pass: No suspicious substitutions detected. |
| Explicit Context | 🟢 | Pass: Annotation value and affected resource type explicitly named. |

**Top 3 Issues:**
1. YAML code fence missing language tag at line 20.
2. 63-word Cause paragraph — split into three sentences.

---

## 03-46-init-containers-cant-access-network.md

**Document:** Init Containers Can't Access the Network
**Scope:** Full document

| Category | Rating | Finding |
|----------|:------:|---------|
| Correctness Signals | 🟡 | Review: Line 18 — annotation value is `sidecar.istio.io/nativeSidecar=true` (no quotes), but the YAML example at line 27 uses `"true"` (quoted). In 03-45, line 8 also uses `"false"` with quotes. Standardize: YAML strings `"true"`/`"false"` are correct in YAML; bare `true` in annotation values should match the YAML example. |
| Information Density | 🟡 | Review: Line 8 — Cause paragraph is 68 words. Split into three sentences: (1) what istio-proxy does, (2) default native sidecar behavior, (3) what the annotation does and its consequence for init containers. |
| Structure | 🟢 | Pass: Clean Symptom/Cause/Solution/Related Links structure. |
| Modular Information Units | 🟢 | Pass: Single cause, two-branch solution mirroring 03-45. |
| Terminology Consistency | 🟢 | Pass: Consistent with sibling guide 03-45 in terminology. |
| Writing Style | 🟢 | Pass: Factual, no buzzwords. |
| Procedural Logic | 🟢 | Pass: Two-branch check is clear. |
| Answer-First Content | 🟢 | Pass: Solution starts with the diagnostic check. |
| User Intent Alignment | 🟢 | Pass: Title matches symptom; solution resolves it. |
| Authority and Evidence | 🟢 | Pass: Link to native sidecar concept doc; YAML example provided. |
| Summaries and Extractable Answers | 🟢 | Pass: Final sentence explains expected result after fix. |
| Metadata and Structured Signals | 🟢 | Pass: "Istio module 1.22" and version named. |
| Explicit Relationships | 🟢 | Pass: Init container startup sequence vs sidecar startup explained. |
| Explicit Context | 🟢 | Pass: Actors (init container, istio-proxy, regular sidecar) clearly named. |

**Top 3 Issues:**
1. Annotation value inconsistency: bare `true` in prose vs quoted `"true"` in YAML — standardize.
2. 68-word Cause paragraph — split into three sentences.

---

## 03-50-recovering-from-unintentional-istio-removal.md

**Document:** Reverting the Istio Module's Deletion
**Scope:** Full document

| Category | Rating | Finding |
|----------|:------:|---------|
| Structure | 🔴 | Fix: Lines 1–2 — document opens with a body sentence before the `## Symptom` heading: "Follow the steps outlined in this troubleshooting guide if you unintentionally deleted the Istio module and want to restore the cluster to its normal state without losing any resources created in the cluster." This 33-word sentence should be removed or moved into a brief intro section with a heading. |
| Writing Style | 🟡 | Review: Line 18 — `>### Note:` non-standard callout. Use `> [!NOTE]`. Also line 1: "Follow the steps outlined in this troubleshooting guide" is self-referential and adds no information. Remove. |
| Information Density | 🟡 | Review: Line 25 — "For example, the issue occurs when you delete Istio, but there are still VirtualService resources either created by you or installed by another Kyma component or module." — 29 words. Split: (1) example scenario, (2) blocking mechanism. |
| Terminology Consistency | 🟢 | Pass: "Istio CR", "Istio module", "finalizer" used consistently. |
| Modular Information Units | 🟢 | Pass: Single cause, single 4-step solution. |
| Procedural Logic | 🟢 | Pass: Steps are numbered; outcome described after each. |
| Answer-First Content | 🟢 | Pass: kubectl command to verify the condition provided immediately in Symptom. |
| User Intent Alignment | 🟢 | Pass: Title and symptom match well. |
| Authority and Evidence | 🟢 | Pass: Link to blocking deletion strategy design rationale provided. |
| Summaries and Extractable Answers | 🟢 | Pass: Final sentence describes expected outcome after fix. |
| Metadata and Structured Signals | 🟢 | Pass: "Istio module", "Kyma", "kyma-system" named. |
| Explicit Relationships | 🟢 | Pass: Finalizer → deletion blocked → manual removal → re-add chain explained. |
| Explicit Context | 🟢 | Pass: `IstioCustomResourcesDangling` reason code and VirtualService dependency named. |
| Correctness Signals | 🟢 | Pass: No suspicious substitutions detected. |

**Top 3 Issues:**
1. Body text before `## Symptom` heading — remove or add a heading.
2. `>### Note:` — use `> [!NOTE]`.
3. 29-word example sentence — split into two.

---

## 03-60-404-on-istio-gateway.md

**Document:** You Get 404 Not Found
**Scope:** Full document

| Category | Rating | Finding |
|----------|:------:|---------|
| Information Density | 🟡 | Review: Line 10 — "The error might be caused by conflicts in the Istio Gateway host. For example, if you create two Gateways with the same host, Istio Ingress Gateway cannot reliably match an incoming request to a specific Gateway. As a result, requests receive 404 errors. Read the [Istio documentation](…) to learn more about this behavior." — sentence 2 is 25 words. Split: (1) conflict statement, (2) result. Also "Read the Istio documentation to learn more" is a filler sentence — replace with a parenthetical link on the preceding sentence. |
| Explicit Relationships | 🟡 | Review: Line 12 — "Note that when you create `Ingress` resources using Istio as their ingress class, a `Gateway` entry is also created underneath." — this is an important implicit-relationship note but appears in the Cause section without a heading or callout. Consider a `> [!NOTE]` callout. |
| Structure | 🟢 | Pass: Symptom/Cause/Solution present. |
| Modular Information Units | 🟢 | Pass: Short, focused document. |
| Terminology Consistency | 🟢 | Pass: "Gateway", "Istio Ingress Gateway", "Ingress" used consistently. |
| Writing Style | 🟢 | Pass: Factual, concise, no buzzwords. |
| Procedural Logic | 🟢 | Pass: Single-action solution is appropriate for this scope. |
| Answer-First Content | 🟢 | Pass: Cause names the conflict immediately. |
| User Intent Alignment | 🟢 | Pass: 404 error maps directly to the title. |
| Authority and Evidence | 🟢 | Pass: Link to Istio documentation on the specific problem. |
| Summaries and Extractable Answers | 🟢 | Pass: Solution is a single extractable sentence. |
| Metadata and Structured Signals | 🟢 | Pass: "Istio", "Istio Ingress Gateway" named. |
| Correctness Signals | 🟢 | Pass: No suspicious substitutions detected. |
| Explicit Context | 🟢 | Pass: Ingress-to-Gateway auto-creation noted. |

**Top 3 Issues:**
1. 25-word sentence in Cause — split into two.
2. "Read the Istio documentation to learn more" filler sentence — merge into preceding sentence as a parenthetical link.
3. Implicit Ingress→Gateway note could use a `> [!NOTE]` callout for visibility.

---

## 03-65-403-if-host-header-contains-port.md

**Document:** You Get 403 Forbidden if Host Header Contains Port
**Scope:** Full document

| Category | Rating | Finding |
|----------|:------:|---------|
| Procedural Logic | 🟡 | Review: Line 42 — Solution opens with RFC references and "the general recommendation is to fix the client implementation" — this is abstract before actionable. Move the YAML workaround first, then the RFC background second. Reader needs the workaround immediately. |
| Structure | 🟢 | Pass: Symptom/Cause/Solution structure present. Example YAML and curl in Cause is well-placed. |
| Modular Information Units | 🟢 | Pass: Single cause, two-option solution. |
| Terminology Consistency | 🟢 | Pass: "AuthorizationPolicy", "Host header" consistent. |
| Writing Style | 🟢 | Pass: Precise, factual. |
| Answer-First Content | 🟢 | Pass: Cause named in first sentence. |
| User Intent Alignment | 🟢 | Pass: Exact error condition described in title and symptom. |
| Authority and Evidence | 🟢 | Pass: RFC 9110 and RFC 3986 cited. |
| Summaries and Extractable Answers | 🟢 | Pass: Both solution options clearly summarized. |
| Metadata and Structured Signals | 🟢 | Pass: "Istio", "AuthorizationPolicy", "Kyma" named. |
| Information Density | 🟢 | Pass: All sentences under 20 words. |
| Correctness Signals | 🟢 | Pass: No suspicious substitutions. |
| Explicit Context | 🟢 | Pass: Host header behavior with and without port shown concretely. |
| Explicit Relationships | 🟢 | Pass: Istio host-matching behavior → 403 cause explained. |

**Top 3 Issues:**
1. Solution presents RFC background before the actionable workaround — swap order.

---

## 03-70-reconciliation-fails-on-istio-install.md

**Document:** Changes to Istio Resources Are Not Reverted After Reconciliation
**Scope:** Full document

| Category | Rating | Finding |
|----------|:------:|---------|
| Structure | 🔴 | Fix: Line 4 — heading is `## Symptoms` (plural). All other guides use `## Symptom` (singular). Standardize to `## Symptom`. |
| Writing Style | 🟡 | Review: Line 19 — `> ### Tip:` is non-standard callout format. Use `> [!TIP]`. |
| Explicit Relationships | 🟡 | Review: Line 12 — "If an external component, like a mutating webhook, adds a container … and that new container fails to start for any reason, the Pod is unable to reach the `Running` state. As a result, the Istio module reconciliation fails." — 36-word sentence. Split into two. |
| Terminology Consistency | 🟢 | Pass: "Istio Ingress Gateway Deployment", "Istiod Deployment", "Istio CNI DaemonSets" consistent. |
| Modular Information Units | 🟢 | Pass: Clear symptom list, single cause, 4-step solution. |
| Procedural Logic | 🟢 | Pass: Steps are numbered and ordered correctly. |
| Answer-First Content | 🟢 | Pass: Cause named immediately. |
| User Intent Alignment | 🟢 | Pass: Three symptom bullets cover all observable states. |
| Authority and Evidence | 🟢 | Pass: kubectl commands shown. |
| Summaries and Extractable Answers | 🟢 | Pass: Cause sentence is extractable. |
| Metadata and Structured Signals | 🟢 | Pass: "Istio", "istio-system" named. |
| Information Density | 🟢 | Pass: Most sentences under 20 words. |
| Correctness Signals | 🟢 | Pass: No suspicious substitutions. |
| Explicit Context | 🟢 | Pass: "mutating webhook" named as the external component. |

**Top 3 Issues:**
1. `## Symptoms` — standardize to `## Symptom`.
2. `> ### Tip:` — use `> [!TIP]`.
3. 36-word cause sentence — split into two.

---

## 03-80-cannot-connect-to-hana-db.md

**Document:** SAP HANA Database Connection Issues
**Scope:** Full document

| Category | Rating | Finding |
|----------|:------:|---------|
| Information Density | 🟡 | Review: Lines 8–9 — "The Istio module's default configuration does not restrict outbound traffic. This means that the application should have no issues connecting to a SAP HANA Database instance. If you are experiencing issues, they may be related to the SAP HANA Database instance or your cluster configuration. To identify the source of the problem, follow the troubleshooting steps." — 54 words. Trim: "By default, the Istio module does not restrict outbound traffic. If you cannot connect to SAP HANA Database, the issue is likely in the database instance or cluster configuration. Follow these steps to identify the source." |
| Writing Style | 🟡 | Review: Line 5 — "You're unable to connect" — contraction in a symptom statement. Use "You are unable to connect". |
| Structure | 🟢 | Pass: Symptom/Cause/Solution with two clearly separated sub-procedures. |
| Modular Information Units | 🟢 | Pass: Outside-cluster and inside-cluster checks are well separated. |
| Terminology Consistency | 🟢 | Pass: "SAP HANA Database", "SAP HANA Client", "hdbsql" consistent. |
| Procedural Logic | 🟢 | Pass: Steps are numbered; expected output shown. |
| Answer-First Content | 🟢 | Pass: Cause clarifies this is not an Istio restriction issue upfront. |
| User Intent Alignment | 🟢 | Pass: Two diagnostic paths (outside/inside cluster) cover the likely scenarios. |
| Authority and Evidence | 🟢 | Pass: SAP Development Tools link provided. Dockerfile example included. |
| Summaries and Extractable Answers | 🟢 | Pass: "If the connection is successful…the issue is not related to…" is extractable at each step. |
| Metadata and Structured Signals | 🟢 | Pass: "SAP HANA Database", "Istio module", "Kubernetes" named. |
| Explicit Relationships | 🟢 | Pass: Each step ends with a conclusion that scopes the source of the problem. |
| Correctness Signals | 🟢 | Pass: No suspicious substitutions. |
| Explicit Context | 🟢 | Pass: Platform (Linux x86 64-bit), tools, and namespaces explicit. |

**Top 3 Issues:**
1. 54-word Cause paragraph — trim to 3 concise sentences.
2. "You're unable" contraction — use "You are unable".

---

## 03-90-istio-cert-unknown.md

**Document:** Istio Cannot Verify an HTTPS Certificate Generated by a Trusted Signing CA
**Scope:** Full document

| Category | Rating | Finding |
|----------|:------:|---------|
| Structure | 🔴 | Fix: Line 17 — Solution heading is `## Remedy`, not `## Solution`. All other guides use `## Solution`. Standardize. |
| Writing Style | 🟡 | Review: Line 20 — "To ensure that the certificate is trusted by Istio, verify that you are using the most up-to-date version of the Istio module." — 25 words. Split: (1) verify you have the latest version, (2) what that guarantees for SAP BTP users. |
| Explicit Relationships | 🟡 | Review: Line 20 — "If you are using SAP BTP, Kyma runtime, the solution guarantees that you have the most up-to-date version." — "the solution" is ambiguous. Specify: "SAP BTP, Kyma runtime automatically provides the most up-to-date Istio module version." |
| Correctness Signals | 🟡 | Review: Line 6 — Symptom section opens with "See the possible symptoms:" followed by a bare line before the first bullet. The first item (`Istiod logs include multiple warnings…`) is not part of a bullet list — it appears as a loose line. Format as a bullet to match the others. |
| Modular Information Units | 🟢 | Pass: Symptom list, single cause, single remedy. |
| Terminology Consistency | 🟢 | Pass: "JWKS", "Istiod", "root CA" consistent. |
| Answer-First Content | 🟢 | Pass: Cause names the specific failure mode (unrecognized root CA). |
| User Intent Alignment | 🟢 | Pass: Four symptom variants cover the observable states. |
| Authority and Evidence | 🟢 | Pass: References to JWKS URI, root CA concepts. |
| Summaries and Extractable Answers | 🟢 | Pass: Cause paragraph is concise and extractable. |
| Metadata and Structured Signals | 🟢 | Pass: "Istio module", "SAP BTP, Kyma runtime" named. |
| Information Density | 🟢 | Pass: Most sentences under 20 words. |
| Procedural Logic | 🟢 | Pass: Two-step remedy (check version, then verify CA trust) is ordered correctly. |
| Explicit Context | 🟢 | Pass: Internal CA vs public CA distinction explained. |

**Top 3 Issues:**
1. `## Remedy` heading — standardize to `## Solution`.
2. First symptom bullet is a loose line, not a list item — format as bullet.
3. "the solution" ambiguous reference — replace with "SAP BTP, Kyma runtime automatically…".

---

## 03-95-uneven-load-balancing-with-destination-rules.md

**Document:** Uneven Traffic Distribution with DestinationRules
**Scope:** Full document

| Category | Rating | Finding |
|----------|:------:|---------|
| Information Density | 🟡 | Review: Line 11 — "Istio implicitly activates locality load balancing whenever you configure **outlierDetection** in a DestinationRule, even if you don't explicitly set **localityLbSetting.enabled**." — 26 words. Split at the comma: (1) implicit activation statement, (2) the "even if" clause. |
| Structure | 🟢 | Pass: Symptom/Cause/Solution/Additional Information — logical hierarchy. |
| Modular Information Units | 🟢 | Pass: Before/After YAML examples cleanly separated. |
| Terminology Consistency | 🟢 | Pass: "DestinationRule", "outlierDetection", "localityLbSetting" consistent throughout. |
| Writing Style | 🟢 | Pass: Factual, precise, no buzzwords. |
| Procedural Logic | 🟢 | Pass: Before/After pattern with apply command is clear and complete. |
| Answer-First Content | 🟢 | Pass: Root cause (implicit locality LB) stated at the start of Cause. |
| User Intent Alignment | 🟢 | Pass: Symptom matches title; solution is concrete. |
| Authority and Evidence | 🟢 | Pass: Link to Istio locality weight distribution docs; observability tools mentioned. |
| Summaries and Extractable Answers | 🟢 | Pass: Additional Information section provides extractable design notes. |
| Metadata and Structured Signals | 🟢 | Pass: "Istio", "DestinationRule", `networking.istio.io/v1beta1` explicit. |
| Explicit Relationships | 🟢 | Pass: outlierDetection → implicit locality LB → uneven distribution chain explained. |
| Correctness Signals | 🟢 | Pass: No suspicious substitutions. |
| Explicit Context | 🟢 | Pass: Multi-zone cluster context and locality label distribution mentioned. |

**Top 3 Issues:**
1. 26-word sentence at line 11 — split at comma.

---

## Cross-Document Pattern Summary

### Overview

| Document | 🔴 | 🟡 | Top Issue |
|----------|:--:|:--:|-----------|
| 03-00 Network Connectivity | 1 | 3 | No Symptom/Cause/Solution structure |
| 03-05 Verbosity of Ingress Logs | 0 | 3 | Non-standard callout; verbose log block |
| 03-10 503 No Access | 1 | 3 | Invalid kubectl command |
| 03-20 Connection Refused | 0 | 2 | Solution needs ordering guidance |
| 03-30 No Sidecar | 1 | 2 | Unclosed string in kubectl command |
| 03-40 Incompatible Sidecar | 0 | 2 | Possible component name typo |
| 03-45 Jobs Can't Finish | 0 | 2 | Missing YAML code fence language tag |
| 03-46 Init Containers | 0 | 2 | Annotation value inconsistency |
| 03-50 Istio Removal | 1 | 2 | Body text before first heading |
| 03-60 404 Not Found | 0 | 2 | Filler sentence; density |
| 03-65 403 Forbidden | 0 | 1 | Solution order (RFC before workaround) |
| 03-70 Reconciliation Fails | 1 | 2 | "Symptoms" plural heading |
| 03-80 HANA DB | 0 | 2 | 54-word cause paragraph |
| 03-90 Cert Unknown | 1 | 3 | "Remedy" instead of "Solution" |
| 03-95 Uneven Load Balancing | 0 | 1 | 26-word sentence |

### Recurring Strengths

- **Symptom/Cause/Solution structure** is present in 13 of 15 guides.
- **Code examples** are consistently provided with copy-pasteable commands.
- **Cross-linking** to related guides and upstream Istio/Kubernetes docs is a strength throughout.
- **Cause sections** are generally concise and extractable as standalone answers.

### Recurring Weaknesses

| Pattern | Affected Files |
|---------|---------------|
| Non-standard callout format (`> ### Note:` / `> ### Tip:`) | 03-05, 03-50, 03-70 |
| Broken or incomplete CLI commands | 03-10 (missing resource type), 03-30 (unclosed string) |
| Cause/intro paragraph density > 40 words | 03-30, 03-45, 03-46, 03-80 |
| Body text before first `##` heading | 03-00, 03-50 |
| Heading inconsistency (`Symptoms` plural, `Remedy` instead of `Solution`) | 03-70, 03-90 |
| Missing code fence language tags | 03-45, 03-46 |

### Prioritized Action List

1. **Fix broken CLI commands** — 03-10 line 40 (missing `pod` resource type), 03-30 line 98 (unclosed string). Copy-paste failures block users immediately.
2. **Standardize callout syntax** — Replace all `> ### Note:` and `> ### Tip:` with `> [!NOTE]` and `> [!TIP]` across 03-05, 03-50, 03-70.
3. **Standardize heading names** — `## Symptoms` → `## Symptom` (03-70), `## Remedy` → `## Solution` (03-90).
4. **Add Symptom/Cause/Solution structure to 03-00** — currently uses only numbered diagnostic sections.
5. **Split dense Cause paragraphs** — 03-30, 03-45, 03-46, 03-80 all have opening paragraphs over 40 words.
6. **Add language tags to code fences** — 03-45 and 03-46 YAML examples missing ` ```yaml `.
7. **Remove body text before first heading** — 03-50 intro sentence, 03-00 opening paragraph.
8. **Fix annotation value inconsistency** — 03-46 prose uses bare `true`, YAML uses `"true"`.
