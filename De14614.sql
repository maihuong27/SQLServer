create database QLNhapXuat
use QLNhapXuat

create table SanPham
(
	maSP char(5) primary key,
	tenSP varchar(20),
	mauSac varchar(20),
	soLuong int,
	giaBan money
)

create table Nhap
(
	soHDN char(5) primary key,
	maSP char(5) foreign key references SanPham on update cascade on delete cascade,
	soLuongN int,
	ngayN date
)

create table Xuat
(
	soHDX char(5) primary key,
	maSP char(5) foreign key references SanPham on update cascade on delete cascade,
	soLuongX int,
	ngayX date
)

insert into SanPham values
('SP01', 'San pham 1', 'Mau xanh', 200, 100000),
('SP02', 'San pham 2', 'Mau do', 1000, 250000),
('SP03', 'San pham 3', 'Mau tim', 500, 700000)

insert into Nhap values
('N01', 'SP01', 100, '1/1/2021'),
('N02', 'SP01', 10, '3/4/2019'),
('N03', 'SP02', 70, '7/7/2015')

insert into Xuat values
('X01', 'SP02', 20, '1/4/2019'),
('X02', 'SP03', 50, '8/8/2020')

select * from SanPham
select * from Nhap 
select * from Xuat

--Ham tinh tong tien nhap cua 1 cong ty
create function Cau2(@tenSP varchar(20))
returns money
as
	begin
		declare @tongTien money
		select @tongTien = sum(soLuongN*giaBan) 
		from Nhap inner join SanPham on Nhap.maSP = SanPham.maSP
		where tenSP = @tenSP
		return @tongTien
	end

select dbo.Cau2('San pham 2')

--Thu tuc them moi san pham
create proc Cau3 @maSP char(5), @tenSP varchar(20), @mauSac varchar(20), @soLuong int, @giaBan money, @kq int output
as
	begin
		if(exists(select * from SanPham where maSP = @maSP))
			begin
				print 'San pha da ton tai'
				set @kq = 1
			end
		else
			begin
				insert into SanPham values (@maSP, @tenSP, @mauSac, @soLuong, @giaBan)
				set @kq = 0
			end
	end

--TH1: San pham da ton tai
declare @check int
exec Cau3 'SP01', 'San pham 1', 'Mau vang', 100, 340000, @check output
select @check
--TH2: Chen thanh cong
declare @check int
exec Cau3 'SP04', 'San pham 4', 'Mau vang', 100, 340000, @check output
select @check

select * from SanPham

--Tao trigger insert cho bang Xuat. Kiem tra so luong Xuat < so Luong 
alter trigger Cau4 on Xuat for insert
as
	begin
		declare @soLuong int, @soLuongX int, @maSP char(20)
		select @soLuongX = soLuongX, @maSP = maSP from inserted
		select @soLuong = soLuong from SanPham where maSP = @maSP
		if(@soLuongX > @soLuong)
			begin
				raiserror ('So luong hang khong du', 16, 1)
				rollback tran
			end
		else
			update SanPham set soLuong = soLuong - @soLuongX where maSP = @maSP
	end

select * from SanPham
select * from Xuat

--TH1: So luong khong du
insert into Xuat values ('X03', 'SP03', 1000000, '1/1/2020')
--TH2:Update va chen thanh cong
insert into Xuat values ('X03', 'SP03', 100, '1/1/2020')
select * from SanPham
select * from Xuat
