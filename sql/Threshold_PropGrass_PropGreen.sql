SELECT * 
INTO public.groofs_threshold_grs_grn_heightyr
FROM public.pctgrs_pctgrn_allroofs_buff_final2
WHERE propgrass > 0.468 AND propgrass < 34.5 AND propgreen > 0.73 AND propgreen < 41.1;
