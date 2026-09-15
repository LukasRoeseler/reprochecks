# Environment & Provenance Note — ECTA8852 (2026-09-14)

## Engine
- anomalyco/opencode (ReproAI), DeepSeek V4 Flash via uniGPT
- ReproAI rules 2026.06.27 (REPRO_STANDARDS.md)
- Audit date: 2026-09-14

## Host environment
- OS: win32 (Windows), PowerShell 5.1
- Rscript: R version 4.6.1 (2026-06-24), path C:\Program Files\R\R-4.6.1\bin\Rscript.exe
  (base stats + dplyr used; no author code run)
- Python 3.8.10 with numpy/pandas/scipy/statsmodels; xlrd (installed during audit) for reading .xls if needed
- All analysis re-implemented in R from raw behavior .txt; Python used for loading/preprocessing and as a
  second-language cross-check of headline counts and payoffs.

## Provenance chain (shipped -> recomputed)
1. Econometric Society article browse page:
   https://www.econometricsociety.org/publications/econometrica/2011/05/01/experimental-study-collective-deliberation
2. Supplemental archive: .../supp/8852_data and programs_0.zip   (457243 bytes)
   Legacy link (http://www.econometricsociety.org/ecta/Supmat/8852_dataandprograms.zip) returns 404; the
   live mirror at the browse page was used. This is the same package (file names match the paper's reference).
3. Extracted to extracted\Data\:
   - BehaviorOutcomes\*.txt (per-session per-round; 10 cols)  -> raw source
   - MessageData\*.xls (message logs)                         -> not used (content coding required)
   - File_Label_Key.docx / BasicParamOverview.docx            -> schema documentation
   - NO analysis code (.do/.R/.m/.sas) is shipped, despite the archive being named "data and programs".
4. Unified analysis table: exec_check\output\master_behavior.csv (13,311 individual decisions), built by
   exec_check\scripts\00_preprocess.py directly from the raw .txt (no intermediate summary file relied upon).
5. Statistics recomputed in R scripts 01-06b; outputs compared to the manuscript.

## Version/drift caveats
- No author code/fit-time environment is available to pin; all tests are closed-form counts/percentages,
  proportions and a GLM probit, so R-version drift is not expected to affect the descriptive percentages.
- Table IV probit reproduction is convention-sensitive (AME vs at-means MEM); the at-means convention gives
  an exact match for the flagship coefficient. No byte-for-byte Stata/limdep reproduction was attempted
  (no code shipped).

## Provenance of copied originals
- paper.pdf and paper_extracted.txt (working directory) were NOT modified.
- The supplemental zip was downloaded fresh on 2026-09-14 and stored under data\8852_data_and_programs.zip;
  extracted copy under extracted\ (read-only reference; analysis works on outputs only).
