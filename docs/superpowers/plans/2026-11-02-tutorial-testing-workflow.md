# Tutorial Testing Workflow Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Automate execution of every Kyma Istio tutorial as a scheduled GitHub Actions workflow, so tutorials are continuously verified against real clusters provisioned on Gardener.

**Architecture:** Each tutorial's bash code blocks are extracted into a standalone script under `hack/ci/tutorials/`, structured as shell functions (`step_1`, `step_2`, …) called by a `run_all_steps` entry point. The extractor replaces `{PLACEHOLDER}` patterns with `$VAR` references; a `substitutions.sh` file exports the test values for all known placeholders and is sourced by the runner before executing any tutorial. An optional `.override.sh` sidecar per tutorial redefines individual step functions to replace test-specific behaviour (e.g. a different DNS provider) without touching the generated file. A new composite action (`tutorial-test-gardener`) wraps the existing Gardener provision/deprovision lifecycle and runs one tutorial script. Two triggers: a PR path-filtered job that tests only modified tutorials, and a weekly scheduled job that runs the full matrix.

**Tech Stack:** Bash, Python 3, GitHub Actions composite actions, Gardener (AWS), kubectl, Helm.

**Spec:** This plan — no separate spec document. Requirements are captured in the conversation and in this plan's Global Constraints section.

## Global Constraints

- Follow existing patterns in `.github/actions/e2e-test-gardener/` and `hack/ci/gardener/` exactly — same env var names, same `common.sh` utilities, same `configurations/aws-ipv4` preset.
- All new bash scripts must start with `set -euo pipefail` and `source hack/ci/common.sh` for consistency.
- Tutorial scripts live in `hack/ci/tutorials/` — one `.sh` per tutorial, named after the tutorial file without the `.md` extension (e.g. `01-10-external-authorization-provider.sh`).
- The extractor replaces `{PLACEHOLDER}` patterns (e.g. `{NAMESPACE_NAME}`, `{YOUR_DOMAIN_NAME}`) in extracted bash blocks with `$VAR` references (e.g. `$TUTORIAL_NAMESPACE`, `$TUTORIAL_DOMAIN_NAME`) at generation time.
- `hack/ci/tutorials/substitutions.sh` exports the canonical test values for all known placeholder variables. It is sourced by the runner before any tutorial script runs.
- `TUTORIAL_DOMAIN_NAME` is injected as a GitHub Actions variable (`vars.TUTORIAL_DOMAIN_NAME`) — a real domain the team controls, required for DNS/TLS tutorials.
- `TUTORIAL_NAMESPACE` defaults to `tutorial-test` and is hardcoded in `substitutions.sh`.
- Each generated script wraps every extracted bash block in a numbered shell function (`step_1`, `step_2`, …) and ends with a `run_all_steps` call that invokes them in order.
- An optional override file `<tutorial-stem>.override.sh` may exist alongside a generated script. It redefines only the step functions that need replacing. The runner sources the generated script first, then the override (if present), then calls `run_all_steps`.
- Override files are not sync-checked — they are exempt by design.
- The scheduled workflow uses `environment: e2e` (same as other Gardener jobs) so it inherits the same secret/variable scope and approval gate.
- Secrets: `GARDENER_TOKEN` (secret), `GARDENER_PROJECT_NAME` (var), `TUTORIAL_DOMAIN_NAME` (var) — same naming convention as all other Gardener workflows.
- Triggers: PR with path filter `docs/user/tutorials/**.md` runs only tutorials modified in that PR (dynamic matrix from `git diff`); weekly schedule (`0 5 * * 1`, Monday 06:00 CET) runs the full matrix.
- Cluster name pattern: `tut-<short-hash>` (same md5/head pattern as existing jobs: `istio-$(echo $RANDOM | md5sum | head -c 7)`).
- Gardener configuration: `aws-ipv4` (same as `istio-e2e-test-aws` jobs).
- Deprovision runs on `success() || cancelled()` — same guard as `e2e-test-gardener`.
- No Slack failure notification needed.

## Open Questions / To Clarify Before Implementing

