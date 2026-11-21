# AGENTS.md — PolyAgent workspace

This file is the public workspace guide for **PolyAgent**, a platform for configuring agents, chatting with them, and using them through a web console, CLI, or API/SDK. The bootstrap repository lives at `.bootstrap/polyagent/`; its initialization script copies this guide to the workspace root. The workspace root itself is **not a Git repository**. Each child project is an independent Git repository with its own history, dependencies, CI, and releases. There is no root-level build or shared lockfile.

This guide describes the relationships between repositories. Read a child repository's own `AGENTS.md` and README before changing its code. The [architecture documentation](https://duke-ece.github.io/managed-agents-docs/architecture) has more detail about the implemented system.

## Initialize the workspace

1. Read `.bootstrap/polyagent/workspace/README.md`, then run `.bootstrap/polyagent/scripts/init-workspace.sh` from the workspace root.
2. The script copies this guide to the workspace root, clones public repositories from `.bootstrap/polyagent/workspace/repos.tsv`, checks existing origins and branches, and creates local `.agents/skills/` symlinks. It does not pull or modify existing child checkouts.
3. To reproduce a team member's complete workspace, add repositories you are authorized to access to the ignored `.bootstrap/polyagent/workspace/repos.local.tsv` and rerun the script. The public list alone cannot clone private or personal repositories. Report missing access rather than substituting a different repository.
4. Review the script's results. Work in one child repository at a time; for a cross-repository change, read the relevant requirement in `managed-agents-design/` first.

## How the platform fits together

```text
Web console / CLI / SDK client
    → authenticated HTTP API gateway
    ├── session-manager → durable session records and transcripts
    └── agent-runtime → model streaming and agent behavior
                         ├── pi agent libraries
                         ├── session-manager → completed turns
                         └── sandbox execution → isolated tools
```

The web console authenticates users, sends chat requests, and receives streamed responses. The API gateway verifies identity and translates HTTP requests into internal gRPC calls. `session-manager` owns durable sessions, transcripts, and access checks. `agent-runtime` hosts live sessions, calls an OpenAI-compatible model through the published pi libraries, streams events, and writes completed turns to `session-manager`. Sandbox execution is isolated from the runtime; the current CubeSandbox integration is a bounded development pilot, so consult the service documentation before assuming a specific tool-execution path is generally deployed. Supabase supplies authentication and database storage.

## Repository map

| Directory | Responsibility |
| --- | --- |
| `managed-agents-frontend/` | React web console: login, agents, chat, sessions, and account controls. |
| `agent-runtime/` | TypeScript gRPC service for live agents, model streaming, and transcript write-through. |
| `session-manager/` | Go gRPC service for durable sessions and transcripts, including ownership checks. |
| `sandbox-manager/` | Go service for isolated tool execution and sandbox lifecycle. |
| `protos/` | Shared gRPC contracts; generated consumers pin released versions. |
| `managed-agents-cli/` | Standalone Go command-line client. |
| `managed-agents-sdk/` | TypeScript SDK for application integrations. |
| `managed-agents-sdk-example/` | Example application using the SDK. |
| `managed-agents-docs/` | Developer, architecture, service, and operations documentation. |
| `managed-agents-design/` | Cross-repository requirements, decisions, and delivery records. |
| `standards/` | Engineering conventions and service templates. |
| `pi/` | Upstream agent-harness checkout for reference; platform builds use published packages pinned by `agent-runtime`. |

Some gateway, mobile, team operations, and personal repositories are outside the public manifest. Their owners control access. If they are added through `.bootstrap/polyagent/workspace/repos.local.tsv`, follow each repository's own guide; do not infer its internal behavior from this public overview.

## Cross-repository rules

- **Contracts:** Change `.proto` sources and generated code together in `protos/`. Consumers adopt a released tag or package version; do not replace a pinned dependency with a local path. The runtime keeps vendored proto copies through its documented sync command.
- **Session state:** Treat `session-manager` and its backing store as the durable source of truth. Live runtime sessions can be recreated from transcripts; do not assume runtime memory is durable.
- **Requirements:** A feature spanning repositories belongs in a requirement directory in `managed-agents-design/`. Record decisions and delivery evidence there. Code, migrations, and tests stay in their owning repositories.
- **Changes and checks:** Use the build and test commands documented by each child repository. Do not run one workspace-wide build or commit multiple repositories as if they were one project.
- **Product name:** Use **PolyAgent** in user-facing copy. Established technical identifiers such as repository names, package paths, API routes, and configuration keys stay unchanged unless a separate migration is planned.
- **Local files:** `.agents/skills/` holds generated symlinks. Child repositories and `.bootstrap/polyagent/workspace/repos.local.tsv` are local checkout state. Do not commit credentials, private keys, `.env` files, or machine-specific configuration.
