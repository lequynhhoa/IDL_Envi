; Stacking from a image
pro tach_kenh_anh_va_xuat_tiff


ENVI_BATCH_INIT, LOG_FILE = 'batch_log.txt'   ; Khởi tạo

; Find file in working directory G:\Backup\Hoa.lq\temp\Tach kenh\  , 
files = FINDFILE('c:\Temp\Refrectance\kq\layer\*.hdr', count=count)
;Xác định các thông số cho hàm 
fid = lonarr(count)
pos = lonarr(count)
dims = lonarr(5,count)
out_bname = strarr(count)
; Vòng lặp trên các tệp tin được tìm thấy ở thư mục Gop anh
FOR j= 0,4 DO BEGIN  ; vòng lặp cho ảnh Landsat 3 kênh, ở đây tách mỗi kênh là 1 ảnh - 3 kênh là 3 ảnh

  FOR i=0,count-1 DO BEGIN
    ;Mở các file cần sử dụng
      envi_open_data_file, files(i), r_fid=layer_fid
      if (layer_fid eq -1) then begin
        envi_batch_exit
        return
      endif
    ; Truy van một số thông tin hữu ích về các dữ liệu đầu vào
    ENVI_FILE_QUERY, layer_fid, NS = ns, NL = nl, NB = nb, sname=sname
    ; Các tham số của hàm ghép lớp
    fid[i] = layer_fid
    pos[i] = j
    dims[0,i] = [-1,0,ns-1,0,nl-1]
    out_bname[i] = STRMID(sname,STRPOS(sname,''),7) ; Lấy tên cho kênh ảnh và 10 là ký tự khi ghi tên kênh trên ảnh kết quả
   Endfor 
   
; Xuất file ra thư mục G:\Backup\Hoa.lq\temp\Tach kenh   
     out_name = 'c:\Temp\Refrectance\kq\layer\'+STRMID(sname,STRPOS(sname,''),7) + string(j*1+1) ;

; Thiết lập các tham số
  out_dt = 4 ; Định dạng kiểu float 1: Byte (8 bits), 2: Integer (16 bits), 3: Long integer (32 bits), 4: Floating-point (32 bits)...
  out_proj = envi_get_projection(fid=layer_fid, pixel_size=out_ps) ; tham số về tọa độ
                                                      
  ; tach
envi_doit, 'envi_layer_stacking_doit', $
    fid=fid, pos=pos, dims=dims, $
    out_dt=out_dt, out_name=out_name, $ 
    out_bname = out_bname, $
    interp=0, out_ps=out_ps, $
    out_proj=out_proj, r_fid=r_fid

; Select file anh, de cbi xuat ra tiff

;envi_select, title='Lua chon Anh can xuat', $
;fid=fid,dims=dims,pos=pos 



; Xuat ra tiff
envi_output_to_external_format,fid=fid,$
dims=dims,$
pos=pos,$

/tiff,$
out_name='c:\Temp\create_idl_test\'+STRMID(sname,STRPOS(sname,''),7) + string(j*1+1)+'.tif'

Endfor  

ENVI_BATCH_EXIT

END