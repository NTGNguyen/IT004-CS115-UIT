--1. Tạo database tên BAITHI gồm có 4 table NHACUNGCAP, DUOCPHAM, PHIEUNHAP,
--CTPN. Tạo khóa chính, khóa ngoại cho các table đó (2đ).

CREATE DATABASE BAITHI
USE BAITHI

CREATE TABLE NHACUNGCAP(
	MANCC VARCHAR(100) PRIMARY KEY NOT NULL,
	TENNCC VARCHAR(100),
	QUOCGIA VARCHAR(100),
	LOAINCC VARCHAR(100)
)

CREATE TABLE DUOCPHAM(
	MADP VARCHAR(100) PRIMARY KEY NOT NULL,
	TENDP VARCHAR(100),
	LOAIDP VARCHAR(100),
	GIA FLOAT,
)

CREATE TABLE PHIEUNHAP(
	SOPN VARCHAR(100) PRIMARY KEY NOT NULL,
	NGNHAP DATETIME,
	MANCC VARCHAR(100) FOREIGN KEY REFERENCES NHACUNGCAP(MANCC),
	LOAINHAP VARCHAR(100),
)

CREATE TABLE CTPN(
	SOPN VARCHAR(100) FOREIGN KEY REFERENCES PHIEUNHAP(SOPN),
	MADP VARCHAR(100) FOREIGN KEY REFERENCES DUOCPHAM(MADP),
	SOLUONG INT,
)
--2. Nhập dữ liệu cho 4 table như đề bài (1đ).

INSERT INTO NHACUNGCAP(MANCC,TENNCC,QUOCGIA,LOAINCC)
VALUES
('NCC01','Phuc Hung','Viet Nam','Thuong Xuyen'),
('NCC02','J. B. Pharmaceuticals','India','Vang Lai'),
('NCC03','Sapharce','Singapore','Vang Lai')

INSERT INTO DUOCPHAM(MADP,TENDP,LOAIDP,GIA)
VALUES
('DP01','Thuoc ho PH','Siro',120000),
('DP02','Zecuf Herbal CouchRemedy','Vien nen',200000),
('DP03','Cotrim','Vien sui',120000)

INSERT INTO PHIEUNHAP(SOPN,NGNHAP,MANCC,LOAINHAP)
VALUES
('00001','2021-12-01 14:30:15','NCC01','Noi dia'),
('00002','2021-12-01 14:30:15','NCC03','Nhap khau'),
('00003','2021-12-01 14:30:15','NCC02','Nhap khau')

INSERT INTO CTPN(SOPN,MADP,SOLUONG)
VALUES
('00001','DP01','100'),
('00001','DP02','200'),
('00003','DP03','543')

--3. Hiện thực ràng buộc toàn vẹn sau: Tất cả các dược phẩm có loại là Siro đều có giá lớn hơn
--100.000đ

CREATE TRIGGER trg_chk
ON DUOCPHAM 
AFTER INSERT, UPDATE
AS BEGIN 
	IF EXISTS(SELECT * FROM INSERTED ist WHERE ist.GIA < 200 AND ist.LOAIDP = 'Siro')
	BEGIN
		RAISERROR('..',16,1);
		ROLLBACK;
	END
END;
--Hiện thực ràng buộc toàn vẹn sau: Phiếu nhập của những nhà cung cấp ở những quốc gia
--khác Việt Nam đều có loại nhập là Nhập khẩu. (2đ).

CREATE TRIGGER trg_chk_qg
ON PHIEUNHAP
AFTER INSERT,UPDATE
AS BEGIN
	IF EXISTS(	SELECT * FROM inserted ist 
				JOIN NHACUNGCAP ncc ON ncc.MANCC = ist.MANCC
				WHERE ncc.QUOCGIA NOT IN ('Viet Nam') AND ist.LOAINHAP NOT IN ('Nhap khau'))
	BEGIN
		RAISERROR('...',16,1);
		ROLLBACK;
	END
END;

--5. Tìm tất cả các phiếu nhập có ngày nhập trong tháng 12 năm 2017, sắp xếp kết quả tăng dần
--theo ngày nhập (1đ)
SELECT * FROM PHIEUNHAP pn
WHERE MONTH(pn.NGNHAP) = 12
ORDER BY NGNHAP

--6. Tìm dược phẩm được nhập số lượng nhiều nhất trong năm 2017 (1đ).
SELECT TOP 1 MADP,SUM(SOLUONG) so_luong_nhap 
FROM CTPN
GROUP BY MADP
ORDER BY SUM(SOLUONG) DESC
--7. Tìm dược phẩm chỉ có nhà cung cấp thường xuyên (LOAINCC là Thuong xuyen) cung cấp,
--nhà cung cấp vãng lai (LOAINCC là Vang lai) không cung cấp. (1đ).
SELECT dp.MADP 
FROM DUOCPHAM dp
JOIN CTPN ctpn
ON dp.MADP = ctpn.MADP
JOIN PHIEUNHAP pn
ON ctpn.SOPN = pn.SOPN
JOIN NHACUNGCAP ncc
ON ncc.MANCC = pn.MANCC
WHERE LOAINCC = 'Thuong xuyen'
--8. Tìm nhà cung cấp đã từng cung cấp tất cả những dược phẩm có giá trên 100.000đ trong năm
--2017 (1đ).
SELECT dp.MADP 
FROM DUOCPHAM dp
JOIN CTPN ctpn
ON dp.MADP = ctpn.MADP
JOIN PHIEUNHAP pn
ON ctpn.SOPN = pn.SOPN
JOIN NHACUNGCAP ncc
ON ncc.MANCC = pn.MANCC
WHERE YEAR(pn.NGNHAP) = 2017
AND dp.GIA > 100000