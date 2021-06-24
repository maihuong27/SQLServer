create database QLBenhVien
use QLBenhVien

create table BenhNhan
(
	maBN char(5) primary key,
	tenBN varchar(20),
	gioiTinh varchar(10),
	soDT char(15),
	email varchar(20)
)

create table Khoa
(
	maKhoa char(5) primary key,
	tenKhoa varchar(20),
	diaChi varchar(20),
	tienNgay money,
	tongBenhNhan int
)

create table HoaDon
(
	soDH char(5) primary key,
	maBN char(5) foreign key references BenhNhan on update cascade on delete cascade,
	maKhoa char(5) foreign key references Khoa on update cascade on delete cascade,
	soNgay int
)

insert into BenhNhan values
('BN01', 'Benh nhan 1', 'Nam', '0917785386', 'maihuong@gmail.com'),
('BN02', 'Benh nhan 2', 'Nu', '0917785386', 'maihuong@gmail.com'),
('BN03', 'Benh nhan 3', 'Nam', '0917785386', 'maihuong@gmail.com')

insert into Khoa values
('K01', 'Khoa 1', 'Ha Noi', 100000, 40),
('K02', 'Khoa 2', 'Ha Noi', 70000, 30),
('K03', 'Khoa 3', 'Ha Noi', 850000, 50)

insert into HoaDon values
('HD01', 'BN01', 'K02', 10),
('HD02', 'BN01', 'K03', 7),
('HD03', 'BN01', 'K01', 5),
('HD04', 'BN02', 'K03', 9),
('HD05', 'BN03', 'K01', 1)

select * from BenhNhan
select * from Khoa
select * from HoaDon

--Cau2: ham dua ra so tien phai thanh toan, maBN nhap tu ban phim
create function Cau2(@maBn char(5))
returns money
as
	begin
		declare @tien money
		select @tien = sum(tienNgay*soNgay)
		from HoaDon inner join Khoa on HoaDon.maKhoa = Khoa.maKhoa
		where maBN = @maBn
		return @tien
	end

select * from Khoa
select * from HoaDon

select dbo.Cau2('BN02')

--Cau3: thu tuc nhap cho bang HoaDon voi cac thong tin nhap tu ban phim
--Kiem tra xem ten khoa nhap vao co dung khong. Neu khong dua ra thong bao

create proc Cau3 @soDH char(5), @maBN char(5), @tenKhoa varchar(20), @soNgay int
as
	begin
		if(not exists(select * from Khoa where tenKhoa = @tenKhoa))
			print 'Ten khoa khong hop le'
		else
			begin
				declare @maKhoa char(5)
				select @maKhoa = maKhoa from Khoa where tenKhoa = @tenKhoa
				insert into HoaDon values (@soDH, @maBN, @maKhoa, @soNgay)
			end
	end

select * from Khoa
select * from HoaDon

--TH1: Ten khoa khong hop le
exec Cau3 'HD06', 'BN02', 'Khoa 4', 20
--TH2: Chen thanh cong
exec Cau3 'HD06', 'BN02', 'Khoa 1', 20
select * from Khoa
select * from HoaDon

--Cau 4: Trigger insert 1 hoa don, cap nhat lai so luong benh nhan trong bang khoa
create trigger Cau4 on HoaDon for insert 
as
	begin
		declare @maKhoa char(5)
		select @maKhoa = maKhoa from inserted
		update Khoa set tongBenhNhan = tongBenhNhan + 1 where maKhoa = @maKhoa
	end

select * from Khoa
select * from HoaDon

insert into HoaDon values ('HD07', 'BN03', 'K02', 11)

select * from Khoa
select * from HoaDon