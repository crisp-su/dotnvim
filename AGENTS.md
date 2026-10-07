# AGENTS.md

Guidance for coding agents working in this repository.

## Repository scope

- This repo is a Nix flake that builds a Nixvim (Neovim) configuration.
- Primary languages are `Nix` and `Lua`.
- Flake entry point is `flake.nix`.
- Main module trees are `config/`, `options/`, `lib/`, `lua/`, `overlays/`, and `modules/`.

## External agent rules (Cursor/Copilot)

- No `.cursor/rules/`, `.cursorrules`, or `.github/copilot-instructions.md` files were found in this repo.
- If those files are added later, treat them as additional constraints and merge them into this guide.

## Environment and setup

- Preferred environment is `nix develop`.
- One-off command execution uses `nix develop -c <cmd>`.
- Dev shell tools (from `shell.nix`): `nil`, `statix`, `nixfmt`, `stylua`, `prettier`.
- Supported flake systems are `x86_64-linux` and `aarch64-linux`.

## Build commands

- Build default package: `nix build .#default`.
- Build explicit system package: `nix build .#packages.x86_64-linux.default`.
- Show available outputs: `nix flake show`.
- Build home-manager module consumers through downstream HM config (not directly from this flake).

## Run commands

- Run Neovim app: `nix run .#nvim`.
- Print generated `init.lua`: `nix run .#nixvim-print-init`.

## Lint and format commands

- Nix lint (all): `nix develop -c statix check .`.
- Nix lint (single file): `nix develop -c statix check config/tools/telescope.nix`.
- Nix format (all): `nix develop -c nixfmt .`.
- Nix format check (single file): `nix develop -c nixfmt --check flake.nix`.
- Lua format (all): `nix develop -c stylua .`.
- Lua format check (single file): `nix develop -c stylua --check lua/utils/root.lua`.
- Prettier check: `nix develop -c prettier --check .`.
- Prettier write: `nix develop -c prettier --write .`.

## Test and check commands

- Canonical validation: `nix flake check`.
- All systems: `nix flake check --all-systems`.
- Checks are defined in `flake/checks.nix` and include:
  - `checks.<system>.nvimBuild`
  - `checks.<system>.nvimStartup` (headless startup smoke test)
  - `checks.<system>.nixfmt`
  - `checks.<system>.prettier`
  - `checks.<system>.statix`
  - `checks.<system>.stylua`

## Single-test workflow (important)

- There is no unit-test runner with named tests.
- The closest equivalent to "run one test" is building one check attribute.
- Run one startup smoke check: `nix build .#checks.x86_64-linux.nvimStartup`.
- Run one formatting/lint check: `nix build .#checks.x86_64-linux.stylua` (or `statix`, `nixfmt`, `prettier`).
- Run one output build: `nix build .#packages.x86_64-linux.default`.
- For tight iteration, run single-file checks (`statix`, `nixfmt --check`, `stylua --check`) before full flake checks.

## Repository layout conventions

- `config/default.nix` auto-imports all `*.nix` files under `config/` except itself.
- `options/default.nix` auto-imports all `*.nix` files under `options/` except itself.
- `config/default.nix` exports Lua files from `lua/` via `extraFiles`.
- Files prefixed with `_` are intentionally excluded by auto-loading logic.
- Add new modules as standalone files in existing trees; avoid manual import wiring unless pattern changes.

## Nix style guidelines

- Use 2-space indentation and keep lines near 120 chars.
- Prefer explicit attr sets with trailing semicolons.
- Write package lists as `with pkgs; [ ... ];` instead of repeated `pkgs.xxx` entries.
- Keep function arg sets multiline and stable (commonly `{ config, lib, lib', pkgs, ... }:`).
- Keep `let ... in` blocks focused and short.
- Prefer `lib.mkIf` / `lib.mkMerge` over ad-hoc branching.
- Prefer deterministic ordering for attrs and lists (alphabetic or conceptual groups).
- Reuse `lib'` namespaces before adding duplicated helpers.
- Use `__raw` plus `/* lua */ '' ... ''` when embedding Lua callbacks in Nix.
- Follow existing plugin patterns under `plugins.<name>`.

