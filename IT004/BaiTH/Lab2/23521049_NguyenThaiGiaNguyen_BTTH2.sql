USE QLBH_2020
--III. Ngôn ngữ truy vấn dữ liệu:
--1. In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quoc” sản xuất.
SELECT MASP,TENSP FROM SANPHAM
WHERE NUOCSX = 'Trung Quoc'
--2. In ra danh sách các sản phẩm (MASP, TENSP) có đơn vị tính là “cay”, ”quyen”.
SELECT MASP,TENSP FROM SANPHAM
WHERE DVT IN ('cay','quyen')
--3. In ra danh sách các sản phẩm (MASP,TENSP) có mã sản phẩm bắt đầu là “B” và kết
--thúc là “01”.
SELECT MASP,TENSP FROM SANPHAM
WHERE MASP LIKE 'B%01'
--4. In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quốc” sản xuất có giá từ 30.000
--đến 40.000.
SELECT MASP,TENSP FROM SANPHAM
WHERE NUOCSX = 'Trung Quoc' AND GIA >= 30000 AND GIA <= 40000
--5. In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quoc” hoặc “Thai Lan” sản
--xuất có giá từ 30.000 đến 40.000.
SELECT MASP,TENSP FROM SANPHAM
WHERE NUOCSX IN ('Trung Quoc','Thai Lan') AND GIA >= 30000 AND GIA <= 40000
--6. In ra các số hóa đơn, trị giá hóa đơn bán ra trong ngày 1/1/2007 và ngày 2/1/2007.
SELECT SOHD,TRIGIA FROM HOADON
WHERE NGHD <= '2007-01-02' AND NGHD >= '2007-01-01'
--7. In ra các số hóa đơn, trị giá hóa đơn trong tháng 1/2007, sắp xếp theo ngày (tăng dần) và
--trị giá của hóa đơn (giảm dần).
SELECT SOHD,TRIGIA FROM HOADON
WHERE MONTH(NGHD) = 1 AND YEAR(NGHD) = 2007 
ORDER BY NGHD, TRIGIA DESC
--8. In ra danh sách các khách hàng (MAKH, HOTEN) đã mua hàng trong ngày 1/1/2007.
SELECT kh.MAKH,HOTEN FROM HOADON hd
INNER JOIN KHACHHANG kh
ON hd.MAKH = kh.MAKH
WHERE NGHD >= '2007-01-01'
--9. In ra số hóa đơn, trị giá các hóa đơn do nhân viên có tên “Nguyen Van B” lập trong ngày
--28/10/2006.
SELECT SOHD,TRIGIA FROM HOADON hd
INNER JOIN NHANVIEN nv
ON hd.MANV = nv.MANV
WHERE HOTEN = 'Nguyen Van B' AND NGHD >= '2006-10-28'
--10. In ra danh sách các sản phẩm (MASP,TENSP) được khách hàng có tên “Nguyen Van A”
--mua trong tháng 10/2006.
SELECT SOHD,TRIGIA FROM HOADON hd
INNER JOIN NHANVIEN nv
ON hd.MANV = nv.MANV
WHERE HOTEN = 'Nguyen Van B' AND MONTH(NGHD) = 10 AND YEAR(NGHD) = 2006
--11. Tìm các số hóa đơn đã mua sản phẩm có mã số “BB01” hoặc “BB02”.
SELECT SOHD FROM CTHD
WHERE MASP = 'BB01'
UNION
SELECT SOHD FROM CTHD
WHERE MASP = 'BB02'
--12. Tìm các số hóa đơn đã mua sản phẩm có mã số “BB01” hoặc “BB02”, mỗi sản phẩm
--mua với số lượng từ 10 đến 20.
SELECT DISTINCT SOHD FROM CTHD
WHERE MASP IN('BB01','BB02') AND SL>=10 AND SL<=20
--13. Tìm các số hóa đơn mua cùng lúc 2 sản phẩm có mã số “BB01” và “BB02”, mỗi sản
--phẩm mua với số lượng từ 10 đến 20.
SELECT DISTINCT SOHD FROM CTHD
WHERE MASP ='BB01' AND SL>=10 AND SL<=20
INTERSECT
SELECT DISTINCT SOHD FROM CTHD
WHERE MASP ='BB02' AND SL>=10 AND SL<=20
--14. In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quoc” sản xuất hoặc các sản
--phẩm được bán ra trong ngày 1/1/2007.
SELECT DISTINCT sp.MASP,TENSP FROM SANPHAM sp
INNER JOIN CTHD cthd
ON sp.MASP = cthd.MASP
INNER JOIN HOADON hd
ON cthd.SOHD = hd.SOHD
WHERE NUOCSX = 'Trung Quoc' OR NGHD = '2007-1-1'
--15. In ra danh sách các sản phẩm (MASP,TENSP) không bán được.
SELECT MASP,TENSP FROM SANPHAM
EXCEPT
SELECT MASP,TENSP 
FROM SANPHAM
WHERE EXISTS(
SELECT 1 FROM CTHD
WHERE SANPHAM.MASP = CTHD.MASP
)
--16. In ra danh sách các sản phẩm (MASP,TENSP) không bán được trong năm 2006.
SELECT MASP,TENSP FROM SANPHAM
EXCEPT
SELECT MASP,TENSP 
FROM SANPHAM
WHERE EXISTS(
SELECT 1 FROM CTHD cthd
JOIN HOADON hd
ON hd.SOHD = cthd.SOHD
WHERE SANPHAM.MASP = CTHD.MASP AND YEAR(hd.NGHD) = 2006
)




--17. In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quoc” sản xuất không bán
--được trong năm 2006.
SELECT MASP,TENSP FROM SANPHAM
WHERE NUOCSX = 'Trung Quoc'
EXCEPT
SELECT MASP,TENSP 
FROM SANPHAM
WHERE EXISTS(
SELECT 1 FROM CTHD cthd
JOIN HOADON hd
ON hd.SOHD = cthd.SOHD
WHERE SANPHAM.MASP = CTHD.MASP AND YEAR(hd.NGHD) = 2006
)