AFFECT-X 2.0 — Professor Polish UI

Replace BOTH files in <project>\ui:
  affectx2_dashboard.m
  signal_lab2.m

Main dashboard improvements:
- Academic title: Speaker-Independent Speech Emotion Recognition.
- 'Inference Result' wording instead of 'Result Engine'.
- Plot titles and labels forced to high-contrast colours.
- Dark integrated ECOC relative-score meter replaces the white gauge.
- More vertical space for the main analysis area.
- All Control Deck buttons remain visible.
- Bottom area reduced and rebalanced.
- Top table shows Top 5, while the centre chart still shows all emotion classes.
- Research Evidence panel replaces code-like Research Design text.
- Softer navy/slate professional colour palette.
- AutoResizeChildren='off' so custom resize callback works without warnings.

After replacement:
  clear affectx2_dashboard signal_lab2
  clear functions
  rehash
  startup_affectx2
  START_HERE

Open options 12 and 13.
