---
name: vesta-figure-maker
description: "Use VESTA to create, batch-render or audit crystal and volumetric-data figures or rotation animations. Use for VESTA scenes and structure visualization, not all CIF/POSCAR edits."
---

# VESTA Figure Maker

Turn natural-language figure requirements into a reproducible VESTA scene and a visually checked export.

## Core model

Use both automation surfaces:

1. Treat `.vesta` as the reusable text scene containing structure references, boundaries, display styles, and volumetric-data references.
2. Use VESTA's `-export_img` command to render that scene.

Always close the loop:

`request -> prepare/edit .vesta -> export -> inspect image -> revise -> export again`

The bundled export helper requires macOS with VESTA installed at `/Applications/VESTA.app`; other platforms need an adapted export command.

Read [references/automation-model.md](references/automation-model.md) before editing `.vesta`, handling volumetric data, batching figures, or making animations.

## Choose an execution path

- Use an existing `.vesta` scene directly when it already contains the intended style and structure.
- Use a known-good `.vesta` scene as the style authority for a batch. Preserve its visual settings and change only validated structure/data references and requested scene parameters.
- Use the VESTA GUI through available UI automation tools when a first style scene must be created or when atom colors, bonds, polyhedra, background, projection, labels, or lighting need visual adjustment.
- Use `scripts/vesta_export.sh` for repeatable raster export after the scene is ready.
- Use direct command-line rotations only for simple, validated transformations. Do not pretend the command-line interface is a complete or stable API.

## Prepare the request

Inspect the input files and establish:

- structure source and phase;
- target view direction or crystallographic axis;
- drawing boundary or repeat count;
- representation: ball-and-stick, polyhedra, space-filling, stick, wireframe, isosurface, or a combination;
- visible unit cell, axes, labels, bonds, and polyhedra;
- background and output format;
- scientific parameters such as bond cutoff, isosurface level, opacity, and density sign/color;
- whether one figure, a batch, a panel, or animation frames are required.

Infer ordinary visual defaults when safe. Ask for scientific parameters only when guessing could change interpretation. Never invent an isosurface threshold, charge-density sign convention, bond cutoff, or coordination interpretation and present it as scientifically chosen.

## Build a reproducible scene

1. Preserve the original structure and volumetric-data files.
2. Create a working `.vesta` scene next to the intended outputs or in a dedicated working folder.
3. For a new visual style, open the source in VESTA and configure:
   - drawing boundary/repeat count;
   - view alignment and magnification;
   - orthographic or perspective projection;
   - atom radii and colors;
   - bond pairs, cutoffs, radii, and styles;
   - polyhedron centers, opacity, and color;
   - unit-cell edges, axes/compass, labels, background, and lighting.
4. Save the result as `.vesta` before export.
5. For linked structure or density data, keep relative paths valid. Inspect `IMPORT_STRUCTURE`, `IMPORT_DENSITY`, and related entries instead of blindly replacing arbitrary text.

For comparable scientific panels, hold the style, view convention, projection, scale, output dimensions, colors, and scientific display parameters constant unless the user explicitly requests a difference.

## Export

Prefer a new output filename; do not overwrite an existing figure silently.

Run:

```bash
scripts/vesta_export.sh scene.vesta figure.png 4
```

The equivalent macOS command is:

```bash
open -n -a VESTA.app --args -open scene.vesta -export_img scale=4 figure.png
```

Use `scale=4` as the default for a publication-oriented raster when runtime and image size are reasonable. `scale` multiplies the current VESTA graphics viewport, so verify actual pixel dimensions rather than assuming them.

Prefer PNG for general lossless delivery and TIFF when explicitly required. Use VESTA's vector export through the GUI when the user requests SVG/PDF/EPS/PS.

## Inspect and iterate

Open every exported image and check:

- the intended axis/view and camera orientation;
- complete, unclipped atoms, bonds, polyhedra, isosurfaces, and unit-cell edges;
- excessive overlap or hidden central features;
- boundary consistency and sufficient breathing room;
- correct colors, background, labels, axes, opacity, and line/radius balance;
- consistent viewport and object scale across a batch;
- expected image dimensions and non-empty output.

Revise the `.vesta` scene or GUI settings and render again when any check fails. Do not report success from file existence alone.

## Batch figures and animation

For a batch:

1. Validate one representative structure end to end.
2. Freeze the approved `.vesta` style and scientific parameters.
3. Generate each scene and image with distinct filenames.
4. Inspect every image; use a contact sheet only as an additional consistency check.
5. Create a panel only after the individual figures pass.

For rotation or breathing animations:

1. Generate a deterministic sequence of scene/view states.
2. Export numbered lossless frames.
3. Inspect key frames and the full frame geometry.
4. Assemble GIF/MP4 with `ffmpeg`.
5. Retain the frame recipe or scene sequence for reproducibility.

## Deliver

Return:

- the final figure(s);
- the final `.vesta` scene or style template;
- for batches or scientifically parameterized plots, a concise manifest recording input, view, boundary, representation, scale, and parameters;
- animation output plus its frame recipe when applicable.

State clearly which scientific choices came from the user and which visual defaults were inferred.

## Boundaries

- Treat VESTA as free for the vendor-described academic/scientific/educational/noncommercial use, not as open-source software.
- Verify `-export_img` on the installed VESTA version before a large batch.
- Do not replace scientific judgment with visual plausibility.
- Prefer ASE, pymatgen, Crystal Toolkit, 3Dmol.js, or OVITO when the real requirement is headless CI, web embedding, or a fully open-source rendering stack.
