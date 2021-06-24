create database quanlbhang
use quanlbhang

create table CongTy
(
	maCT char(5) primary key,
	tenCT varchar(20),
	diaChi varchar(50)
)

create table SanPham 
(
	maSP char(5) primary key,
	tenSP varchar(20),
	slCo int, 
	giaBan money
)

create table CungUng
(
	maCT char(5) foreign key references CongTy on update cascade on delete cascade,
	maSP char(5) foreign key references SanPham on update cascade on delete cascade,
	primary key (maCT, maSP),
	slCU int,
	ngayCU date
)

insert into CongTy values
('CT01', 'Cong ty 1', 'Dia chi 1'),
('CT02', 'Cong ty 2', 'Dia chi 2'),
('CT03', 'Cong ty 3', 'Dia chi 3')

insert into SanPham values
('SP01', 'San pham 1', 100, 20000),
('SP02', 'San pham 2', 150, 10000),
('SP03', 'San pham 3', 70, 90000)

insert into CungUng values
('CT01', 'SP01', 20, '1/1/2021'),
('CT01', 'SP02', 50, '1/1/2021'),
('CT01', 'SP03', 100, '1/1/2021'),
('CT02', 'SP01', 28, '1/1/2021'),
('CT03', 'SP02', 87, '1/1/2021')

select * from CongTy
select * from SanPham
select * from CungUng

--Ham
create function Cau2(@tenCT varchar(20), @ngayCU date)
returns @danhSach table (
							tenSP varchar(20),
							soLuong int,
							giaBan money
						)
as
	begin
		insert into @danhSach
		select tenSP, slCo, giaBan 
		from SanPham inner join CungUng on SanPham.maSP = CungUng.maSP
			 inner join CongTy on CongTy.maCT = CungUng.maCT
		where @ngayCU = ngayCU and tenCT = @tenCT
		return
	end

select * from Cau2 ('Cong ty 1', '1/1/2021')

--Procduce
create proc Cau3 @maCT char(5), @tenCT varchar(20), @diaChi varchar(50), @kq int output
as
	begin
		if (exists(select * from CongTy where maCT = @maCT))
			begin
				print 'Cong ty da ton tai!!!'
				set @kq = 1
			end	
		else
			begin
				insert into CongTy values (@maCT, @tenCT, @diaChi)
				set @kq = 0
			end
	end

--Cong ty da ton tai
select * from CongTy
declare @check int
exec Cau3 'CT03', 'Cong ty 4', 'Dia chi 4', @check output
select @check

--Dung
select * from CongTy
declare @check int
exec Cau3 'CT04', 'Cong ty 4', 'Dia chi 4', @check output
select @check

--trigger
alter trigger Cau4 on CungUng for update
as
	begin
		declare @slCUCu int, @slCUMoi int, @maSP char(5), @slCo int
		select @slCUCu = slCU, @maSP = maSP from deleted
		select @slCUMoi = slCU from inserted
		select @slCo = slCo from SanPham where @maSP = maSP
		if (@slCUMoi - @slCUCu > @slCo)
			begin
				raiserror ('Khong du so luong!!!', 16, 1)
				rollback transaction
				return
			end
		update SanPham set slCo = slCo - (@slCUMoi - @slCUCu) where maSP = @maSP
	end

--So luong khong du
select * from CungUng
select * from SanPham

update CungUng set slCU = 10000000 where maCT = 'CT01' and maSP = 'SP01'

--Dung
update CungUng set slCU = 10 where maCT = 'CT01' and maSP = 'SP01'
select * from CungUng
select * from SanPham

