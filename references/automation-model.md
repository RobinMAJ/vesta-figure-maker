# VESTA automation model

## Contents

- Historical local validation
- Two automation surfaces
- Scene-editing rules
- Common figure workflows
- Official reference routes

## Historical local validation

The following is a record from the original development environment, not a portability guarantee or a fresh validation of this release. The bundled export helper is macOS-specific.

- App path: `/Applications/VESTA.app`
- Executable: `/Applications/VESTA.app/Contents/MacOS/VESTA`
- Validated on this Mac on 2026-07-24 with a minimal NaCl CIF.
- Confirmed operation: open a crystal structure and export a non-empty PNG with `-export_img scale=2`.
- Observed result: 4832 × 1920 PNG. Pixel dimensions depend on the active VESTA graphics viewport, so never treat this size as a universal `scale=2` result.

The macOS invocation used by this skill is:

```bash
open -n -a VESTA.app --args -open structure.cif -export_img scale=2 out.png
```

Treat this command as a useful entry point, not a complete official SDK. Run a small representative validation before a batch or after changing VESTA/macOS versions.

## Two automation surfaces

### Command-line export

VESTA supports opening a file and exporting an image from command-line arguments. The official command-line manual documents:

- `-open file`
- `-export_img [scale=n] file`
- `-rotate_x angle`, `-rotate_y angle`, `-rotate_z angle`
- `-scale factor`
- `-scale_width_to size`
- `-flush`

Use the smallest validated command sequence. Export format is inferred from the output extension.

### `.vesta` text scene

A `.vesta` file stores structural data or references plus graphical settings. It may include relative linked files through entries such as:

- `IMPORT_STRUCTURE`
- `IMPORT_DENSITY`
- `IMPORT_TEXTURE`
- `IMPORT_ORFFE`

Use a saved `.vesta` file as the style template for repeatable work. Keep linked files together or update relative paths deliberately. Preserve unknown fields and edit only understood blocks.

## Scene-editing rules

- Copy the template before editing.
- Diff the edited scene against the template.
- Change one concern at a time: structure reference, boundary, view, or display property.
- Preserve structure coordinates and scientific data unless the user explicitly asks to modify them.
- Reopen the generated scene in VESTA and visually validate it.
- Save an approved scene before running a batch.
- Never use broad search-and-replace on element symbols or numeric values.

Changing a drawing boundary can regenerate objects and reset hidden/selected states. Recheck object visibility and polyhedra after boundary edits.

## Common figure workflows

### Publication structure figure

1. Load CIF/POSCAR/CONTCAR or an approved `.vesta` scene.
2. Set the requested crystallographic view.
3. Set the repeat/boundary.
4. Configure atoms, bonds, polyhedra, cell edges, axes, background, lighting, and projection.
5. Save `.vesta`.
6. Export at `scale=4` unless another target is specified.
7. Inspect and revise.

### Consistent folder batch

1. Approve one representative scene.
2. Freeze visual and scientific parameters.
3. Generate one scene and one image per structure.
4. Keep output names traceable to source names.
5. Inspect every image and then compare a contact sheet.

### Volumetric-data isosurfaces

1. Keep CHGCAR/ELFCAR/density files linked to the correct structure and cell.
2. Record the isosurface level, sign convention, colors, opacity, and boundary.
3. Apply the same parameters across comparable systems.
4. Treat threshold selection as a scientific choice, not an aesthetic guess.
5. Inspect for clipping, occlusion, and misleading opacity.

### Displacement vectors

Compute atom mappings and displacement vectors outside VESTA, then write the validated vector fields into a copied `.vesta` scene. Verify periodic wrapping and atom correspondence before rendering.

### Animation

Generate numbered view states or rotate with validated command-line operations, export lossless frames, inspect key frames, and assemble with `ffmpeg`.

## Official reference routes

- Main manual: <https://jp-minerals.org/vesta/en/doc/VESTA.html>
- Command-line interface: <https://jp-minerals.org/vesta/en/doc/VESTAch17.html>
- Input/output and image formats: <https://jp-minerals.org/vesta/en/doc/VESTAch18.html>
- Bonds and polyhedra: <https://jp-minerals.org/vesta/en/doc/VESTAch8.html>
- Drawing boundaries and view direction: <https://jp-minerals.org/vesta/en/doc/VESTAch10.html>
- Object properties: <https://jp-minerals.org/vesta/en/doc/VESTAch12.html>

This skill treats the agent as a script layer around VESTA: combine `.vesta` text editing with command-line export and visually inspect every render.