~~1. **Tutorial script maintenance:** Resolved — generated once, committed as first-class source files.~~
~~2. **Placeholder values:** Resolved — extractor rewrites `{PLACEHOLDER}` to `$VAR` references; `substitutions.sh` exports test values; `TUTORIAL_DOMAIN_NAME` injected as a GitHub Actions variable.~~
3. **Verification step:** After running a tutorial, how do we assert success beyond "the script exited 0"? Is there a `curl` check, a `kubectl wait`, or just exit code?
4. **Cleanup per tutorial:** Each tutorial creates namespaces, workloads, and CRs. Should the tutorial script include a cleanup step, or is the whole cluster discarded after each run (making cleanup unnecessary)?
5. **Tutorial dependencies:** Some tutorials (e.g. `01-55` mTLS egress) may depend on prerequisites set up by earlier tutorials. Should they run independently in separate jobs (each on a fresh cluster) or sequentially on one cluster?
6. **Fork testing:** Confirm that the fork has `GARDENER_TOKEN` secret, `GARDENER_PROJECT_NAME` and `TUTORIAL_DOMAIN_NAME` variables configured, and the `e2e` environment exists with the approval gate removed for iteration speed.
~~7. **Trigger:** Resolved — PR path filter for modified tutorials + weekly full matrix.~~


## Review Focus

- **Unresolved placeholder variables** — resolved by extractor rewriting `{PLACEHOLDER}` to `$VAR` and `substitutions.sh` exporting test values. Verify the extractor covers every placeholder pattern found across all tutorials before generating.
- **Cluster leak on workflow cancellation:** if the job is cancelled after provision but before the deprovision step, the shoot stays running and accumulates cost. The `if: success() || cancelled()` guard on deprovision covers this — verify it is present.
- **`KUBECONFIG` not exported to tutorial script:** the tutorial script is run as a subprocess (`bash tutorial.sh`); the `KUBECONFIG` env var set by the provision step must be explicitly passed or exported, not just set in the action's environment block.
- **`helm` not available on `ubuntu-latest`:** the `01-10` tutorial calls `helm repo add` and `helm install`. Helm is not pre-installed on GitHub-hosted runners; a setup step is required.
- **Matrix job naming collisions:** if two tutorial file names produce the same short name after stripping the prefix, artifact upload names will collide. Use the full filename (without `.md`) as the matrix value, not a trimmed label.

---

## File Map

| Path | Status | Purpose |
|------|--------|---------|
| `hack/ci/tutorials/extract-code-blocks.py` | Create | Extracts bash blocks from a `.md` tutorial into a step-function `.sh`; rewrites `{PLACEHOLDER}` to `$VAR` references |
| `hack/ci/tutorials/substitutions.sh` | Create | Exports test values for all known placeholder variables (`TUTORIAL_NAMESPACE`, `TUTORIAL_DOMAIN_NAME`, etc.) |
| `hack/ci/tutorials/run-tutorial.sh` | Create | Thin wrapper: sources generated script, then override if present, calls `run_all_steps` |
| `hack/ci/tutorials/01-10-external-authorization-provider.sh` | Create (generated) | Step-function script for tutorial 01-10 |
| `hack/ci/tutorials/01-20-expose-httbin-gateway-api.sh` | Create (generated) | Step-function script for tutorial 01-20 |
| `hack/ci/tutorials/01-30-expose-tcp-gateway-api.sh` | Create (generated) | …and so on for each tutorial |
| `hack/ci/tutorials/<stem>.override.sh` | Create (per tutorial, as needed) | Redefines individual step functions that differ in CI testing (e.g. DNS provider) |
| `hack/ci/tutorials/check-tutorial-sync.sh` | Create | PR check: fails if a `.md` was modified in the PR but its generated `.sh` was not |
| `.github/actions/tutorial-test-gardener/action.yaml` | Create | Composite action: generate cluster name → prepare kubeconfig → provision → source substitutions → run tutorial → gather artifacts → deprovision |
| `.github/workflows/schedule-tutorials.yaml` | Create | Weekly full-matrix workflow + PR path-filtered workflow (dynamic matrix from `git diff`) |
| `.github/workflows/pull-request.yaml` | Modify | Add tutorial sync check job and PR tutorial test job |

---

## Task 1: Tutorial extractor in-repo

**Files:**
- Create: `hack/ci/tutorials/extract-code-blocks.py`

