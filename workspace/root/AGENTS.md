# AGENTS.md — PolyAgent multi-repository workspace

This file is for coding agents. Start here even if you know nothing about PolyAgent. The workspace root is **not a Git repository**; every child project has its own `.git`, remote, dependencies, CI, and versioning. The public bootstrap checkout lives in `.bootstrap/polyagent/` and installs this file, the root `Makefile`, and `scripts/git-status.py`.

## Product and working model

**PolyAgent** is the user-facing name. Use it in UI text, page titles, documentation, and other copy. Existing technical identifiers such as repository names, Go module paths, npm packages, CLI commands, API routes, environment variables, and container images remain unchanged unless a separate compatibility migration is planned.

Work inside **one repository at a time**. There is no workspace-wide build, root package manager, or lockstep release. For a change spanning repositories, use a requirement in `managed-agents-design/` to coordinate the contract and delivery. Do not replace released cross-repository dependencies with local filesystem paths.

## Initialize and inspect

The bootstrap instructions are in `.bootstrap/polyagent/workspace/README.md`. Run `.bootstrap/polyagent/scripts/init-workspace.sh` from this root to install missing workspace files, clone the 13 repositories available without credentials, verify remotes and branches, and create local `.agents/skills/` links. The script does not pull or alter existing child checkouts.

The default manifest is `.bootstrap/polyagent/workspace/repos.tsv`. Four more known repositories requiring GitHub authorization are listed in `.bootstrap/polyagent/workspace/repos.restricted.tsv`; after access is configured, rerun the script with `--include-restricted`. Additional personal checkouts can go in the ignored `.bootstrap/polyagent/workspace/repos.local.tsv`. If access is missing, report it; do not substitute a different repository or claim a complete checkout. Use the manifests' default branches for a new workspace, not feature branches or temporary worktrees from another machine. The bootstrap repository, child repositories, and `.agents/skills/` are separate from this unversioned root.

## Platform request flow

```text
Browser (managed-agents-frontend) / CLI / SDK application
  → authenticated HTTP API gateway
      ├── session-manager → durable sessions, transcripts, ownership checks
      └── agent-runtime → live agent and streamed model events
            ├── published pi agent libraries
            ├── session-manager → completed turns and hydration
            └── isolated sandbox execution when enabled
```

The web console uses Supabase authentication. The API gateway verifies the caller and translates HTTP/streaming requests into internal gRPC calls. `session-manager` is the durable source of truth for sessions and messages; `agent-runtime` keeps live agents in memory and can recreate one from a stored transcript. Its model endpoint is OpenAI-compatible. Tool execution runs outside the runtime through sandbox services. The CubeSandbox integration is a bounded development pilot; check the current service guides and requirement delivery record before describing it as generally deployed.

