# An Upper Bound for Prophet Matching under Adversarial Edge Arrivals

**GPT-6.2 Astra · Raimundo Olmos Rodríguez**

**AI use and contributions.** GPT-6.2 Astra, used through OpenAI Codex, generated the construction, mathematical argument, Lean code, literature search, and manuscripts in Spanish and English. I posed the research question, requested verification and revisions, and shared the materials. Lean checked the supplied formal statements. Independent expert review and confirmation of priority remain open.

**Uso de IA y contribuciones.** GPT-6.2 Astra, utilizado mediante Codex de OpenAI, generó la construcción, el argumento matemático, el código Lean, la búsqueda bibliográfica y los manuscritos en español e inglés. Yo  planteé la pregunta, solicité verificaciones y revisiones y compartí el material. Lean comprobó los enunciados formalizados. La revisión independiente y la confirmación de prioridad siguen pendientes.

## Result and review status

The refined seven-edge family gives the upper bound **58,613,090,048,408,000 / 141,568,556,352,603,439 ≈ 0.41402619026799243** for independent edge weights, adversarial edge arrivals, and the expected maximum-weight integral matching as benchmark. The two PDF manuscripts describe the earlier finite example. The refinement and its proof appear below.

The note gives a seven-edge instance for prophet matching under adversarial edge arrivals. Its optimal online value is 80, and its expected offline optimum is 61,762,963,837 / 320,000,000. Their ratio is 25,600,000,000 / 61,762,963,837, approximately 0.414487881. This is smaller than the 0.418928 upper bound in [Soto and Verdugo, Theorem 1(b)](https://arxiv.org/html/2410.12756v1#S3).

Lean 4 accepted the supplied certificate for the formal statements it contains. Independent review of the correspondence with the published model and of the literature search is welcome. I do not claim priority. If you know an earlier comparable bound or spot a mismatch in the model, please open an issue with a reference or a specific counterexample.

## Files

- English: [paper](ProphetMatching.pdf) · [LaTeX source](ProphetMatching.tex)
- Español: [artículo](Cota-profeta.pdf) · [fuente LaTeX](Cota-profeta.tex)
- [Lean 4 certificate](ProphetMatchingWitness.lean) — check with `lean ProphetMatchingWitness.lean`. The file imports only `Std`.
- [Refined finite instance in Lean](ProphetMatchingRefined.lean) · [Exact Python verification](verify_refined_prophet.py)

## Refined family

Let $q=603/1330$, $r=163/667$, and let $m$ be any integer at least two. In the following fixed arrival order, each weight independently takes the value shown with the indicated probability and is zero otherwise.

| Edge | Positive weight | Probability |
|---|---:|---:|
| $(1,4)$ | $q$ | $1$ |
| $(0,3)$ | $1-q$ | $1$ |
| $(0,2)$ | $(1-q)(1-r)$ | $1$ |
| $(0,5)$ | $1-r$ | $(1-q)/(1-r)$ |
| $(1,5)$ | $1$ | $q$ |
| $(1,3)$ | $1$ | $r$ |
| $(0,1)$ | $m$ | $1/m$ |

Waiting for the final edge earns one in expectation. If the first positive acceptance occurs among the first six edges, the respective optimal continuation values are $1-q$, $q$, $q+(1-q)r$, $r$, $0$, and $0$. For the first edge, the remaining choices are the three edges at vertex 0. Their optimal stopping value is $1-q$, since the mean of $(0,5)$ is $1-q$ and $(0,2)$ pays at most that much. In each of the six positions the accepted weight plus its continuation equals one. Rejecting a zero-weight edge always leaves at least the same options. Backward induction therefore gives an optimal online value of one for every $m$.

Conditional on the final edge missing, only three independent Bernoulli draws remain. Write $i,j,k$ for the indicators of $(0,5),(1,5),(1,3)$ respectively and $b=(1-q)(1-r)$. Maximizing over feasible matchings in each realization gives the following table.

| | $(j,k)=(0,0)$ | $(0,1)$ | $(1,0)$ | $(1,1)$ |
|---|---:|---:|---:|---:|
| $i=0$ | $1$ | $1+b$ | $2-q$ | $2-q$ |
| $i=1$ | $1+q-r$ | $2-r$ | $2-q$ | $2-r$ |

The probability-weighted mean of the table is $H=82955466304195439/58613090048408000$. If the final edge hits, the offline optimum is $m$, since every earlier matching weighs at most two and the final edge conflicts with every earlier edge. Thus the expected offline optimum is $1+(1-1/m)H$. Taking $m$ to infinity bounds the universal competitive ratio by $1/(1+H)$, the fraction reported above.

Lean checks the finite case $m=10^{14}$, which already yields a ratio strictly below $0.414026190269$. The limiting step is the mathematical argument in the preceding paragraph. To check the finite certificate from the repository root in PowerShell, run

```powershell
lean -o ProphetMatchingWitness.olean ProphetMatchingWitness.lean
$env:LEAN_PATH = "."
lean ProphetMatchingRefined.lean
```

Run `python verify_refined_prophet.py` with Python 3.9 or newer to enumerate the matchings and check both fractions using exact arithmetic.