**Interfaces:**
- Consumes: path to a `.md` file (CLI arg)
- Produces: `hack/ci/tutorials/<stem>.sh` — executable bash script where each extracted bash block becomes a `step_N()` function, ending with a `run_all_steps` function that calls them in order and a `run_all_steps` invocation at the bottom

- [ ] **Step 1: Write extractor**

  Adapt logic from `test/scripts-automation/extract-code-blocks.py`. Output format:

  ```bash
  #!/usr/bin/env bash
  # GENERATED from docs/user/tutorials/<stem>.md — bootstrap only, edit freely
  # Override individual steps in <stem>.override.sh
  set -euo pipefail

  step_1() {
    export NAMESPACE={NAMESPACE_NAME}
  }

  step_2() {
    kubectl create ns $NAMESPACE
    kubectl label namespace $NAMESPACE istio-injection=enabled --overwrite
  }

  # ... one function per extracted bash block

  run_all_steps() {
    step_1; step_2; step_3  # ... all step names in order
  }

  run_all_steps
  ```

- [ ] **Step 2: Verify manually**

  ```bash
  python3 hack/ci/tutorials/extract-code-blocks.py \
    docs/user/tutorials/01-10-external-authorization-provider.md
  # Expect: hack/ci/tutorials/01-10-external-authorization-provider.sh created, chmod 755
  # Each bash block is a step_N() function; run_all_steps calls them all
  ```

- [ ] **Step 3: Generate all tutorial scripts**

  ```bash
  for f in docs/user/tutorials/0*.md; do
    python3 hack/ci/tutorials/extract-code-blocks.py "$f"
  done
  ls hack/ci/tutorials/*.sh
  ```

- [ ] **Step 4: Commit**

  ```bash
  git add hack/ci/tutorials/
  git commit -m "feat: add tutorial extractor and generated tutorial scripts"
  ```

---

## Task 2: Placeholder substitutions file

**Files:**
- Create: `hack/ci/tutorials/substitutions.sh`

**Interfaces:**
- Consumes: `TUTORIAL_DOMAIN_NAME` env var (injected by the composite action from `vars.TUTORIAL_DOMAIN_NAME`)
- Produces: exports `TUTORIAL_NAMESPACE`, `TUTORIAL_DOMAIN_NAME`, `TUTORIAL_GATEWAY`, and any other placeholder variables needed by tutorial scripts

- [ ] **Step 1: Audit all placeholders across tutorials**

  ```bash
  grep -roh '{[A-Z_]*}' docs/user/tutorials/0*.md | sort -u
  # Collect the full list of {PLACEHOLDER} patterns to map
  ```

- [ ] **Step 2: Write `substitutions.sh`**

  One export per placeholder variable. Example:

  ```bash
  #!/usr/bin/env bash
  # Test values for tutorial placeholder variables.
  # TUTORIAL_DOMAIN_NAME must be set in the environment (GitHub Actions var).
  require_vars TUTORIAL_DOMAIN_NAME

  export TUTORIAL_NAMESPACE="tutorial-test"
  export TUTORIAL_GATEWAY="kyma-system/kyma-gateway"
  # add one line per placeholder found in step 1
  ```

- [ ] **Step 3: Update extractor placeholder mapping**

  The extractor must replace each `{PLACEHOLDER}` with its corresponding `$VAR` name using a fixed mapping table (e.g. `{NAMESPACE_NAME}` → `$TUTORIAL_NAMESPACE`, `{YOUR_DOMAIN_NAME}` → `$TUTORIAL_DOMAIN_NAME`). Any unrecognised placeholder must cause the extractor to print a warning and exit non-zero so it is never silently passed through.

- [ ] **Step 4: Re-generate all tutorial scripts**

  ```bash
  for f in docs/user/tutorials/0*.md; do
    python3 hack/ci/tutorials/extract-code-blocks.py "$f"
  done
  grep -r '{' hack/ci/tutorials/*.sh && echo "WARN: unresolved placeholders remain" || echo "OK"
  ```

- [ ] **Step 5: Commit**

  ```bash
  git add hack/ci/tutorials/substitutions.sh hack/ci/tutorials/*.sh hack/ci/tutorials/extract-code-blocks.py
  git commit -m "feat: add placeholder substitutions and re-generate tutorial scripts"
  ```

---

## Task 3: Tutorial runner script

**Files:**
- Create: `hack/ci/tutorials/run-tutorial.sh`

