Create database PartShipmentDB
go
use PartShipmentDB
go
Create table Nhacungcap 
(
maNCC		varchar(5),
tenNCC	varchar(20), 
trangthai 	numeric(2),
thanhpho	varchar(30),
Constraint PKNcc primary key (maNCC)
)


create table Phutung 
(
 maPT		varchar(5),
 tenPT	varchar(10),
 mausac	varchar(10),
 khoiluong	float,
 thanhpho	 varchar(30),
 Constraint PKPt Primary Key (maPT) 
)


Create table Vanchuyen 
(
maNCC		varchar(5) ,
maPT		varchar(5),
soluong	numeric(5), 
Constraint PKVc primary key (maNCC,maPT),
Constraint FKShip1 foreign key (maNCC) references Nhacungcap (maNCC),
Constraint FKShip2 foreign key (maPT) references Phutung (maPT)
)


insert into Nhacungcap values ('S1','Smith','20','London')
insert into Nhacungcap values ('S2','Jones','10','Paris')
insert into Nhacungcap values ('S3','Blake','30','Paris')
insert into Nhacungcap values ('S4','Clark','20','London')
insert into Nhacungcap values ('S5','Adams','30','Athens')


Insert  into Phutung values  ( 'P1' , 'Nut' , 'Red' , 12.0 , 'London')
Insert  into Phutung values  ( 'P2' , 'Bolt' , 'Green', 17.0 , 'Paris')
Insert  into Phutung values  ( 'P3' , 'Screw' , 'Blue', 17.0 , 'Oslo')
Insert  into Phutung values  ( 'P4' , 'Screw' , 'Red' , 14.0 , 'London')
Insert  into Phutung values  ( 'P5' , 'Cam' , 'Blue' , 12.0 , 'Paris')
Insert  into Phutung values  ( 'P6' , 'Cog' , 'Red' , 19.0 , 'London')



Insert into Vanchuyen values ('S1','P1',300)
Insert into Vanchuyen values ('S1','P2',200)
Insert into Vanchuyen values ('S1','P3',400)
Insert into Vanchuyen values ('S1','P4',200)
Insert into Vanchuyen values ('S1','P5',100)
Insert into Vanchuyen values ('S1','P6',100)
Insert into Vanchuyen values ('S2','P1',300)
Insert into Vanchuyen values ('S2','P2',400)
Insert into Vanchuyen values ('S3','P2',200)
Insert into Vanchuyen values ('S4','P2',200)
Insert into Vanchuyen values ('S4','P4',300)
Insert into Vanchuyen values ('S4','P5',400)

