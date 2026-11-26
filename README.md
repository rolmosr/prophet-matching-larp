# An Upper Bound for Prophet Matching under Adversarial Edge Arrivals

**GPT-6.2 Astra · Raimundo Olmos Rodríguez**

**AI use and contributions.** GPT-6.2 Astra, used through OpenAI Codex, generated the construction, mathematical argument, Lean code, literature search, and manuscripts in Spanish and English. I posed the research question, requested verification and revisions, and shared the materials. Lean checked the supplied formal statements. Independent expert review and confirmation of priority remain open.

**Uso de IA y contribuciones.** GPT-6.2 Astra, utilizado mediante Codex de OpenAI, generó la construcción, el argumento matemático, el código Lean, la búsqueda bibliográfica y los manuscritos en español e inglés. Yo  planteé la pregunta, solicité verificaciones y revisiones y compartí el material. Lean comprobó los enunciados formalizados. La revisión independiente y la confirmación de prioridad siguen pendientes.

## Result and review status

The note gives a seven-edge instance for prophet matching under adversarial edge arrivals. Its optimal online value is 80, and its expected offline optimum is 61,762,963,837 / 320,000,000. Their ratio is 25,600,000,000 / 61,762,963,837, approximately 0.414487881. This is smaller than the 0.418928 upper bound in [Soto and Verdugo, Theorem 1(b)](https://arxiv.org/html/2410.12756v1#S3).

Lean 4 accepted the supplied certificate for the formal statements it contains. Independent review of the correspondence with the published model and of the literature search is welcome. I do not claim priority. If you know an earlier comparable bound or spot a mismatch in the model, please open an issue with a reference or a specific counterexample.

## Files

- English: [paper](ProphetMatching.pdf) · [LaTeX source](ProphetMatching.tex)
- Español: [artículo](Cota-profeta.pdf) · [fuente LaTeX](Cota-profeta.tex)
- [Lean 4 certificate](ProphetMatchingWitness.lean) — check with `lean ProphetMatchingWitness.lean`. The file imports only `Std`.