**Interfaces:**
- Consumes: `$1` = path to a generated tutorial `.sh`; sources `substitutions.sh` then `<stem>.override.sh` if it exists; requires `KUBECONFIG` and `TUTORIAL_DOMAIN_NAME` in env
- Produces: exit code 0 on success, non-zero on failure; stdout/stderr streamed to the CI log

- [ ] **Step 1: Write `run-tutorial.sh`**

  ```bash
  #!/usr/bin/env bash
  set -euo pipefail
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "${script_dir}/../common.sh"

  require_positional tutorial_script "$1"
  require_vars KUBECONFIG TUTORIAL_DOMAIN_NAME
  [[ -f "$tutorial_script" ]] || { echo "Tutorial script not found: $tutorial_script"; exit 1; }

  source "${script_dir}/substitutions.sh"

  stem="$(basename "$tutorial_script" .sh)"
  override="${script_dir}/${stem}.override.sh"

  start_group "Running tutorial: ${stem}"
  source "$tutorial_script"
  [[ -f "$override" ]] && source "$override"
  run_all_steps
  end_group
  ```

  > The generated script's final line is guarded by `[[ "${BASH_SOURCE[0]}" == "$0" ]]` (added in Task 1), so sourcing it only defines the step functions without executing them.

- [ ] **Step 2: Verify locally (dry run)**

  ```bash
  export KUBECONFIG=/dev/null TUTORIAL_DOMAIN_NAME=tutorial.example.com
  bash hack/ci/tutorials/run-tutorial.sh hack/ci/tutorials/01-10-external-authorization-provider.sh
  # Expect: fails on kubectl (no real cluster) but substitutions load and env var validation passes
  ```

- [ ] **Step 3: Verify override loading**

  ```bash
  # Create a temporary override that redefines step_1
  cat > /tmp/test.override.sh <<'EOF'
  step_1() { echo "overridden step_1"; }
  EOF
  cp /tmp/test.override.sh hack/ci/tutorials/01-10-external-authorization-provider.override.sh
  bash hack/ci/tutorials/run-tutorial.sh hack/ci/tutorials/01-10-external-authorization-provider.sh 2>&1 | grep "overridden step_1"
  rm hack/ci/tutorials/01-10-external-authorization-provider.override.sh
  ```

- [ ] **Step 5: Commit**

  ```bash
  git add hack/ci/tutorials/run-tutorial.sh
  git commit -m "feat: add tutorial runner with step-function override support"
  ```

---

## Task 4: PR sync check

**Files:**
- Create: `hack/ci/tutorials/check-tutorial-sync.sh`
- Modify: `.github/workflows/pull-request.yaml`

**Interfaces:**
- Consumes: `$GITHUB_BASE_REF` (set by GitHub Actions on PRs); uses `git diff --name-only origin/$GITHUB_BASE_REF...HEAD`
- Produces: exit code 0 if in sync, non-zero with a descriptive message listing which `.sh` files need updating

- [ ] **Step 1: Write `check-tutorial-sync.sh`**

  ```bash
  #!/usr/bin/env bash
  set -euo pipefail
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  tutorial_dir="$(cd "${script_dir}/../../../docs/user/tutorials" && pwd)"

  base="${GITHUB_BASE_REF:-main}"
  changed_files=$(git diff --name-only "origin/${base}...HEAD")

  failed=false
  while IFS= read -r md_file; do
    stem="$(basename "$md_file" .md)"
    sh_file="hack/ci/tutorials/${stem}.sh"
    if ! echo "$changed_files" | grep -qF "$sh_file"; then
      echo "ERROR: $md_file was modified but $sh_file was not updated in this PR."
      echo "       Re-generate with: python3 hack/ci/tutorials/extract-code-blocks.py $md_file"
      echo "       Then review and adjust the generated script as needed."
      failed=true
    fi
  done < <(echo "$changed_files" | grep '^docs/user/tutorials/.*\.md$')

  [[ "$failed" == "true" ]] && exit 1 || echo "Tutorial sync check passed."
  ```

- [ ] **Step 2: Add job to `pull-request.yaml`**

  Add a new job (no cluster needed, `ubuntu-latest`, no environment gate):

  ```yaml
  tutorial-sync-check:
    name: Tutorial sync check
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
        with:
          fetch-depth: 0
      - name: Check tutorial/script sync
        run: bash hack/ci/tutorials/check-tutorial-sync.sh
  ```

