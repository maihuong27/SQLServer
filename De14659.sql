create database QLSinhVien_demo
use QLSinhVien_demo

create table Khoa
(
	maKhoa char(5) primary key,
	tenKhoa varchar(20)
)	

create table Lop
(
	maLop char(5) primary key,
	tenLop varchar(20),
	siSo int,
	maKhoa char(5) foreign key references Khoa on update cascade on delete cascade
)

create table SinhVien
(
	maSV char(5) primary key,
	hoTen varchar(20),
	ngaySinh date,
	gioiTinh varchar(20),
	maLop char(5) foreign key references Lop on update cascade on delete cascade
)

insert into Khoa values
('K01', 'Khoa 1'), ('K02', 'Khoa 2'), ('K03', 'Khoa 3')

insert into Lop values
('L01', 'Lop 1', 30, 'K02'),
('L02', 'Lop 2', 40, 'K01'),
('L03', 'Lop 3', 50, 'K03')

insert into SinhVien values
('SV01', 'Sinh vien 1', '1/1/2001', 'Nam', 'L01'),
('SV02', 'Sinh vien 2', '1/1/2002', 'Nu', 'L02'),
('SV03', 'Sinh vien 3', '1/1/2003', 'Nu', 'L03'),
('SV04', 'Sinh vien 4', '1/1/2004', 'Nu', 'L01'),
('SV05', 'Sinh vien 5', '1/1/2005', 'Nam', 'L02')

select * from Khoa
select * from Lop
select * from SinhVien

--Cau 2: Ham dua ra maSV, ho ten, tuoi voi ten khoa duoc nhap tu ban phim
create function Cau2(@tenKhoa varchar(20))
returns @thongtin table (
							maSV char(5),
							hoTen varchar(20),
							tuoi int
							)
as
	begin
		insert into @thongtin
		select maSV, hoTen, 'tuoi' = DATEDIFF(year, ngaySinh, getdate())
		from SinhVien inner join Lop on SinhVien.maLop = Lop.maLop
			inner join Khoa on Lop.maKhoa = Khoa.maKhoa
		where tenKhoa = @tenKhoa
		return
	end

select * from Khoa
select * from Lop
select * from SinhVien
select * from dbo.Cau2('Khoa 1')

--Cau 3: Tao thu tuc tim kiem sinh vien theo tuoi, bien nhap vao la TuTuoi, DenTuoi
create proc Cau3 @tuTuoi int, @denTuoi int
as
	begin
		select maSV, hoTen, ngaySinh, tenLop, tenKhoa, 'tuoi' = DATEDIFF(year, ngaySinh, GETDATE())
		from SinhVien inner join Lop on SinhVien.maLop = Lop.maLop
			inner join Khoa on Lop.maKhoa = Khoa.maKhoa
		where DATEDIFF(year, ngaySinh, getdate()) between @tuTuoi and @denTuoi
	end

select * from SinhVien
exec Cau3 16, 18

--Cau 4: Tao trigger insert sinh vien, cap nhat lai si so o
--bang lop, si so > 80 khong cho them dua ra canh bao
create trigger Cau4 on SinhVien for insert
as
	begin
		declare @maLop char(5), @soLuong int
		select @maLop = maLop from inserted
		select @soLuong = siSo from Lop where maLop = @maLop
		if(@soluong > 80)
			begin
				raiserror ('So luong sinh vien da du', 16, 1)
				rollback tran
			end
		else
			update Lop set siSo = siSo + 1 where maLop = @maLop
	end

insert into Lop values ('L04', 'Lop 4', 90, 'K01')
select * from Lop
select * from SinhVien
--TH1: So luong sinh vien lop hon 80
insert into SinhVien values ('SV06', 'Sinh vien 6', '1/1/2001', 'Nu', 'L04')

--Th2: Th dung
insert into SinhVien values ('SV06', 'Sinh vien 6', '1/1/2001', 'Nu', 'L01')
select * from Lop
select * from SinhVien
