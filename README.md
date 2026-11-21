<div align="center">
  <img src="https://managed-agents.colab.duke.edu/favicon.svg" alt="PolyAgent icon" width="80" height="80" />
  <h1>PolyAgent</h1>
  <p><strong>Build an agent once. Use it from the console, CLI, or your application.</strong></p>
  <h2><a href="https://managed-agents.colab.duke.edu/">🚀 Open PolyAgent →</a></h2>
  <p><a href="https://duke-ece.github.io/managed-agents-docs/">📖 Read the documentation →</a></p>
</div>

PolyAgent is an agent platform developed across the [Duke-ECE](https://github.com/Duke-ECE) repositories. Users configure reusable agents, start conversations, stream replies, and return to saved sessions. Applications can call hosted agents through an HTTP API or TypeScript SDK. Agent tools run in isolated sandboxes when the sandbox integration is enabled.

[![PolyAgent product homepage showing hosted agents and the server-side API](assets/polyagent-home.png)](https://managed-agents.colab.duke.edu/)

## Explore PolyAgent

| Start here | What you can do |
| --- | --- |
| [Web console](https://managed-agents.colab.duke.edu/) | Sign in, configure agents, chat, and create API keys. |
| [Documentation](https://duke-ece.github.io/managed-agents-docs/) | Find setup guides, API examples, and architecture references. |
| [Developer guide](https://duke-ece.github.io/managed-agents-docs/developers/) | Connect an application to a hosted agent. |
| [API guide](https://duke-ece.github.io/managed-agents-docs/developers/api-guide) | Create sessions and consume streamed responses. |
| [CLI](https://github.com/Duke-ECE/managed-agents-cli) | Manage agents and conversations from a terminal. |
| [TypeScript SDK](https://github.com/Duke-ECE/managed-agents-sdk) | Call the chat API from a Node.js server. |

The platform currently runs as a project deployment. Access to the platform-provided LLM is limited to approved accounts; you can configure an agent with your own compatible LLM provider.

## Quick start

1. [Sign in to the console](https://managed-agents.colab.duke.edu/console) and create or clone an agent. Set its instructions, model, and allowed tools. The built-in assistant requires platform LLM access; otherwise configure an agent with your own provider key.
2. Open [Chat](https://managed-agents.colab.duke.edu/chat), select your agent, and send a message. PolyAgent saves the session so you can continue it later.
3. To use the agent from an application, create an [API key](https://managed-agents.colab.duke.edu/keys), keep it on your server, and follow the [developer guide](https://duke-ece.github.io/managed-agents-docs/developers/) to start a session and stream replies.

## Set up a development workspace

This repository also provides an entry point for coding agents working across the PolyAgent repositories. The [workspace AGENTS.md template](workspace/root/AGENTS.md) explains how the services and repositories fit together; [workspace initialization](workspace/README.md) explains how to install it, the root Makefile, and its supporting script in a workspace whose root is not a Git repository. This repository's own [AGENTS.md](AGENTS.md) is only for maintaining the bootstrap files.

Give your coding agent this prompt:

```text
Create a PolyAgent workspace directory whose root is not a Git repository. Clone https://github.com/L-Rocket/PolyAgent.git into <workspace>/.bootstrap/polyagent. Read .bootstrap/polyagent/workspace/root/AGENTS.md and .bootstrap/polyagent/workspace/README.md, then run .bootstrap/polyagent/scripts/init-workspace.sh to clone the 13 repositories available without GitHub credentials, including CubeSandbox. If I provide access to the four restricted repositories, rerun the script with --include-restricted. Verify the installed root AGENTS.md, Makefile, scripts/git-status.py, each child repository's remote and branch, and the .agents/skills/ symlinks. Do not commit child repositories, credentials, or machine-specific configuration. When finished, report the initialization results and any repository access I need to provide.
```

The [default manifest](workspace/repos.tsv) lists 13 repositories that can be cloned without credentials, including upstream CubeSandbox. Four more are recorded in the [restricted manifest](workspace/repos.restricted.tsv); authorized team members can add them with `--include-restricted`. Additional repositories can be listed locally.

## Architecture

![PolyAgent target architecture with a platform cluster and a dedicated CubeSandbox cluster](https://raw.githubusercontent.com/Duke-ECE/managed-agents-design/main/requirements/0005-cubesandbox-integration/two-clusters.png)

This [two-cluster architecture diagram](https://github.com/Duke-ECE/managed-agents-design/blob/main/requirements/0005-cubesandbox-integration/two-clusters.png) shows the target separation between the platform services and CubeSandbox session MicroVMs. It uses the project's earlier “Managed Agents” name. The current CubeSandbox integration is a bounded development pilot; the dedicated multi-node Cube cluster and durable sandbox lifecycle shown here are **not yet generally available**. See the [architecture guide](https://duke-ece.github.io/managed-agents-docs/architecture) for the implemented request flow and the [CubeSandbox design](https://github.com/Duke-ECE/managed-agents-design/tree/main/requirements/0005-cubesandbox-integration) for rollout status.

## Main repositories

PolyAgent is a collection of independently versioned repositories. Existing technical repository names remain `managed-agents-*` for compatibility.

| Repository | Role |
| --- | --- |
| [Frontend](https://github.com/Duke-ECE/managed-agents-frontend) | React console and chat interface. |
| [Agent runtime](https://github.com/Duke-ECE/agent-runtime) | Runs agent sessions and streams model responses. |
| [Session manager](https://github.com/Duke-ECE/session-manager) | Owns durable sessions, transcripts, and access checks. |
| [Sandbox manager](https://github.com/Duke-ECE/sandbox-manager) | Manages isolated tool execution. |
| [CLI](https://github.com/Duke-ECE/managed-agents-cli) | Terminal client. |
| [TypeScript SDK](https://github.com/Duke-ECE/managed-agents-sdk) | Server-side application integration. |
| [SDK example](https://github.com/Duke-ECE/managed-agents-sdk-example) | Minimal integration example. |
| [Protobuf contracts](https://github.com/Duke-ECE/protos) | Shared gRPC service definitions. |
| [Documentation](https://github.com/Duke-ECE/managed-agents-docs) | Developer and operator guides. |
| [Design records](https://github.com/Duke-ECE/managed-agents-design) | Cross-repository requirements and decisions. |

The API gateway and mobile application repositories require separate access. They appear in the restricted workspace manifest, while this public source index links only to public repositories. Each repository retains its own license and visibility; this repository's MIT license does not change them.

## Learn more

- [Developer quick start](https://duke-ece.github.io/managed-agents-docs/developers/)
- [API reference and examples](https://duke-ece.github.io/managed-agents-docs/developers/api-guide)
- [Platform architecture](https://duke-ece.github.io/managed-agents-docs/architecture)
- [Deployment and operations](https://duke-ece.github.io/managed-agents-docs/deployment)
- [Product changelog](https://duke-ece.github.io/managed-agents-docs/changelog)

## License

This overview repository is licensed under the [MIT License](LICENSE). Each linked repository retains its own license and visibility.