select * from Vanchuyen 
SELECT * FROM Nhacungcap
SELECT * FROM Phutung
	--1. Hiển thị thông tin (maNCC, tenNCC, thanhpho) của tất cả nhà cung cấp.
	SELECT maNCC,tenNCC,thanhpho from Nhacungcap
	--2. Hiển thị thông tin của tất cả các phụ tùng.
	SELECT * FROM Phutung
	--3. Hiển thị thông tin các nhà cung cấp ở thành phố London.
	SELECT * FROM Nhacungcap
	WHERE thanhpho = 'London'
	--4. Hiển thị mã phụ tùng, tên và màu sắc của tất cả các phụ tùng ở thành 
	--phố Paris.
	SELECT maPT,tenPT,mausac FROM Phutung
	WHERE thanhpho = 'Paris'
	--5. Hiển thị mã phụ tùng, tên, khối lượng của những phụ tùng có khối 
	--lượng lớn hơn 15.
	SELECT maPT,tenPT,khoiluong FROM Phutung
	WHERE khoiluong > 15
	--6. Tìm những phụ tùng (maPT, tenPt, mausac) có khối lượng lớn hơn 15, 
	--không phải màu đỏ (red). 
	SELECT maPT,tenPT,mausac FROM Phutung
	WHERE NOT (mausac = 'Red' AND khoiluong<=15)
	--7. Tìm những phụ tùng (maPT, tenPt, mausac) có khối lượng lớn hơn 15, 
	--màu sắc khác màu đỏ (red) và xanh (green).
	SELECT maPT,tenPT,mausac FROM Phutung
	WHERE (khoiluong>15) AND (mausac NOT IN ('Red','Green'))
	--8. Hiển thị những phụ tùng (maPT, tenPT, khối lượng) có khối lượng lớn 
	--hơn 15 và nhỏ hơn 20, sắp xếp theo tên phụ tùng.
	SELECT maPT,tenPT,khoiluong FROM Phutung
	WHERE (khoiluong>15) AND (khoiluong<20)
	ORDER BY tenPT
	--9. Hiển thị những phụ tùng được vận chuyển bởi nhà cung cấp có mã số S1. 
	--Không hiển thị kết quả trùng. (sử dụng phép kết).
	SELECT DISTINCT vc.maPT,pt.tenPT,pt.mausac,pt.khoiluong,pt.thanhpho	
	FROM Vanchuyen vc INNER JOIN
	Phutung pt ON vc.maPT = pt.maPT
	WHERE vc.maNCC ='S1'
	--10. Hiển thị những nhà cung cấp vận chuyển phụ tùng có mã là P1 (sử dụng 
	--phép kết).
	SELECT ncc.maNCC,ncc.tenNCC,ncc.trangthai,ncc.thanhpho
	FROM Nhacungcap ncc INNER JOIN
	Vanchuyen vc ON ncc.maNCC = vc.maNCC
	WHERE vc.maPT = 'P1'
	--11. Hiển thị thông tin nhà cung cấp ở thành phố London và có vận chuyển 
	--phụ tùng của thành phố London. Không hiển thị kết quả trùng. (Sử dụng 
	--phép kết)
	SELECT DISTINCT ncc.maNCC,ncc.tenNCC,ncc.trangthai
	FROM Nhacungcap ncc
	INNER JOIN Vanchuyen vc ON vc.maNCC = ncc.maNCC
	INNER JOIN Phutung pt ON pt.maPT =vc.maPT
	WHERE ncc.thanhpho = 'London' AND pt.thanhpho = 'London'
	--12. Lặp lại câu 9 nhưng sử dụng toán tử IN.
	SELECT DISTINCT vc.maPT,pt.tenPT,pt.mausac,pt.khoiluong,pt.thanhpho	
	FROM Vanchuyen vc INNER JOIN
	Phutung pt ON vc.maPT = pt.maPT
	WHERE vc.maNCC IN('S1')
	--13. Lặp lại câu 10 nhưng sử dụng toán tử IN
	SELECT ncc.maNCC,ncc.tenNCC,ncc.trangthai,ncc.thanhpho
	FROM Nhacungcap ncc INNER JOIN
	Vanchuyen vc ON ncc.maNCC = vc.maNCC
	WHERE vc.maPT IN ('P1')
	--14. Lặp lại câu 9 nhưng sử dụng toán tử EXISTS
	SELECT *
	FROM Phutung pt
	WHERE EXISTS
	(
		SELECT 1
		FROM Vanchuyen vc
		WHERE pt.maPT = vc.maPT AND vc.maNCC = 'S1'
	)
	
	--15. Lặp lại câu 10 nhưng sử dụng toán tử EXISTS
	SELECT * 
	FROM Nhacungcap ncc
	WHERE EXISTS
	(
		SELECT 1
		FROM Vanchuyen vc
		WHERE vc.maNCC = ncc.maNCC AND vc.maPT = 'P1'
	)
	--16. Lặp lại câu 11 nhưng sử dụng truy vấn con. Sử dụng toán tử IN.
	SELECT DISTINCT t_1.maNCC,t_1.tenNCC,t_1.trangthai FROM(
	SELECT ncc.maNCC,ncc.tenNCC,ncc.trangthai,ncc.thanhpho,vc.maPT
	FROM Nhacungcap ncc INNER JOIN 
	Vanchuyen vc ON ncc.maNCC = vc.maNCC) t_1
	INNER JOIN Phutung pt ON pt.maPT = t_1.maPT
	where t_1.thanhpho IN ('London') AND pt.thanhpho IN ('London')
	--17. Lặp lại câu 11 nhưng dùng truy vấn con. Sử dụng toán tử EXISTS.
	SELECT ncc.maNCC,ncc.tenNCC,ncc.trangthai
	FROM Nhacungcap ncc
	WHERE EXISTS (
		SELECT 1 
		FROM Phutung pt
		INNER JOIN Vanchuyen vc ON vc.maPT = pt.maPT
		WHERE pt.thanhpho = 'London'
	) AND ncc.thanhpho = 'London'