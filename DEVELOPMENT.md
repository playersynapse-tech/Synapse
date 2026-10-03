# Development Guide

This guide explains how to set up, test, and contribute to Synapse plugins.

## Prerequisites

- Roblox Studio (latest version recommended)
- Basic understanding of Roblox and Luau scripting
- A test place to validate plugin behavior

## Project structure

```text
plugins/
├── tool-configurator/
│   ├── SynapseToolConfig.luau    (Plugin entry point)
│   └── Modules/                   (Feature modules)
└── ui-designer/
    ├── SynapseUiDesigner.luau     (Plugin entry point)
    └── Modules/                   (Feature modules)
```

Each plugin is self-contained with its own modules and entry script.

## Running a plugin locally

### For Tool Configurator

1. Open Roblox Studio.
2. Create or open a test place.
3. In the Home tab, click Plugins → Manage Plugins.
4. Click Load from file and navigate to:
   ```text
   plugins/tool-configurator/SynapseToolConfig.luau
   ```
5. The plugin toolbar should appear in Studio.
6. Test the plugin on sample assets such as tools, equipment, or weapons.

### For UI Designer

1. Open Roblox Studio.
2. Create or open a test place.
3. In the Home tab, click Plugins → Manage Plugins.
4. Click Load from file and navigate to:
   ```text
   plugins/ui-designer/SynapseUiDesigner.luau
   ```
5. The plugin toolbar should appear in Studio.
6. Test UI creation, animation, and property workflows.

## Testing checklist

Before opening a pull request, verify:

- [ ] Plugin loads without errors in Studio
- [ ] UI elements render correctly
- [ ] Core workflow completes as expected
- [ ] Undo/redo integration works correctly
- [ ] No console warnings or errors appear
- [ ] Edge cases are handled gracefully
- [ ] Existing plugin behavior remains intact

## Code style

- Use clear, descriptive variable and function names
- Keep functions focused and modular
- Follow the existing module conventions
- Avoid unrelated refactors in feature or bug-fix pull requests
- Keep logic separated between UI, operations, and data handling

## Module organization

Each plugin uses a modular architecture:

- Foundation: utilities, config, and shared state
- UIBase: UI widgets and rendering
- Operations: workflow logic and conversion tools
- Windows: plugin windows and modals
- InputToolbar: toolbar controls and actions

## Making changes

1. Create a branch for your feature or fix.
2. Update the relevant plugin modules.
3. Validate the behavior in Studio.
4. Commit with a clear, focused message.
5. Open a pull request with a short description and test notes.

## Debugging tips

- Use `print()` and `warn()` to inspect runtime behavior
- Check the Output window in Studio for errors
- Test with a variety of objects and selections
- Validate behavior across different Studio workflows and edge cases

## Questions or issues?

See [CONTRIBUTING.md](./CONTRIBUTING.md) for contribution rules and expectations.
