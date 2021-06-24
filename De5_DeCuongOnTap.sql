create database QLSach_De5
use QLSach_De5

create table TacGia
(
	maTG char(5) primary key,
	tenTG varchar(20),
	soLuongCo int
)

create table NhaXB
(
	maNXB char(5) primary key,
	tenNXB varchar(20),
	soLuongCo int
)

create table Sach
(
	maSach char(5) primary key,
	tenSach varchar(20),
	maNXB char(5) foreign key references NhaXB on update cascade on delete cascade,
	maTG char(5) foreign key references TacGia on update cascade on delete cascade,
	namXB int,
	soLuong int,
	donGia money
)

insert into TacGia values
('TG01', 'Tac gia 1', 10),
('TG02', 'Tac gia 2', 5),
('TG03', 'Tac gia 3', 7)

insert into NhaXB values
('NXB1', 'Nha xuat ban 1', 50000),
('NXB2', 'Nha xuat ban 2', 45000),
('NXB3', 'Nha xuat ban 3', 100000)

insert into Sach values
('S01', 'Sach 1', 'NXB1', 'TG02', 2001, 2000, 120000),
('S02', 'Sach 2', 'NXB2', 'TG03', 2019, 5000, 150000),
('S03', 'Sach 3', 'NXB3', 'TG01', 2021, 7000, 70000),
('S04', 'Sach 4', 'NXB1', 'TG03', 2018, 1000, 90000)

select * from TacGia
select * from NhaXB
select * from Sach

/*
Hãy tạo hàm đưa ra thống kê tiền bán theo tên TG, gồm Masach, tensach, TenTG,TienBan 
(TienBan=SoLuong*DonGia) với tham số truyền là TenTG(lưu ý: một tác giả có thể xuất bản nhiều 
sách -  gom nhóm lại kết quả).
*/

create function Cau2(@tenTG varchar(20))
returns @thongke table(
						maSach char(5),
						tenSach varchar(20),
						tenTG varchar(20),
						tienBan money
						)
as
	begin
		insert into @thongke
		select maSach, tenSach, tenTG, 'tienBan' = soLuong * donGia
		from Sach inner join TacGia on Sach.maTG = TacGia.maTG
		where tenTG = @tenTG
		return
	end

select * from Sach
select * from TacGia
select * from dbo.Cau2('Tac gia 1')

--Hãy tạo thủ thêm mới 1 tác giả. Nếu tenTG đã có đưa ra thông báo!
create proc Cau3 @maTG char(5), @tenTG varchar(20), @soLuongCo int
as
	begin
		if (exists (select * from TacGia where maTG = @maTG))
			print 'Tac gia da ton tai'
		else
			insert into TacGia values (@maTG, @tenTG, @soLuongCo)
	end

--TH1: Tac gia da ton tai
exec Cau3 'TG03', 'Tac gia 3', 15
--TH2: Chen thanh cong
exec Cau3 'TG04', 'Tac gia 4', 15
select * from TacGia

/*
DE 6: Hãy tạo view đưa ra tiền bán theo tên TG, gồm Masach, Tensach, TenTG,TienBan 
(TienBan=SoLuong*DonGia) 
*/

alter view Cau2_6
as
	select tenTG
	from TacGia inner join Sach on TacGia.maTG = Sach.maTG

select * from Sach
select * from TacGia
select * from Cau2_6

select * from NhaXB inner join Sach on Sach.maNXB = NhaXB.maNXB

/*
Hãy tạo view thống kê tiền bán theo tên NXB, gồm Masach, Tensach, TenNXB,TienBan 
(TienBan=SoLuong*DonGia)
*/
create view Cau3_6
as
	select
