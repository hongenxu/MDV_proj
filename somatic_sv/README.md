
### SVs
1. Breakdancer

* Version: breakdancer-max1.4.3
* From:    https://github.com/genome/breakdancer
* Notes:   tumor sample S14 not included due to failing in quality check; filter out SV calls support by less than 5, see `run_breakdancer.pl` for details


2. Delly

* Version: 0.7.2
* From:    https://github.com/dellytools/delly
* Notes:   see `run_delly.pl` for filtering



3. novoBreak

* Version: 1.1.1
* From:    https://sourceforge.net/projects/novobreak/
* Notes:   No;

4. post-processing

* summarizing results from Breakdancer,see `sum_breakdancer.pl` for details;
* summarizing results from Delly, see `sum_delly.pl` for details;
* summarizing results from novoBreak,see `sum_novobreak.pl` for details;
* compare results from these tools, see `cmp_3tools.pl` for details;
