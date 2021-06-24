create database QLSinhVien_De3
use QLSinhVien_De3

create table Khoa
(
	maKhoa char(5) primary key,
	tenKhoa varchar(20)
)

create table Lop 
(
	maLop char(5) primary key,
	tenLop varchar(20),
	siSo int default 0,
	maKhoa char(5) foreign key references Khoa on update cascade on delete cascade
)

create table SinhVien
(
	maSV char(5) primary key,
	hoTen varchar(20),
	ngaySinh date,
	gioiTinh bit,
	maLop char(5) foreign key references Lop on update cascade on delete cascade
)

insert into Khoa values ('K01', 'Khoa 1'), ('K02', 'Khoa 2')

insert into Lop values
('L01', 'Lop 1', 45, 'K01'),
('L02', 'Lop 2', 30, 'K02')

insert into SinhVien values 
('SV01', 'Sinh vien 1', '1/1/2001', 1, 'L01'),
('SV02', 'Sinh vien 2', '2/2/2002', 0, 'L02'),
('SV03', 'Sinh vien 3', '3/3/2003', 1, 'L02'),
('SV04', 'Sinh vien 4', '4/4/2004', 0, 'L01'),
('SV05', 'Sinh vien 5', '5/5/2005', 1, 'L02')

select * from Khoa
select * from Lop
select * from SinhVien

--Hãy tạo View đưa ra thống kê số lớp của từng khoa gồm các thông tin: TenKhoa, Số lớp.
create view Cau2
as
	select tenKhoa, 'soLop' = count(*)
	from Khoa inner join Lop on Khoa.maKhoa = Lop.maKhoa
	group by tenKhoa

select * from Cau2

/*
Viết hàm với tham số truyền vào là MaKhoa, hàm trả về một bảng gồm các thông tin:
MaSV, HoTen, NgaySinh, GioiTinh (là “Nam“ hoặc “Nữ“), TenLop, TenKhoa.
*/
create function Cau3(@maKhoa char(5))
returns @thongTin table (
							maSV char(5),
							hoTen varchar(20),
							ngaySinh date,
							gioiTinh varchar(10),
							tenLop varchar(20),
							tenKhoa varchar(20)
							)
as
	begin
		insert into @thongTin
		select maSV, hoTen, ngaySinh, case gioiTinh when 1 then 'Nu' when 0 then 'Nam' end, 
			tenLop, tenKhoa
		from SinhVien inner join Lop on SinhVien.maLop = Lop.maLop 
			inner join Khoa on Lop.maKhoa = Khoa.maKhoa
		where Khoa.maKhoa = @maKhoa
		return
	end

select * from Khoa
select * from Lop
select * from SinhVien
select * from Cau3('K02')

/*
Hãy tạo thủ tục lưu trữ tìm kiếm sinh viên theo khoảng tuổi và lớp (Với 3 tham số vào là: 
TuTuoi và DenTuoi và tên lớp). Kết quả tìm được sẽ đưa ra một danh sách gồm: MaSV, HoTen, 
NgaySinh,TenLop,TenKhoa, Tuoi
*/

create proc Cau4(@tuTuoi int, @denTuoi int, @tenLop varchar(20))
as
	begin
		select maSV, hoTen, ngaySinh tenLop, tenKhoa, 'tuoi' = datediff(year, ngaySinh, GETDATE())
		from SinhVien inner join Lop on SinhVien.maLop = Lop.maLop
			inner join Khoa on Lop.maKhoa = Khoa.maKhoa
		where tenLop = @tenLop and (datediff(year, ngaySinh, GETDATE()) between @tuTuoi and @denTuoi)
	end

exec Cau4 18, 30, 'Lop 2'

/*
Tạo Hàm Đưa ra những sinh viên (của một khoa nào đó với tên khoa nhập từ bàn phím) gồm: 
MaSV, HoTen, Tuổi (năm hiện tại – năm sinh).
*/

create function Cau4_b(@tenKhoa varchar(20))
returns @sinhVien table (
							maSV char(5),
							hoTen varchar(20),
							tuoi int
							)
as
	begin
		insert into @sinhVien
		select maSV, hoTen, 'tuoi' = datediff(year, ngaySinh, getdate())
		from SinhVien inner join Lop on SinhVien.maLop = Lop.maLop
			inner join Khoa on Lop.maKhoa = Khoa.maKhoa
		where tenKhoa = @tenKhoa
		return
	end

select * from Cau4_b('Khoa 2')
