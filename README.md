# VESTA Figure Maker

A Codex skill for creating reproducible crystal-structure and volumetric-data figures with [VESTA](https://jp-minerals.org/vesta/en/). It combines editable `.vesta` scenes, command-line image export, and visual inspection so that the final image remains traceable to its inputs and rendering parameters.

The skill guides an agent through the complete figure workflow. The included export script renders a prepared scene; scene preparation, scientific parameter selection, and visual review remain separate steps.

## What it helps you do

- Create structure figures from CIF, POSCAR, CONTCAR, or existing `.vesta` scenes.
- Configure crystallographic views, drawing boundaries, atom and bond styles, polyhedra, cell edges, labels, lighting, and projection.
- Render consistent figure batches using an approved scene as the style template.
- Visualize linked volumetric data, including charge-density and ELF isosurfaces, with explicit thresholds, sign conventions, colors, and opacity.
- Prepare deterministic rotation or breathing-animation frames and assemble them with `ffmpeg`.
- Audit exported images for clipping, occlusion, orientation, dimensions, and consistency.

## Requirements

- **Codex with local skill support** to use the instructions as an agent workflow.
- **VESTA, installed separately.** Download it from the [official VESTA site](https://jp-minerals.org/vesta/en/). This repository does not include the VESTA application.
- **macOS for the included export wrapper.** The script expects `/Applications/VESTA.app` and uses `zsh`, `open`, `stat`, and `sips`.
- **A GUI interaction tool available to the agent** when a new style must be configured or adjusted in VESTA. Existing approved scenes can be reused for export.
- **`ffmpeg` for animation assembly**, if needed.

The bundled wrapper is macOS-specific. It uses the macOS application launcher and native image utilities. Validate VESTA's command-line export on your installed version before starting a large batch.

## Install

Clone this repository into your Codex skills directory:

```bash
mkdir -p "${CODEX_HOME:-$HOME/.codex}/skills"
git clone https://github.com/RobinMAJ/vesta-figure-maker.git \
  "${CODEX_HOME:-$HOME/.codex}/skills/vesta-figure-maker"
```

If the repository is private, use your authenticated GitHub credentials. With the GitHub CLI, you can instead run:

```bash
gh repo clone RobinMAJ/vesta-figure-maker \
  "${CODEX_HOME:-$HOME/.codex}/skills/vesta-figure-maker"
```

If that directory already exists, inspect it before updating or replacing it. Start a new Codex session if the installed skill is not yet listed.

## Use in Codex

Invoke the skill by name and provide the input files and figure requirements:

```text
Use $vesta-figure-maker to render structure.cif along the c axis.
Use an orthographic projection, a white background, and visible unit-cell
edges. Save the final scene and export a PNG at scale 4.
```

```text
Use $vesta-figure-maker to render the structures in this folder with the
style from approved-template.vesta. Keep the view, projection, drawing
boundary, output scale, colors, and bond settings consistent. Inspect
every image and include a manifest of the inputs and rendering parameters.
```

```text
Use $vesta-figure-maker to visualize the supplied charge-density difference
with isosurfaces at +0.003 and -0.003 e/angstrom^3. Use yellow for positive
values and cyan for negative values, with opacity 0.6. Verify the density
units, sign convention, structure, and cell before rendering. Save these
parameters with the final scene.
```

The numeric values in the last prompt are an example of user-supplied settings, not recommended thresholds for other datasets. Choose values and units that match your calculation and scientific question.

## Quick image export

Prepare and save your scene in VESTA, then run:

```bash
skill_dir="${CODEX_HOME:-$HOME/.codex}/skills/vesta-figure-maker"
zsh "$skill_dir/scripts/vesta_export.sh" scene.vesta figure.png 4
```

The script accepts:

```text
vesta_export.sh INPUT OUTPUT [SCALE]
```

- `INPUT`: an existing scene or structure file that VESTA can open.
- `OUTPUT`: a new output file in an existing directory.
- `SCALE`: a positive integer, defaulting to `4`.

The wrapper refuses to overwrite an existing output. It waits for a non-empty file whose size is stable across two successive checks, then reports its pixel dimensions and format. The default wait limit is 90 seconds; override it when necessary:

```bash
VESTA_EXPORT_TIMEOUT_SECONDS=180 \
  zsh "$skill_dir/scripts/vesta_export.sh" scene.vesta figure.png 4
```

The underlying macOS invocation is:

```bash
open -n -a VESTA.app --args \
  -open scene.vesta -export_img scale=4 figure.png
```

`scale` multiplies the current VESTA graphics viewport. It does not specify a fixed image size. Inspect the reported dimensions and the image itself after every export.

Use PNG for general lossless delivery or TIFF when required. For vector output such as SVG, PDF, EPS, or PS, use VESTA's GUI export workflow.

## Reproducible figure workflow

```text
Request -> prepare or edit .vesta -> export -> inspect -> revise -> export again
```

1. **Preserve the inputs.** Work from copies of structure files, density files, and style templates.
2. **Establish the view and scientific settings.** Record the source and phase, crystallographic direction, drawing boundary, representation, and relevant bond or isosurface parameters.
3. **Save the scene.** Keep linked data paths valid, including `IMPORT_STRUCTURE` and `IMPORT_DENSITY` references. Preserve unfamiliar scene fields and edit only understood blocks.
4. **Render to a distinct filename.** Keep the output traceable to the input scene and export scale.
5. **Inspect the result.** Check orientation, clipping, hidden features, overlap, colors, labels, opacity, object scale, and pixel dimensions. Revise the scene and re-export when needed.
6. **Deliver the image and its recipe.** Retain the final `.vesta` scene. For batches or figures with scientific display parameters, include a concise manifest; for animations, retain the frame recipe or scene sequence.

For comparable panels, keep the view convention, projection, object scale, output dimensions, colors, and scientific parameters consistent. Approve one representative scene before generating a batch, then inspect every exported image. A contact sheet supplements individual inspection.

Bond cutoffs, isosurface levels, density signs, units, and coordination interpretations can affect scientific meaning. The skill requires these choices to be grounded in the supplied data and user requirements; visual plausibility alone does not establish their validity.

## Repository layout

```text
vesta-figure-maker/
├── SKILL.md                         # Agent instructions and workflow boundaries
├── agents/
│   └── openai.yaml                  # Skill display metadata and default prompt
├── references/
│   └── automation-model.md          # Scene editing, export, and reference guide
└── scripts/
    └── vesta_export.sh              # macOS export wrapper
```

## Limitations

- This is an agent skill and a small export helper, not a complete VESTA automation API.
- The wrapper checks output readiness and reports dimensions; it does not verify scientific correctness or visual quality.
- Rendering depends on the installed VESTA version, GUI state, and graphics viewport. A representative export should be checked after an application or operating-system update.
- A `.vesta` scene may depend on external structure or density files. Keep those files with the scene or update their relative paths deliberately.
- Atom correspondence, periodic wrapping, and displacement vectors must be validated before rendering vector fields or animations.
- VESTA is distributed under its own terms. Consult the vendor's current terms for your intended use.

## VESTA references

- [VESTA manual](https://jp-minerals.org/vesta/en/doc/VESTA.html)
- [Command-line interface](https://jp-minerals.org/vesta/en/doc/VESTAch17.html)
- [Input, output, and image formats](https://jp-minerals.org/vesta/en/doc/VESTAch18.html)
- [Bonds and polyhedra](https://jp-minerals.org/vesta/en/doc/VESTAch8.html)
- [Drawing boundaries and view direction](https://jp-minerals.org/vesta/en/doc/VESTAch10.html)
- [Object properties](https://jp-minerals.org/vesta/en/doc/VESTAch12.html)