- [ ] **Step 3: Verify locally**

  ```bash
  # Simulate a changed .md with no corresponding .sh change
  GITHUB_BASE_REF=main bash hack/ci/tutorials/check-tutorial-sync.sh
  # Expect: passes on a clean branch; fails if you stage a .md change without the .sh
  ```

- [ ] **Step 4: Commit**

  ```bash
  git add hack/ci/tutorials/check-tutorial-sync.sh .github/workflows/pull-request.yaml
  git commit -m "feat: add PR check for tutorial/script sync"
  ```

---

## Task 5: Composite GitHub Action

**Files:**
- Create: `.github/actions/tutorial-test-gardener/action.yaml`

**Interfaces:**
- Consumes inputs: `gardener_secret`, `gardener_project_name`, `gardener_configuration`, `tutorial_script` (repo-relative path to the `.sh`), `tutorial_domain_name`
- Produces: cluster artifacts uploaded to Actions artifacts; exits non-zero if tutorial fails

- [ ] **Step 1: Write `action.yaml`**

  Model directly on `.github/actions/e2e-test-gardener/action.yaml`. Replace the "Run e2e tests" step with:

  ```yaml
  - name: Run tutorial
    shell: bash
    env:
      KUBECONFIG: "${{ github.workspace }}/${{ env.CLUSTER_NAME }}_kubeconfig.yaml"
      TUTORIAL_DOMAIN_NAME: ${{ inputs.tutorial_domain_name }}
      GATEWAY: ${{ inputs.gateway }}
    run: |
      bash "${{ github.workspace }}/${{ inputs.tutorial_script }}"
  ```

  Add a setup-helm step before the tutorial run (needed by tutorials that call `helm`):

  ```yaml
  - name: Set up Helm
    uses: azure/setup-helm@v4
  ```

  Keep: Generate cluster name, Prepare gardener kubeconfig, Provision cluster, Gather cluster artifacts, Upload artifacts, Deprovision cluster steps — identical to `e2e-test-gardener`.

  Remove: `manager_image`, `operator_version`, `test_make_target`, `test_ip_family` inputs — not needed for tutorials.

  Add inputs: `tutorial_script`, `namespace`, `domain_name`, `gateway`.

- [ ] **Step 2: Verify action.yaml is valid YAML**

  ```bash
  python3 -c "import yaml, sys; yaml.safe_load(open('.github/actions/tutorial-test-gardener/action.yaml'))" && echo OK
  ```

- [ ] **Step 3: Commit**

  ```bash
  git add .github/actions/tutorial-test-gardener/
  git commit -m "feat: add tutorial-test-gardener composite action"
  ```

---

## Task 6: Scheduled workflow

**Files:**
- Create: `.github/workflows/schedule-tutorials.yaml`

**Interfaces:**
- Consumes: `secrets.GARDENER_TOKEN`, `vars.GARDENER_PROJECT_NAME`, `vars.TUTORIAL_DOMAIN_NAME`
- Produces: weekly full-matrix run + PR run for only modified tutorials; no Slack notification