The [public architecture guide](https://duke-ece.github.io/managed-agents-docs/architecture) explains the implemented request flow. Diagrams explicitly labeled proposed or target are not evidence of a completed rollout.

## Repository map

| Directory or component | Role | First checks |
| --- | --- | --- |
| `managed-agents-frontend/` | React web console for login, agent configuration, chat, sessions, and access controls. | Its `AGENTS.md`/README; `npm ci`, `npm run build`. |
| `managed-agents-backend/` (access-controlled) | Authenticated HTTP and SSE gateway; resolves agent templates and calls session/runtime services. | Its own `AGENTS.md`; Go build, vet, test. |
| `session-manager/` | Go gRPC service for durable session records and transcripts, including user ownership. | README; `go build ./...`, `go vet ./...`, `go test ./...`. |
| `agent-runtime/` | TypeScript gRPC service hosting pi agents and streaming chat; persists completed turns. | README; `npm ci`, `npm run build`, `npm test`. |
| `sandbox-manager/` | Go service for isolated tool execution and sandbox lifecycle. | README; Go build, vet, test. |
| `protos/` | Shared gRPC contracts and committed generated Go code. | `buf lint`, `buf generate`; inspect consumer pins. |
| `managed-agents-cli/` | Standalone Go client for user-scoped operations. | Its `AGENTS.md`; Go build, vet, test. |
| `managed-agents-mobile/` (access-controlled) | Mobile client. | Its own `AGENTS.md` and README. |
| `managed-agents-sdk/` | TypeScript application SDK. | Its README and package scripts. |
| `managed-agents-sdk-example/` | Example application using the SDK. | Its README and package scripts. |
| `managed-agents-docs/` | VitePress developer, architecture, service, and operations guides. | `npm ci`, `npm run docs:build`. |
| `managed-agents-design/` | Cross-repository requirements, decisions, and delivery records. | Relevant `requirements/<id>/` directory. |
| `standards/` | Shared engineering conventions and service templates. | Read before changing a service's structure. |
| `pi/` | Upstream agent-harness reference checkout; platform builds consume published packages pinned in `agent-runtime`. | Read `pi/AGENTS.md`; do not run its full build or test outside its documented workflow. |
| `CubeSandbox/` | Upstream reference source for the CubeSandbox integration; independent of PolyAgent releases. | Read its `AGENTS.md` before changing or building it. |
| `my-go-layout/` (access-controlled) | Personal Go layout reference, independent of the platform. | Read its own README; do not treat it as a deployment unit. |
| `teamSkills/` (access-controlled) | Team operations and onboarding skills. | The bootstrap script links matching skill directories into `.agents/skills/`. |

The 17 entries across both manifests are repositories, not one composite source tree. The bootstrap checkout is an eighteenth, separate repository. Temporary preview and release worktrees are extra checkouts of existing repositories and are intentionally not in either manifest. Read the owning repository's guide and license before changing or reusing its code.

## Service boundaries worth preserving

### Web console and API

The frontend owns interaction state and presentation. It talks to the HTTP API for agent templates, sessions, transcripts, account information, and streamed chat; it does not call internal gRPC services or read server-side keys. Its local sample preview is intentionally separate from real authentication and backend behavior. UI changes should be checked at both desktop and mobile widths, then built with the repository's own command.

The API gateway owns the browser-facing authentication boundary. It verifies a user token, derives identity from that token, and translates JSON and SSE to internal calls. It creates durable session records through `session-manager` before starting their live runtime state. If the runtime loses an in-memory session, the gateway can resume it under the same id after checking durable ownership and status. A failed durable create must remain visible as an error. Agent templates and any platform-provided LLM configuration are resolved server-side; browser code must never receive service credentials.

### Runtime and sessions

The runtime owns the live agent loop and streaming model events, not long-term storage. Each session uses published pi libraries and an OpenAI-compatible endpoint. A completed chat turn is written through to `session-manager`; interrupted or failed turns should not be presented as durable history. Resume must hydrate from the stored transcript without changing the session's established model or persona unexpectedly. Read the runtime's own guide before changing prompt, model, tool, or hydration precedence.

`session-manager` owns session lifecycle, transcripts, pagination, and permission checks. User-scoped reads and writes are owner-scoped; privileged service paths have separate authentication. An ended session remains readable but cannot accept new turns. Database tables and migrations are maintained by the owning service, and session data should not be accessed directly from the browser. Use the service's Go tests, including its fake storage and gRPC seams, when changing those boundaries.

### Sandbox execution

`sandbox-manager` owns sandbox resources and execution boundaries. Older protocol packages cover single-use Kubernetes sandboxes; the newer CubeSandbox session-workspace path is a development pilot. The `CubeSandbox/` checkout is upstream reference source, not a PolyAgent service release. Keep these modes distinct in code and documentation. A tool call's execution and cleanup rules belong to the sandbox service, while the runtime only calls the relevant contract. Consult the current requirement and service guide for deployment status before changing rollout assumptions.

## Contracts and state

- `protos/` is the single source of truth for internal gRPC interfaces. Change a `.proto` and generated `gen/go/` together; never edit generated code by hand. Breaking changes use a new protocol package according to that repository's policy.
- Go consumers pin released proto tags. `agent-runtime` keeps vendored proto files and refreshes them through its documented `npm run sync-proto` command after a release. Do not import neighboring checkouts directly.
- Chat stream events cross runtime gRPC, gateway SSE, and frontend rendering. Keep event names and payloads aligned across those owners.
- Session records and transcripts belong to `session-manager`; runtime memory is a recreatable live cache. Completed turns are written through. A missing live session can be resumed from durable history subject to ownership and status checks.
- Database migrations live with the owning service. Multiple repositories use one database project, so migration filenames use timestamped versions rather than short counters.

## Root-level convenience commands

The root `Makefile` is a local wrapper. It runs commands inside the owning frontend or docs repository and does not build the platform as one project. Node.js 22 or newer is required for the previews.

| Command | Purpose |
| --- | --- |
| `make help` | Show available shortcuts. |
| `make git-status` | Read-only scan of child repositories and worktrees; uses Python 3 and locally cached Git refs. |
| `make install-frontend`, `make install-docs` | Run `npm ci` in the respective repository. |
| `make preview` | Start a frontend sample-data preview at `http://localhost:5173/login`. |
| `make preview-auth` | Start the frontend with real login after browser-safe local auth variables are configured. |
| `make preview-docs` | Start VitePress at `http://localhost:5174/managed-agents-docs/`. |
| `make preview-all` | Start sample frontend and docs previews together. |
| `make auth-env` | Fetch browser-safe frontend variables with authenticated `gh` into an ignored `.env.local`; refuses to overwrite an existing file. |

The frontend preview port can be set with `FRONTEND_PORT` and the docs port with `DOCS_PORT`. Real OAuth login requires the configured `localhost:5173` return origin. The sample preview is for interface review and does not verify real authentication or backend behavior. Do not put a service-role or other secret key in a frontend `VITE_*` variable.

## Change and documentation workflow

1. Read the target repository's `AGENTS.md`, README, and relevant code. Use its own build and test commands. This workspace map is an orientation, not a replacement for current repository instructions.
2. For work spanning repositories, find or create one requirement in `managed-agents-design/requirements/`. Keep its design, decision log, and delivery record together. Implement and verify each repository independently.
3. For interface changes, update `protos/` first, release the contract, then bump each consumer. Record the version and verification in the requirement's delivery record.
4. Review `managed-agents-docs/` whenever user workflows, API contracts, setup, operations, or rollout status changes. Build the docs site after editing it. Distinguish an implemented feature from a pilot or proposed design.
5. Keep service code, SQL migrations, manifests, and tests in their owning repositories. Never commit credentials, local `.env` files, machine-specific configuration, or generated `.agents/skills/` links.

If a task matches an installed skill, load it before working. Skill links are local workspace setup; the bootstrap script creates them from its bundled skills and from an authorized `teamSkills/` checkout when present.
