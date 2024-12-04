USE QLBH_2020

--I. Ngôn ngữ định nghĩa dữ liệu (Data Definition Language): 
--11. Ngày mua hàng (NGHD) của một khách hàng thành viên sẽ lớn hơn hoặc bằng ngày 
--khách hàng đó đăng ký thành viên (NGDK).
CREATE TRIGGER trg_chk_kh
ON KHACHHANG
AFTER UPDATE
AS 
BEGIN
	DECLARE @NGDK SMALLDATETIME
	
	SELECT @NGDK = NGDK FROM inserted
	IF (@NGDK > ANY(SELECT NGHD FROM HOADON hd
					JOIN inserted ist ON hd.MAKH = ist.MAKH))
		BEGIN
			RAISERROR('Ngay mua hang phai lon hon hoac bang ngay dk khach hang',16,1);
			ROLLBACK;
		END
END

CREATE TRIGGER trg_chk_ng
ON HOADON
AFTER INSERT,UPDATE
AS
BEGIN
	IF NOT EXISTS(SELECT * FROM  inserted ist
				JOIN KHACHHANG nv ON nv.MAKH = ist.MAKH
				WHERE ist.NGHD > nv.NGDK)
		BEGIN
			RAISERROR('Ngay mua hang phai lon hon hoac bang ngay dk khach hang',16,1);
			ROLLBACK;
		END
END
--12. Ngày bán hàng (NGHD) của một nhân viên phải lớn hơn hoặc bằng ngày nhân viên đó 
--vào làm. 
CREATE TRIGGER trg_chk_nv
ON NHANVIEN
AFTER UPDATE
AS 
BEGIN
	DECLARE @NGVL SMALLDATETIME
	
	SELECT @NGVL = NGVL FROM inserted
	IF (@NGVL > ANY(SELECT NGHD FROM HOADON hd
					JOIN inserted ist ON hd.MANV = ist.MANV))
		BEGIN
			RAISERROR('Ngay mua hang phai lon hon hoac bang ngay dk khach hang',16,1);
			ROLLBACK;
		END
END

CREATE TRIGGER trg_chk_ngay
ON HOADON
AFTER INSERT,UPDATE
AS
BEGIN
	IF NOT EXISTS(SELECT * FROM  inserted ist
				JOIN NHANVIEN nv ON nv.MANV = ist.MANV
				WHERE ist.NGHD > nv.NGVL)
		BEGIN
			RAISERROR('Ngay mua hang phai lon hon hoac bang ngay dk khach hang',16,1);
			ROLLBACK;
		END
END

USE QUANLIGIAOVU_0208
--I. Ngôn ngữ định nghĩa dữ liệu (Data Definition Language):
--9.  Lớp trưởng của một lớp phải là học viên của lớp đó. 
CREATE TRIGGER trg_chk_loptruong
ON LOP
AFTER UPDATE
AS
BEGIN
	IF NOT EXISTS(SELECT * FROM HOCVIEN hv
					JOIN inserted ist ON hv.MAHV = ist.TRGLOP
					WHERE ist.MALOP = hv.MALOP)
		BEGIN
			RAISERROR('Lop Truong Phai La Hoc vien cua lop do',16,1);
			ROLLBACK TRANSACTION;
		END
END 

CREATE TRIGGER trg_del_hocvien
ON HOCVIEN
AFTER DELETE
AS 
BEGIN
	IF EXISTS	(SELECT * FROM deleted de 
				 JOIN LOP l 
				 ON de.MAHV = l.TRGLOP
				 WHERE de.MALOP = l.TRGLOP)
		BEGIN
			RAISERROR('Khong the xoa lop truong',16,1);
			ROLLBACK TRANSACTION;
		END
END
--10. Trưởng khoa phải là giáo viên thuộc khoa và có học vị “TS” hoặc “PTS”. 
CREATE TRIGGER trg_chk_trgkhoa
ON KHOA
AFTER UPDATE
AS 
BEGIN
	DECLARE @TRGKHOA VARCHAR(100)
	SELECT @TRGKHOA = TRGKHOA  FROM inserted
	IF NOT EXISTS(SELECT * FROM GIAOVIEN gv
					JOIN inserted ist ON gv.MAGV = ist.TRGKHOA
					WHERE ist.MAKHOA = gv.MAKHOA) OR @TRGKHOA NOT IN ('TS','PTS')
		BEGIN
				RAISERROR('Truong khoa phai thuoc khoa do va co hoc vi TS Hoac PTS',16,1);
				ROLLBACK;
		END
END