- [ ] **Step 1: Write `schedule-tutorials.yaml`**

  Two top-level `on:` triggers and two jobs (weekly full matrix, PR dynamic matrix):

  ```yaml
  name: Tutorial Tests

  permissions:
    contents: read

  on:
    schedule:
      - cron: '0 5 * * 1'   # weekly, Monday 06:00 CET
    pull_request:
      paths:
        - 'docs/user/tutorials/**.md'

  concurrency:
    group: ${{ github.workflow }}-${{ github.ref_name }}
    cancel-in-progress: true

  jobs:
    # --- Weekly: run all tutorials ---
    tutorial-test-scheduled:
      name: Tutorial - ${{ matrix.tutorial }}
      if: github.event_name == 'schedule'
      environment:
        name: e2e
        deployment: false
      runs-on: ubuntu-latest
      strategy:
        fail-fast: false
        matrix:
          tutorial:
            - 01-10-external-authorization-provider
            - 01-20-expose-httbin-gateway-api
            - 01-30-expose-tcp-gateway-api
            - 01-40-enable-sidecar-injection
            - 01-50-send-requests-using-egress
            - 01-55-send-requests-using-egress-and-mtls
            - 01-60-enable-nlb-load-balancer
            - 01-65-expose-workload-vs
            - 01-70-enable-outlier-detection-metrics
      steps:
        - uses: actions/checkout@v7
        - uses: ./.github/actions/tutorial-test-gardener
          with:
            gardener_secret: ${{ secrets.GARDENER_TOKEN }}
            gardener_project_name: ${{ vars.GARDENER_PROJECT_NAME }}
            gardener_configuration: aws-ipv4
            tutorial_script: hack/ci/tutorials/${{ matrix.tutorial }}.sh
            tutorial_domain_name: ${{ vars.TUTORIAL_DOMAIN_NAME }}

    # --- PR: run only modified tutorials ---
    detect-changed-tutorials:
      name: Detect changed tutorials
      if: github.event_name == 'pull_request'
      runs-on: ubuntu-latest
      outputs:
        tutorials: ${{ steps.diff.outputs.tutorials }}
      steps:
        - uses: actions/checkout@v7
          with:
            fetch-depth: 0
        - id: diff
          name: Build tutorial list from changed files
          run: |
            tutorials=$(git diff --name-only origin/${{ github.base_ref }}...HEAD \
              | grep '^docs/user/tutorials/.*\.md$' \
              | sed 's|docs/user/tutorials/||; s|\.md$||' \
              | jq -Rnc '[inputs]')
            echo "tutorials=${tutorials}" >> $GITHUB_OUTPUT

    tutorial-test-pr:
      name: Tutorial (PR) - ${{ matrix.tutorial }}
      if: github.event_name == 'pull_request' && needs.detect-changed-tutorials.outputs.tutorials != '[]'
      needs: detect-changed-tutorials
      environment:
        name: e2e
        deployment: false
      runs-on: ubuntu-latest
      strategy:
        fail-fast: false
        matrix:
          tutorial: ${{ fromJson(needs.detect-changed-tutorials.outputs.tutorials) }}
      steps:
        - uses: actions/checkout@v7
        - uses: ./.github/actions/tutorial-test-gardener
          with:
            gardener_secret: ${{ secrets.GARDENER_TOKEN }}
            gardener_project_name: ${{ vars.GARDENER_PROJECT_NAME }}
            gardener_configuration: aws-ipv4
            tutorial_script: hack/ci/tutorials/${{ matrix.tutorial }}.sh
            tutorial_domain_name: ${{ vars.TUTORIAL_DOMAIN_NAME }}
  ```

- [ ] **Step 2: Verify workflow YAML**

  ```bash
  python3 -c "import yaml, sys; yaml.safe_load(open('.github/workflows/schedule-tutorials.yaml'))" && echo OK
  ```

- [ ] **Step 3: Commit**

  ```bash
  git add .github/workflows/schedule-tutorials.yaml
  git commit -m "feat: add tutorial testing workflow (weekly + PR triggers)"
  ```

---

## Task 7: Fork smoke test

**Pre-conditions:** Fork exists on GitHub; `GARDENER_TOKEN` secret, `GARDENER_PROJECT_NAME` and `TUTORIAL_DOMAIN_NAME` variables configured on the fork; `e2e` environment created with no approval gate.

- [ ] **Step 1: Push branch to fork**

  ```bash
  git remote add fork https://github.com/<your-handle>/istio.git
  git push fork HEAD:tutorial-testing
  ```

- [ ] **Step 2: Trigger workflow manually**

  On the fork's Actions tab → "Schedule Tutorial Tests" → Run workflow → select branch `tutorial-testing`. Run with a single tutorial first by temporarily setting `matrix.tutorial` to only `01-10-external-authorization-provider`.

- [ ] **Step 3: Verify**

  - Cluster appears in Gardener project during the run
  - Tutorial commands execute against the cluster
  - Cluster is deprovisioned after the job (check Gardener dashboard)
  - Artifacts are uploaded (cluster logs, shoot YAML)

- [ ] **Step 4: Expand matrix and re-run**

  Once 01-10 passes, restore the full matrix and trigger again. Note which tutorials pass/fail for follow-up.

- [ ] **Step 5: Open PR to upstream**

  Once all tutorials pass (or failures are understood), open a PR from the fork branch to `kyma-project/istio:main`.
