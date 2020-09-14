# IMP-6 phenotype distribution 
This page includes data analyzed in the paper "Geographical distribution of Enterobacteriaceae with a carbapenemase IMP-6 phenotype and its association with antimicrobial use: an analysis using comprehensive national surveillance data on antimicrobial resistance" by Aki Hirabayashi, Koji Yahara, Toshiki Kajihara, Motoyuki Sugai, and Keigo Shibayama. 



The aggregated data files are downloadable in this page,  They were tabulated from the comprehensive national surveillance data of all routine bacteriological test results from more than 1400 hospitals for each prefecture in Japan in 2015 and 2016.  The data tabulation was at first conducted using a Java program, as written and available in https://github.com/bioprojects/GLASS-JANIS-comparison/

"data2_combined_per_prefecture.xlsx" was then created using an in-house Perl script

```
perl prepare_prop_DrugDiff_per_prefecture_summary.pl \
  --B1     data0/kensa_snapshot_2016.default_inpatient_withDedup_DrugDiff_20191120171314.Eng.txt \
  --B2     data0/kensa_snapshot_2015.default_inpatient_withDedup_DrugDiff_20191120170121.Eng.txt \
  --CAZ1   data0/kensa_snapshot_2015.default_inpatient_withDedup_DrugDiff_20200305153225_CAZ.Eng.txt \
  --CAZ2   data0/kensa_snapshot_2016.default_inpatient_withDedup_DrugDiff_20200305154447_CAZ.Eng.txt \
  --PIPC1  data0/kensa_snapshot_2015.default_inpatient_withDedup_DrugDiff_20200310110531_PIPC.Eng.txt \
  --PIPC2  data0/kensa_snapshot_2016.default_inpatient_withDedup_DrugDiff_20200310111747_PIPC.Eng.txt \
  --FOM1   data0/kensa_snapshot_2015.default_inpatient_withDedup_DrugDiff_20200605163644_FOM.Eng.txt \
  --FOM2   data0/kensa_snapshot_2016.default_inpatient_withDedup_DrugDiff_20200605093840_FOM.Eng.txt \
  --AMK1   data0/kensa_snapshot_2015.default_inpatient_withDedup_DrugDiff_20200605163613_AMK.Eng.txt \
  --AMK2   data0/kensa_snapshot_2016.default_inpatient_withDedup_DrugDiff_20200605093804_AMK.Eng.txt \
> data2_combined_per_prefecture.tsv
```

followed by manually merging with another national surveillance data of antimicrobial use for each prefecture in the last 3 columns.  