CREATE TRIGGER trg_del_gv
ON GIAOVIEN
AFTER DELETE
AS 
BEGIN
	IF EXISTS	(SELECT * FROM deleted de 
				 JOIN KHOA kh ON kh.TRGKHOA = de.MAGV
				 WHERE de.MAKHOA = kh.MAKHOA)
		BEGIN
			RAISERROR('Khong the xoa Truong Khoa'16,1);
			ROLLBACK TRANSACTION;
		END
END
--15. Học viên chỉ được thi một môn học nào đó khi lớp của học viên đã học xong môn học này. 
CREATE TRIGGER trg_chk_scomple
ON KETQUATHI
AFTER INSERT,UPDATE
AS 
BEGIN
	IF EXISTS(SELECT * FROM inserted ist
				JOIN GIANGDAY gd ON gd.MAMH = ist.MAMH
				JOIN HOCVIEN hv ON hv.MAHV = ist.MAHV
				WHERE gd.MALOP = hv.MALOP AND ist.NGTHI < gd.DENNGAY)
		BEGIN
			RAISERROR('Ngay thi phai lon hon ngay ket thuc',16,1);
			ROLLBACK TRANSACTION;
		END
END
--16. Mỗi học kỳ của một năm học, một lớp chỉ được học tối đa 3 môn. 
CREATE TRIGGER trg_chk_solanhoc
ON GIANGDAY
AFTER INSERT, UPDATE
AS 
BEGIN
	IF EXISTS   (SELECT * FROM
					(SELECT NAM,HOCKY,MALOP,COUNT(MAMH) somon FROM GIANGDAY
					GROUP BY NAM,HOCKY,MALOP) t_1
				WHERE somon > 3)
		BEGIN
			RAISERROR('So mon hoc cua moi lop trong mot ki cua mot nam hoc khong duoc lon hon 3',16,1);
			ROLLBACK;
		END
END
--17. Sỉ số của một lớp bằng với số lượng học viên thuộc lớp đó. 
CREATE TRIGGER trg_chk_soluonghocvien
ON LOP
AFTER UPDATE
AS
BEGIN
	IF EXISTS ( SELECT* FROM   (SELECT MALOP,COUNT(MAHV) SOHV
								FROM HOCVIEN
				                GROUP BY MALOP)t_1
				JOIN lOP l ON l.MALOP = t_1.MALOP
				WHERE l.SISO != t_1.SOHV)
		BEGIN
			RAISERROR('So hoc vien cua lop do phai bang si so cua lop',16,1);
			ROLLBACK;
		END
END

CREATE TRIGGER trg_hv
ON HOCVIEN
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	UPDATE LOP
	SET SISO = (SELECT COUNT(*)
				FROM HOCVIEN
				WHERE LOP.MALOP = HOCVIEN.MALOP)
END
--18. Trong quan hệ DIEUKIEN giá trị của thuộc tính MAMH và MAMH_TRUOC trong cùng một bộ 
--không được giống nhau (“A”,”A”) và cũng không tồn tại hai bộ (“A”,”B”) và (“B”,”A”). 
CREATE TRIGGER trg_chk_montienquyet
ON DIEUKIEN
AFTER INSERT, UPDATE
AS 
BEGIN
	DECLARE @MAMH VARCHAR(100),@MAMH_TRUOC VARCHAR(100)
	SELECT @MAMH = MAMH FROM inserted
	SELECT @MAMH_TRUOC = MAMH_TRUOC FROM inserted

	IF @MAMH_TRUOC = @MAMH OR EXISTS (SELECT * FROM inserted ist 
										JOIN DIEUKIEN dk
										ON ist.MAMH = dk.MAMH_TRUOC AND ist.MAMH_TRUOC = dk.MAMH)
		BEGIN
			RAISERROR('Khong thoa dieu kien',16,1);
			ROLLBACK TRANSACTION;
		END
END
--19. Các giáo viên có cùng học vị, học hàm, hệ số lương thì mức lương bằng nhau. 
CREATE TRIGGER trg_chk_gv
ON GIAOVIEN
AFTER INSERT, UPDATE
AS
BEGIN
	IF EXISTS  (SELECT* FROM inserted ist 
				JOIN GIAOVIEN gv
				ON ist.HOCVI = gv.HOCVI AND ist.HOCHAM = gv.HOCHAM AND ist.HESO = gv.HESO
				WHERE gv.MUCLUONG != ist.MUCLUONG)
		BEGIN
			RAISERROR('Khong thoa dieu kien',16,1);
			ROLLBACK TRANSACTION;
		END
END

