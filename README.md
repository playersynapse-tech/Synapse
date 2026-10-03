<div align="center">
<table width="100%">
<tr>
<td align="center" bgcolor="#0B1220">
<br />
<img src="./Logo.png" alt="Synapse logo" width="132" />
<h1>SYNAPSE</h1>
<p><strong>Purpose-built tools for Roblox Studio.</strong></p>
<img src="https://readme-typing-svg.demolab.com?font=JetBrains+Mono&weight=600&size=18&duration=2600&pause=700&color=33C8F0&center=true&vCenter=true&width=560&lines=BUILD+FASTER.;DESIGN+WITH+PRECISION.;MAKE+EVERY+CLICK+COUNT." alt="Build faster. Design with precision. Make every click count." />
<br />
<a href="https://create.roblox.com/store/asset/121407719443899?viewFromStudio=true&keyword=&searchId=ff92379b-5d8f-404a-8d87-b4e7c38b8f82"><img src="https://img.shields.io/badge/TOOL%20CONFIGURATOR-OPEN%20PLUGIN-007AFF?style=for-the-badge&labelColor=101820" alt="Open Tool Configurator plugin" /></a>
&nbsp;
<a href="https://create.roblox.com/store/asset/136370912247705/SynapseUiDesigner?viewFromStudio=true&keyword=&searchId=ff92379b-5d8f-404a-8d87-b4e7c38b8f82"><img src="https://img.shields.io/badge/UI%20DESIGNER-OPEN%20PLUGIN-00A6A6?style=for-the-badge&labelColor=101820" alt="Open UI Designer plugin" /></a>
<br /><br />
</td>
</tr>
</table>
</div>

<p align="center">
<img src="https://img.shields.io/badge/ROBLOX-STUDIO-101820?style=flat-square&logo=roblox&logoColor=white" alt="Roblox Studio" />
<img src="https://img.shields.io/badge/SOURCE-AVAILABLE-007AFF?style=flat-square" alt="Source available" />
<img src="https://img.shields.io/badge/PLUGIN-TOOLS-00A6A6?style=flat-square" alt="Plugin tools" />
</p>

## The Toolkit

Synapse is an independent collection of Roblox Studio plugins focused on making everyday creator workflows faster, clearer and safer.

| Plugin | What it does | Source |
|:--|:--|:--|
| **Synapse Tool Configurator** | Converts models and parts into ready-to-use Tools, with Handle setup, joints, Grip controls, attachments, validation and optional backups. | [Browse source](./plugins/tool-configurator/) |
| **Synapse UI Designer** | Builds and animates interfaces with a hierarchy, preview workspace, property inspector, timeline, easing and reusable animation data. | [Browse source](./plugins/ui-designer/) |

## Built for Real Workflows

<table>
<tr>
<td width="50%" valign="top">
<h3>Tool Configurator</h3>
<p>Prepare weapons, equipment, simulator items and other assets with a guided, reversible setup flow.</p>
<ul>
<li>Detects candidate Handles and validates the selection</li>
<li>Creates Motor6D or WeldConstraint joints</li>
<li>Configures Grip values and RightGripAttachment</li>
<li>Supports backups, protected objects and undo-aware actions</li>
</ul>
<p><a href="https://create.roblox.com/store/asset/121407719443899?viewFromStudio=true&keyword=&searchId=ff92379b-5d8f-404a-8d87-b4e7c38b8f82">Open in Creator Store</a></p>
</td>
<td width="50%" valign="top">
<h3>UI Designer</h3>
<p>Shape interfaces and animation timelines in a focused Studio workflow, using on-screen controls and context menus.</p>
<ul>
<li>Creates and organizes common UI objects</li>
<li>Edits keyframes, easing, events and properties</li>
<li>Previews ready-made animation effects</li>
<li>Saves and imports reusable animation data</li>
</ul>
<p><a href="https://create.roblox.com/store/asset/136370912247705/SynapseUiDesigner?viewFromStudio=true&keyword=&searchId=ff92379b-5d8f-404a-8d87-b4e7c38b8f82">Open in Creator Store</a></p>
</td>
</tr>
</table>

## Repository

```text
plugins/
	tool-configurator/
		SynapseToolConfig.luau
		Modules/
	ui-designer/
		SynapseUiDesigner.luau
		Modules/
```

Each plugin keeps its entry point and feature modules together for easier review and maintenance.

<div align="center">
<img src="https://capsule-render.vercel.app/api?type=waving&color=0:0B1220,55:075B8C,100:00A6A6&height=110&section=footer" width="100%" alt="" />
<sub>Designed for creators. Built for Roblox Studio.</sub>
</div>
