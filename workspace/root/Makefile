# Local preview shortcuts for this multi-repository workspace.
# Run from the workspace root. Each command stays in the owning repository.

FRONTEND_DIR := managed-agents-frontend
DOCS_DIR := managed-agents-docs
FRONTEND_PORT ?= 5173
DOCS_PORT ?= 5174

.PHONY: help preview preview-ui preview-auth preview-docs preview-all auth-env install-frontend install-docs check-node
.PHONY: git-status

help:
	@printf 'Local previews (run from the workspace root):\n'
	@printf '  make preview          Frontend with sample data, no login (http://localhost:%s/login)\n' '$(FRONTEND_PORT)'
	@printf '  make preview-auth     Frontend with real login (http://localhost:5173/login)\n'
	@printf '  make preview-docs     Documentation (http://localhost:%s/managed-agents-docs/)\n' '$(DOCS_PORT)'
	@printf '  make preview-all      Frontend sample preview and docs together\n'
	@printf '  make auth-env         Fetch browser-safe auth variables into frontend .env.local\n'
	@printf '  make install-frontend / install-docs  Install dependencies with npm ci\n'
	@printf '  make git-status       Show uncommitted files and local-only commits across repositories\n'
	@printf '\nUse FRONTEND_PORT=... or DOCS_PORT=... to change sample-preview ports.\n'

git-status:
	@python3 scripts/git-status.py

check-node:
	@node -e 'if (Number(process.versions.node.split(".")[0]) < 22) { console.error("Node.js 22 or newer is required."); process.exit(1) }'

install-frontend: check-node
	@cd $(FRONTEND_DIR) && npm ci

install-docs: check-node
	@cd $(DOCS_DIR) && npm ci

preview: preview-ui

preview-ui: check-node
	@printf 'Frontend sample preview: http://localhost:%s/login (click Enter local preview)\n' '$(FRONTEND_PORT)'
	@cd $(FRONTEND_DIR) && VITE_LOCAL_PREVIEW=true npm run dev -- --host localhost --port $(FRONTEND_PORT) --strictPort

preview-auth: check-node
	@if [ '$(FRONTEND_PORT)' != '5173' ]; then \
		printf 'Real login requires FRONTEND_PORT=5173 (the configured OAuth return URL).\n' >&2; exit 1; \
	fi
	@if [ ! -f $(FRONTEND_DIR)/.env.local ] || \
		! grep -Eq '^VITE_SUPABASE_URL=.+$$' $(FRONTEND_DIR)/.env.local || \
		! grep -Eq '^VITE_SUPABASE_ANON_KEY=.+$$' $(FRONTEND_DIR)/.env.local; then \
		printf 'Missing frontend auth variables. Run make auth-env first.\n' >&2; exit 1; \
	fi
	@printf 'Frontend real-login preview: http://localhost:5173/login\n'
	@cd $(FRONTEND_DIR) && VITE_LOCAL_PREVIEW=false npm run dev -- --host localhost --port 5173 --strictPort

preview-docs: check-node
	@printf 'Documentation preview: http://localhost:%s/managed-agents-docs/\n' '$(DOCS_PORT)'
	@cd $(DOCS_DIR) && npm run docs:dev -- --host localhost --port $(DOCS_PORT) --strictPort

preview-all:
	@$(MAKE) -j2 preview-ui preview-docs

auth-env:
	@if [ -e $(FRONTEND_DIR)/.env.local ]; then \
		printf 'Frontend .env.local already exists; leaving it unchanged.\n' >&2; exit 1; \
	fi
	@command -v gh >/dev/null || { printf 'Install and authenticate GitHub CLI (gh) first.\n' >&2; exit 1; }
	@umask 077; tmp=$$(mktemp $(FRONTEND_DIR)/.env.local.tmp.XXXXXX) || exit 1; \
		trap 'rm -f "$$tmp"' EXIT; \
		url=$$(gh variable get VITE_SUPABASE_URL --repo Duke-ECE/managed-agents-frontend) || exit 1; \
		key=$$(gh variable get VITE_SUPABASE_ANON_KEY --repo Duke-ECE/managed-agents-frontend) || exit 1; \
		if [ -z "$$url" ] || [ -z "$$key" ]; then printf 'GitHub auth variables are empty.\n' >&2; exit 1; fi; \
		printf 'VITE_SUPABASE_URL=%s\nVITE_SUPABASE_ANON_KEY=%s\n' "$$url" "$$key" > "$$tmp"; \
		mv "$$tmp" $(FRONTEND_DIR)/.env.local; \
		printf 'Created frontend .env.local. Run make preview-auth.\n'