--20. Học viên chỉ được thi lại (lần thi >1) khi điểm của lần thi trước đó dưới 5.
CREATE TRIGGER trg_lanthi
ON KETQUATHI
AFTER INSERT 
AS 
BEGIN
	DECLARE @LANTHI TINYINT
	
	SELECT @LANTHI = LANTHI FROM KETQUATHI
	
	IF @LANTHI > 1 AND EXISTS	(SELECT * FROM INSERTED ist 
								 JOIN KETQUATHI kq 
								 ON ist.MAHV = kq.MAHV AND ist.MAMH = kq.MAMH
								 WHERE kq.LANTHI = ist.LANTHI - 1 AND kq.LANTHI >= 5)
		BEGIN
			RAISERROR('Hoc vien chi duoc thi lai neu lan thi truoc do duoi 5',16,1);
			ROLLBACK TRANSACTION;
		END
END

--21. Ngày thi của lần thi sau phải lớn hơn ngày thi của lần thi trước (cùng học viên, cùng môn học). 
CREATE TRIGGER trg_lan_thi
ON KETQUATHI
AFTER INSERT,UPDATE
AS 
BEGIN
	IF EXISTS(	SELECT * FROM INSERTED ist 
				JOIN KETQUATHI kq 
				ON ist.MAHV = kq.MAHV AND ist.MAMH = kq.MAMH
				WHERE kq.LANTHI <ist.LANTHI AND kq.NGTHI > ist.NGTHI)
		BEGIN
			RAISERROR('Ngay thi sau phai lon hon ngay thi truoc',16,1);
			ROLLBACK TRANSACTION;
		END
END
--22. Học viên chỉ được thi những môn mà lớp của học viên đó đã học xong. 
CREATE TRIGGER trg_chk_scomple_2
ON KETQUATHI
AFTER INSERT,UPDATE
AS 
BEGIN
	IF EXISTS(SELECT * FROM inserted ist
				JOIN GIANGDAY gd ON gd.MAMH = ist.MAMH
				JOIN HOCVIEN hv ON hv.MAHV = ist.MAHV
				WHERE gd.MALOP = hv.MALOP AND ist.NGTHI < gd.DENNGAY)
		BEGIN
			RAISERROR('Ngay thi phai lon hon ngay ket thuc',16,1);
			ROLLBACK TRANSACTION;
		END
END
--23. Khi phân công giảng dạy một môn học, phải xét đến thứ tự trước sau giữa các môn học (sau khi học 
--xong những môn học phải học trước mới được học những môn liền sau). 
CREATE TRIGGER chk_bb
ON GIANGDAY
AFTER INSERT
AS 
BEGIN
	IF NOT EXISTS(	SELECT mon_hoc_sau,COUNT(*) AS so_mon 
					FROM (	SELECT gd.MAMH AS mon_hoc_sau,ist.MAMH FROM INSERTED ist
							JOIN GIANGDAY gd
							ON gd.MALOP = ist.MALOP
							WHERE gd.MAMH IN (	SELECT MAMH_TRUOC 
												FROM DIEUKIEN dk
												WHERE dk.MAMH = ist.MAMH)
							AND gd.DENNGAY < ist.TUNGAY) t
				GROUP BY mon_hoc_sau
				HAVING COUNT(*) = (	SELECT COUNT(*)
									FROM DIEUKIEN dk
									WHERE dk.MAMH = mon_hoc_sau))
		BEGIN
			RAISERROR('Phai hoc xong cac mon tien quyet truoc',16,1);
			ROLLBACK TRANSACTION;
		END
END


--24. Giáo viên chỉ được phân công dạy những môn thuộc khoa giáo viên đó phụ trách.
CREATE TRIGGER chk_ist_gd
ON GIANGDAY
AFTER INSERT
AS 
BEGIN
	
	IF NOT EXISTS(	SELECT * FROM inserted ist
					JOIN MONHOC mh ON ist.MAMH = mh.MAMH
					JOIN GIAOVIEN gv ON gv.MAGV = ist.MAGV
					WHERE gv.MAKHOA = mh.MAKHOA)
		BEGIN
			RAISERROR('Giao vien chi duoc day nhung mon do khoa do phu trach',16,1);
			ROLLBACK TRANSACTION;
		END
END

CREATE TRIGGER chk_del_gv
ON GIAOVIEN
AFTER DELETE
AS 
BEGIN
	IF EXISTS(	SELECT * FROM deleted del
				JOIN GIANGDAY gd ON gd.MAGV = del.MAGV)
		BEGIN
			RAISERROR('Giao vien nay da duoc phan cong',16,1);
			ROLLBACK TRANSACTION;
		END
END