## Lua style guidelines

- Formatting is governed by `.stylua.toml`: 2 spaces, width 120, auto-prefer single quotes.
- Use module pattern `local M = {}` ... `return M`.
- Keep `require(...)` at top-level unless lazy-loading is intentional.
- Use `utils.lazy_require(...)` for deferred optional modules.
- Keep functions focused; avoid deep nesting when possible.
- Add EmmyLua annotations for non-trivial APIs (`--- @param`, `--- @return`, `--- @class`, `--- @alias`).

## Imports and dependencies

- Nix imports should be relative and composable.
- In embedded Lua from Nix config, prefer global `Utils.<module>` provided by `config/luaset.nix`.
- In Lua modules, use `require('utils')` family consistently.
- Avoid hard-coding plugin internals when helper wrappers already exist.

## Types and option handling

- Prefer typed options with `lib.mkOption` and `lib.types.*` in Nix modules.
- For plugin options, follow patterns used in `options/plugins/`.
- Preserve explicit normalization/conversion paths (for example root and LSP helpers).
- In Lua, guard optional values (`nil` checks) before field access.

## Naming conventions

- Nix filenames use kebab-case (example: `render-markdown.nix`).
- Lua filenames use snake_case (example: `quick_settings.lua`).
- Lua module table is typically `M`.
- Nix option and attr names use lowerCamelCase when ecosystem conventions expect it.
- Keymap descriptions (`desc`) should be title case and action-oriented.

## Error handling and resilience

- Use `pcall(require, ...)` for optional dependencies.
- Fail fast in Nix helpers with `throw` on invalid inputs.
- Surface user-facing Lua errors via `vim.notify(..., vim.log.levels.ERROR, ...)`.
- Keep fallbacks explicit (for example fallback to CWD in root detection).

## Lazy-loading and performance

- Keep lazy-loading infra in `config/core/lz-n.nix`.
- Default to lazy-loading when low-risk and behavior-preserving.
- Preferred triggers: `cmd` for command tools, `ft` for filetype plugins, `event` for deferred startup.
- Ensure keymaps, setup hooks, and plugin integrations still work after lazy-loading.
- Add `pcall(require, ...)` guards when code may run before plugin load.

## Tool package fallbacks

- Add external tool packages (formatters, linters, language servers, CLI dependencies) at low priority so project environments (e.g. devshells) win:
  - Use `extraPackagesAfter = with pkgs; [ ... ];` for plain packages (appended to the end of `PATH`).
  - Set `packageFallback = true` on `plugins.lsp.servers.<name>` and `dependencies.<name>`.
- Declare tool packages in the module that uses them; duplicates across modules are acceptable.
- Reserve `extraPackages` (PATH prefix) for packages that must override the environment.
- The merged `extraPackagesAfter` bin dirs are exposed to Lua as `Utils.toolchain.fallback_bins` (generated in `config/luaset.nix`).
- Multi-candidate formatter lists must select via `Utils.formatter.pick` (see `lua/utils/formatter.lua`) instead of `stop_after_first`, because all candidates are always available through the fallback `PATH` entries.
- Gate linters that also ship with a fallback package behind the environment via `Utils.linter.set_external_linters` (see `lua/utils/linter.lua`).

## Commit and PR conventions

- Use Conventional Commit style seen in history (`feat(...)`, `fix(...)`, `refactor(...)`, `docs(...)`).
- For `lua/` changes, scope commits by feature area, not generic `utils` when possible.
- Example scope pattern: `feat(tools/oil): ...`.

## Agent workflow recommendations

- Scan related files before editing; follow local patterns over personal preference.
- Prefer small, surgical changes.
- Run targeted checks first, then broader checks.
- Do not edit `flake.lock` unless dependency updates are intentional.
- Avoid adding new tooling unless clearly required.

## Quick pre-PR checklist

- `nix flake check --all-systems`
