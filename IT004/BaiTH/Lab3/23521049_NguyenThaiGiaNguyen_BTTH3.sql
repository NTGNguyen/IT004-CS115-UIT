USE QLBH_2020
--18. Tìm số hóa đơn đã mua tất cả các sản phẩm do Singapore sản xuất.
SELECT hd.SOHD
FROM HOADON hd
JOIN CTHD cthd
ON hd.SOHD = cthd.SOHD
JOIN SANPHAM sp
ON cthd.MASP = sp.MASP
WHERE NUOCSX = 'Singapore'
GROUP BY hd.SOHD
HAVING COUNT(DISTINCT sp.MASP) = (SELECT COUNT(*) FROM SANPHAM WHERE NUOCSX = 'Singapore') 
--19. Tìm số hóa đơn trong năm 2006 đã mua ít nhất tất cả các sản phẩm do Singapore sản
--xuất.
SELECT hd.SOHD
FROM HOADON hd
JOIN CTHD cthd
ON hd.SOHD = cthd.SOHD
JOIN SANPHAM sp
ON cthd.MASP = sp.MASP
WHERE NUOCSX = 'Singapore' AND YEAR(hd.NGHD) = 2006
GROUP BY hd.SOHD
HAVING COUNT(DISTINCT sp.MASP) = (SELECT COUNT(*) FROM SANPHAM WHERE NUOCSX = 'Singapore') 
--20. Có bao nhiêu hóa đơn không phải của khách hàng đăng ký thành viên mua?
SELECT COUNT(t1.SOHD) AS SoHD FROM
(SELECT * FROM HOADON
EXCEPT
SELECT * FROM HOADON hd
WHERE EXISTS (
SELECT 1 FROM KHACHHANG kh
WHERE hd.MAKH = kh.MAKH
))t1
--21. Có bao nhiêu sản phẩm khác nhau được bán ra trong năm 2006.

SELECT COUNT(DISTINCT sp.MASP) SoSPBanRaTrong2006
FROM CTHD ctdh
JOIN HOADON hd
ON ctdh.SOHD = hd.SOHD
JOIN SANPHAM sp
ON ctdh.MASP = sp.MASP
WHERE YEAR(hd.NGHD) = 2006
--22. Cho biết trị giá hóa đơn cao nhất, thấp nhất là bao nhiêu ?
SELECT MAX(TRIGIA) CaoNhat,MIN(TRIGIA) ThapNhat FROM HOADON
--23. Trị giá trung bình của tất cả các hóa đơn được bán ra trong năm 2006 là bao nhiêu?
SELECT AVG(TRIGIA) TriGiaTrungBinh FROM HOADON
WHERE YEAR(NGHD) = 2006
--24. Tính doanh thu bán hàng trong năm 2006.
SELECT SUM(TRIGIA) DoanhThu FROM HOADON
WHERE YEAR(NGHD) = 2006
--25. Tìm số hóa đơn có trị giá cao nhất trong năm 2006.
SELECT TOP 1 WITH TIES SOHD
FROM HOADON
ORDER BY TRIGIA DESC
--26. Tìm họ tên khách hàng đã mua hóa đơn có trị giá cao nhất trong năm 2006.
SELECT TOP 1 WITH TIES HOTEN 
FROM KHACHHANG kh
FULL OUTER JOIN HOADON hd
ON kh.MAKH = hd.MAKH
WHERE YEAR(hd.NGHD) = 2006 
ORDER BY hd.TRIGIA DESC
--27. In ra danh sách 3 khách hàng đầu tiên (MAKH, HOTEN) sắp xếp theo doanh số giảm
--dần.
SELECT TOP 3 MAKH,HOTEN
FROM KHACHHANG 
ORDER BY DOANHSO DESC
--28. In ra danh sách các sản phẩm (MASP, TENSP) có giá bán bằng 1 trong 3 mức giá cao
--nhất.
SELECT MASP,TENSP
FROM SANPHAM
WHERE GIA IN(SELECT DISTINCT TOP 3 GIA FROM SANPHAM ORDER BY GIA DESC)


--29. In ra danh sách các sản phẩm (MASP, TENSP) do “Thai Lan” sản xuất có giá bằng 1
--trong 3 mức giá cao nhất (của tất cả các sản phẩm).
SELECT MASP,TENSP
FROM SANPHAM
WHERE GIA IN(SELECT DISTINCT TOP 3 GIA FROM SANPHAM ORDER BY GIA DESC) AND NUOCSX = 'Thai Lan'
--30. In ra danh sách các sản phẩm (MASP, TENSP) do “Trung Quoc” sản xuất có giá bằng 1
--trong 3 mức giá cao nhất (của sản phẩm do “Trung Quoc” sản xuất).
SELECT MASP,TENSP
FROM SANPHAM
WHERE GIA IN(SELECT DISTINCT TOP 3 GIA FROM SANPHAM WHERE NUOCSX = 'Trung Quoc' ORDER BY GIA DESC) AND NUOCSX = 'Trung Quoc'
--31. * In ra danh sách khách hàng nằm trong 3 hạng cao nhất (xếp hạng theo doanh số).
SELECT TOP 3 WITH TIES MAKH,HOTEN
FROM KHACHHANG
ORDER BY DOANHSO DESC
--32. Tính tổng số sản phẩm do “Trung Quoc” sản xuất.
SELECT COUNT(MASP) TongSoSPTQ
FROM SANPHAM
WHERE NUOCSX = 'Trung Quoc'
--33. Tính tổng số sản phẩm của từng nước sản xuất.
SELECT NUOCSX,COUNT(MASP) TongSoSP
FROM SANPHAM
GROUP BY NUOCSX
--34. Với từng nước sản xuất, tìm giá bán cao nhất, thấp nhất, trung bình của các sản phẩm.
SELECT NUOCSX,MAX(GIA) as GiaBanCaoNhat,MIN(GIA) as GiaBanThapNhat,AVG(GIA) as GiaBanTrungBinh
FROM SANPHAM
GROUP BY NUOCSX
--35. Tính doanh thu bán hàng mỗi ngày.
SELECT NGHD,SUM(TRIGIA) as Doanhthu
FROM HOADON
GROUP BY NGHD
--36. Tính tổng số lượng của từng sản phẩm bán ra trong tháng 10/2006.
SELECT sp.MASP,sp.TENSP,COUNT(cthd.SOHD) SoLuongSP FROM CTHD cthd
LEFT OUTER JOIN SANPHAM sp
ON cthd.MASP = sp.MASP
LEFT OUTER JOIN HOADON hd
ON cthd.SOHD = hd.SOHD
WHERE MONTH(hd.NGHD) = 10 AND YEAR(hd.NGHD) = 2006
GROUP BY sp.MASP,sp.TENSP

