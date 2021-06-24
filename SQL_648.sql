create database QLySinhVien
use QLySinhVien

create table Khoa 
(
	maKhoa char(5) primary key,
	tenKhoa varchar(20),
	sDT char(15)
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
	gioiTinh char(5),
	ngaySinh date,
	maLop char(5) foreign key references Lop on update cascade on delete cascade
)

insert into Khoa values
('K01', 'Khoa 1', '012345678'),
('K02', 'Khoa 2', '0123436546'),
('K03', 'Khoa 3', '091423546546')

insert into Lop values
('L04', 'Lop 4', 79, 'K02'),
('L02', 'Lop 2', 45, 'K03'),
('L03', 'Lop 3', 60, 'K01')

insert into SinhVien values
('SV01', 'Sinh vien 1', 'Nu', '1/1/2001', 'L02'),
('SV02', 'Sinh vien 2', 'Nam', '1/1/2001', 'L01'),
('SV03', 'Sinh vien 3', 'Nu', '1/1/2001', 'L02'),
('SV04', 'Sinh vien 4', 'Nam', '1/1/2001', 'L03'),
('SV05', 'Sinh vien 5', 'Nu', '1/1/2001', 'L01')

select * from Khoa
select * from Lop
select * from SinhVien

--Cau 2
alter function Cau2 (@tenKhoa varchar(20))
returns @danhsach table (
						maLop char(5),
						tenLop varchar(20),
						siSo int
						)
as
	begin
		declare @maKhoa char(5)
		select @maKhoa = maKhoa from Khoa where tenKhoa = @tenKhoa
		insert into @danhsach
		select maLop, tenLop, siSo from Lop where maKhoa = @maKhoa
		return
	end

select * from Khoa
select * from Lop

select * from dbo.Cau2('Khoa 1')

--Cau 3
create proc Cau3 @maSV char(5), @hoTen varchar(20), @ngaySinh date, @gioiTinh char(5), @tenLop varchar(20)
as
	begin
		if (not exists(select * from Lop where tenLop = @tenLop))
			begin
				print 'Khong ton tai lop!!!'
				return
			end
		declare @maLop char(5)
		select @maLop = maLop from Lop where tenLop = @tenLop
		insert into SinhVien values (@maSV, @hoTen, @gioiTinh, @ngaySinh, @maLop)
	end

--Sai ten lop
exec Cau3 'SV06', 'Sinh vien 6', '1/1/2001', 'Nu', 'Lop 7'

--Dung
exec Cau3 'SV06', 'Sinh vien 6', '1/1/2001', 'Nu', 'Lop 1'
select * from SinhVien

--Cau 4
create trigger Cau4 on SinhVien for update
as
	begin
		if(update(maLop))
			begin
			declare @maLopCu char(5), @maLopMoi char(5)
			select @maLopCu = maLop from deleted
			select @maLopMoi = maLop from inserted
				update Lop set siSo = siSo - 1 where maLop = @maLopCu
				update Lop set siSo = siSo + 1 where maLop = @maLopMoi
			declare @siSoMoi int
			select @siSoMoi = siSo from Lop where maLop = @maLopMoi
			if (@siSoMoi >= 80)
				begin
					raiserror ('Lop day!!', 16, 1)
					rollback transaction
				end
			end
	end

select * from Lop
select * from SinhVien
--Lop day
update SinhVien set maLop = 'L04' where maSV = 'SV06'

--Dung
update SinhVien set maLop = 'L03' where maSV = 'SV06'
select * from Lop
select * from SinhVien
