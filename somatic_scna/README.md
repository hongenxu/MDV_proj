
### SCNAs

<table>
    <tr>
        <th>software</th>
        <th>type of mutation</th>
    </tr>
    <tr>
        <td>copyCat</td>
        <td>CN gain; CN loss</td>
    </tr>
    <tr>
            <td>Control-FREEC</td>
            <td>CN gain; CN loss; LOH</td>
    </tr>
    <tr>
            <td>genoCN</td>
            <td>CN gain; CN loss; LOH</td>
    </tr>
    <tr>
            <td>ASCAT</td>
            <td>CN gain; CN loss; LOH</td>
    </tr>

</table>


#### NGS data

1. Control-FREEC
* Version: 9.8b
* From: https://github.com/BoevaLab/FREEC/releases
* Notes: See `get_mappability_of_galgal5.sh` and `rename_mappability.pl` for details how to create mappability file used for Control-FREEC; See `create_files_for_FREEC.sh` for details for generating files required by running Control-FREEC; `config_WGS.txt` was modified from the file contained in Control-FREEC package, please copy this file into your Control-FREEC installed main directory (needed for running `run_control-freec.pl`); see `run_control-freec.pl` for details of running control-freec.

2. copyCat
* Version: 1.6.11
* From:  https://github.com/chrisamiller/copyCat
* Notes:
chicken GC and mappability files were created by following the [link](https://xfer.genome.wustl.edu/gxfer1/project/cancer-genomics/readDepth/createCustomAnnotations.v1.tar.gz);
`copycat.R` was executed by `run_copycat.pl`.

3. post-processing
* summarize results from copyCat, see `sum_copycat_results.pl` for details;
* summarize results from Control-FREEC, see `sum_freec_results.pl` for details; 
* compare CN gain and loss by copyCat and Control-FREEC, see `cmp_controlfreec_copycat.sh` for details


#### Microarray data
0. preprocessing
* copy CEL file and rename, see `copy_rename_microarray.pl` for details

1. PennCNV-Affy
* Version: Not Available 
* From: http://www.openbioinformatics.org/penncnv/download/gw6.tar.gz
* Notes: only for preprocessing CEL data to LRR and BAF; see `run_penncnv_affy.sh` for details

2. PennCNV
* Version: 1.0.4
* From: https://github.com/WGLab/PennCNV/releases
* Notes: for creating Population Frequency of B allele (PFB) file using 8 samples mixed from 6 control birds, see `prepare_pfb.pl` for details

3. post-processing

* split output files from PennCNV-Affy to LRR and BAF, see `tolrr_baf.pl` for details, the output files will be required by running genoCN and ASCAT
* join LRR values from samples into a single file, join BAF values from samples into a single file, see `joinlrr_baf.R` for details, required additionally by running ASCAT

4. genoCN
* Version: 1.26.0
* From: https://www.bioconductor.org/packages/release/bioc/html/genoCN.html
* Notes: see `genoCN.R` and `run_genoCN.sh` for details for running genoCN; 

5. ASCAT
* Version: 2.4.3
* From: https://github.com/Crick-CancerGenomics/ascat
* Notes: see `ascat.R` for details