--37. Tính doanh thu bán hàng của từng tháng trong năm 2006.
SELECT MONTH(NGHD) Thang,SUM(TRIGIA) DoanhThu
FROM HOADON hd
WHERE YEAR(NGHD) = 2006
GROUP BY MONTH(NGHD)

--38. Tìm hóa đơn có mua ít nhất 4 sản phẩm khác nhau.
SELECT t1.SOHD FROM
(SELECT SOHD,COUNT(DISTINCT MASP) SoSP
FROM CTHD
GROUP BY SOHD) AS t1
WHERE t1.SoSP >=4
--39. Tìm hóa đơn có mua 3 sản phẩm do “Viet Nam” sản xuất (3 sản phẩm khác nhau).
SELECT t1.SOHD FROM
(SELECT SOHD,COUNT(DISTINCT sp.MASP) SoSP
FROM CTHD cthd
JOIN SANPHAM sp
ON cthd.MASP = sp.MASP
WHERE sp.NUOCSX = 'Viet Nam'
GROUP BY SOHD) AS t1
WHERE t1.SoSP = 3
--40. Tìm khách hàng (MAKH, HOTEN) có số lần mua hàng nhiều nhất.
SELECT TOP 1 MAKH,HOTEN FROM
(
SELECT hd.MAKH,HOTEN,COUNT(SOHD) as SoLanMua
FROM HOADON hd
JOIN KHACHHANG kh
ON hd.MAKH = kh.MAKH
GROUP BY hd.MAKH,HOTEN
)AS t1
ORDER BY SoLanMua DESC
--41. Tháng mấy trong năm 2006, doanh số bán hàng cao nhất ?
SELECT TOP 1 Thang FROM
(SELECT MONTH(NGHD) Thang,SUM(TRIGIA) DoanhThu
FROM HOADON hd
WHERE YEAR(NGHD) = 2006
GROUP BY MONTH(NGHD)) t1
ORDER BY DoanhThu DESC
--42. Tìm sản phẩm (MASP, TENSP) có tổng số lượng bán ra thấp nhất trong năm 2006.
SELECT TOP 1 WITH TIES MASP,TENSP,SoLuongSP FROM
(SELECT sp.MASP,sp.TENSP,COUNT(cthd.SOHD) SoLuongSP FROM CTHD cthd
LEFT OUTER JOIN SANPHAM sp
ON cthd.MASP = sp.MASP
LEFT OUTER JOIN HOADON hd
ON cthd.SOHD = hd.SOHD
WHERE YEAR(hd.NGHD) = 2006
GROUP BY sp.MASP,sp.TENSP) t1
ORDER BY SoLuongSP
--43. *Mỗi nước sản xuất, tìm sản phẩm (MASP,TENSP) có giá bán cao nhất.
SELECT t1.NUOCSX,sp.MASP,sp.TENSP FROM
(SELECT NUOCSX,MAX(GIA) as GIA
FROM SANPHAM
GROUP BY NUOCSX) AS t1
JOIN SANPHAM sp
ON t1.NUOCSX = sp.NUOCSX AND t1.GIA = sp.GIA
--44. Tìm nước sản xuất sản xuất ít nhất 3 sản phẩm có giá bán khác nhau.
SELECT NUOCSX FROM
(SELECT NUOCSX,COUNT(GIA) as SoGiaBan,COUNT(MASP) SoSP
FROM SANPHAM
GROUP BY NUOCSX)AS t1
WHERE SOGiaBan>= 3 AND SoSP >= 3
--45. *Trong 10 khách hàng có doanh số cao nhất, tìm khách hàng có số lần mua hàng nhiều
--nhất.
SELECT TOP 1 MAKH,HOTEN FROM
(SELECT t1.MAKH,HOTEN,COUNT(SOHD) as SoLanMuaHang
FROM
(SELECT TOP 10 MAKH,HOTEN
FROM KHACHHANG
ORDER BY DOANHSO DESC) AS t1
JOIN HOADON hd
ON t1.MAKH = hd.MAKH
GROUP BY t1.MAKH,HOTEN) AS t2


