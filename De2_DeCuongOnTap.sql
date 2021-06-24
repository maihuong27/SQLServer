create database QLBenhVien_De2
use QLBenhVien_De2

create table BenhVien
(
	maBV char(5) primary key,
	tenBV varchar(20)
)

create table KhoaKham 
(
	maKhoa char(5) primary key,
	tenKhoa varchar(20),
	soBenhNhanh int,
	maBV char(5) foreign key references BenhVien on update cascade on delete cascade
)

create table BenhNhan
(
	maBN char(5) primary key,
	hoTen varchar(20),
	ngaySinh date,
	gioiTinh varchar(10),
	soNgayNV int, 
	maKhoa char(5) foreign key references KhoaKham on update cascade on delete cascade
)

insert into BenhVien values ('BV01', 'Benh vien 1'), ('BV02', 'Benh vien 2')

insert into KhoaKham values
('KK01', 'Khoa kham 1', 50, 'BV01'),
('KK02', 'Khoa kham 2', 45, 'BV02')

insert into BenhNhan values
('BN01', 'Benh nhan 1', '1/1/2001', 'Nu', 15, 'KK01'),
('BN02', 'Benh nhan 2', '2/2/2002', 'Nam', 4, 'KK02'),
('BN03', 'Benh nhan 3', '3/3/2003', 'Nu', 2, 'KK02'),
('BN04', 'Benh nhan 4', '4/4/2004', 'Nam', 7, 'KK01'),
('BN05', 'Benh nhan 5', '5/5/2005', 'Nu', 1, 'KK02')

select * from BenhVien
select * from KhoaKham
select * from benhNhan


/*
Hãy tạo Hàm đưa ra thống kê số bệnh nhân Nữ của từng khoa khám gồm các thông tin: 
MaKhoa, TenKhoa, Số_người. Tham số truyền vào là mã khoa.
*/

create function Cau2(@maKhoa char(5))
returns @thongKe table (
						maKhoa char(5),
						tenKhoa varchar(20),
						soNguoi int
						)
as
	begin
		insert into @thongKe
		select KhoaKham.maKhoa, tenKhoa, 'soNguoi' = count(*)
		from BenhNhan inner join KhoaKham on BenhNhan.maKhoa = KhoaKham.maKhoa
		where gioiTinh = 'Nu' and KhoaKham.maKhoa = @maKhoa
		group by KhoaKham.maKhoa, tenKhoa
		return
	end

select * from dbo.Cau2('KK02')

/*	
Hãy tạo thủ tục lưu trữ tìm kiếm bệnh nhân theo khoảng tuổi (Với 2 tham số vào là: TuTuoi và 
DenTuoi). Kết quả tìm được sẽ đưa ra một danh sách gồm: MaBN, HoTen, NgaySinh,Tenkhoa, Tuoi.
*/

create proc Cau3 @tuTuoi int, @denTuoi int
as
	begin
		select maBN, hoTen, ngaySinh, tenKhoa, 'tuoi' = datediff(year, ngaySinh, getdate())
		from BenhNhan inner join KhoaKham on BenhNhan.maKhoa = KhoaKham.maKhoa
		where datediff(year, ngaySinh, getdate()) between @tuTuoi and @denTuoi
	end

select * from BenhVien
select * from KhoaKham
select * from benhNhan
exec Cau3 18, 30