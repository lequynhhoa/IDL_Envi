;IDL convert from SIN coordinate to WGS 84 coordiante(.img, .hdr,...)
; Bản chuẩn: 09/10/2013

pro SIN_to_WGS84

compile_opt IDL2

envi, /restore_base_save_files  
envi_batch_init, log_file='batch.txt'  

; Open the input file  
FNS = dialog_pickfile(PATH ='c:\Temp\Refrectance\kq\',Filter='*.hdr', /multiple_files)


for i = 0, n_elements(FNS)-1 do begin
envi_open_file, FNS[i], r_fid=fid 
If (fid eq -1) then begin
  envi_batch_exit
  return
endif
 
envi_file_query, fid, dims=dims, nb=nb, sname=sname
pos = lindgen(nb)

out_name ='c:\Temp\Refrectance\kq\'+STRMID(sname,STRPOS(sname,''),9)+'_wgs84'; Get strings number 9

Proj = envi_proj_create(/geographic, datum='WGS-84')  
o_pixel_size = [0.004187D, 0.004187D]  


envi_convert_file_map_projection,$  
fid=fid,pos=pos,dims=dims, o_proj=Proj, $
   o_pixel_size=o_pixel_size, grid=[50,50], $    
   out_name=out_name, warp_method=0, $    
   resampling=1, background=0  

Endfor
envi_batch_exit
end