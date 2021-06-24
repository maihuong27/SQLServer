create database QLBanHang_De1
use QLBanHang_De1

create table CongTy
(
	maCT char(5) primary key,
	tenCT varchar(20), 
	trangThai varchar(20),
	thanhPho varchar(20)
)

create table SanPham
(
	maSP char(5) primary key,
	tenSP varchar(20),
	mauSac varchar(20),
	soLuong int,
	giaBan money
)

create table CungUng
(
	maCT char(5) foreign key references CongTy on update cascade on delete cascade,
	maSP char(5) foreign key references SanPham on update cascade on delete cascade,
	primary key (maCT, maSP),
	soLuongCungUng int
)

insert into CongTy values
('CT01', 'Cong ty 1', 'Dang mo cua', 'Ha Noi'),
('CT02', 'Cong ty 2', 'Da dong cua', 'TP HCM'),
('CT03', 'Cong ty 3', 'Dang mo cua', 'Ha Noi')

insert into SanPham values
('SP01', 'San pham 1', 'Xanh', 100, 20000),
('SP02', 'San pham 2', 'Do', 200, 32000),
('SP03', 'San pham 3', 'Tim', 150, 17000)

insert into CungUng values
('CT01', 'SP01', 20),
('CT01', 'SP02', 50),
('CT01', 'SP03', 10),
('CT02', 'SP01', 30),
('CT03', 'SP02', 15)

select * from CongTy
select * from SanPham
select * from CungUng

--Tạo 1 hàm đưa ra các TenSP, mausac, soluong, giaban của công ty với tên công ty nhập từ bàn phím
create function Cau2(@tenCT varchar(20))
returns @thongTin table (
							tenSP varchar(20),
							mauSac varchar(20),
							giaBan money
							)
as
	begin
		insert into @thongTin
		select tenSP, mauSac, giaBan
		from CungUng inner join SanPham on CungUng.maSP = SanPham.maSP 
			inner join CongTy on CungUng.maCT = CongTy.maCT
		where tenCT = @tenCT
		return
	end

select * from CongTy
select * from SanPham
select * from CungUng
select * from dbo.Cau2('Cong ty 2')

/*Viết thủ tục thêm mới 1 công ty với mact, TenCT, trangthai, thanhpho nhập từ bàn phím, 
nếu tên công ty đó tồn tại trước đó hãy đưa ra thông báo.*/

create proc Cau3 @maCT char(5), @tenCT varchar(20), @trangThai varchar(20), @thanhPho varchar(20)
as
	begin
		if(exists(select * from CongTy where tenCT = @tenCT))
			print 'Cong ty da ton tai'
		else
			insert into CongTy values (@maCT, @tenCT, @trangThai, @thanhPho)
	end

--TH1: Cong ty da ton tai
exec Cau3 'CT01', 'Cong ty 1', 'Dang mo cua', 'Ha Noi'
--TH2: Chen thanh cong
exec Cau3 'CT04', 'Cong ty 4', 'Dang dong cua', 'Ninh Binh'
select * from CongTy
